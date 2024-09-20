     # Check for Administrator privileges and relaunch as Administrator if not running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Set the PowerShell window appearance
$Host.UI.RawUI.WindowTitle = "$($myInvocation.MyCommand.Definition) (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

(Invoke-WebRequest "https://raw.githubusercontent.com/lptstr/winfetch/master/winfetch.ps1" -UseBasicParsing).Content.Remove(0,1) | Invoke-Expression
Write-Host "Press Enter to continue:"
Read-Host

function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
    function Show-Progress {
    param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
    $percent = $CurrentValue / $TotalValue
    $percentComplete = $percent * 100
    if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
    else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
    }
    try {
    $request = [System.Net.HttpWebRequest]::Create($URL)
    $response = $request.GetResponse()
    if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
    if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
    if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
    if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
    [long]$fullSize = $response.ContentLength
    [byte[]]$buffer = new-object byte[] 1048576
    [long]$total = [long]$count = 0
    $reader = $response.GetResponseStream()
    $writer = new-object System.IO.FileStream $File, 'Create'
    do {
    $count = $reader.Read($buffer, 0, $buffer.Length)
    $writer.Write($buffer, 0, $count)
    $total += $count
    if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
    } while ($count -gt 0)
    }
    finally {
    $reader.Close()
    $writer.Close()
    }
    }
 
 Write-Host "Select an option:"
    Write-Host "1) Install apps"
    Write-Host "2) Clean graphics drivers with DDU"
    Write-Host "3 Install Nvidia driver"
    Write-Host "4 Apply Nvidia settings"
    Write-Host "5) Continue with the rest of the script"
    Write-Host "6) Winutil"
     while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-6]$') {
    switch ($choice) {


1 {
    Write-Host "Installing apps..."
    # Replace the path below with the actual path to your installation script
    Start-Process powershell -ArgumentList "-NoExit", "-File", "C:\files\apps.ps1"
   }

2 {
   Write-Host "Installing: DDU . . ."
# download ddu
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/DDU.zip" -File "$env:TEMP\DDU.zip"
# extract files
Expand-Archive "$env:TEMP\DDU.zip" -DestinationPath "$env:TEMP\DDU" -ErrorAction SilentlyContinue
# create config for ddu
$MultilineComment = @"
<?xml version="1.0" encoding="utf-8"?>
<DisplayDriverUninstaller Version="18.0.7.8">
	<Settings>
		<SelectedLanguage>en-US</SelectedLanguage>
		<RemoveMonitors>True</RemoveMonitors>
		<RemoveCrimsonCache>True</RemoveCrimsonCache>
		<RemoveAMDDirs>True</RemoveAMDDirs>
		<RemoveAudioBus>True</RemoveAudioBus>
		<RemoveAMDKMPFD>True</RemoveAMDKMPFD>
		<RemoveNvidiaDirs>True</RemoveNvidiaDirs>
		<RemovePhysX>True</RemovePhysX>
		<Remove3DTVPlay>True</Remove3DTVPlay>
		<RemoveGFE>True</RemoveGFE>
		<RemoveNVBROADCAST>True</RemoveNVBROADCAST>
		<RemoveNVCP>True</RemoveNVCP>
		<RemoveINTELCP>True</RemoveINTELCP>
		<RemoveAMDCP>True</RemoveAMDCP>
		<UseRoamingConfig>False</UseRoamingConfig>
		<CheckUpdates>False</CheckUpdates>
		<CreateRestorePoint>False</CreateRestorePoint>
		<SaveLogs>False</SaveLogs>
		<RemoveVulkan>False</RemoveVulkan>
		<ShowOffer>False</ShowOffer>
		<EnableSafeModeDialog>False</EnableSafeModeDialog>
		<PreventWinUpdate>True</PreventWinUpdate>
		<UsedBCD>False</UsedBCD>
		<KeepNVCPopt>False</KeepNVCPopt>
	</Settings>
</DisplayDriverUninstaller>
"@
Set-Content -Path "$env:TEMP\DDU\Settings\Settings.xml" -Value $MultilineComment -Force
# set config to read only
Set-ItemProperty -Path "$env:TEMP\DDU\Settings\Settings.xml" -Name IsReadOnly -Value $true
# prevent downloads of drivers from windows update
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f | Out-Null
# create msconfig shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Safe Mode Toggle.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Windows\System32\msconfig.exe"
$Shortcut.Save()
# create ddu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Display Driver Uninstaller.lnk")
$Shortcut.TargetPath = "$env:TEMP\DDU\Display Driver Uninstaller.exe"
$Shortcut.Save()
Clear-Host
Write-Host "Restarting To Safe Mode: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# toggle safe mode
cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
# restart
shutdown -r -t 00
2 }

3 {
    Clear-Host
# clean old files
Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver.exe" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:TEMP\7-Zip.exe" -ErrorAction SilentlyContinue | Out-Null
# find latest nvidia driver
$uri = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=120&pfid=929&osID=57&languageCode=1033&isWHQL=1&dch=1&sort1=0&numberOfResults=1'
$response = Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing
$payload = $response.Content | ConvertFrom-Json
$version =  $payload.IDS[0].downloadInfo.Version
# check windows version & bits
$windowsVersion = if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {"win10-win11"} else {"win8-win7"}
$windowsArchitecture = if ([Environment]::Is64BitOperatingSystem) {"64bit"} else {"32bit"}
# create download link
$url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-dch-whql.exe"
Write-Output "Downloading: Nvidia Driver $version . . ."
# download nvidia driver
Get-FileFromWeb -URL $url -File "$env:TEMP\NvidiaDriver.exe"
Clear-Host
Write-Host "Installing: Nvidia Driver . . ."
# download 7zip
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/7-Zip.exe" -File "$env:TEMP\7-Zip.exe"
# install 7zip
Start-Process -wait "$env:TEMP\7-Zip.exe" /S
# extract files with 7zip
cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\NvidiaDriver.exe" -o"$env:TEMP\NvidiaDriver" -y | Out-Null
# install nvidia driver
Start-Process "$env:TEMP\NvidiaDriver\setup.exe"
}
4 {
    Clear-Host
Write-Host "Installing: NvidiaProfileInspector . . ."
# download inspector
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Inspector.zip" -File "$env:TEMP\Inspector.zip"
# extract files
Expand-Archive "$env:TEMP\Inspector.zip" -DestinationPath "$env:TEMP\Inspector" -ErrorAction SilentlyContinue
# create config for inspector
$MultilineComment = @"
<?xml version="1.0" encoding="utf-16"?>
<ArrayOfProfile>
  <Profile>
    <ProfileName>Base Profile</ProfileName>
    <Executeables />
    <Settings>
      <ProfileSetting>
        <SettingNameInfo> </SettingNameInfo>
        <SettingID>390467</SettingID>
        <SettingValue>2</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Negative LOD bias</SettingNameInfo>
        <SettingID>1686376</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Trilinear optimization</SettingNameInfo>
        <SettingID>3066610</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync Tear Control</SettingNameInfo>
        <SettingID>5912412</SettingID>
        <SettingValue>2525368439</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred refresh rate</SettingNameInfo>
        <SettingID>6600001</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Maximum pre-rendered frames</SettingNameInfo>
        <SettingID>8102046</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Anisotropic filter optimization</SettingNameInfo>
        <SettingID>8703344</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync</SettingNameInfo>
        <SettingID>11041231</SettingID>
        <SettingValue>138504007</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Shader disk cache maximum size</SettingNameInfo>
        <SettingID>11306135</SettingID>
        <SettingValue>4294967295</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Quality</SettingNameInfo>
        <SettingID>13510289</SettingID>
        <SettingValue>20</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Anisotropic sample optimization</SettingNameInfo>
        <SettingID>15151633</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Display the VRR Indicator</SettingNameInfo>
        <SettingID>268604728</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Flag to control smooth AFR behavior</SettingNameInfo>
        <SettingID>270198627</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic filtering setting</SettingNameInfo>
        <SettingID>270426537</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Power management mode</SettingNameInfo>
        <SettingID>274197361</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Gamma correction</SettingNameInfo>
        <SettingID>276652957</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Mode</SettingNameInfo>
        <SettingID>276757595</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>FRL Low Latency</SettingNameInfo>
        <SettingID>277041152</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter</SettingNameInfo>
        <SettingID>277041154</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter for NVCPL</SettingNameInfo>
        <SettingID>277041162</SettingID>
        <SettingValue>357</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Toggle the VRR global feature</SettingNameInfo>
        <SettingID>278196567</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>VRR requested state</SettingNameInfo>
        <SettingID>278196727</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>G-SYNC</SettingNameInfo>
        <SettingID>279476687</SettingID>
        <SettingValue>4</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic filtering mode</SettingNameInfo>
        <SettingID>282245910</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Setting</SettingNameInfo>
        <SettingID>282555346</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>CUDA Sysmem Fallback Policy</SettingNameInfo>
        <SettingID>283962569</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Enable G-SYNC globally</SettingNameInfo>
        <SettingID>294973784</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>OpenGL GDI compatibility</SettingNameInfo>
        <SettingID>544392611</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Threaded optimization</SettingNameInfo>
        <SettingID>549528094</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred OpenGL GPU</SettingNameInfo>
        <SettingID>550564838</SettingID>
        <SettingValue>id,2.0:268410DE,00000100,GF - (400,2,161,24564) @ (0)</SettingValue>
        <ValueType>String</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vulkan/OpenGL present method</SettingNameInfo>
        <SettingID>550932728</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
    </Settings>
  </Profile>
</ArrayOfProfile>
"@
Set-Content -Path "$env:TEMP\Inspector\Inspector.nip" -Value $MultilineComment -Force
# import config
Start-Process -wait "$env:TEMP\Inspector\nvidiaProfileInspector.exe" -ArgumentList "$env:TEMP\Inspector\Inspector.nip"
# open nvidiacontrolpanel
Start-Process "shell:appsFolder\NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj!NVIDIACorp.NVIDIAControlPanel"
}
5 {
    Write-Host "Installing: Direct X . . ."
# download direct x
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -File "$env:TEMP\DirectX.exe"
# download 7zip
Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2301-x64.exe" -File "$env:TEMP\7-Zip.exe"
# install 7zip
Start-Process -wait "$env:TEMP\7-Zip.exe" /S
# extract files with 7zip
cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\DirectX.exe" -o"$env:TEMP\DirectX" -y | Out-Null
# install direct x
Start-Process "$env:TEMP\DirectX\DXSETUP.exe"
# Pause for 5 seconds
Start-Sleep -Seconds 5
#install c++
Write-Host "Installing: C ++ . . ."
# download c++ installers
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE" -File "$env:TEMP\vcredist2005_x86.exe"
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE" -File "$env:TEMP\vcredist2005_x64.exe"
Get-FileFromWeb -URL "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe" -File "$env:TEMP\vcredist2008_x86.exe"
Get-FileFromWeb -URL "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" -File "$env:TEMP\vcredist2008_x64.exe"
Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe" -File "$env:TEMP\vcredist2010_x86.exe" 
Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" -File "$env:TEMP\vcredist2010_x64.exe"
Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" -File "$env:TEMP\vcredist2012_x86.exe"
Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" -File "$env:TEMP\vcredist2012_x64.exe"
Get-FileFromWeb -URL "https://aka.ms/highdpimfc2013x86enu" -File "$env:TEMP\vcredist2013_x86.exe"
Get-FileFromWeb -URL "https://aka.ms/highdpimfc2013x64enu" -File "$env:TEMP\vcredist2013_x64.exe"
Get-FileFromWeb -URL "https://aka.ms/vs/17/release/vc_redist.x86.exe" -File "$env:TEMP\vcredist2015_2017_2019_2022_x86.exe"
Get-FileFromWeb -URL "https://aka.ms/vs/17/release/vc_redist.x64.exe" -File "$env:TEMP\vcredist2015_2017_2019_2022_x64.exe"
# start c++ installers
Start-Process -wait "$env:TEMP\vcredist2005_x86.exe" -ArgumentList "/q"
Start-Process -wait "$env:TEMP\vcredist2005_x64.exe" -ArgumentList "/q"
Start-Process -wait "$env:TEMP\vcredist2008_x86.exe" -ArgumentList "/qb"
Start-Process -wait "$env:TEMP\vcredist2008_x64.exe" -ArgumentList "/qb"
Start-Process -wait "$env:TEMP\vcredist2010_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2010_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2012_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2012_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2013_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2013_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2015_2017_2019_2022_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:TEMP\vcredist2015_2017_2019_2022_x64.exe" -ArgumentList "/passive /norestart"



# disable background apps regedit
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f | Out-Null
Clear-Host

# Clean taskbar
# Unpin all taskbar icons
cmd /c "reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1"
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer" -Name "Quick Launch" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -Name "User Pinned" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "TaskBar" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "ImplicitAppShortcuts" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
# pin file explorer to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk")
$Shortcut.TargetPath = "explorer"
$Shortcut.Save()
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; pin file explorer to taskbar
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband]
"Favorites"=hex:00,aa,01,00,00,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,\
  52,87,d6,68,26,00,01,00,26,00,ef,be,10,00,00,00,f4,7e,76,fa,de,9d,da,01,40,\
  61,5d,09,df,9d,da,01,19,b8,5f,09,df,9d,da,01,14,00,56,00,31,00,00,00,00,00,\
  a4,58,a9,26,10,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,a4,58,a9,\
  26,a4,58,a9,26,2e,00,00,00,de,9c,01,00,00,00,02,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,0c,f4,85,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,\
  00,16,00,18,01,32,00,8a,04,00,00,a4,58,b6,26,20,00,46,49,4c,45,45,58,7e,31,\
  2e,4c,4e,4b,00,00,54,00,09,00,04,00,ef,be,a4,58,b6,26,a4,58,b6,26,2e,00,00,\
  00,b7,a8,01,00,00,00,04,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,c0,5a,\
  1e,01,46,00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,\
  00,72,00,2e,00,6c,00,6e,00,6b,00,00,00,1c,00,22,00,00,00,1e,00,ef,be,02,00,\
  55,00,73,00,65,00,72,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,1c,00,12,\
  00,00,00,2b,00,ef,be,19,b8,5f,09,df,9d,da,01,1c,00,74,00,00,00,1d,00,ef,be,\
  02,00,7b,00,46,00,33,00,38,00,42,00,46,00,34,00,30,00,34,00,2d,00,31,00,44,\
  00,34,00,33,00,2d,00,34,00,32,00,46,00,32,00,2d,00,39,00,33,00,30,00,35,00,\
  2d,00,36,00,37,00,44,00,45,00,30,00,42,00,32,00,38,00,46,00,43,00,32,00,33,\
  00,7d,00,5c,00,65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,\
  78,00,65,00,00,00,1c,00,00,00,ff

; remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Dsh]
"AllowNewsAndInterests"=dword:00000000

