Write-Host "Enabling advanced stuff..."
  Start-Sleep -Seconds 3
Start-Process cmd.exe /c
# Registry numlock enabled everywhere
reg add "HKU\S-1-5-19\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f $nul
reg add "HKU\S-1-5-20\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f $nul

# Automatic discovery IE11 proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d "3c0000000f0000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d "3c000000040000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f

# Background apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 0 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\1527c705-839a-4832-9118-54d4Bd6a0c89_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\1527c705-839a-4832-9118-54d4Bd6a0c89_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\c5e2524a-ea46-4f67-841f-6a9465d9d515_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\c5e2524a-ea46-4f67-841f-6a9465d9d515_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\E2A4F912-2574-4A75-9BB0-0D023378592B_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\E2A4F912-2574-4A75-9BB0-0D023378592B_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AccountsControl_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AccountsControl_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AsyncTextService_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AsyncTextService_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BioEnrollment_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BioEnrollment_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CredDialogHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CredDialogHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ECApp_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ECApp_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.LockApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.LockApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Win32WebViewHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Win32WebViewHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.AssignedAccessLockApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.AssignedAccessLockApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CapturePicker_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CapturePicker_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkCaptivePortal_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkCaptivePortal_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkConnectionFlow_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkConnectionFlow_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ParentalControls_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ParentalControls_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PinningConfirmationDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PinningConfirmationDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PrintQueueActionCenter_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PrintQueueActionCenter_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Search_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Search_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.XGpuEjectDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.XGpuEjectDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.UndockedDevKit_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.UndockedDevKit_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NcsiUwpApp_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NcsiUwpApp_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.CBSPreview_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.CBSPreview_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.PrintDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.PrintDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_7njy0v32s6xk6" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_7njy0v32s6xk6" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_d9ma7nkbkv4rp" /v "Disabled" /t REG_DWORD /d 1 /f $nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_d9ma7nkbkv4rp" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_s4jet1zx4n14a" /v "Disabled" /t REG_DWORD /d 1 /f $nul
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_s4jet1zx4n14a" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
#
# OneDrive cleaning that comes with office install
reg delete "HKCU\Software\Microsoft\OneDrive" /f $nul
reg delete "HKCU\Software\Microsoft\SkyDrive" /f $nul
reg delete "HKCU\Software\Classes\grvopen" /f $nul
reg delete "HKCU\Environment" /v "OneDrive" /f $nul

reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f $nul
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f $nul

# Search in taskbar 0 = Hidden, 1 = Show search icon, 2 = Show search box
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f $nul
# Change currency "kn" u "EUR"  HR & EN (Croatia)
reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "EUR" /f $nul
# Disable automatic folder type discovery
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d NotSpecified /f $nul
# Registered owner & organization
#reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "RegisteredOrganization" /t REG_SZ /d "(-_-)" /f $nul
#reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "RegisteredOwner" /t REG_SZ /d "Gazda" /f $nul
# Enable DNS over HTTPS (DoH)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d 2 /f $nul
# Remove Auto run Defender
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f $nul
# Disable autologger telemetry: CloudExperienceHostOobe.etl, Cellcore.etl, WinPhoneCritical.etl
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe" /v "Start" /t REG_DWORD /d 0 /f $nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudExperienceHost" /v "ETWLoggingEnabled" /t REG_DWORD /d 0 /f $nul
# Clean Windows from OneDrive (comes with Office installations)
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive1" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive2" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive3" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive4" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive5" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive6" /f $nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive7" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive1" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive2" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive3" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive4" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive5" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive6" /f $nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive7" /f $nul
# Disable updates for microsoft office
schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
schtasks /change /tn "Microsoft\Office\Office Feature Updates Logon" /disable
schtasks /change /tn "Microsoft\Office\Office Feature Updates" /disable
schtasks /change /tn "Microsoft\Office\Office Automatic Updates 2.0" /disable
# Firefox
schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
schtasks /delete /tn "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /f

# Disable activity log and clipboard
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f

# Disable cliboard history
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowClipboardHistory" /t REG_DWORD /d 0 /f

# Disable windows event logging
# Check all policies: auditpol /get /Category:*
auditpol /set /subcategory:"Special Logon" /success:disable
auditpol /set /subcategory:"Audit Policy Change" /success:disable
auditpol /set /subcategory:"User Account Management" /success:disable
# Password never expires
net.exe accounts /maxpwage:unlimited
# Disable telemetry. UnifedTelemetryClient
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
# Defender auto run disabled
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "SecurityHealth" /t REG_EXPAND_SZ /d "%%SystemRoot%%\system32\SecurityHealthSystray.exe" /f
#
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT" /v "Start" /t REG_DWORD /d 3 /f

