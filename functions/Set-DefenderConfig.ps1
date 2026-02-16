function Set-DefenderConfig {
    try {
        Clear-Host    
        Write-Host ""
        Write-Host "Enabling and Setting Defender..." -ForegroundColor Cyan
        Start-Sleep -Seconds 3

        # https://www.powershellgallery.com/packages/WindowsDefender_InternalEvaluationSetting
        # https://social.technet.microsoft.com/wiki/contents/articles/52251.manage-windows-defender-using-powershell.aspx
        # https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=windowsserver2019-ps

        $mpPreference = Get-MpPreference
        $mpPreference.DisableRealtimeMonitoring = $false
        $mpPreference.MAPSReporting = "0"
        $mpPreference.SubmitSamplesConsent = "AlwaysPrompt"
        $mpPreference.CheckForSignaturesBeforeRunningScan = 1
        $mpPreference.DisableBehaviorMonitoring = $false
        $mpPreference.DisableIOAVProtection = $false
        $mpPreference.DisableScriptScanning = $false
        $mpPreference.DisableRemovableDriveScanning = $false
        $mpPreference.DisableBlockAtFirstSeen = $false
        $mpPreference.PUAProtection = 1
        $mpPreference.DisableArchiveScanning = $false
        $mpPreference.DisableEmailScanning = $false
        $mpPreference.EnableFileHashComputation = $true
        $mpPreference.DisableIntrusionPreventionSystem = $false
        $mpPreference.DisableSshParsing = $false
        $mpPreference.DisableDnsParsing = $false
        $mpPreference.DisableDnsOverTcpParsing = $false
        $mpPreference.EnableDnsSinkhole = $true
        $mpPreference.EnableControlledFolderAccess = "Enabled"
        $mpPreference.EnableNetworkProtection = "Enabled"
        $mpPreference.MP_FORCE_USE_SANDBOX = 1
        $mpPreference.CloudBlockLevel = "High"
        $mpPreference.CloudExtendedTimeout = 50
        $mpPreference.SignatureDisableUpdateOnStartupWithoutEngine = $false
        $mpPreference.DisableArchiveScanningAlternateDataStream = $false
        $mpPreference.DisableBehaviorMonitoringAlternateDataStream = $false
        $mpPreference.ScanArchiveFilesWithPassword = $true
        $mpPreference.ScanDownloads = 2
        $mpPreference.ScanNetworkFiles = 2
        $mpPreference.ScanIncomingMail = 2
        $mpPreference.ScanMappedNetworkDrivesDuringFullScan = $true
        $mpPreference.ScanRemovableDrivesDuringFullScan = $true
        $mpPreference.ScanScriptsLoadedInInternetExplorer = $true
        $mpPreference.ScanScriptsLoadedInOfficeApplications = $true
        $mpPreference.ScanSubDirectoriesDuringQuickScan = $true
        $mpPreference.ScanRemovableDrivesDuringQuickScan = $true
        $mpPreference.ScanMappedNetworkDrivesDuringQuickScan = $true
        $mpPreference.DisableBehaviorMonitoringMemoryDoubleFree = $false
        $mpPreference.DisableBehaviorMonitoringNonSystemSigned = $false
        $mpPreference.DisableBehaviorMonitoringUnsigned = $false
        $mpPreference.DisableBehaviorMonitoringPowershellScripts = $false
        $mpPreference.DisableBehaviorMonitoringNonMsSigned = $false
        $mpPreference.DisableBehaviorMonitoringNonMsSystem = $false
        $mpPreference.DisableBehaviorMonitoringNonMsSystemProtected = $false
        $mpPreference.EnableControlledFolderAccessMemoryProtection = $true
        $mpPreference.EnableControlledFolderAccessNonScriptableDlls = $true
        $mpPreference.EnableControlledFolderAccessNonMsSigned = $true
        $mpPreference.EnableControlledFolderAccessNonMsSystem = $true
        $mpPreference.EnableControlledFolderAccessNonMsSystemProtected = $true
        $mpPreference.ScanRemovableDriveDuringFullScan = $true
        $mpPreference.ScanNetworkFilesDuringFullScan = $true
        $mpPreference.ScanNetworkFilesDuringQuickScan = $true
        $mpPreference.EnableNetworkProtectionRealtimeInspection = $true
        $mpPreference.EnableNetworkProtectionExploitInspection = $true
        $mpPreference.EnableNetworkProtectionControlledFolderAccessInspection = $true
        $mpPreference.SignatureDisableUpdateOnStartupWithoutEngine = $false
        $mpPreference.SignatureDisableUpdateOnStartupWithoutEngine = $false
        
        Set-MpPreference -PreferenceObject $mpPreference

        Write-Host "Defender preferences set successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to apply Defender preferences: $_" -ForegroundColor Red
    }

      Write-Host "Disabling Account Prompts" -ForegroundColor Cyan
      $accountProtectionKeyPath = "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State\AccountProtection_MicrosoftAccount_Disconnected"

      if (!(Test-Path -Path $accountProtectionKeyPath)) {
          New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -Name "AccountProtection_MicrosoftAccount_Disconnected" -PropertyType DWORD -Value 1 -Force
      } else {
          Set-ItemProperty -Path $accountProtectionKeyPath -Name "AccountProtection_MicrosoftAccount_Disconnected" -Value 1
      }

    Write-Host "Configure Cloud-delivered Protections" -ForegroundColor Cyan
    Set-MpPreference -MAPSReporting 0
    Set-MpPreference -SubmitSamplesConsent AlwaysPrompt
  
}