; left taskbar alignment
;[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
;"TaskbarAl"=dword:00000000

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; remove task view from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowTaskViewButton"=dword:00000000

; remove chat from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000

; remove copilot from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000

; remove news and interests
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

; remove security taskbar icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
"SecurityHealth"=hex:07,00,00,00,05,db,8a,69,8a,49,d9,01

; Disable start menu tips and recommendations
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_IrisRecommendations"=dword:00000000

; Disable show recently added apps and recommendations
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start]
"ShowRecentList"=dword:00000000

; Disable suggested content in settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000

; Disable show whats new after update
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"SubscribedContent-310093Enabled"=dword:00000000

; Disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; Disable search highlights
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000000

; show all taskbar icons w10 only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"EnableAutoTray"=dword:00000000
"@
Set-Content -Path "$env:TEMP\Taskbar Clean.reg" -Value $MultilineComment -Force
# import reg file
Set-Location -Path "$env:TEMP"
Regedit.exe /S "Taskbar Clean.reg"
# CLEAN START MENU W11
$progresspreference = 'silentlycontinue'
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin" -ErrorAction SilentlyContinue
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/start2.bin" -File "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
# CLEAN START MENU W10
# delete startmenulayout.xml
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
# create startmenulayout.xml
$MultilineComment = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
Set-Content -Path "C:\Windows\StartMenuLayout.xml" -Value $MultilineComment -Force -Encoding ASCII
# assign startmenulayout.xml registry
$layoutFile="C:\Windows\StartMenuLayout.xml"
$regAliases = @("HKLM", "HKCU")
foreach ($regAlias in $regAliases){
$basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
$keyPath = $basePath + "\Explorer"
IF(!(Test-Path -Path $keyPath)) {
New-Item -Path $basePath -Name "Explorer" | Out-Null
}
Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1 | Out-Null
Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile | Out-Null
}
# restart explorer
Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
Timeout /T 5 | Out-Null
# disable lockedstartlayout registry
foreach ($regAlias in $regAliases){
$basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
$keyPath = $basePath + "\Explorer"
Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}
# restart explorer
Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
# delete startmenulayout.xml
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
Clear-Host

