function Run-Trusted([String]$command) {

    Stop-Service -Name TrustedInstaller -Force -ErrorAction SilentlyContinue
    # Get bin path to revert later
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='TrustedInstaller'"
    $DefaultBinPath = $service.PathName
    # Convert command to base64 to avoid errors with spaces
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    $base64Command = [Convert]::ToBase64String($bytes)
    # Change bin to command
    sc.exe config TrustedInstaller binPath= "cmd.exe /c powershell.exe -encodedcommand $base64Command" | Out-Null
    # Run the command
    sc.exe start TrustedInstaller | Out-Null
    # Set bin back to default
    sc.exe config TrustedInstaller binpath= "`"$DefaultBinPath`"" | Out-Null
    Stop-Service -Name TrustedInstaller -Force -ErrorAction SilentlyContinue
  
  }
  
  # Disable AI registry keys
  Write-Host 'Applying Registry Keys...'
  # Set for local machine and current user to be sure
  $hives = @('HKLM', 'HKCU')
  foreach ($hive in $hives) {
    Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v 'TurnOffWindowsCopilot' /t REG_DWORD /d '1' /f *>$null
    Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableAIDataAnalysis' /t REG_DWORD /d '1' /f *>$null
  }
  Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'ShowCopilotButton' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKCU\Software\Microsoft\input\Settings' /v 'InsightsEnabled' /t REG_DWORD /d '0' /f *>$null
  # Disable copilot in edge
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotCDPPageContext' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotPageContext' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'DiscoverPageContextEnabled' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'HubsSidebarEnabled' /t REG_DWORD /d '0' /f *>$null
  # Force policy changes
  gpupdate /force >$null
  
  
  $aipackages = @(
    'MicrosoftWindows.Client.Photon'
    'MicrosoftWindows.Client.AIX'
    'MicrosoftWindows.Client.CoPilot'
    'Microsoft.Windows.Ai.Copilot.Provider'
    'Microsoft.Copilot'
  )
  
  $provisioned = get-appxprovisionedpackage -online 
  $appxpackage = get-appxpackage -allusers
  $eol = @()
  $store = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
  $users = @('S-1-5-18'); if (test-path $store) { $users += $((Get-ChildItem $store -ea 0 | Where-Object { $_ -like '*S-1-5-21*' }).PSChildName) }
  
  # Uninstall packages
  
  # Use eol trick to uninstall some locked packages
  foreach ($choice in $aipackages) {
    Write-Host "Removing $choice"
    if ('' -eq $choice.Trim()) { continue }
    foreach ($appx in $($provisioned | Where-Object { $_.PackageName -like "*$choice*" })) {
        $next = !1; foreach ($no in $skip) { if ($appx.PackageName -like "*$no*") { $next = !0 } } ; if ($next) { continue }
        $PackageName = $appx.PackageName; $PackageFamilyName = ($appxpackage | Where-Object { $_.Name -eq $appx.DisplayName }).PackageFamilyName
        New-Item "$store\Deprovisioned\$PackageFamilyName" -force >''; 
        foreach ($sid in $users) { New-Item "$store\EndOfLife\$sid\$PackageName" -force >'' } ; $eol += $PackageName
        dism /online /set-nonremovableapppolicy /packagefamily:$PackageFamilyName /nonremovable:0 >''
        remove-appxprovisionedpackage -packagename $PackageName -online -allusers >''
    }
    foreach ($appx in $($appxpackage | Where-Object { $_.PackageFullName -like "*$choice*" })) {
        $next = !1; foreach ($no in $skip) { if ($appx.PackageFullName -like "*$no*") { $next = !0 } } ; if ($next) { continue }
        $PackageFullName = $appx.PackageFullName;
        New-Item "$store\Deprovisioned\$appx.PackageFamilyName" -force >''; 
        foreach ($sid in $users) { New-Item "$store\EndOfLife\$sid\$PackageFullName" -force >'' } ; $eol += $PackageFullName
        dism /online /set-nonremovableapppolicy /packagefamily:$PackageFamilyName /nonremovable:0 >''
        remove-appxpackage -package $PackageFullName -allusers >''
    }
  }
  
  # Undo EOL unblock trick to prevent latest cumulative update (LCU) failing 
  foreach ($sid in $users) { foreach ($PackageName in $eol) { Remove-Item "$store\EndOfLife\$sid\$PackageName" -force -ErrorAction SilentlyContinue >'' } }
  
  # Remove recall optional feature 
  $ProgressPreference = 'SilentlyContinue'
  try {
    Disable-WindowsOptionalFeature -Online -FeatureName 'Recall' -Remove -ErrorAction Stop *>$null
  }
  catch {
    # Hide error
  }
  
  
  Write-Host 'Removing Package Files...'
  #-----------------------------------------------------------------------remove files
  $appsPath = 'C:\Windows\SystemApps'
  $appsPath2 = 'C:\Program Files\WindowsApps'
  $pathsSystemApps = (Get-ChildItem -Path $appsPath -Directory -Force).FullName 
  $pathsWindowsApps = (Get-ChildItem -Path $appsPath2 -Directory -Force).FullName 
  
  $packagesPath = @()
  #get full path
  foreach ($package in $aipackages) {
  
    foreach ($path in $pathsSystemApps) {
        if ($path -like "*$package*") {
            $packagesPath += $path
        }
    }
  
    foreach ($path in $pathsWindowsApps) {
        if ($path -like "*$package*") {
            $packagesPath += $path
        }
    }
  
  }
  
  
  foreach ($Path in $packagesPath) {
    # Only remove dlls from photon to prevent startmenu from breaking
    if ($path -like '*Photon*') {
        $command = "`$dlls = (Get-ChildItem -Path $Path -Filter *.dll).FullName; foreach(`$dll in `$dlls){Remove-item ""`$dll"" -force}"
        Run-Trusted -command $command
    }
    else {
        $command = "Remove-item ""$Path"" -force -recurse"
        Run-Trusted -command $command
    }
  }
  
  # Remove package installers in edge dir
  # Installs Microsoft.Windows.Ai.Copilot.Provider
  $dir = "${env:ProgramFiles(x86)}\Microsoft"
  $folders = @(
    'Edge',
    'EdgeCore',
    'EdgeWebView'
  )
  foreach ($folder in $folders) {
    if ($folder -eq 'EdgeCore') {
        # Edge core doesnt have application folder
        $fullPath = (Get-ChildItem -Path "$dir\$folder\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
        
    }
    else {
        $fullPath = (Get-ChildItem -Path "$dir\$folder\Application\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
    }
    if ($fullPath -ne $null) { Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue }
  }
  
  # Remove any screenshots from recall
  Write-Host 'Removing Any Screenshots...'
  Remove-Item -Path "$env:LOCALAPPDATA\CoreAIPlatform*" -Force -Recurse -ErrorAction SilentlyContinue
  
  
  $input = Read-Host 'Done! Press Any Key to Exit'
  if ($input) { exit }
  