# Tasks
schtasks /Create /F /RU "SYSTEM" /RL HIGHEST /SC HOURLY /TN PrilagodeniTasks /TR "cmd /c %windir%\PrilagodeniTasks.cmd"
schtasks /Run /I /TN PrilagodeniTasks
timeout /T 5
schtasks /delete /F /TN PrilagodeniTasks

            
                                         
# Register DNS
ipconfig /registerdns
# Disable DNS Functions (LLMNR, Resolution, Devolution, ParallelAandAAAA)
 netsh.exe winhttp reset proxy
# Disable NetBIOS over TCP/IP
#Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.TcpipNetbiosOptions -eq 0 } | ForEach-Object { $_.SetTcpipNetbios(2) }
#Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.TcpipNetbiosOptions -eq 1 } | ForEach-Object { $_.SetTcpipNetbios(2) }
# Disable Teredo
netsh interface teredo set state disabled
# Bootloader
bcdedit /timeout 4
# Force install uncertified drivers
bcdedit /set nointegritychecks off
# Disable hibernation
powercfg -h off
# Disable 8dot3
fsutil behavior set disable8dot3 1
# Disable Bitlocker and encryption
fsutil behavior set disableencryption 1
# Update NTFS "Last Access" (User Managed, Last Access Updates Disabled)
fsutil behavior set disablelastaccess 1
# Increase memory for access NTFS files
fsutil behavior set memoryusage 2
# Disable NET Core CLI telemetry
setx DOTNET_CLI_TELEMETRY_OPTOUT 1
# Disable automatic repair
fsutil repair set c: 0
# Disable tracking IPsec filtera firewall (wfpdiag.etl, Process Hacker omogućuje ovo praćenje)
netsh.exe wfp set options netevents = off
# Passwords never expire
net.exe accounts /maxpwage:unlimited
# regsvr32 /s %SystemRoot%\System32\DolbyDecMFT.dll
# regsvr32 /s %SystemRoot%\SysWOW64\DolbyDecMFT.dll

# Tasks
# schtasks /change /tn "CreateExplorerShellUnelevatedTask" /enable
# schtasks /delete /tn "MicrosoftEdgeUpdateTaskMachineCore" /f
# schtasks /change /tn "Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" /disable
#
# Disable telemtry and diagnostics
schtasks /change /tn "Microsoft\Windows\WDI\ResolutionHost" /disable
schtasks /change /tn "Microsoft\Windows\UNP\RunUpdateNotificationMgr" /disable
schtasks /change /tn "Microsoft\Windows\DUSM\dusmtask" /disable
# Disable tasks extra
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
# Disable task "Cleaning the system drive during idle time"
schtasks /change /tn "Microsoft\Windows\DiskCleanup\SilentCleanup" /disable
# Disable task "Cleaning language parameters"
schtasks /change /tn "Microsoft\Windows\MUI\LPRemove" /disable
# Disable tasks "Maintenance drive spaces (analogue RAID, virtual disks)"
schtasks /change /tn "Microsoft\Windows\SpacePort\SpaceAgentTask" /disable
schtasks /change /tn "Microsoft\Windows\SpacePort\SpaceManagerTask" /disable
# Disable task "Loading voice models"
schtasks /change /tn "Microsoft\Windows\Speech\SpeechModelDownloadTask" /disable
# Disable tasks "Active Directory"
schtasks /change /tn "Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)" /disable
schtasks /change /tn "Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" /disable
# Disable ProvTool.exe tasks (for SYSPREP and change Windows edition)
# Tasks to reconcile packages during SYSPREP and others via "ProvTool.exe":
schtasks /change /tn "Microsoft\Windows\Management\Provisioning\Logon" /disable
schtasks /change /tn "Microsoft\Windows\Management\Provisioning\Cellular" /disable
# Disalbe task for archiving (works only in auto maintenance)
schtasks /change /tn "Microsoft\Windows\FileHistory\File History (maintenance mode)" /disable

# Disable telemetry for Microsoft Office 2016/2019+
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack" /disable
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn" /disable
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack2016" /disable
schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /disable
schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable

# Disable default browser agent reporting services (firefox)
schtasks /change /tn "Mozilla\Firefox Default Browser Agent 308046B0AF4A39CB" /disable
schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
schtasks /change /tn "Mozilla\Firefox Default Browser Agent D2CEEC440E2074BD" /disable

# Deactivate not needed tasks
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical" /disable
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64" /disable
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical" /disable
schtasks /change /tn "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319" /disable

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
# Disable task "CloudExperienceHost"
# schtasks /change /tn "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /disable
#

# schtasks /change /tn "Microsoft\Windows\TextServicesFramework\MsCtfMonitor" /disable