# stop edge running
$stop = "MicrosoftEdgeUpdate", "OneDrive", "WidgetService", "Widgets", "msedge", "msedgewebview2"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
# uninstall copilot
Get-AppxPackage -allusers *Microsoft.Windows.Ai.Copilot.Provider* | Remove-AppxPackage
# disable copilot regedit
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d "1" /f | Out-Null
Write-Host "Restart to apply . . ."
Clear-Host
# disable widgets regedit
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" /v "value" /t REG_DWORD /d "0" /f | Out-Null
# remove windows widgets from taskbar regedit
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f | Out-Null
# stop widgets running
Stop-Process -Force -Name Widgets -ErrorAction SilentlyContinue | Out-Null
Stop-Process -Force -Name WidgetService -ErrorAction SilentlyContinue | Out-Null
Clear-Host
$progresspreference = 'silentlycontinue'
# disable gamebar regedit
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f | Out-Null
# disable open xbox game bar using game controller regedit
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f | Out-Null
# disable gameinput service regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\GameInputSvc" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# disable gamedvr and broadcast user service regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\BcastDVRUserService" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# disable xbox accessory management service regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# disable xbox live auth manager service regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\XblAuthManager" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# disable xbox live game save service regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\XblGameSave" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# disable xbox live networking service regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# stop gamebar running
Stop-Process -Force -Name GameBar -ErrorAction SilentlyContinue | Out-Null
# uninstall gamebar & xbox apps
Get-AppxPackage -allusers *Microsoft.GamingApp* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.Xbox.TCUI* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.XboxApp* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.XboxGameOverlay* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.XboxIdentityProvider* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage
Clear-Host
# import ultimate power plan
cmd /c "powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 99999999-9999-9999-9999-999999999999 >nul 2>&1"
# set ultimate power plan active
cmd /c "powercfg /SETACTIVE 99999999-9999-9999-9999-999999999999 >nul 2>&1"
# get all powerplans
$output = powercfg /L
$powerPlans = @()
foreach ($line in $output) {
# extract guid manually to avoid lang issues
if ($line -match ':') {
$parse = $line -split ':'
$index = $parse[1].Trim().indexof('(')
$guid = $parse[1].Trim().Substring(0, $index)
$powerPlans += $guid
}
}
# delete all powerplans
foreach ($plan in $powerPlans) {
cmd /c "powercfg /delete $plan" | Out-Null
}
Clear-Host
# disable hibernate
powercfg /hibernate off
cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power`" /v `"HibernateEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power`" /v `"HibernateEnabledDefault`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
# disable lock
cmd /c "reg add `"HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings`" /v `"ShowLockOption`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
# disable sleep
cmd /c "reg add `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings`" /v `"ShowSleepOption`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
# disable fast boot
cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power`" /v `"HiberbootEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
# unpark cpu cores
cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583`" /v `"ValueMax`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
# disable power throttling
cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling`" /v `"PowerThrottlingOff`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
# unhide hub selective suspend timeout
cmd /c "reg add `"HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683`" /v `"Attributes`" /t REG_DWORD /d `"2`" /f >nul 2>&1"
# unhide usb 3 link power management
cmd /c "reg add `"HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009`" /v `"Attributes`" /t REG_DWORD /d `"2`" /f >nul 2>&1"
# MODIFY DESKTOP & LAPTOP SETTINGS
# hard disk turn off hard disk after 0%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000
# desktop background settings slide show paused
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 001
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 001
# wireless adapter settings power saving mode maximum performance
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 000
# sleep
# sleep after 0%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000
# allow hybrid sleep off
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 000
# hibernate after
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000
# allow wake timers disable
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 000
# usb settings
# hub selective suspend timeout 0
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000
# usb selective suspend setting disabled
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000
# usb 3 link power management - off
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 000
# power buttons and lid start menu power button shut down
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 002
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 002
# pci express link state power management off
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000
# processor power management
# minimum processor state 100%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064
# system cooling policy active
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 001
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 001
# maximum processor state 100%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064
# display
# turn off display after 0%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000
# display brightness 100%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 0x00000064
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 0x00000064
# dimmed display brightness 100%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 0x00000064
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 0x00000064
# enable adaptive brightness off
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 000
# video playback quality bias video playback performance bias
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 001
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 001
# when playing video optimize video quality
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 000
# MODIFY LAPTOP SETTINGS
# intel(r) graphics settings intel(r) graphics power plan maximum performance
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002
Clear-Host
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002
Clear-Host
# amd power slider overlay best performance
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 c763b4ec-0e50-4b6b-9bed-2b92a6ee884e 7ec1751b-60ed-4588-afb5-9819d3d77d90 003
Clear-Host
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 c763b4ec-0e50-4b6b-9bed-2b92a6ee884e 7ec1751b-60ed-4588-afb5-9819d3d77d90 003
Clear-Host
# ati graphics power settings ati powerplay settings maximize performance
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 f693fb01-e858-4f00-b20f-f30e12ac06d6 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 001
Clear-Host
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 f693fb01-e858-4f00-b20f-f30e12ac06d6 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 001
Clear-Host
# switchable dynamic graphics global settings maximize performance
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e276e160-7cb0-43c6-b20b-73f5dce39954 a1662ab2-9d34-4e53-ba8b-2639b9e20857 003
Clear-Host
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e276e160-7cb0-43c6-b20b-73f5dce39954 a1662ab2-9d34-4e53-ba8b-2639b9e20857 003
Clear-Host
# battery
# critical battery notification off
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 000
# critical battery action do nothing
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 000
# low battery level 0%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 0x00000000
# critical battery level 0%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 0x00000000
# low battery notification off
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 000
# low battery action do nothing
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 000
# reserve battery level 0%
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 0x00000000
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 0x00000000
# immersive control panel
# low screen brightness when using battery saver disable
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da 13d09884-f74e-474a-a852-b6bde8ad03a8 0x00000064
Clear-Host
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da 13d09884-f74e-474a-a852-b6bde8ad03a8 0x00000064
Clear-Host
# immersive control panel
# turn battery saver on automatically at never
powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0x00000000
Clear-Host
powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0x00000000
Clear-Host
Clear-Host
Write-Host "Installing: Set Timer Resolution Service . . ."
# create .cs file
$MultilineComment = @"
using System;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.ComponentModel;
using System.Configuration.Install;
using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Management;
using System.Threading;
using System.Diagnostics;
[assembly: AssemblyVersion("2.1")]
[assembly: AssemblyProduct("Set Timer Resolution service")]
namespace WindowsService
{
    class WindowsService : ServiceBase
    {
        public WindowsService()
        {
            this.ServiceName = "STR";
            this.EventLog.Log = "Application";
            this.CanStop = true;
            this.CanHandlePowerEvent = false;
            this.CanHandleSessionChangeEvent = false;
            this.CanPauseAndContinue = false;
            this.CanShutdown = false;
        }
        static void Main()
        {
            ServiceBase.Run(new WindowsService());
        }
        protected override void OnStart(string[] args)
        {
            base.OnStart(args);
            ReadProcessList();
            NtQueryTimerResolution(out this.MininumResolution, out this.MaximumResolution, out this.DefaultResolution);
            if(null != this.EventLog)
                try { this.EventLog.WriteEntry(String.Format("Minimum={0}; Maximum={1}; Default={2}; Processes='{3}'", this.MininumResolution, this.MaximumResolution, this.DefaultResolution, null != this.ProcessesNames ? String.Join("','", this.ProcessesNames) : "")); }
                catch {}
            if(null == this.ProcessesNames)
            {
                SetMaximumResolution();
                return;
            }
            if(0 == this.ProcessesNames.Count)
            {
                return;
            }
            this.ProcessStartDelegate = new OnProcessStart(this.ProcessStarted);
            try
            {
                String query = String.Format("SELECT * FROM __InstanceCreationEvent WITHIN 0.5 WHERE (TargetInstance isa \"Win32_Process\") AND (TargetInstance.Name=\"{0}\")", String.Join("\" OR TargetInstance.Name=\"", this.ProcessesNames));
                this.startWatch = new ManagementEventWatcher(query);
                this.startWatch.EventArrived += this.startWatch_EventArrived;
                this.startWatch.Start();
            }
            catch(Exception ee)
            {
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(ee.ToString(), EventLogEntryType.Error); }
                    catch {}
            }
        }
        protected override void OnStop()
        {
            if(null != this.startWatch)
            {
                this.startWatch.Stop();
            }

            base.OnStop();
        }
        ManagementEventWatcher startWatch;
        void startWatch_EventArrived(object sender, EventArrivedEventArgs e) 
        {
            try
            {
                ManagementBaseObject process = (ManagementBaseObject)e.NewEvent.Properties["TargetInstance"].Value;
                UInt32 processId = (UInt32)process.Properties["ProcessId"].Value;
                this.ProcessStartDelegate.BeginInvoke(processId, null, null);
            } 
            catch(Exception ee) 
            {
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(ee.ToString(), EventLogEntryType.Warning); }
                    catch {}

            }
        }
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern Int32 WaitForSingleObject(IntPtr Handle, Int32 Milliseconds);
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern IntPtr OpenProcess(UInt32 DesiredAccess, Int32 InheritHandle, UInt32 ProcessId);
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern Int32 CloseHandle(IntPtr Handle);
        const UInt32 SYNCHRONIZE = 0x00100000;
        delegate void OnProcessStart(UInt32 processId);
        OnProcessStart ProcessStartDelegate = null;
        void ProcessStarted(UInt32 processId)
        {
            SetMaximumResolution();
            IntPtr processHandle = IntPtr.Zero;
            try
            {
                processHandle = OpenProcess(SYNCHRONIZE, 0, processId);
                if(processHandle != IntPtr.Zero)
                    WaitForSingleObject(processHandle, -1);
            } 
            catch(Exception ee) 
            {
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(ee.ToString(), EventLogEntryType.Warning); }
                    catch {}
            }
            finally
            {
                if(processHandle != IntPtr.Zero)
                    CloseHandle(processHandle); 
            }
            SetDefaultResolution();
        }
        List<String> ProcessesNames = null;
        void ReadProcessList()
        {
            String iniFilePath = Assembly.GetExecutingAssembly().Location + ".ini";
            if(File.Exists(iniFilePath))
            {
                this.ProcessesNames = new List<String>();
                String[] iniFileLines = File.ReadAllLines(iniFilePath);
                foreach(var line in iniFileLines)
                {
                    String[] names = line.Split(new char[] {',', ' ', ';'} , StringSplitOptions.RemoveEmptyEntries);
                    foreach(var name in names)
                    {
                        String lwr_name = name.ToLower();
                        if(!lwr_name.EndsWith(".exe"))
                            lwr_name += ".exe";
                        if(!this.ProcessesNames.Contains(lwr_name))
                            this.ProcessesNames.Add(lwr_name);
                    }
                }
            }
        }
        [DllImport("ntdll.dll", SetLastError=true)]
        static extern int NtSetTimerResolution(uint DesiredResolution, bool SetResolution, out uint CurrentResolution);
        [DllImport("ntdll.dll", SetLastError=true)]
        static extern int NtQueryTimerResolution(out uint MinimumResolution, out uint MaximumResolution, out uint ActualResolution);
        uint DefaultResolution = 0;
        uint MininumResolution = 0;
        uint MaximumResolution = 0;
        long processCounter = 0;
        void SetMaximumResolution()
        {
            long counter = Interlocked.Increment(ref this.processCounter);
            if(counter <= 1)
            {
                uint actual = 0;
                NtSetTimerResolution(this.MaximumResolution, true, out actual);
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(String.Format("Actual resolution = {0}", actual)); }
                    catch {}
            }
        }
        void SetDefaultResolution()
        {
            long counter = Interlocked.Decrement(ref this.processCounter);
            if(counter < 1)
            {
                uint actual = 0;
                NtSetTimerResolution(this.DefaultResolution, true, out actual);
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(String.Format("Actual resolution = {0}", actual)); }
                    catch {}
            }
        }
    }
    [RunInstaller(true)]
    public class WindowsServiceInstaller : Installer
    {
        public WindowsServiceInstaller()
        {
            ServiceProcessInstaller serviceProcessInstaller = 
                               new ServiceProcessInstaller();
            ServiceInstaller serviceInstaller = new ServiceInstaller();
            serviceProcessInstaller.Account = ServiceAccount.LocalSystem;
            serviceProcessInstaller.Username = null;
            serviceProcessInstaller.Password = null;
            serviceInstaller.DisplayName = "Set Timer Resolution Service";
            serviceInstaller.StartType = ServiceStartMode.Automatic;
            serviceInstaller.ServiceName = "STR";
            this.Installers.Add(serviceProcessInstaller);
            this.Installers.Add(serviceInstaller);
        }
    }
}
"@
Set-Content -Path "$env:SystemDrive\Windows\SetTimerResolutionService.cs" -Value $MultilineComment -Force
# compile and create service
Start-Process -Wait "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe" -ArgumentList "-out:C:\Windows\SetTimerResolutionService.exe C:\Windows\SetTimerResolutionService.cs" -WindowStyle Hidden
# delete file
Remove-Item "$env:SystemDrive\Windows\SetTimerResolutionService.cs" -ErrorAction SilentlyContinue | Out-Null
# install and start service
New-Service -Name "Set Timer Resolution Service" -BinaryPathName "$env:SystemDrive\Windows\SetTimerResolutionService.exe" -ErrorAction SilentlyContinue | Out-Null
Set-Service -Name "Set Timer Resolution Service" -StartupType Auto -ErrorAction SilentlyContinue | Out-Null
Set-Service -Name "Set Timer Resolution Service" -Status Running -ErrorAction SilentlyContinue | Out-Null

Clear-Host
Write-Host "Registry: Optimize . . ."
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; --LEGACY CONTROL PANEL--




; EASE OF ACCESS
; disable narrator
[HKEY_CURRENT_USER\Software\Microsoft\Narrator\NoRoam]
"DuckAudio"=dword:00000000
"WinEnterLaunchEnabled"=dword:00000000
"ScriptingEnabled"=dword:00000000
"OnlineServicesEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Narrator]
"NarratorCursorHighlight"=dword:00000000
"CoupleNarratorCursorKeyboard"=dword:00000000

; disable ease of access settings 
[HKEY_CURRENT_USER\Software\Microsoft\Ease of Access]
"selfvoice"=dword:00000000
"selfscan"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility]
"Sound on Activation"=dword:00000000
"Warning Sounds"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\HighContrast]
"Flags"="4194"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
"Flags"="2"
"AutoRepeatRate"="0"
"AutoRepeatDelay"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys]
"Flags"="130"
"MaximumSpeed"="39"
"TimeToMaximumSpeed"="3000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
"Flags"="2"

