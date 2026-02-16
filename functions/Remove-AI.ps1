function Remove-AI {
  Clear-Host
  Write-Host "Removing AI/Copilot/Recall..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  
  If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit	
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows Anti-AI Configuration Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will disable ALL AI features in Windows 11" -ForegroundColor Gray
Write-Host "to protect your privacy and reduce cloud data collection." -ForegroundColor Gray
Write-Host ""

# ============================================================================
# 1. Disable Windows Copilot
# ============================================================================
Write-Host "[1/10] Disable Windows Copilot" -ForegroundColor Yellow
Write-Host "Features: App removal, taskbar button, hardware key remap" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        # Remove Copilot app packages
        Write-Host "  Removing Copilot app packages..." -ForegroundColor Gray
        
        $copilotRemoved = $false
        
        # Current user
        $copilotPackages = Get-AppxPackage -Name "*Copilot*" -ErrorAction SilentlyContinue
        foreach ($package in $copilotPackages) {
            Remove-AppxPackage -Package $package.PackageFullName -ErrorAction SilentlyContinue
            $copilotRemoved = $true
        }
        
        # All users
        $copilotAllUsers = Get-AppxPackage -AllUsers -Name "*Copilot*" -ErrorAction SilentlyContinue
        foreach ($package in $copilotAllUsers) {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            $copilotRemoved = $true
        }
        
        # Provisioned packages
        $provisionedCopilot = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*Copilot*" }
        foreach ($package in $provisionedCopilot) {
            Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction SilentlyContinue | Out-Null
            $copilotRemoved = $true
        }
        
        # Registry policies
        $paths = @(
            @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "TurnOffWindowsCopilot"; Value = 1},
            @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; Name = "TurnOffWindowsCopilot"; Value = 1},
            @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; Name = "ShowCopilotButton"; Value = 0},
            @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; Name = "DisableWindowsCopilot"; Value = 1},
            @{Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; Name = "TurnOffWindowsCopilot"; Value = 1},
            @{Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; Name = "ShowCopilotButton"; Value = 0}
        )
        
        foreach ($item in $paths) {
            if (-not (Test-Path $item.Path)) {
                New-Item -Path $item.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -Type DWord -Force
        }
        
        # Remap hardware Copilot key to Notepad
        $aiPathHKCU = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"
        if (-not (Test-Path $aiPathHKCU)) {
            New-Item -Path $aiPathHKCU -Force | Out-Null
        }
        Set-ItemProperty -Path $aiPathHKCU -Name "SetCopilotHardwareKey" -Value "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Type String -Force
        
        Write-Host "`nWindows Copilot Disabled Successfully!" -ForegroundColor Green
        if ($copilotRemoved) {
            Write-Host "  App packages removed" -ForegroundColor Gray
        }
        Write-Host "  Policies applied" -ForegroundColor Gray
        Write-Host "  Hardware key remapped to Notepad" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Copilot: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 2. Disable Advanced Copilot Features
# ============================================================================
Write-Host "[2/10] Disable Advanced Copilot Features" -ForegroundColor Yellow
Write-Host "Features: Recall export, URI handlers, Edge sidebar" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        # Recall export block
        $aiPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        if (-not (Test-Path $aiPolicyPath)) {
            New-Item -Path $aiPolicyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $aiPolicyPath -Name "AllowRecallExport" -Value 0 -Type DWord -Force
        
        # Block URI handlers
        $uriHandlers = @("ms-copilot", "ms-edge-copilot")
        foreach ($handler in $uriHandlers) {
            $handlerPath = "Registry::HKEY_CLASSES_ROOT\$handler"
            if (Test-Path $handlerPath) {
                $backupPath = "Registry::HKEY_CLASSES_ROOT\${handler}_DISABLED_BY_ANTIUI"
                if (-not (Test-Path $backupPath)) {
                    Remove-Item -Path $handlerPath -Recurse -Force -ErrorAction SilentlyContinue
                    New-Item -Path $backupPath -Force -ErrorAction SilentlyContinue | Out-Null
                }
            }
        }
        
        # Edge Copilot sidebar
        $edgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
        if (-not (Test-Path $edgePolicyPath)) {
            New-Item -Path $edgePolicyPath -Force | Out-Null
        }
        
        $edgePolicies = @("EdgeSidebarEnabled", "ShowHubsSidebar", "HubsSidebarEnabled", "CopilotPageContext", "CopilotCDPPageContext")
        foreach ($policy in $edgePolicies) {
            Set-ItemProperty -Path $edgePolicyPath -Name $policy -Value 0 -Type DWord -Force
        }
        
        Write-Host "`nAdvanced Copilot Features Disabled Successfully!" -ForegroundColor Green
        Write-Host "  Recall export blocked" -ForegroundColor Gray
        Write-Host "  URI handlers blocked" -ForegroundColor Gray
        Write-Host "  Edge sidebar disabled" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable advanced Copilot features: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 3. Disable Windows Recall
# ============================================================================
Write-Host "[3/10] Disable Windows Recall" -ForegroundColor Yellow
Write-Host "Features: Component removal, snapshot deletion, data providers" -ForegroundColor Gray
Write-Host "WARNING: Requires system reboot!" -ForegroundColor Red
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $devicePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        $userPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        
        if (-not (Test-Path $devicePath)) {
            New-Item -Path $devicePath -Force | Out-Null
        }
        if (-not (Test-Path $userPath)) {
            New-Item -Path $userPath -Force | Out-Null
        }
        
        # Device-scope policies
        Set-ItemProperty -Path $devicePath -Name "AllowRecallEnablement" -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $devicePath -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force
        
        # User-scope policies
        Set-ItemProperty -Path $userPath -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $userPath -Name "DisableRecallDataProviders" -Value 1 -Type DWord -Force
        
        Write-Host "`nWindows Recall Disabled Successfully!" -ForegroundColor Green
        Write-Host "  Component will be removed on reboot" -ForegroundColor Gray
        Write-Host "  Existing snapshots will be deleted on reboot" -ForegroundColor Gray
        Write-Host "  Data providers disabled" -ForegroundColor Gray
        Write-Host ""
        Write-Host "IMPORTANT: REBOOT REQUIRED!" -ForegroundColor Yellow
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Recall: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 4. Set Recall Protection (App/URI Deny Lists)
# ============================================================================
Write-Host "[4/10] Set Recall Protection" -ForegroundColor Yellow
Write-Host "Features: App deny list, URI deny list, storage limits" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        # App deny list
        $denyApps = @(
            "Microsoft.MicrosoftEdge_8wekyb3d8bbwe!App",
            "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App",
            "KeePassXC_8wekyb3d8bbwe!KeePassXC",
            "Microsoft.RemoteDesktop_8wekyb3d8bbwe!App"
        )
        Set-ItemProperty -Path $regPath -Name "SetDenyAppListForRecall" -Value $denyApps -Type MultiString -Force
        
        # URI deny list
        $denyUris = @("*.bank.*", "*.paypal.*", "mail.*", "webmail.*", "*password*", "*login*")
        Set-ItemProperty -Path $regPath -Name "SetDenyUriListForRecall" -Value $denyUris -Type MultiString -Force
        
        # Storage limits
        Set-ItemProperty -Path $regPath -Name "SetMaximumStorageDurationForRecallSnapshots" -Value 30 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "SetMaximumStorageSpaceForRecallSnapshots" -Value 10 -Type DWord -Force
        
        Write-Host "`nRecall Protection Applied Successfully!" -ForegroundColor Green
        Write-Host "  Critical apps protected (Edge, Terminal, RDP, Password managers)" -ForegroundColor Gray
        Write-Host "  Sensitive URLs protected (Banking, Email, Login pages)" -ForegroundColor Gray
        Write-Host "  Storage limited to 30 days / 10 GB" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to set Recall protection: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 5. Click to Do
# ============================================================================
Write-Host "[5/10] Disable Click to Do" -ForegroundColor Yellow
Write-Host "Features: Screenshot AI analysis and action suggestions" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $devicePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        $userPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        
        if (-not (Test-Path $devicePath)) {
            New-Item -Path $devicePath -Force | Out-Null
        }
        if (-not (Test-Path $userPath)) {
            New-Item -Path $userPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $devicePath -Name "DisableClickToDo" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $userPath -Name "DisableClickToDo" -Value 1 -Type DWord -Force
        
        Write-Host "`nClick to Do Disabled Successfully!" -ForegroundColor Green
        Write-Host "  Screenshot AI analysis disabled" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Click to Do: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 6. Disable File Explorer AI Actions
# ============================================================================
Write-Host "[6/10] Disable File Explorer AI Actions" -ForegroundColor Yellow
Write-Host "Features: AI context menu in File Explorer" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "HideAIActionsMenu" -Value 1 -Type DWord -Force
        
        Write-Host "`nFile Explorer AI Actions Disabled Successfully!" -ForegroundColor Green
        Write-Host "  AI Actions menu hidden from context menu" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Explorer AI Actions: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 7. Disable Notepad AI
# ============================================================================
Write-Host "[7/10] Disable Notepad AI" -ForegroundColor Yellow
Write-Host "Features: Write, Summarize, Rewrite, Explain" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\WindowsNotepad"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "DisableAIFeatures" -Value 1 -Type DWord -Force
        
        Write-Host "`nNotepad AI Disabled Successfully!" -ForegroundColor Green
        Write-Host "  All AI features disabled (Write/Summarize/Rewrite/Explain)" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Notepad AI: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 8. Disable Paint AI
# ============================================================================
Write-Host "[8/10] Disable Paint AI" -ForegroundColor Yellow
Write-Host "Features: Cocreator, Generative Fill, Image Creator" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "DisableCocreator" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "DisableGenerativeFill" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "DisableImageCreator" -Value 1 -Type DWord -Force
        
        Write-Host "`nPaint AI Disabled Successfully!" -ForegroundColor Green
        Write-Host "  Cocreator disabled" -ForegroundColor Gray
        Write-Host "  Generative Fill disabled" -ForegroundColor Gray
        Write-Host "  Image Creator disabled" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Paint AI: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 9. Disable Settings Agent
# ============================================================================
Write-Host "[9/10] Disable Settings Agent" -ForegroundColor Yellow
Write-Host "Features: AI-powered natural language search in Settings" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "DisableSettingsAgent" -Value 1 -Type DWord -Force
        
        Write-Host "`nSettings Agent Disabled Successfully!" -ForegroundColor Green
        Write-Host "  AI search disabled (fallback to classic search)" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable Settings Agent: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 10. Disable System AI Models (Master Switch)
# ============================================================================
Write-Host "[10/10] Disable System AI Models" -ForegroundColor Yellow
Write-Host "Features: Master switch to block ALL apps from using AI models" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        # AppPrivacy master switch
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "LetAppsAccessSystemAIModels" -Value 2 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "LetAppsAccessGenerativeAI" -Value 2 -Type DWord -Force
        
        # CapabilityAccessManager deny
        $capabilityPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\systemAIModels"
        
        if (-not (Test-Path $capabilityPath)) {
            New-Item -Path $capabilityPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $capabilityPath -Name "Value" -Value "Deny" -Type String -Force
        
        Write-Host "`nSystem AI Models Disabled Successfully!" -ForegroundColor Green
        Write-Host "  Master switch set to Force Deny" -ForegroundColor Gray
        Write-Host "  Blocks: Notepad, Paint, Photos, Clipchamp, Snipping Tool AI" -ForegroundColor Gray
        Write-Host "  All future AI apps blocked automatically" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable System AI Models: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Anti-AI Configuration Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "All selected AI features have been disabled." -ForegroundColor Green
Write-Host "Your privacy is now better protected!" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host "  - If you disabled Recall, a system reboot is required" -ForegroundColor Gray
Write-Host "  - Some changes take effect immediately" -ForegroundColor Gray
Write-Host "  - Cloud data collection has been reduced" -ForegroundColor Gray
Write-Host "AI Policies applied successfully!" -ForegroundColor Green
Start-Sleep -Seconds 3

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Anti-AI Configuration Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalChecks = 0
$passedChecks = 0
$failedChecks = 0

# Helper function to check registry value
function Test-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $ExpectedValue,
        [string]$Description
    )
    
    $script:totalChecks++
    
    try {
        if (-not (Test-Path $Path)) {
            Write-Host "   FAIL: $Description" -ForegroundColor Red
            Write-Host "     Registry path does not exist: $Path" -ForegroundColor Gray
            $script:failedChecks++
            return $false
        }
        
        $value = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
        
        if ($null -eq $value) {
            Write-Host "   FAIL: $Description" -ForegroundColor Red
            Write-Host "     Registry value not set: $Name" -ForegroundColor Gray
            $script:failedChecks++
            return $false
        }
        
        # Handle array comparison
        if ($ExpectedValue -is [array]) {
            $match = $true
            if ($value -is [array]) {
                if ($value.Count -ne $ExpectedValue.Count) {
                    $match = $false
                }
            } else {
                $match = $false
            }
            
            if ($match) {
                Write-Host "   PASS: $Description" -ForegroundColor Green
                $script:passedChecks++
                return $true
            } else {
                Write-Host "   FAIL: $Description" -ForegroundColor Red
                Write-Host "     Expected array, got: $value" -ForegroundColor Gray
                $script:failedChecks++
                return $false
            }
        }
        
        # Standard value comparison
        if ($value -eq $ExpectedValue) {
            Write-Host "   PASS: $Description" -ForegroundColor Green
            $script:passedChecks++
            return $true
        } else {
            Write-Host "   FAIL: $Description" -ForegroundColor Red
            Write-Host "     Expected: $ExpectedValue, Got: $value" -ForegroundColor Gray
            $script:failedChecks++
            return $false
        }
    }
    catch {
        Write-Host "   FAIL: $Description" -ForegroundColor Red
        Write-Host "     Error: $_" -ForegroundColor Gray
        $script:failedChecks++
        return $false
    }
}

function Start-Trusted([String]$command) {

    try {
        Stop-Service -Name TrustedInstaller -Force -ErrorAction Stop -WarningAction Stop
    }
    catch {
        taskkill /im trustedinstaller.exe /f >$null
    }
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='TrustedInstaller'"
    $DefaultBinPath = $service.PathName
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    $base64Command = [Convert]::ToBase64String($bytes)
    sc.exe config TrustedInstaller binPath= "cmd.exe /c powershell.exe -encodedcommand $base64Command" | Out-Null
    sc.exe start TrustedInstaller | Out-Null
    sc.exe config TrustedInstaller binpath= "`"$DefaultBinPath`"" | Out-Null
    try {
        Stop-Service -Name TrustedInstaller -Force -ErrorAction Stop -WarningAction Stop
    }
    catch {
        taskkill /im trustedinstaller.exe /f >$null
    }
    
}

function Write-Status {
    param(
        [string]$msg,
        [bool]$errorOutput = $false
    )
    if ($errorOutput) {
        Write-Host "[ ! ] $msg" -ForegroundColor Red
    }
    else {
        Write-Host "[ + ] $msg" -ForegroundColor Cyan
    }
   
    
}

  Write-Status -msg 'Disabling Copilot and Recall...'
  $hives = @('HKLM', 'HKCU')
  foreach ($hive in $hives) {
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v 'TurnOffWindowsCopilot' /t REG_DWORD /d '1' /f *>$null
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableAIDataAnalysis' /t REG_DWORD /d '1' /f *>$null
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'AllowRecallEnablement' /t REG_DWORD /d '0' /f *>$null
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableClickToDo' /t REG_DWORD /d '1' /f *>$null
  }
  Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'ShowCopilotButton' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKCU\Software\Microsoft\input\Settings' /v 'InsightsEnabled' /t REG_DWORD /d '0' /f *>$null
  Write-Status -msg 'Disabling Copilot In Windows Search...'
  Reg.exe add 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer' /v 'DisableSearchBoxSuggestions' /t REG_DWORD /d '1' /f *>$null
  Write-Status -msg 'Disabling Copilot In Edge...'
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotCDPPageContext' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotPageContext' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'HubsSidebarEnabled' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat' /v 'IsUserEligible' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKCU\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat' /v 'IsUserEligible' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings' /v 'AutoOpenCopilotLargeScreens' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\generativeAI' /v 'Value' /t REG_SZ /d 'Deny' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' /v 'LetAppsAccessGenerativeAI' /t REG_DWORD /d '2' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' /v 'LetAppsAccessSystemAIModels' /t REG_DWORD /d '2' /f *>$null
  Write-Status -msg 'Disabling Image Creator In Paint...'
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'Behavior' /t REG_DWORD /d '1056800' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'highrange' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'lowrange' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'mergealgorithm' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'policytype' /t REG_DWORD /d '4' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'RegKeyPathRedirect' /t REG_SZ /d 'Software\Microsoft\Windows\CurrentVersion\Policies\Paint' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'RegValueNameRedirect' /t REG_SZ /d 'DisableImageCreator' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'value' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableImageCreator' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableCocreator' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableGenerativeFill' /t REG_DWORD /d '1' /f *>$null
  Write-Status -msg 'Applying Registry Changes...'
  gpupdate /force >$null

  Write-Status -msg 'Removing Copilot Nudges Registry Keys...'
  $keys = @(
      'registry::HKCR\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.wwa',
      'registry::HKCR\Extensions\ContractId\Windows.Launch\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.wwa',
      'registry::HKCR\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\Applications\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
      'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\Applications\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
      'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
      'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.wwa',
      'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.mca',
      'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.Launch\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.wwa'
  )
  $fullkey = @()
  foreach ($key in $keys) {
      try {
          $fullKey = Get-Item -Path $key -ErrorAction Stop
          if ($null -eq $fullkey) { continue }
          if ($fullkey.Length -gt 1) {
              foreach ($multikey in $fullkey) {
                  $command = "Remove-Item -Path `"registry::$multikey`" -Force -Recurse"
                  Start-Trusted -command $command
                  Start-Sleep 1
                  Remove-Item -Path "registry::$multikey" -Force -Recurse -ErrorAction SilentlyContinue
              }
          }
          else {
              $command = "Remove-Item -Path `"registry::$fullKey`" -Force -Recurse"
              Start-Trusted -command $command
              Start-Sleep 1
              Remove-Item -Path "registry::$fullKey" -Force -Recurse -ErrorAction SilentlyContinue
          }
          
      }
      catch {
          continue
      }
  }
  $JSONPath = "$env:windir\System32\IntegratedServicesRegionPolicySet.json"
  if (Test-Path $JSONPath) {
      Write-Host 'Disabling CoPilot Policies in ' -NoNewline
      Write-Host "[$JSONPath]" -ForegroundColor Yellow
  
      takeown /f $JSONPath *>$null
      icacls $JSONPath /grant administrators:F /t *>$null
  
      $jsonContent = Get-Content $JSONPath | ConvertFrom-Json
      try {
          $copilotPolicies = $jsonContent.policies | Where-Object { $_.'$comment' -like '*CoPilot*' }
          foreach ($policies in $copilotPolicies) {
              $policies.defaultState = 'disabled'
          }
          $newJSONContent = $jsonContent | ConvertTo-Json -Depth 100
          Set-Content $JSONPath -Value $newJSONContent -Force
          Write-Status -msg "$($copilotPolicies.count) CoPilot Policies Disabled"
      }
      catch {
          Write-Status -msg 'CoPilot Not Found in IntegratedServicesRegionPolicySet' -errorOutput $true
      }
  
      
  }
  $packageRemovalPath = "$env:TEMP\aiPackageRemoval.ps1"
  if (!(test-path $packageRemovalPath)) {
      New-Item $packageRemovalPath -Force | Out-Null
  }
  $aipackages = @(
      'MicrosoftWindows.Client.Photon'
      'MicrosoftWindows.Client.AIX'
      'MicrosoftWindows.Client.CoPilot'
      'Microsoft.Windows.Ai.Copilot.Provider'
      'Microsoft.Copilot'
      'Microsoft.MicrosoftOfficeHub'
      'MicrosoftWindows.Client.CoreAI'
  )
  
$code = @'
$aipackages = @(
    'MicrosoftWindows.Client.Photon'
    'MicrosoftWindows.Client.AIX'
    'MicrosoftWindows.Client.CoPilot'
    'Microsoft.Windows.Ai.Copilot.Provider'
    'Microsoft.Copilot'
    'Microsoft.MicrosoftOfficeHub'
    'MicrosoftWindows.Client.CoreAI'
)

$provisioned = get-appxprovisionedpackage -online 
$appxpackage = get-appxpackage -allusers
$eol = @()
$store = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
$users = @('S-1-5-18'); if (test-path $store) { $users += $((Get-ChildItem $store -ea 0 | Where-Object { $_ -like '*S-1-5-21*' }).PSChildName) }

foreach ($choice in $aipackages) {
    foreach ($appx in $($provisioned | Where-Object { $_.PackageName -like "*$choice*" })) {

        $PackageName = $appx.PackageName 
        $PackageFamilyName = ($appxpackage | Where-Object { $_.Name -eq $appx.DisplayName }).PackageFamilyName

        New-Item "$store\Deprovisioned\$PackageFamilyName" -force
     
        Set-NonRemovableAppsPolicy -Online -PackageFamilyName $PackageFamilyName -NonRemovable 0
       
        foreach ($sid in $users) { 
            New-Item "$store\EndOfLife\$sid\$PackageName" -force
        }  
        $eol += $PackageName
        remove-appxprovisionedpackage -packagename $PackageName -online -allusers
    }
    foreach ($appx in $($appxpackage | Where-Object { $_.PackageFullName -like "*$choice*" })) {

        $PackageFullName = $appx.PackageFullName
        $PackageFamilyName = $appx.PackageFamilyName
        New-Item "$store\Deprovisioned\$PackageFamilyName" -force
        
        Set-NonRemovableAppsPolicy -Online -PackageFamilyName $PackageFamilyName -NonRemovable 0
       
        $inboxApp = "$store\InboxApplications\$PackageFullName"
        Remove-Item -Path $inboxApp -Force
       
        # Get all installed user sids for package due to not all showing up in reg
        foreach ($user in $appx.PackageUserInformation) { 
            $sid = $user.UserSecurityID.SID
            if ($users -notcontains $sid) {
                $users += $sid
            }
            New-Item "$store\EndOfLife\$sid\$PackageFullName" -force
            remove-appxpackage -package $PackageFullName -User $sid 
        } 
        $eol += $PackageFullName
        remove-appxpackage -package $PackageFullName -allusers
    }
}
'@
  Set-Content -Path $packageRemovalPath -Value $code -Force 
  try {
      Set-ExecutionPolicy Unrestricted -Force -ErrorAction Stop
  }
  catch {
      $ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Name 'ExecutionPolicy' -ErrorAction SilentlyContinue
      Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'EnableScripts' /t REG_DWORD /d '1' /f >$null
      Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
  }


  Write-Status -msg 'Removing AI Appx Packages...'
  $command = "&$env:TEMP\aiPackageRemoval.ps1"
  Start-Trusted -command $command
  
  do {
      Start-Sleep 1
      $packages = get-appxpackage -AllUsers | Where-Object { $aipackages -contains $_.Name }
      foreach ($package in $packages) {
          if ($package.PackageUserInformation -like '*pending removal*') {
              $ProgressPreference = 'SilentlyContinue'
              &$env:TEMP\aiPackageRemoval.ps1 *>$null
          }
      }
      
  }while ($packages)
  
  Write-Status -msg 'Packages Removed Sucessfully...'
  Remove-Item $packageRemovalPath -Force
  if ($ogExecutionPolicy) {
      Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d $ogExecutionPolicy /f >$null
  }
  
  $eolPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife'
  $eolKeys = (Get-ChildItem $eolPath).Name
  foreach ($path in $eolKeys) {
      Remove-Item "registry::$path" -Recurse -Force -ErrorAction SilentlyContinue
  }

  $ProgressPreference = 'SilentlyContinue'
  try {
      Write-Status -msg 'Removing Recall Optional Feature...'
      Disable-WindowsOptionalFeature -Online -FeatureName 'Recall' -Remove -NoRestart -ErrorAction Stop *>$null
  }
  catch {
      
  }
  Write-Status -msg 'Removing Appx Package Files...'
  $appsPath = 'C:\Windows\SystemApps'
  $appsPath2 = 'C:\Program Files\WindowsApps'
  $pathsSystemApps = (Get-ChildItem -Path $appsPath -Directory -Force).FullName 
  $pathsWindowsApps = (Get-ChildItem -Path $appsPath2 -Directory -Force).FullName 

  $packagesPath = @()
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
      if ($path -like '*Photon*') {
          $command = "`$dlls = (Get-ChildItem -Path $Path -Filter *.dll).FullName; foreach(`$dll in `$dlls){Remove-item ""`$dll"" -force}"
          Start-Trusted -command $command
          Start-Sleep 1
      }
      else {
          $command = "Remove-item ""$Path"" -force -recurse"
          Start-Trusted -command $command
          Start-Sleep 1
      }
  }

  Write-Status -msg 'Removing Hidden Copilot Installers...'
  $dir = "${env:ProgramFiles(x86)}\Microsoft"
  $folders = @(
      'Edge',
      'EdgeCore',
      'EdgeWebView'
  )
  foreach ($folder in $folders) {
      if ($folder -eq 'EdgeCore') {
          $fullPath = (Get-ChildItem -Path "$dir\$folder\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
          
      }
      else {
          $fullPath = (Get-ChildItem -Path "$dir\$folder\Application\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
      }
      if ($fullPath -ne $null) { Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue }
  }

  $inboxapps = 'C:\Windows\InboxApps'
  $installers = Get-ChildItem -Path $inboxapps -Filter '*Copilot*'
  foreach ($installer in $installers) {
      takeown /f $installer.FullName *>$null
      icacls $installer.FullName /grant administrators:F /t *>$null
      try {
          Remove-Item -Path $installer.FullName -Force -ErrorAction Stop
      }
      catch {
          $command = "Remove-Item -Path $($installer.FullName) -Force"
          Start-Trusted -command $command 
      }
      
  }

  Write-Status -msg 'Hiding Ai Components in Settings...'
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v 'SettingsPageVisibility' /t REG_SZ /d 'hide:aicomponents;' /f >$null
  
  Write-Status -msg 'Disabling Rewrite Ai Feature for Notepad...'
  reg load HKU\TEMP "$env:LOCALAPPDATA\Packages\Microsoft.WindowsNotepad_8wekyb3d8bbwe\Settings\settings.dat" >$null
$regContent = @'
Windows Registry Editor Version 5.00

[HKEY_USERS\TEMP\LocalState]
"RewriteEnabled"=hex(5f5e10b):00,e0,d1,c5,7f,ee,83,db,01
'@
  New-Item "$env:TEMP\DisableRewrite.reg" -Value $regContent -Force | Out-Null
  regedit.exe /s "$env:TEMP\DisableRewrite.reg"
  Start-Sleep 1
  reg unload HKU\TEMP >$null
  Remove-Item "$env:TEMP\DisableRewrite.reg" -Force -ErrorAction SilentlyContinue
  Reg.exe add 'HKLM\SOFTWARE\Policies\WindowsNotepad' /v 'DisableAIFeatures' /t REG_DWORD /d '1' /f *>$null
  
  Write-Status -msg 'Removing Any Screenshots By Recall...'
  Remove-Item -Path "$env:LOCALAPPDATA\CoreAIPlatform*" -Force -Recurse -ErrorAction SilentlyContinue
  

# ============================================================================
# 1. Windows Copilot
# ============================================================================
Write-Host "[1/10] Checking Windows Copilot..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "TurnOffWindowsCopilot" -ExpectedValue 1 -Description "WindowsAI Copilot disabled (HKLM)"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ExpectedValue 1 -Description "WindowsCopilot disabled (HKLM)"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "ShowCopilotButton" -ExpectedValue 0 -Description "Copilot button hidden (HKLM)"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableWindowsCopilot" -ExpectedValue 1 -Description "Explorer Copilot disabled"
Test-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ExpectedValue 1 -Description "WindowsCopilot disabled (HKCU)"
Test-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "ShowCopilotButton" -ExpectedValue 0 -Description "Copilot button hidden (HKCU)"
Test-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "SetCopilotHardwareKey" -ExpectedValue "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Description "Hardware key remapped to Notepad"

# Check Copilot app packages
$totalChecks++
$copilotPackages = Get-AppxPackage -Name "*Copilot*" -ErrorAction SilentlyContinue
if ($copilotPackages) {
    Write-Host "    WARNING: Copilot app packages still present" -ForegroundColor Yellow
    $failedChecks++
} else {
    Write-Host "   PASS: Copilot app packages removed" -ForegroundColor Green
    $passedChecks++
}

Write-Host ""

# ============================================================================
# 2. Advanced Copilot Features
# ============================================================================
Write-Host "[2/10] Checking Advanced Copilot Features..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "AllowRecallExport" -ExpectedValue 0 -Description "Recall export blocked"

# Check URI handlers
$totalChecks++
$uriBlocked = $true
foreach ($handler in @("ms-copilot", "ms-edge-copilot")) {
    $handlerPath = "Registry::HKEY_CLASSES_ROOT\$handler"
    if (Test-Path $handlerPath) {
        $uriBlocked = $false
        break
    }
}
if ($uriBlocked) {
    Write-Host "   PASS: URI handlers blocked (ms-copilot, ms-edge-copilot)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host "   FAIL: URI handlers still active" -ForegroundColor Red
    $failedChecks++
}

# Edge sidebar
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "EdgeSidebarEnabled" -ExpectedValue 0 -Description "Edge sidebar disabled"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ShowHubsSidebar" -ExpectedValue 0 -Description "Hubs sidebar hidden"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "CopilotPageContext" -ExpectedValue 0 -Description "Copilot page context disabled"

Write-Host ""

# ============================================================================
# 3. Windows Recall
# ============================================================================
Write-Host "[3/10] Checking Windows Recall..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "AllowRecallEnablement" -ExpectedValue 0 -Description "Recall component disabled (requires reboot)"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -ExpectedValue 1 -Description "AI data analysis disabled (HKLM)"
Test-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -ExpectedValue 1 -Description "AI data analysis disabled (HKCU)"
Test-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableRecallDataProviders" -ExpectedValue 1 -Description "Recall data providers disabled"

Write-Host ""

# ============================================================================
# 4. Recall Protection
# ============================================================================
Write-Host "[4/10] Checking Recall Protection..." -ForegroundColor Yellow

# App deny list (just check if exists, not exact content)
$totalChecks++
$appDenyList = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "SetDenyAppListForRecall" -ErrorAction SilentlyContinue).SetDenyAppListForRecall
if ($appDenyList) {
    Write-Host "   PASS: App deny list configured ($($appDenyList.Count) apps)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host "   FAIL: App deny list not configured" -ForegroundColor Red
    $failedChecks++
}

# URI deny list
$totalChecks++
$uriDenyList = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "SetDenyUriListForRecall" -ErrorAction SilentlyContinue).SetDenyUriListForRecall
if ($uriDenyList) {
    Write-Host "   PASS: URI deny list configured ($($uriDenyList.Count) patterns)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host "   FAIL: URI deny list not configured" -ForegroundColor Red
    $failedChecks++
}

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "SetMaximumStorageDurationForRecallSnapshots" -ExpectedValue 30 -Description "Storage duration limit: 30 days"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "SetMaximumStorageSpaceForRecallSnapshots" -ExpectedValue 10 -Description "Storage space limit: 10 GB"

Write-Host ""

# ============================================================================
# 5. Click to Do
# ============================================================================
Write-Host "[5/10] Checking Click to Do..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableClickToDo" -ExpectedValue 1 -Description "Click to Do disabled (HKLM)"
Test-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableClickToDo" -ExpectedValue 1 -Description "Click to Do disabled (HKCU)"

Write-Host ""

# ============================================================================
# 6. File Explorer AI Actions
# ============================================================================
Write-Host "[6/10] Checking File Explorer AI Actions..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideAIActionsMenu" -ExpectedValue 1 -Description "AI Actions menu hidden"

Write-Host ""

# ============================================================================
# 7. Notepad AI
# ============================================================================
Write-Host "[7/10] Checking Notepad AI..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\WindowsNotepad" -Name "DisableAIFeatures" -ExpectedValue 1 -Description "Notepad AI features disabled"

Write-Host ""

# ============================================================================
# 8. Paint AI
# ============================================================================
Write-Host "[8/10] Checking Paint AI..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" -Name "DisableCocreator" -ExpectedValue 1 -Description "Cocreator disabled"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" -Name "DisableGenerativeFill" -ExpectedValue 1 -Description "Generative Fill disabled"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" -Name "DisableImageCreator" -ExpectedValue 1 -Description "Image Creator disabled"

Write-Host ""

# ============================================================================
# 9. Settings Agent
# ============================================================================
Write-Host "[9/10] Checking Settings Agent..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableSettingsAgent" -ExpectedValue 1 -Description "Settings Agent disabled"

Write-Host ""

# ============================================================================
# 10. System AI Models
# ============================================================================
Write-Host "[10/10] Checking System AI Models..." -ForegroundColor Yellow

Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessSystemAIModels" -ExpectedValue 2 -Description "System AI Models access: Force Deny"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessGenerativeAI" -ExpectedValue 2 -Description "Generative AI access: Force Deny"
Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\systemAIModels" -Name "Value" -ExpectedValue "Deny" -Description "CapabilityAccessManager: Deny"

Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Checks:  $totalChecks" -ForegroundColor White
Write-Host "Passed:        $passedChecks" -ForegroundColor Green
Write-Host "Failed:        $failedChecks" -ForegroundColor Red
Write-Host ""

$percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

if ($failedChecks -eq 0) {
    Write-Host " SUCCESS! All Anti-AI settings are properly configured!" -ForegroundColor Green
    Write-Host "   Your system is fully protected (100%)" -ForegroundColor Green
} elseif ($percentage -ge 80) {
    Write-Host "  MOSTLY CONFIGURED ($percentage%)" -ForegroundColor Yellow
    Write-Host "   Most settings are applied, but some failed." -ForegroundColor Yellow
    Write-Host "   Review failed checks above and re-run the configuration script." -ForegroundColor Yellow
} else {
    Write-Host " INCOMPLETE CONFIGURATION ($percentage%)" -ForegroundColor Red
    Write-Host "   Many settings are missing or incorrect." -ForegroundColor Red
    Write-Host "   Please run the Anti-AI Configuration script." -ForegroundColor Red
}

Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Cyan
Write-Host "  - If Recall shows as disabled, reboot is required for full removal" -ForegroundColor Gray
Write-Host "  - Some changes may require restarting affected applications" -ForegroundColor Gray
Write-Host "  - Run this script again after reboot to verify final state" -ForegroundColor Gray
Write-Host ""
Start-Sleep -Seconds 3

}