[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
"Flags"="34"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry]
"Flags"="0"
"FSTextEffect"="0"
"TextEffect"="0"
"WindowsEffect"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SlateLaunch]
"ATapp"=""
"LaunchAT"=dword:00000000




; CLOCK AND REGION
; disable notify me when the clock changes
[HKEY_CURRENT_USER\Control Panel\TimeDate]
"DstNotification"=dword:00000000




; APPEARANCE AND PERSONALIZATION
; open file explorer to this pc
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001

; hide frequent folders in quick access
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowFrequent"=dword:00000000

; show file name extensions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000

; disable search history
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDeviceSearchHistoryEnabled"=dword:00000000

; disable show files from office.com
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowCloudFilesInQuickAccess"=dword:00000000

; disable display file size information in folder tips
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"FolderContentsInfoTip"=dword:00000000

; enable display full path in the title bar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState]
"FullPath"=dword:00000001

; disable show pop-up description for folder and desktop items
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowInfoTip"=dword:00000000

; disable show preview handlers in preview pane
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowPreviewHandlers"=dword:00000000

; disable show status bar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowStatusBar"=dword:00000000

; disable show sync provider notifications
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowSyncProviderNotifications"=dword:00000000

; disable use sharing wizard
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"SharingWizardOn"=dword:00000000

; disable show network
[HKEY_CURRENT_USER\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}]
"System.IsPinnedToNameSpaceTree"=dword:00000000




; HARDWARE AND SOUND
; disable lock
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
"ShowLockOption"=dword:00000000

; disable sleep
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
"ShowSleepOption"=dword:00000000

; sound communications do nothing
[HKEY_CURRENT_USER\Software\Microsoft\Multimedia\Audio]
"UserDuckingPreference"=dword:00000003

; disable startup sound
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation]
"DisableStartupSound"=dword:00000001

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\EditionOverrides]
"UserSetting_DisableStartupSound"=dword:00000001

; sound scheme none
[HKEY_CURRENT_USER\AppEvents\Schemes]
@=".None"

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\.Default\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\CriticalBatteryAlarm\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\DeviceConnect\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\DeviceDisconnect\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\DeviceFail\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\FaxBeep\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\LowBatteryAlarm\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\MailBeep\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\MessageNudge\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Default\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.IM\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Mail\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Proximity\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Reminder\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.SMS\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\ProximityConnection\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemAsterisk\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemExclamation\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemHand\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemNotification\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\WindowsUAC\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\DisNumbersSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\HubOffSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\HubOnSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\HubSleepSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\MisrecoSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\PanelSound\.current]
@=""

; disable autoplay
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers]
"DisableAutoplay"=dword:00000001

; disable enhance pointer precision
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"

; mouse pointers scheme none
[HKEY_CURRENT_USER\Control Panel\Cursors]
"AppStarting"=hex(2):00,00
"Arrow"=hex(2):00,00
"ContactVisualization"=dword:00000000
"Crosshair"=hex(2):00,00
"GestureVisualization"=dword:00000000
"Hand"=hex(2):00,00
"Help"=hex(2):00,00
"IBeam"=hex(2):00,00
"No"=hex(2):00,00
"NWPen"=hex(2):00,00
"Scheme Source"=dword:00000000
"SizeAll"=hex(2):00,00
"SizeNESW"=hex(2):00,00
"SizeNS"=hex(2):00,00
"SizeNWSE"=hex(2):00,00
"SizeWE"=hex(2):00,00
"UpArrow"=hex(2):00,00
"Wait"=hex(2):00,00
@=""

; disable device installation settings
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=dword:00000001




; NETWORK AND INTERNET
; disable allow other network users to control or disable the shared internet connection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Network\SharedAccessConnection]
"EnableControl"=dword:00000000




; SYSTEM AND SECURITY

; Disable ai insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"InsightsEnabled"=dword:00000000

; set appearance options to custom
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:3

; disable animate controls and elements inside windows
; disable fade or slide menus into view
; disable fade or slide tooltips into view
; disable fade out menu items after clicking
; disable show shadows under mouse pointer
; disable show shadows under windows
; disable slide open combo boxes
; disable smooth-scroll list boxes
[HKEY_CURRENT_USER\Control Panel\Desktop]
"UserPreferencesMask"=hex(2):90,12,03,80,10,00,00,00

; disable animate windows when minimizing and maximizing
[HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics]
"MinAnimate"="0"

; disable animations in the taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAnimations"=dword:0

; disable enable peek
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"EnableAeroPeek"=dword:0

; disable save taskbar thumbnail previews
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"AlwaysHibernateThumbnails"=dword:0

; Enable end task in taskbar right click menu
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings]
"TaskbarEndTask"=dword:00000001

; enable show thumbnails instead of icons
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"IconsOnly"=dword:0

; disable show translucent selection rectangle
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ListviewAlphaSelect"=dword:0

; disable show window contents while dragging
;[HKEY_CURRENT_USER\Control Panel\Desktop]
;"DragFullWindows"="0"

; enable smooth edges of screen fonts
[HKEY_CURRENT_USER\Control Panel\Desktop]
"FontSmoothing"="2"

; disable use drop shadows for icon labels on the desktop
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ListviewShadow"=dword:0

; adjust for best performance of programs
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026

; disable remote assistance
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000000




; TROUBLESHOOTING
; disable automatic maintenance
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance]
"MaintenanceDisabled"=dword:00000001




; SECURITY AND MAINTENANCE
; disable report problems
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting]
"Disabled"=dword:00000001




; --IMMERSIVE CONTROL PANEL--




; WINDOWS UPDATE
; disable delivery optimization
[HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings]
"DownloadMode"=dword:00000000




; PRIVACY
; disable show me notification in the settings app
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
"EnableAccountNotifications"=dword:00000000

; disable location
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
"Value"="Deny"

; disable allow location override
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CPSS\Store\UserLocationOverridePrivacySetting]
"Value"=dword:00000000

; enable camera
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam]
"Value"="Allow"

; enable microphone 
[Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone]
"Value"="Allow"

; disable voice activation
[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationEnabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationLastUsed"=dword:00000000

; disable notifications
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener]
"Value"="Deny"

; disable account info
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
"Value"="Deny"

; disable contacts
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts]
"Value"="Deny"

; disable calendar
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments]
"Value"="Deny"

; disable phone calls
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall]
"Value"="Deny"

; disable call history
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory]
"Value"="Deny"

; disable email
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email]
"Value"="Deny"

; disable tasks
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks]
"Value"="Deny"

; disable messaging
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat]
"Value"="Deny"

; disable radios
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios]
"Value"="Deny"

; disable other devices 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync]
"Value"="Deny"

; app diagnostics 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics]
"Value"="Deny"

; disable documents
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary]
"Value"="Deny"

; disable downloads folder 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder]
"Value"="Deny"

; disable music library
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary]
"Value"="Deny"

; disable pictures
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary]
"Value"="Deny"

; disable videos
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary]
"Value"="Deny"

; disable file system
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess]
"Value"="Deny"

; disable let websites show me locally relevant content by accessing my language list 
[HKEY_CURRENT_USER\Control Panel\International\User Profile]
"HttpAcceptLanguageOptOut"=dword:00000001

; disable let windows improve start and search results by tracking app launches  
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

; disable personal inking and typing dictionary
[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
"RestrictImplicitInkCollection"=dword:00000001
"RestrictImplicitTextCollection"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
"HarvestContacts"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
"AcceptedPrivacyPolicy"=dword:00000000

; disable sending required data
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000

; feedback frequency never
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules]
"NumberOfSIUFInPeriod"=dword:00000000
"PeriodInNanoSeconds"=-

; disable store my activity history on this device 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
"PublishUserActivities"=dword:00000000




; SEARCH
; disable search highlights
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000000

; disable safe search
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings]
"SafeSearchMode"=dword:00000000

; disable cloud content search for work or school account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsAADCloudSearchEnabled"=dword:00000000

; disable cloud content search for microsoft account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsMSACloudSearchEnabled"=dword:00000000




; EASE OF ACCESS
; disable magnifier settings 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ScreenMagnifier]
"FollowCaret"=dword:00000000
"FollowNarrator"=dword:00000000
"FollowMouse"=dword:00000000
"FollowFocus"=dword:00000000

; disable narrator settings
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator]
"IntonationPause"=dword:00000000
"ReadHints"=dword:00000000
"ErrorNotificationType"=dword:00000000
"EchoChars"=dword:00000000
"EchoWords"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NarratorHome]
"MinimizeType"=dword:00000000
"AutoStart"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NoRoam]
"EchoToggleKeys"=dword:00000000

; disable use the print screen key to open screeen capture
[HKEY_CURRENT_USER\Control Panel\Keyboard]
"PrintScreenKeyForSnippingEnabled"=dword:00000000




; GAMING
; disable game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000

; disable enable open xbox game bar using game controller
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=dword:00000000

; enable game mode
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"AutoGameModeEnabled"=dword:00000001

; other settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AudioEncodingBitrate"=dword:0001f400
"AudioCaptureEnabled"=dword:00000000
"CustomVideoEncodingBitrate"=dword:003d0900
"CustomVideoEncodingHeight"=dword:000002d0
"CustomVideoEncodingWidth"=dword:00000500
"HistoricalBufferLength"=dword:0000001e
"HistoricalBufferLengthUnit"=dword:00000001
"HistoricalCaptureEnabled"=dword:00000000
"HistoricalCaptureOnBatteryAllowed"=dword:00000001
"HistoricalCaptureOnWirelessDisplayAllowed"=dword:00000001
"MaximumRecordLength"=hex(b):00,D0,88,C3,10,00,00,00
"VideoEncodingBitrateMode"=dword:00000002
"VideoEncodingResolutionMode"=dword:00000002
"VideoEncodingFrameRateMode"=dword:00000000
"EchoCancellationEnabled"=dword:00000001
"CursorCaptureEnabled"=dword:00000000
"VKToggleGameBar"=dword:00000000
"VKMToggleGameBar"=dword:00000000
"VKSaveHistoricalVideo"=dword:00000000
"VKMSaveHistoricalVideo"=dword:00000000
"VKToggleRecording"=dword:00000000
"VKMToggleRecording"=dword:00000000
"VKTakeScreenshot"=dword:00000000
"VKMTakeScreenshot"=dword:00000000
"VKToggleRecordingIndicator"=dword:00000000
"VKMToggleRecordingIndicator"=dword:00000000
"VKToggleMicrophoneCapture"=dword:00000000
"VKMToggleMicrophoneCapture"=dword:00000000
"VKToggleCameraCapture"=dword:00000000
"VKMToggleCameraCapture"=dword:00000000
"VKToggleBroadcast"=dword:00000000
"VKMToggleBroadcast"=dword:00000000
"MicrophoneCaptureEnabled"=dword:00000000
"SystemAudioGain"=hex(b):10,27,00,00,00,00,00,00
"MicrophoneGain"=hex(b):10,27,00,00,00,00,00,00




; TIME & LANGUAGE 
; disable show the voice typing mic button
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"IsVoiceTypingKeyEnabled"=dword:00000000

; disable capitalize the first letter of each sentence
; disable play key sounds as i type
; disable add a period after i double-tap the spacebar
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"EnableAutoShiftEngage"=dword:00000000
"EnableKeyAudioFeedback"=dword:00000000
"EnableDoubleTapSpace"=dword:00000000

; disable typing insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"InsightsEnabled"=dword:00000000




; ACCOUNTS
; disable use my sign in info after restart
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"DisableAutomaticRestartSignOn"=dword:00000001




; APPS
; disable automatically update maps
[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
"AutoUpdateEnabled"=dword:00000000

; disable archive apps 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Appx]
"AllowAutomaticAppArchiving"=dword:00000000




; PERSONALIZATION
; solid color personalize your background
[HKEY_CURRENT_USER\Control Panel\Desktop]
"Wallpaper"=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers]
"BackgroundType"=dword:00000001

; dark theme 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
"AppsUseLightTheme"=dword:00000000
"SystemUsesLightTheme"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
"AppsUseLightTheme"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent]
"StartColorMenu"=dword:ff3d3f41
"AccentColorMenu"=dword:ff484a4c
"AccentPalette"=hex(3):DF,DE,DC,00,A6,A5,A1,00,68,65,62,00,4C,4A,48,00,41,\
3F,3D,00,27,25,24,00,10,0D,0D,00,10,7C,10,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"EnableWindowColorization"=dword:00000001
"AccentColor"=dword:ff484a4c
"ColorizationColor"=dword:c44c4a48
"ColorizationAfterglow"=dword:c44c4a48

; disable transparency
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]
"EnableTransparency"=dword:00000000

; always hide most used list in start menu
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"ShowOrHideMostUsedApps"=dword:00000002

[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"ShowOrHideMostUsedApps"=-

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-

; more pins personalization start
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_Layout"=dword:00000001

; disable show recently added apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"HideRecentlyAddedApps"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideRecentlyAddedApps"=dword:00000001

; disable show account-related notifications
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_AccountNotifications"=dword:00000000

; disable show recently opened items in start, jump lists and file explorer
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_TrackDocs"=dword:00000000 

; left taskbar alignment
;[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
;"TaskbarAl"=dword:00000000

; remove chat from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000

; remove task view from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowTaskViewButton"=dword:00000000

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh] 
"AllowNewsAndInterests"=dword:00000000

; remove copilot from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000

; remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

; remove news and interests
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; show all taskbar icons
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"EnableAutoTray"=dword:00000000

; remove security taskbar icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
"SecurityHealth"=hex(3):07,00,00,00,05,DB,8A,69,8A,49,D9,01

; disable use dynamic lighting on my devices
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000

; disable compatible apps in the forground always control lighting 
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"ControlledByForegroundApp"=dword:00000000

; disable match my windows accent color 
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"UseSystemAccentColor"=dword:00000000

; disable show key background
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"IsKeyBackgroundEnabled"=dword:00000000

; disable show recommendations for tips shortcuts new apps and more
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_IrisRecommendations"=dword:00000000

; disable share any window from my taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarSn"=dword:00000000




; DEVICES
; disable usb issues notify
[HKEY_CURRENT_USER\Software\Microsoft\Shell\USB]
"NotifyOnUsbErrors"=dword:00000000

; disable let windows manage my default printer
[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Windows]
"LegacyDefaultPrinterMode"=dword:00000001

; disable write with your fingertip
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\EmbeddedInkControl]
"EnableInkingWithTouch"=dword:00000000




; SYSTEM
; 100% dpi scaling
[HKEY_CURRENT_USER\Control Panel\Desktop]
"LogPixels"=dword:00000060
"Win8DpiScaling"=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\DWM]
"UseDpiScaling"=dword:00000000

; disable fix scaling for apps
[HKEY_CURRENT_USER\Control Panel\Desktop]
"EnablePerProcessSystemDPI"=dword:00000000

; turn on hardware accelerated gpu scheduling
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers]
"HwSchMode"=dword:00000002

; disable variable refresh rate & enable optimizations for windowed games
[HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences]
"DirectXUserGlobalSettings"="SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;"

; disable notifications
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications]
"ToastEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"SubscribedContent-338389Enabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
"ScoobeSystemSettingEnabled"=dword:00000000

; disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; disable focus assist
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\??windows.data.notifications.quiethourssettings\Current]
"Data"=hex(3):02,00,00,00,B4,67,2B,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,14,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,55,00,6E,00,72,00,65,00,73,00,74,00,72,\
00,69,00,63,00,74,00,65,00,64,00,CA,28,D0,14,02,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentfullscreen?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,97,1D,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,26,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,41,00,6C,00,61,00,72,00,6D,00,73,00,4F,\
00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentgame?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,6C,39,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,50,00,72,00,69,00,6F,00,72,00,69,00,74,\
00,79,00,4F,00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentpostoobe?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,06,54,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,50,00,72,00,69,00,6F,00,72,00,69,00,74,\
00,79,00,4F,00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentpresentation?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,83,6E,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,26,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,41,00,6C,00,61,00,72,00,6D,00,73,00,4F,\
00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentscheduled?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,2E,8A,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,50,00,72,00,69,00,6F,00,72,00,69,00,74,\
00,79,00,4F,00,6E,00,6C,00,79,00,C2,28,01,D1,32,80,E0,AA,8A,99,30,D1,3C,80,\
E0,F6,C5,D5,0E,CA,50,00,00

; battery options optimize for video quality
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
"VideoQualityOnBattery"=dword:00000001

; disable storage sense
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\StorageSense]
"AllowStorageSenseGlobal"=dword:00000000

; disable snap window settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"SnapAssist"=dword:00000000
"DITest"=dword:00000000
"EnableSnapBar"=dword:00000000
"EnableTaskGroups"=dword:00000000
"EnableSnapAssistFlyout"=dword:00000000
"SnapFill"=dword:00000000
"JointResize"=dword:00000000

; alt tab open windows only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"MultiTaskingAltTabFilter"=dword:00000003

; disable share across devices
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP]
"RomeSdkChannelUserAuthzPolicy"=dword:00000000
"CdpSessionUserAuthzPolicy"=dword:00000000




; --OTHER--




; STORE
; disable update apps automatically
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore]
"AutoDownload"=dword:00000002




; EDGE
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
"StartupBoostEnabled"=dword:00000000
"HardwareAccelerationModeEnabled"=dword:00000000
"BackgroundModeEnabled"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\edgeupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\edgeupdatem]
"Start"=dword:00000004




; CHROME
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome]
"StartupBoostEnabled"=dword:00000000
"HardwareAccelerationModeEnabled"=dword:00000000
"BackgroundModeEnabled"=dword:00000000
"HighEfficiencyModeEnabled"=dword:00000001

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdatem]
"Start"=dword:00000004




; NVIDIA
; disable nvidia tray icon
[HKEY_CURRENT_USER\Software\NVIDIA Corporation\NvTray]
"StartOnLogin"=dword:00000000




; --CAN'T DO NATIVELY--




; UWP APPS
; disable background apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000002

; disable windows input experience preload
[HKEY_CURRENT_USER\Software\Microsoft\input]
"IsInputAppPreloadEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Dsh]
"IsPrelaunchEnabled"=dword:00000000

; disable web search in start menu 
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001

; disable copilot
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; disable widgets
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
"value"=dword:00000000




; NVIDIA
; enable old nvidia sharpening
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS]
"EnableGR535"=dword:00000000




; POWER
; unpark cpu cores 
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583]
"ValueMax"=dword:00000000

; disable power throttling
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
"PowerThrottlingOff"=dword:00000001

; disable hibernate
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power]
"HibernateEnabled"=dword:00000000
"HibernateEnabledDefault"=dword:00000000

; disable fast boot
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power]
"HiberbootEnabled"=dword:00000000




; DISABLE ADVERTISING & PROMOTIONAL
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"ContentDeliveryAllowed"=dword:00000000
"FeatureManagementEnabled"=dword:00000000
"OemPreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEverEnabled"=dword:00000000
"RotatingLockScreenEnabled"=dword:00000000
"RotatingLockScreenOverlayEnabled"=dword:00000000
"SilentInstalledAppsEnabled"=dword:00000000
"SlideshowEnabled"=dword:00000000
"SoftLandingEnabled"=dword:00000000
"SubscribedContent-310093Enabled"=dword:00000000
"SubscribedContent-314563Enabled"=dword:00000000
"SubscribedContent-338388Enabled"=dword:00000000
"SubscribedContent-338389Enabled"=dword:00000000
"SubscribedContent-338389Enabled"=dword:00000000
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000
"SubscribedContent-353698Enabled"=dword:00000000
"SubscribedContentEnabled"=dword:00000000
"SystemPaneSuggestionsEnabled"=dword:00000000




; OTHER
; remove 3d objects
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

[-HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

; remove quick access
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
"HubMode"=dword:00000001

; remove home
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]

; remove gallery
[HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
"System.IsPinnedToNameSpaceTree"=dword:00000000

; restore the classic context menu
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; disable menu show delay
[HKEY_CURRENT_USER\Control Panel\Desktop]
"MenuShowDelay"="0"

; disable driver searching & updates
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"SearchOrderConfig"=dword:00000000

; mouse fix (no accel with epp on)
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSensitivity"="10"
"SmoothMouseXCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	C0,CC,0C,00,00,00,00,00,\
	80,99,19,00,00,00,00,00,\
	40,66,26,00,00,00,00,00,\
	00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,A8,00,00,00,00,00,\
	00,00,E0,00,00,00,00,00

[HKEY_USERS\.DEFAULT\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"
"@
Set-Content -Path "$env:TEMP\Registry Optimize.reg" -Value $MultilineComment -Force
# edit reg file
$path = "$env:TEMP\Registry Optimize.reg"
(Get-Content $path) -replace "\?","$" | Out-File $path
# import reg file
Regedit.exe /S "$env:TEMP\Registry Optimize.reg"
Clear-Host

Clear-Host
# black lockscreen
# create new image
Add-Type -AssemblyName System.Windows.Forms
$screenWidth = [System.Windows.Forms.SystemInformation]#PrimaryMonitorSize.Width
$screenHeight = [System.Windows.Forms.SystemInformation]#PrimaryMonitorSize.Height
Add-Type -AssemblyName System.Drawing
$file = "C:\Windows\Black.jpg"
$edit = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight
$color = [System.Drawing.Brushes]#Black
$graphics = [System.Drawing.Graphics]#FromImage($edit)
$graphics.FillRectangle($color, 0, 0, $edit.Width, $edit.Height)
$graphics.Dispose()
$edit.Save($file)
$edit.Dispose()
# set image settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v "LockScreenImagePath" /t REG_SZ /d "C:\Windows\Black.jpg" /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v "LockScreenImageStatus" /t REG_DWORD /d "1" /f | Out-Null
Write-Host "Set Lockscreen to black"

Clear-Host
$progresspreference = 'silentlycontinue'
Write-Host "Uninstalling: UWP Apps. Please wait . . ."
# uninstall all uwp apps keep nvidia
Get-AppXPackage -allusers | Where-Object {$_.name -notlike '*NVIDIA*'} | Remove-AppxPackage -ErrorAction SilentlyContinue
Timeout /T 2 | Out-Null
# install cbs needed for w11 explorer
Get-AppXPackage -AllUsers *Microsoft.WindowsAppRuntime.CBS* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Timeout /T 2 | Out-Null
# install hevc video extension needed for amd recording
Get-AppXPackage -AllUsers *Microsoft.HEVCVideoExtension* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Timeout /T 2 | Out-Null
# install heif image extension needed for some files
Get-AppXPackage -AllUsers *Microsoft.HEIFImageExtension* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Timeout /T 2 | Out-Null
# install paint w11
Get-AppXPackage -AllUsers *Microsoft.Paint* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Timeout /T 2 | Out-Null
# install photos
Get-AppXPackage -AllUsers *Microsoft.Windows.Photos* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Timeout /T 2 | Out-Null
# install notepad w11
Get-AppXPackage -AllUsers *Microsoft.WindowsNotepad* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Timeout /T 2 | Out-Null
Clear-Host
Write-Host "Uninstalling: UWP Features. Please wait . . ."
# uninstall all uwp features
# network drivers, paint & notepad left out
Remove-WindowsCapability -Online -Name "App.StepsRecorder~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "App.Support.QuickAssist~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Browser.InternetExplorer~~~~0.0.11.0" | Out-Null
Remove-WindowsCapability -Online -Name "DirectX.Configuration.Database~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Hello.Face.18967~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Hello.Face.20134~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "MathRecognizer~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Media.WindowsMediaPlayer~~~~0.0.12.0" | Out-Null
Remove-WindowsCapability -Online -Name "Microsoft.Wallpapers.Extended~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Ethernet.Client.Intel.E1i68x64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Ethernet.Client.Intel.E2f68~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Ethernet.Client.Realtek.Rtcx21x64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.MSPaint~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Notepad.System~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Notepad~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Broadcom.Bcmpciedhd63~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Broadcom.Bcmpciedhd63~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Broadcom.Bcmwl63al~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Broadcom.Bcmwl63al~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Broadcom.Bcmwl63a~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Broadcom.Bcmwl63a~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwbw02~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwbw02~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwew00~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwew00~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwew01~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwew01~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwlv64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwlv64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwns64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwns64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwsw00~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwsw00~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw02~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw02~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw04~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw04~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw06~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw06~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw08~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw08~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw10~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Intel.Netwtw10~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Marvel.Mrvlpcie8897~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Marvel.Mrvlpcie8897~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Qualcomm.Athw8x~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Qualcomm.Athw8x~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Qualcomm.Athwnx~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Qualcomm.Athwnx~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Qualcomm.Qcamain10x64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Qualcomm.Qcamain10x64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Ralink.Netr28x~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Ralink.Netr28x~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl8187se~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl8187se~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl8192se~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl8192se~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl819xp~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl819xp~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl85n64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtl85n64~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane01~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane01~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane13~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane13~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane~~~~0.0.1.0" | Out-Null
# Remove-WindowsCapability -Online -Name "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Microsoft.Windows.WordPad~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "OneCoreUAP.OneSync~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Print.Fax.Scan~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Print.Management.Console~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "WMIC~~~~" | Out-Null
# breaks uwp snippingtool w10
# Remove-WindowsCapability -Online -Name "Windows.Client.ShellComponents~~~~0.0.1.0" | Out-Null
Remove-WindowsCapability -Online -Name "Windows.Kernel.LA57~~~~0.0.1.0" | Out-Null
Clear-Host
Write-Host "Uninstalling: Legacy Features. Please wait . . ."
# uninstall all legacy features
# .net framework 4.8 advanced services left out
# Dism /Online /NoRestart /Disable-Feature /FeatureName:NetFx4-AdvSrvs | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:WCF-Services45 | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:WCF-TCP-PortSharing45 | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:MediaPlayback | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-PrintToPDFServices-Features | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-XPSServices-Features | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-Foundation-Features | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-Foundation-InternetPrinting-Client | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:MSRDC-Infrastructure | Out-Null
# breaks search
# Dism /Online /NoRestart /Disable-Feature /FeatureName:SearchEngine-Client-Package | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:SMB1Protocol | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:SMB1Protocol-Client | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:SMB1Protocol-Deprecation | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:SmbDirect | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:Windows-Identity-Foundation | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2Root | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2 | Out-Null
Dism /Online /NoRestart /Disable-Feature /FeatureName:WorkFolders-Client | Out-Null
Clear-Host
Write-Host "Uninstalling: Legacy Apps. Please wait . . ."
# uninstall microsoft update health tools w11
cmd /c "MsiExec.exe /X{C6FD611E-7EFE-488C-A0E0-974C09EF6473} /qn >nul 2>&1"
# uninstall microsoft update health tools w10
cmd /c "MsiExec.exe /X{1FC1A6C2-576E-489A-9B4A-92D21F542136} /qn >nul 2>&1"
# clean microsoft update health tools w10
cmd /c "reg delete `"HKLM\SYSTEM\ControlSet001\Services\uhssvc`" /f >nul 2>&1"
Unregister-ScheduledTask -TaskName PLUGScheduler -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
# uninstall update for windows 10 for x64-based systems
cmd /c "MsiExec.exe /X{B9A7A138-BFD5-4C73-A269-F78CCA28150E} /qn >nul 2>&1"
cmd /c "MsiExec.exe /X{85C69797-7336-4E83-8D97-32A7C8465A3B} /qn >nul 2>&1"
# stop onedrive running
Stop-Process -Force -Name OneDrive -ErrorAction SilentlyContinue | Out-Null
# uninstall onedrive w10
cmd /c "C:\Windows\SysWOW64\OneDriveSetup.exe -uninstall >nul 2>&1"
# clean onedrive w10 
Get-ScheduledTask | Where-Object {$_.Taskname -match 'OneDrive'} | Unregister-ScheduledTask -Confirm:$false
# uninstall onedrive w11
cmd /c "C:\Windows\System32\OneDriveSetup.exe -uninstall >nul 2>&1"
# clean adobe type manager w10
cmd /c "reg delete `"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Font Drivers`" /f >nul 2>&1"
# uninstall old snippingtool w10
Start-Process "C:\Windows\System32\SnippingTool.exe" -ArgumentList "/Uninstall"
Clear-Host
# silent window for old snippingtool w10
$processExists = Get-Process -Name SnippingTool -ErrorAction SilentlyContinue
if ($processExists) {
$running = $true
do {
$openWindows = Get-Process | Where-Object { $_.MainWindowTitle -ne '' } | Select-Object MainWindowTitle
foreach ($window in $openWindows) {
if ($window.MainWindowTitle -eq 'Snipping Tool') {
Stop-Process -Force -Name SnippingTool -ErrorAction SilentlyContinue | Out-Null
$running = $false
}
}
} while ($running)
} else {
}
Timeout /T 1 | Out-Null

Clear-Host
$progresspreference = 'silentlycontinue'
Write-Host "Installing: Store. Please wait . . ."
# install store
Get-AppXPackage -AllUsers *Microsoft.WindowsStore* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Get-AppXPackage -AllUsers *Microsoft.Microsoft.StorePurchaseApp * | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Clear-Host

Clear-Host
Write-Host "Network Adapter: Only Allow IPv4 . . ."
$progresspreference = 'silentlycontinue'
# disable all adapter settings keep ipv4
Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue
# rerun so settings stick
Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue

# ... existing code ...

Clear-Host
Write-Host "Updating hosts file..."

# Define the path to the hosts file
$hostsFile = "$env:windir\System32\drivers\etc\hosts"

# Define the entries you want to add or modify
$hostEntries = @"
127.0.0.1	activity.windows.com
127.0.0.1	tile-service.weather.microsoft.com
127.0.0.1	evoke-windowsservices-tas.msedge.net
127.0.0.1	cdn.onenote.net
#127.0.0.1	spclient.wg.spotify.com
127.0.0.1	ctldl.windowsupdate.com
127.0.0.1	www.bing.com
127.0.0.1	fp.msedge.net
127.0.0.1	k-ring.msedge.net
127.0.0.1	b-ring.msedge.net
127.0.0.1	www.bing.com
#127.0.0.1	login.live.com
127.0.0.1	cs.dds.microsoft.com
127.0.0.1	dmd.metaservices.microsoft.com
127.0.0.1	v10.events.data.microsoft.com
127.0.0.1	watson.telemetry.microsoft.com
127.0.0.1	fs.microsoft.com
127.0.0.1	licensing.mp.microsoft.com
127.0.0.1	inference.location.live.net
127.0.0.1	maps.windows.com
127.0.0.1	ssl.ak.dynamic.tiles.virtualearth.net
127.0.0.1	ssl.ak.tiles.virtualearth.net
127.0.0.1	dev.virtualearth.net
127.0.0.1	ecn.dev.virtualearth.net
127.0.0.1	ssl.bing.com
#127.0.0.1	login.live.com
127.0.0.1	edge.activity.windows.com
127.0.0.1	edge.microsoft.com
127.0.0.1	msedge.api.cdp.microsoft.com
#127.0.0.1	go.microsoft.com/fwlink
#127.0.0.1	go.microsoft.com
127.0.0.1	img-prod-cms-rt-microsoft-com.akamaized.net
127.0.0.1	wns.windows.com
127.0.0.1	storecatalogrevocation.storequality.microsoft.com
127.0.0.1	displaycatalog.mp.microsoft.com
127.0.0.1	storesdk.dsx.mp.microsoft.com
127.0.0.1	pti.store.microsoft.com
127.0.0.1	manage.devcenter.microsoft.com
127.0.0.1	store-images.s-microsoft.com
127.0.0.1	www.msftconnecttest.com
127.0.0.1	outlook.office365.com
127.0.0.1	office.com
127.0.0.1	blobs.officehome.msocdn.com
127.0.0.1	officehomeblobs.blob.core.windows.net
127.0.0.1	blob.core.windows.net
127.0.0.1	self.events.data.microsoft.com
127.0.0.1	outlookmobile-office365-tas.msedge.net
127.0.0.1	roaming.officeapps.live.com
127.0.0.1	substrate.office.com
127.0.0.1	g.live.com
127.0.0.1	oneclient.sfx.ms
127.0.0.1	logincdn.msauth.net
127.0.0.1	windows.policies.live.net
127.0.0.1	api.onedrive.com
127.0.0.1	skydrivesync.policies.live.net
127.0.0.1	storage.live.com
127.0.0.1	settings.live.net
127.0.0.1	settings.data.microsoft.com
127.0.0.1	settings-win.data.microsoft.com
127.0.0.1	pipe.aria.microsoft.com
127.0.0.1	config.edge.skype.com
127.0.0.1	config.teams.microsoft.com
127.0.0.1	wdcp.microsoft.com
127.0.0.1	smartscreen-prod.microsoft.com
127.0.0.1	definitionupdates.microsoft.com
127.0.0.1	smartscreen.microsoft.com
127.0.0.1	checkappexec.microsoft.com
127.0.0.1	arc.msn.com
127.0.0.1	ris.api.iris.microsoft.com
127.0.0.1	mucp.api.account.microsoft.com
127.0.0.1	prod.do.dsp.mp.microsoft.com
127.0.0.1	emdl.ws.microsoft.com
127.0.0.1	dl.delivery.mp.microsoft.com
127.0.0.1	windowsupdate.com
127.0.0.1	delivery.mp.microsoft.com
127.0.0.1	update.microsoft.com
127.0.0.1	adl.windows.com
127.0.0.1	tsfe.trafficshaping.dsp.mp.microsoft.com
127.0.0.1	dlassets-ssl.xboxlive.com
127.0.0.1	da.xboxservices.com
127.0.0.1	www.xboxab.com
0.0.0.0     accounts.firefox.com
0.0.0.0     accounts-static.cdn.mozilla.net
0.0.0.0     activations.cdn.mozilla.net
0.0.0.0     api.accounts.firefox.com
0.0.0.0     autopush.prod.mozaws.net
0.0.0.0     blocklist.addons.mozilla.org
0.0.0.0     blocklists.settings.services.mozilla.com
0.0.0.0     classify-client.services.mozilla.com
0.0.0.0     code.cdn.mozilla.net
0.0.0.0     color.firefox.com
0.0.0.0     content.cdn.mozilla.net
0.0.0.0     content-signature-2.cdn.mozilla.net
0.0.0.0     content-signature.cdn.mozilla.net
0.0.0.0     coverage.mozilla.org
0.0.0.0     crash-reports.mozilla.com
0.0.0.0     crash-stats.mozilla.com
0.0.0.0     discovery.addons.mozilla.org
0.0.0.0     experiments.mozilla.org
0.0.0.0     fastestfirefox.com
0.0.0.0     fhr.cdn.mozilla.net
0.0.0.0     firefox.settings.services.mozilla.com
0.0.0.0     firefoxusercontent.com
0.0.0.0     getpocket.cdn.mozilla.net
0.0.0.0     img-getpocket.cdn.mozilla.net
0.0.0.0     incoming.telemetry.mozilla.org
0.0.0.0     input.mozilla.org
0.0.0.0     install.mozilla.org
0.0.0.0     location.services.mozilla.com
0.0.0.0     mitmdetection.services.mozilla.com
0.0.0.0     normandy.cdn.mozilla.net
0.0.0.0     normandy-cloudfront.cdn.mozilla.net
0.0.0.0     oauth.accounts.firefox.com
0.0.0.0     onyx_tiles.stage.mozaws.net
0.0.0.0     ostats.mozilla.com
0.0.0.0     outgoing.prod.mozaws.net
0.0.0.0     profile.accounts.firefox.com
0.0.0.0     profiler.firefox.com
0.0.0.0     push.services.mozilla.com
0.0.0.0     qsurvey.mozilla.com
0.0.0.0     search.services.mozilla.com
0.0.0.0     self-repair.mozilla.org
0.0.0.0     sentry.prod.mozaws.net
0.0.0.0     shavar.services.mozilla.com
0.0.0.0     snippets.cdn.mozilla.net
0.0.0.0     sync.services.mozilla.com
0.0.0.0     telemetry-coverage.mozilla.org
0.0.0.0     telemetry-experiment.cdn.mozilla.net
0.0.0.0     telemetry.mozilla.org
0.0.0.0     testpilot.firefox.com
0.0.0.0     tiles-cloudfront.cdn.mozilla.net
0.0.0.0     tiles.services.mozilla.com
0.0.0.0     token.services.mozilla.com
0.0.0.0     token.services.mozilla.org
0.0.0.0     tracking-protection.cdn.mozilla.net
0.0.0.0     start.thunderbird.net
0.0.0.0     live.mozillamessaging.com
0.0.0.0     live.thunderbird.net
0.0.0.0     broker-live.mozillamessaging.com
"@

# Backup the original hosts file
Copy-Item $hostsFile "$hostsFile.bak" -Force

# Update the hosts file
Add-Content -Path $hostsFile -Value "`n$hostEntries" -Force

Write-Host "Hosts file updated successfully."

#registry numlock enabled everywhere
reg add "HKU\S-1-5-19\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f 1>nul
reg add "HKU\S-1-5-20\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f 1>nul

# automatic discovery IE11 proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d "3c0000000f0000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d "3c000000040000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f

# background apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 0 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\1527c705-839a-4832-9118-54d4Bd6a0c89_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\1527c705-839a-4832-9118-54d4Bd6a0c89_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\c5e2524a-ea46-4f67-841f-6a9465d9d515_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\c5e2524a-ea46-4f67-841f-6a9465d9d515_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\E2A4F912-2574-4A75-9BB0-0D023378592B_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\E2A4F912-2574-4A75-9BB0-0D023378592B_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AccountsControl_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AccountsControl_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AsyncTextService_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AsyncTextService_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BioEnrollment_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BioEnrollment_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CredDialogHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CredDialogHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ECApp_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ECApp_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.LockApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.LockApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Win32WebViewHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Win32WebViewHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.AssignedAccessLockApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.AssignedAccessLockApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CapturePicker_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CapturePicker_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkCaptivePortal_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkCaptivePortal_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkConnectionFlow_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkConnectionFlow_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ParentalControls_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ParentalControls_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PinningConfirmationDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PinningConfirmationDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PrintQueueActionCenter_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PrintQueueActionCenter_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Search_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Search_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.XGpuEjectDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.XGpuEjectDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.UndockedDevKit_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.UndockedDevKit_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NcsiUwpApp_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NcsiUwpApp_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.CBSPreview_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.CBSPreview_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.PrintDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.PrintDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_7njy0v32s6xk6" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_7njy0v32s6xk6" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_d9ma7nkbkv4rp" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_d9ma7nkbkv4rp" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_s4jet1zx4n14a" /v "Disabled" /t REG_DWORD /d 1 /f 1>nul
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_s4jet1zx4n14a" /v "DisabledByUser" /t REG_DWORD /d 1 /f 1>nul
#
# OneDrive cleaning that comes with office install
reg delete "HKCU\Software\Microsoft\OneDrive" /f 1>nul
reg delete "HKCU\Software\Microsoft\SkyDrive" /f 1>nul
reg delete "HKCU\Software\Classes\grvopen" /f 1>nul
reg delete "HKCU\Environment" /v "OneDrive" /f 1>nul

reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f 1>nul
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f 1>nul

# Search in taskbar 0 = Hidden, 1 = Show search icon, 2 = Show search box
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f 1>nul
# change currency "kn" u "EUR"  HR & EN (Croatia)
reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "EUR" /f 1>nul
# disable automatic folder type discovery
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d NotSpecified /f 1>nul
# registered owner & organization
#reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "RegisteredOrganization" /t REG_SZ /d "(-_-)" /f 1>nul
#reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "RegisteredOwner" /t REG_SZ /d "Gazda" /f 1>nul
# enable DNS over HTTPS (DoH)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d 2 /f 1>nul
# remove Auto run Defender
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f 1>nul
# disable autologger telemetry: CloudExperienceHostOobe.etl, Cellcore.etl, WinPhoneCritical.etl
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe" /v "Start" /t REG_DWORD /d 0 /f 1>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudExperienceHost" /v "ETWLoggingEnabled" /t REG_DWORD /d 0 /f 1>nul
#
# Clean Windows from OneDrive (comes with Office installations)
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive1" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive2" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive3" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive4" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive5" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive6" /f 1>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive7" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive1" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive2" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive3" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive4" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive5" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive6" /f 1>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive7" /f 1>nul
# disable updates for microsoft office
schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
schtasks /change /tn "Microsoft\Office\Office Feature Updates Logon" /disable
schtasks /change /tn "Microsoft\Office\Office Feature Updates" /disable
schtasks /change /tn "Microsoft\Office\Office Automatic Updates 2.0" /disable
# firefox
schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
# obriši tasks "Cleaning Retail Demo content" (radi se tek za vrijeme setupa)
# \Microsoft\Windows\RetailDemo\CleanupOfflineContent
schtasks /delete /tn "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /f
# schtasks /delete /tn "Microsoft\Windows\RetailDemo" /f
# CleanUp
#del /f /q %windir%\PrilagodeniTasks.cmd
del /f /q %ProgramData%\Microsoft\Diagnosis\*.rbs
del /f /q /s %ProgramData%\Microsoft\Diagnosis\ETLLogs\*
del /f /q /s "%ProgramData%\Microsoft\Windows Defender\Scans\*"
del /f /q %SystemRoot%\Panther\*
#rd /s /q "%windir%\Setup\Scripts"

# disable activity log and clipboard
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f

# disable cliboard history
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowClipboardHistory" /t REG_DWORD /d 0 /f

# disable windows event logging
# check all policies: auditpol /get /Category:*
auditpol /set /subcategory:"Special Logon" /success:disable
auditpol /set /subcategory:"Audit Policy Change" /success:disable
auditpol /set /subcategory:"User Account Management" /success:disable
# password never expires
net.exe accounts /maxpwage:unlimited
# disable telemetry. UnifedTelemetryClient
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
# Defender auto run disabled
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "SecurityHealth" /t REG_EXPAND_SZ /d "%%SystemRoot%%\system32\SecurityHealthSystray.exe" /f
#
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT" /v "Start" /t REG_DWORD /d 3 /f

# tasks
schtasks /Create /F /RU "SYSTEM" /RL HIGHEST /SC HOURLY /TN PrilagodeniTasks /TR "cmd /c %windir%\PrilagodeniTasks.cmd"
schtasks /Run /I /TN PrilagodeniTasks
timeout /T 5
schtasks /delete /F /TN PrilagodeniTasks
#
# set default DNS to Cloudflare.
wmic nicconfig where (IPEnabled=TRUE) call SetDNSServerSearchOrder ("1.1.1.1", "1.0.0.1")
# Register DNS
ipconfig /registerdns
# disable DNS Functions (LLMNR, Resolution, Devolution, ParallelAandAAAA)
# netsh.exe winhttp reset proxy
# disable NetBIOS over TCP/IP-a
wmic nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2
wmic nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2
# bootloader
bcdedit /timeout 4
# force install uncertified drivers
bcdedit /set nointegritychecks off
# disable hibernation
powercfg -h off
# disable 8dot3
fsutil behavior set disable8dot3 1
# disable Bitlocker and encryption
fsutil behavior set disableencryption 1
# Update NTFS "Last Access" (User Managed, Last Access Updates Disabled)
fsutil behavior set disablelastaccess 1
# Increase memory for access NTFS files
fsutil behavior set memoryusage 2
# disable NET Core CLI telemetry
setx DOTNET_CLI_TELEMETRY_OPTOUT 1
# disable automatic repair
fsutil repair set c: 0
# disalbe tracking IPsec filtera firewall (wfpdiag.etl, Process Hacker omogućuje ovo praćenje)
netsh.exe wfp set options netevents = off
# passwords never expire
net.exe accounts /maxpwage:unlimited
# regsvr32 /s %SystemRoot%\System32\DolbyDecMFT.dll
# regsvr32 /s %SystemRoot%\SysWOW64\DolbyDecMFT.dll

# Tasks
# schtasks /change /tn "CreateExplorerShellUnelevatedTask" /enable
# schtasks /delete /tn "MicrosoftEdgeUpdateTaskMachineCore" /f
# schtasks /change /tn "Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" /disable
#
# disable telemtry and diagnostics
schtasks /change /tn "Microsoft\Windows\WDI\ResolutionHost" /disable
schtasks /change /tn "Microsoft\Windows\UNP\RunUpdateNotificationMgr" /disable
schtasks /change /tn "Microsoft\Windows\DUSM\dusmtask" /disable
# disable tasks extra
schtasks /change /tn "Microsoft\Windows\SettingSync\BackgroundUpLoadTask" /disable
schtasks /change /tn "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /disable
schtasks /change /tn "Microsoft\Windows\Device Setup\Metadata Refresh" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\HandleCommand" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChanged" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" /disable
schtasks /change /tn "Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" /disable
schtasks /change /tn "Microsoft\Windows\Input\LocalUserSyncDataAvailable" /disable
schtasks /change /tn "Microsoft\Windows\Input\MouseSyncDataAvailable" /disable
schtasks /change /tn "Microsoft\Windows\Input\PenSyncDataAvailable" /disable
schtasks /change /tn "Microsoft\Windows\Input\TouchpadSyncDataAvailable" /disable
schtasks /change /tn "Microsoft\Windows\International\Synchronize Language Settings" /disable
# Sysmain optimizations
schtasks /change /tn "Microsoft\Windows\Sysmain\ResPriStaticDbSync" /disable
schtasks /change /tn "Microsoft\Windows\Sysmain\WsSwapAssessmentTask" /disable
schtasks /change /tn "Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate" /disable
schtasks /change /tn "Microsoft\Windows\Sysmain\HybridDriveCacheRebalance" /disable
# disable task "Cleaning the system drive during idle time"
schtasks /change /tn "Microsoft\Windows\DiskCleanup\SilentCleanup" /disable
# disable task "Cleaning language parameters"
schtasks /change /tn "Microsoft\Windows\MUI\LPRemove" /disable
# disable tasks "Maintenance drive spaces (analogue RAID, virtual disks)"
schtasks /change /tn "Microsoft\Windows\SpacePort\SpaceAgentTask" /disable
schtasks /change /tn "Microsoft\Windows\SpacePort\SpaceManagerTask" /disable
# disable task "Loading voice models"
schtasks /change /tn "Microsoft\Windows\Speech\SpeechModelDownloadTask" /disable
# disable tasks "Active Directory"
schtasks /change /tn "Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)" /disable
schtasks /change /tn "Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" /disable
# disable ProvTool.exe tasks (for SYSPREP and change Windows edition)
# tasks to reconcile packages during SYSPREP and others via "ProvTool.exe":
schtasks /change /tn "Microsoft\Windows\Management\Provisioning\Logon" /disable
schtasks /change /tn "Microsoft\Windows\Management\Provisioning\Cellular" /disable
# disalbe task for archiving (works only in auto maintenance)
schtasks /change /tn "Microsoft\Windows\FileHistory\File History (maintenance mode)" /disable

# disable telemetry for Microsoft Office 2016/2019+
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack" /disable
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn" /disable
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack2016" /disable
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /disable
schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable

# disable default browser agent reporting services (firefox)
schtasks /change /tn "Mozilla\Firefox Default Browser Agent 308046B0AF4A39CB" /disable
schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
schtasks /change /tn "Mozilla\Firefox Default Browser Agent D2CEEC440E2074BD" /disable

# deactivate nepotrebne tasks
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical" /disable
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64" /disable
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical" /disable
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319" /disable
schtasks /change /tn "Microsoft\Windows\Defrag\ScheduledDefrag" /disable
schtasks /change /tn "Microsoft\Windows\Multimedia\SystemSoundsService" /disable
schtasks /change /tn "Microsoft\Windows\NlaSvc\WiFiTask" /disable
schtasks /change /tn "Microsoft\Windows\Printing\EduPrintProv" /disable
schtasks /change /tn "Microsoft\Windows\Printing\PrinterCleanupTask" /disable
schtasks /change /tn "Microsoft\Windows\Printing\PrintJobCleanupTask" /disable
schtasks /change /tn "Microsoft\Windows\RecoveryEnvironment\VerifyWinRE" /disable
schtasks /change /tn "Microsoft\Windows\Servicing\StartComponentCleanup" /disable
schtasks /change /tn "Microsoft\Windows\Setup\SetupCleanupTask" /disable
schtasks /change /tn "Microsoft\Windows\Shell\ThemesSyncedImageDownload" /disable
schtasks /change /tn "Microsoft\Windows\Shell\UpdateUserPictureTask" /disable
schtasks /change /tn "Microsoft\Windows\Storage Tiers Management\Storage Tiers Management Initialization" /disable
schtasks /change /tn "Microsoft\Windows\Task Manager\Interactive" /disable
schtasks /change /tn "Microsoft\Windows\TPM\Tpm-HASCertRetr" /disable
schtasks /change /tn "Microsoft\Windows\TPM\Tpm-Maintenance" /disable
schtasks /change /tn "Microsoft\Windows\UPnP\UPnPHostConfig" /disable
schtasks /change /tn "Microsoft\Windows\WCM\WiFiTask" /disable
schtasks /change /tn "Microsoft\Windows\WlanSvc\CDSSync" /disable
schtasks /change /tn "Microsoft\Windows\WOF\WIM-Hash-Management" /disable
schtasks /change /tn "Microsoft\Windows\WOF\WIM-Hash-Validation" /disable
schtasks /change /tn "Microsoft\Windows\WwanSvc\NotificationTask" /disable
schtasks /change /tn "Microsoft\Windows\WwanSvc\OobeDiscovery" /disable
# disable task "CloudExperienceHost"
# schtasks /change /tn "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /disable
#
# MsCtfMonitor Task (keylogger) je potreban da biste mogli tipkati unutar postavki itd.
# schtasks /change /tn "Microsoft\Windows\TextServicesFramework\MsCtfMonitor" /disable

#Adds additional ContextMenu entries
$regFiles = @(
    "https://raw.githubusercontent.com/fivance/ContextMenu/main/CommandStore.reg",
    "https://raw.githubusercontent.com/fivance/ContextMenu/main/SystemShortcutsContextMenu.reg"
    "https://raw.githubusercontent.com/fivance/ContextMenu/main/SystemToolsContextMenu.reg"
)

foreach ($url in $regFiles) {
    $regFilePath = "$env:TEMP\" + [System.IO.Path]::GetFileName($url)
    Invoke-WebRequest -Uri $url -OutFile $regFilePath
    Start-Process -FilePath "regedit.exe" -ArgumentList "/s $regFilePath" -Wait
    Remove-Item $regFilePath
}

$menu = 'Open Windows PowerShell Here as Administrator'
$command = "$PSHOMEpowershell.exe -NoExit -NoProfile -Command ""Set-Location '%V'"""

'directory', 'directorybackground', 'drive' | ForEach-Object {
New-Item -Path "Registry::HKEY_CLASSES_ROOT$_shell" -Name runascommand -Force |
Set-ItemProperty -Name '(default)' -Value $command -PassThru |
Set-ItemProperty -Path {$_.PSParentPath} -Name '(default)' -Value $menu -PassThru |
Set-ItemProperty -Name HasLUAShield -Value ''
}

# clear %temp% folder
Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Local" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
# clear temp folder
Remove-Item -Path "$env:SystemDrive\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:SystemDrive\Windows" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
# open disk cleanup
Start-Process cleanmgr.exe
exit
 }

6 {
    irm christitus.com/win | iex

   }
    } } else { Write-Host "Invalid input. Please select a valid option (1-6)." 
    Write-Host "Press Enter to continue..."
    Read-Host
    Clear-Host
     } }
   
  
