function Optimize-AdvancedTweaks {
  Clear-Host
  Start-Sleep -Seconds 3

# Disables telemetry trough gpdedit
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection' /v 'AllowTelemetry' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer' /v 'DisableGraphRecentItems' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' /v 'AllowClipboardHistory' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' /v 'AllowCrossDeviceClipboard' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' /v 'EnableActivityFeed' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' /v 'PublishUserActivities' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' /v 'UploadUserActivities' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' /v 'Enabled' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' /v 'DisabledByGroupPolicy' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' /v 'DontSendAdditionalData' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection' /v 'AllowDeviceNameInTelemetry' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' /v 'DisableCloudOptimizedContent' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' /v 'DisableWindowsConsumerFeatures' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' /v 'AllowTelemetry' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' /v 'MaxTelemetryAllowed' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack' /v 'Start' /t REG_DWORD /d '4' /f
Reg.exe add 'HKLM\System\ControlSet001\Services\dmwappushservice' /v 'Start' /t REG_DWORD /d '4' /f
Reg.exe add 'HKLM\System\ControlSet001\Control\WMI\Autologger\Diagtrack-Listener' /v 'Start' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\Software\Policies\Microsoft\Biometrics' /v 'Enabled' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP' /v 'CEIPEnable' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows' /v 'CEIPEnable' /t REG_DWORD /d '0' /f
Reg.exe add 'HKCU\Control Panel\International\User Profile' /v 'HttpAcceptLanguageOptOut' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\AllowTelemetry' /v 'DefaultValue' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\AllowTelemetry' /v 'Value' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\Software\Policies\Microsoft\Windows\DataCollection' /v 'AllowCommercialDataPipeline' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\Software\Policies\Microsoft\Windows\DataCollection' /v 'LimitEnhancedDiagnosticDataWindowsAnalytics' /t REG_DWORD /d '0' /f
Reg.exe add 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' /v 'TailoredExperiencesWithDiagnosticDataEnabled' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Personalization\Settings' /v 'AcceptedPrivacyPolicy' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth' /v 'AllowAdvertising' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System' /v 'AllowExperimentation' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWiFiSenseHotspots' /v 'value' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWiFiHotSpotReporting' /v 'value' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config' /v 'AutoConnectAllowedOEM' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\WMDRM' /v 'DisableOnline' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' /v 'AITEnable' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' /v 'DisableInventory' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' /v 'DisablePCA' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' /v 'DisablePcaRecording' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' /v 'DisableScriptedDiagnosticLogging' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' /v 'DisableUAR' /t REG_DWORD /d '1' /f
Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\StorPort' /v 'TelemetryDeviceHealthEnabled' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\StorPort' /v 'TelemetryErrorDataEnabled' /t REG_DWORD /d '0' /f
Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\StorPort' /v 'TelemetryPerformanceEnabled' /t REG_DWORD /d '0' /f


Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security' /V 'DisableSecuritySettingsCheck' /T 'REG_DWORD' /D '00000001' /F
Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3' /V '1806' /T 'REG_DWORD' /D '00000000' /F
Reg.exe add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3' /V '1806' /T 'REG_DWORD' /D '00000000' /F
# Disable all the loggers under DiagTrack
$subkeys = Get-ChildItem -Path 'HKLM:\System\ControlSet001\Control\WMI\Autologger\Diagtrack-Listener'
foreach ($subkey in $subkeys) {
  Set-ItemProperty -Path "registry::$($subkey.Name)" -Name 'Enabled' -Value 0 -Force
}

Disable-ScheduledTask -TaskName 'Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser' -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName 'Microsoft\Windows\Application Experience\ProgramDataUpdater' -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName 'Microsoft\Windows\Autochk\Proxy' -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName 'Microsoft\Windows\Customer Experience Improvement Program\Consolidator' -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName 'Microsoft\Windows\Customer Experience Improvement Program\UsbCeip' -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName 'Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector' -ErrorAction SilentlyContinue
gpupdate /force

# Faster shutdowns
Reg.exe add 'HKCU\Control Panel\Desktop' /v 'WaitToKillAppTimeout' /t REG_SZ /d '1500' /f *>$null
Reg.exe add 'HKCU\Control Panel\Desktop' /v 'AutoEndTasks' /t REG_SZ /d '1' /f *>$null
Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control' /v 'WaitToKillServiceTimeout' /t REG_SZ /d '1500' /f *>$null

# Removes Windows Backup app
Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\MicrosoftAccount' /v 'DisableUserAuth' /t REG_DWORD /d '1' /f

  Write-Host 'Showing All Apps on Taskbar' -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer' /v 'EnableAutoTray' /t REG_DWORD /d '0' /f
  $keys = Get-ChildItem -Path 'registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings' -Recurse -Force
  foreach ($key in $keys) {
    Set-ItemProperty -Path "registry::$key" -Name 'IsPromoted' -Value 1 -Force
  }

  $scriptContent = @"
`$keys = Get-ChildItem -Path 'registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings' -Recurse -Force

foreach (`$key in `$keys) {
# If the value is set to 0 do not set it to 1
# Set 1 when no reg key is there (new apps)
if ((Get-ItemProperty -Path "registry::`$key").IsPromoted -eq 0) {
}
else {
    Set-ItemProperty -Path "registry::`$key" -Name 'IsPromoted' -Value 1 -Force
}
}
"@

  $scriptPath = "$env:ProgramData\UpdateTaskTrayIcons.ps1"
  Set-Content -Path $scriptPath -Value $scriptContent -Force

  $currentUserName = $env:COMPUTERNAME + '\' + $env:USERNAME
  $username = Get-LocalUser -Name $env:USERNAME | Select-Object -ExpandProperty sid

  $content = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo>
<Date>2024-05-20T12:59:50.8741407</Date>
<Author>$currentUserName</Author>
<URI>\UpdateTaskTray</URI>
</RegistrationInfo>
<Triggers>
<LogonTrigger>
  <Enabled>true</Enabled>
</LogonTrigger>
</Triggers>
<Principals>
<Principal id="Author">
  <UserId>$username</UserId>
  <LogonType>InteractiveToken</LogonType>
  <RunLevel>HighestAvailable</RunLevel>
</Principal>
</Principals>
<Settings>
<MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
<DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
<StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
<AllowHardTerminate>true</AllowHardTerminate>
<StartWhenAvailable>false</StartWhenAvailable>
<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
<IdleSettings>
  <StopOnIdleEnd>true</StopOnIdleEnd>
  <RestartOnIdle>false</RestartOnIdle>
</IdleSettings>
<AllowStartOnDemand>true</AllowStartOnDemand>
<Enabled>true</Enabled>
<Hidden>false</Hidden>
<RunOnlyIfIdle>false</RunOnlyIfIdle>
<WakeToRun>false</WakeToRun>
<ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
<Priority>7</Priority>
</Settings>
<Actions Context="Author">
<Exec>
  <Command>PowerShell.exe</Command>
  <Arguments>-ExecutionPolicy Bypass -WindowStyle Hidden -File C:\ProgramData\UpdateTaskTrayIcons.ps1</Arguments>
</Exec>
</Actions>
</Task>
"@
  Set-Content -Path "$env:TEMP\UpdateTaskTray" -Value $content -Force

  schtasks /Create /XML "$env:TEMP\UpdateTaskTray" /TN '\UpdateTaskTray' /F | Out-Null 

  Remove-Item -Path "$env:TEMP\UpdateTaskTray" -Force -ErrorAction SilentlyContinue
  Write-Host 'Update Task Tray Created...New Apps Will Be Shown Upon Restarting' -ForegroundColor Green


  $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
  
  if (Test-Path $registryPath) {
      Set-ItemProperty -Path $registryPath -Name "RotatingLockScreenEnabled" -Value 0
      Set-ItemProperty -Path $registryPath -Name "RotatingLockScreenOverlayEnabled" -Value 0
      Set-ItemProperty -Path $registryPath -Name "SubscribedContent-338389Enabled" -Value 0
      Write-Output "'Learn more about this picture' has been disabled for the desktop background."
  } else {
      Write-Output "The registry path for ContentDeliveryManager does not exist."
  }
  
  $registryPathDesktop = "HKCU:\Control Panel\Desktop"
  Set-ItemProperty -Path $registryPathDesktop -Name "Wallpaper" -Value ""
  Set-ItemProperty -Path $registryPathDesktop -Name "WallpaperStyle" -Value 0
  Set-ItemProperty -Path $registryPathDesktop -Name "BackgroundType" -Value 1
  Set-ItemProperty -Path $registryPathDesktop -Name "SingleColor" -Value "000000"
  
  RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters ,1 ,True
  
  Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:USERPROFILE\AppData\Local" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  Remove-Item -Path "$env:SystemDrive\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:SystemDrive\Windows" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

  Clear-Host
  Start-Process cmd.exe /c
  reg add "HKU\S-1-5-19\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f $nul
  reg add "HKU\S-1-5-20\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d "3c0000000f0000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d "3c000000040000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f
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
  reg delete "HKCU\Software\Microsoft\OneDrive" /f $nul
  reg delete "HKCU\Software\Microsoft\SkyDrive" /f $nul
  reg delete "HKCU\Software\Classes\grvopen" /f $nul
  reg delete "HKCU\Environment" /v "OneDrive" /f $nul
  reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f $nul
  reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f $nul
  reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "EUR" /f $nul
  reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d NotSpecified /f $nul
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d 2 /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f $nul
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe" /v "Start" /t REG_DWORD /d 0 /f $nul
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudExperienceHost" /v "ETWLoggingEnabled" /t REG_DWORD /d 0 /f $nul
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
  schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
  schtasks /change /tn "Microsoft\Office\Office Feature Updates Logon" /disable
  schtasks /change /tn "Microsoft\Office\Office Feature Updates" /disable
  schtasks /change /tn "Microsoft\Office\Office Automatic Updates 2.0" /disable
  schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
  schtasks /delete /tn "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /f

  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowClipboardHistory" /t REG_DWORD /d 0 /f
  
  auditpol /set /subcategory:"Special Logon" /success:disable
  auditpol /set /subcategory:"Audit Policy Change" /success:disable
  auditpol /set /subcategory:"User Account Management" /success:disable
  net.exe accounts /maxpwage:unlimited
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemtry" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemtry" /t REG_DWORD /d 0 /f
  reg add "HKCU\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemtry" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "SecurityHealth" /t REG_EXPAND_SZ /d "%%SystemRoot%%\system32\SecurityHealthSystray.exe" /f
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT" /v "Start" /t REG_DWORD /d 3 /f
  
  schtasks /Create /F /RU "SYSTEM" /RL HIGHEST /SC HOURLY /TN PrilagodeniTasks /TR "cmd /c %windir%\PrilagodeniTasks.cmd"
  schtasks /Run /I /TN PrilagodeniTasks
  timeout /T 5
  schtasks /delete /F /TN PrilagodeniTasks

            
                                         
  ipconfig /registerdns
  netsh.exe winhttp reset proxy
  netsh interface teredo set state disabled
  bcdedit /timeout 4
  bcdedit /set nointegritychecks off
  powercfg -h off
  fsutil behavior set disable8dot3 1
  fsutil behavior set disableencryption 1
  fsutil behavior set disablelastaccess 1
  fsutil behavior set memoryusage 2
  setx DOTNET_CLI_TELEMETRY_OPTOUT 1
  fsutil repair set c: 0
  netsh.exe wfp set options netevents = off
  net.exe accounts /maxpwage:unlimited
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" `
        -Name "RealTimeIsUniversal" `
        -Type DWord `
        -Value 1 -Force | Out-Null
    $timeService = Get-Service "W32Time" -ErrorAction SilentlyContinue
    if ($timeService.Status -ne "Running") {
  net start "W32Time" | Out-Null
  w32tm /resync | Out-Null
    }
function Disable-UnnecessaryServices {
    [CmdletBinding()]
    param (
        [string[]]$ServiceList = @(
            # Core services
            "WerSvc",                         # Windows Error Reporting
            "OneSyncSvc",                     # Sync Host
            "PcaSvc",                         # Program Compatibility Assistant
            "MessagingService",               # Messaging
            "RetailDemo",                     # Retail Demo
            "diagnosticshub.standardcollector.service", # Diagnostics Hub
            "lfsvc",                          # Geolocation Service
            "AJRouter",                       # AllJoyn Router
            "RemoteRegistry",                 # Remote Registry
            "DUSMsvc",                        # Data Usage
            "DiagTrack",                      # Telemetry
            "MapsBroker",                     # Downloaded Maps Manager

            # Xbox-related
            "XblAuthManager",
            "XblGameSave",
            "XboxNetApiSvc",
            "XboxGipSvc"
        )
    )
  Clear-Host 
  Write-Host "Disabling unnecessary services..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$ts - Beginning service deactivation ritual..." -ForegroundColor Cyan
    Write-Host ""

    foreach ($svc in $ServiceList) {
        try {
            Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
            Write-Host "$ts - Disabled service: $svc" -ForegroundColor Green
        } catch {
            Write-Host "$ts - Could not disable $svc. Error: $_" -ForegroundColor Red
        }
      }
    }


function Disable-UnwantedScheduledTasks {
    [CmdletBinding()]
    param (
        [string[]]$TaskList = @(
            # User experiences, telemetry, etc.
            "Microsoft\Windows\AppID\SmartScreenSpecific",
            "Microsoft\Windows\Application Experience\AitAgent",
            "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
            "Microsoft\Windows\Application Experience\ProgramDataUpdater",
            "Microsoft\Windows\Application Experience\StartupAppTask",
            "Microsoft\Windows\Autochk\Proxy",
            "Microsoft\Windows\CloudExperienceHost\CreateObjectTask",
            "Microsoft\Windows\Customer Experience Improvement Program\BthSQM",
            "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
            "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
            "Microsoft\Windows\Customer Experience Improvement Program\Uploader",
            "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
            "Microsoft\Windows\Maintenance\WinSAT",
            "Microsoft\Windows\PI\Sqm-Tasks",

            # Family Safety and phantom parental controls
            "Microsoft\Windows\Shell\FamilySafetyMonitor",
            "Microsoft\Windows\Shell\FamilySafetyRefresh",
            "Microsoft\Windows\Shell\FamilySafetyUpload",
            "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask",
            "Microsoft\Windows\Shell\FamilySafetyRefreshTask",

            # App update & Microsoft Maps
            "Microsoft\Windows\WindowsUpdate\Automatic App Update",
            "Microsoft\Windows\NetTrace\GatherNetworkInfo",
            "Microsoft\Windows\Maps\MapsUpdateTask",
            "Microsoft\Windows\Maps\MapsToastTask",

            # Xbox GameSave
            "Microsoft\XblGameSave\XblGameSaveTask",
            "Microsoft\XblGameSave\XblGameSaveTaskLogon"
        )
    )
    
    
    function Run-Trusted([String]$command) {

  try {
    Stop-Service -Name TrustedInstaller -Force -ErrorAction Stop -WarningAction Stop
  }
  catch {
    taskkill /im trustedinstaller.exe /f >$null
  }
  $service = Get-WmiObject -Class Win32_Service -Filter "Name='TrustedInstaller'"
  $DefaultBinPath = $service.PathName
  $trustedInstallerPath = "$env:SystemRoot\servicing\TrustedInstaller.exe"
  if ($DefaultBinPath -ne $trustedInstallerPath) {
    $DefaultBinPath = $trustedInstallerPath
  }
  # Convert command to base64 to avoid errors with spaces
  $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
  $base64Command = [Convert]::ToBase64String($bytes)
  # Change bin to command
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


Write-Host "Disabling Bluetooth, Printing and other services..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\BTAGService' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\BthAvctpSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\bthserv' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\BluetoothUserService' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\Fax' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\Spooler' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\PrintWorkflowUserSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\PrintNotify' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\shpamsvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\RemoteRegistry' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\PhoneSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\defragsvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\DoSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\RmSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\wisvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\TabletInputService' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\diagsvc' /v 'Start' /t REG_DWORD /d '4' /f
      $command = "Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\DPS' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\WdiServiceHost' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\WdiSystemHost' /v 'Start' /t REG_DWORD /d '4' /f"
      Run-Trusted -command $command
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\AssignedAccessManagerSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\MapsBroker' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\lfsvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\Netlogon' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\WpcMonSvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\SCardSvr' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\ScDeviceEnum' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\SCPolicySvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\WalletService' /v 'Start' /t REG_DWORD /d '4' /f
      Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\whesvc' /v 'Start' /t REG_DWORD /d '4' /f

  Clear-Host 
  Write-Host "Disabling unnecessary scheduled tasks..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$ts - Beginning scheduled task deactivation..." -ForegroundColor Cyan
    Write-Host ""

    foreach ($task in $TaskList) {
        try {
            schtasks /Change /TN "$task" /Disable | Out-Null
            Write-Host "$ts - Disabled task: $task" -ForegroundColor Green
        } catch {
            Write-Host "$ts - Could not disable task: $task. Error: $_" -ForegroundColor Red
        }
    }
  }

function Remove-BloatwarePackages {

  [CmdletBinding()]
  param(
    [Parameter()]
    [string[]]$AppsList = @(
      "Microsoft.GetHelp","Microsoft.People","Microsoft.YourPhone","Microsoft.GetStarted",
      "Microsoft.Messaging","Microsoft.MicrosoftSolitaireCollection","Microsoft.ZuneMusic",
      "Microsoft.ZuneVideo","Microsoft.Office.OneNote","Microsoft.OneConnect","Microsoft.SkypeApp",
      "Microsoft.CommsPhone","Microsoft.Office.Sway","Microsoft.WindowsFeedbackHub",
      "Microsoft.ConnectivityStore","Microsoft.BingFoodAndDrink","Microsoft.BingHealthAndFitness",
      "Microsoft.BingTravel","Microsoft.WindowsReadingList","DB6EA5DB.MediaSuiteEssentialsforDell",
      "DB6EA5DB.Power2GoforDell","DB6EA5DB.PowerDirectorforDell","DB6EA5DB.PowerMediaPlayerforDell",
      "DellInc.DellDigitalDelivery","*Disney*","*EclipseManager*","*ActiproSoftwareLLC*",
      "*AdobeSystemsIncorporated.AdobePhotoshopExpress*","*Duolingo-LearnLanguagesforFree*",
      "*PandoraMediaInc*","*CandyCrush*","*BubbleWitch3Saga*","*Wunderlist*","*Flipboard*",
      "*Royal Revolt*","*Sway*","*Speed Test*","46928bounde.EclipseManager",
      "613EBCEA.PolarrPhotoEditorAcademicEdition","7EE7776C.LinkedInforWindows",
      "89006A2E.AutodeskSketchBook","ActiproSoftwareLLC.562882FEEB491","CAF9E577.Plex",
      "ClearChannelRadioDigital.iHeartRadio","Drawboard.DrawboardPDF","Fitbit.FitbitCoach",
      "Flipboard.Flipboard","KeeperSecurityInc.Keeper","Microsoft.BingNews",
      "TheNewYorkTimes.NYTCrossword","WinZipComputing.WinZipUniversal","A278AB0D.MarchofEmpires",
      "6Wunderkinder.Wunderlist","A278AB0D.DisneyMagicKingdoms","2FE3CB00.PicsArt-PhotoStudio",
      "D52A8D61.FarmVille2CountryEscape","D5EA27B7.Duolingo-LearnLanguagesforFree",
      "DB6EA5DB.CyberLinkMediaSuiteEssentials","GAMELOFTSA.Asphalt8Airborne",
      "NORDCURRENT.COOKINGFEVER","PandoraMediaInc.29680B314EFC2","Playtika.CaesarsSlotsFreeCasino",
      "ShazamEntertainmentLtd.Shazam","ThumbmunkeysLtd.PhototasticCollage","TuneIn.TuneInRadio",
      "XINGAG.XING","flaregamesGmbH.RoyalRevolt2","king.com.*","king.com.BubbleWitch3Saga",
      "king.com.CandyCrushSaga","king.com.CandyCrushSodaSaga"
    )
  )
  Clear-Host 
  Write-Host "Removing packages..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "$ts - Initiating interstellar purge of Windows bloatware..." -ForegroundColor Cyan
  Write-Host ""

  foreach ($App in $AppsList) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $PackageFullName = (Get-AppxPackage -Name $App -ErrorAction SilentlyContinue).PackageFullName
    $ProPackageFullName = (Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App }).PackageName

    if ($PackageFullName) {
      Write-Host "$ts - Removing installed bloatware package: $App" -ForegroundColor Cyan
      try {
        Remove-AppxPackage -Package $PackageFullName -ErrorAction Stop | Out-Null
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$ts - Package '$App' removed from user profile." -ForegroundColor Green
      }
      catch {
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$ts - Failed to remove '$App': $_" -ForegroundColor Red
      }
    }
    else {
      Write-Host "$ts - Installed package not found: $App" -ForegroundColor Yellow
    }

    if ($ProPackageFullName) {
      Write-Host "$ts - Removing provisioned bloatware: $ProPackageFullName" -ForegroundColor Cyan
      try {
        Remove-AppxProvisionedPackage -Online -PackageName $ProPackageFullName -ErrorAction Stop | Out-Null
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$ts - Provisioned package '$ProPackageFullName' removed." -ForegroundColor Green
      }
      catch {
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$ts - Failed to remove provisioned '$ProPackageFullName': $_" -ForegroundColor Red
      }
    }
    else {
      Write-Host "$ts - No provisioned package found for: $App" -ForegroundColor Yellow
    }

    Start-Sleep -Milliseconds 200
  }
}

  Clear-Host
  Write-Host "Setting NTFS memory usage to 1..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  
  fsutil behavior set memoryusage 1 | Out-Null
          # Enables server-optimized file system caching (Mode 2).
          # NTFS memory usage modes:
          #    0 = Default (legacy behavior)
          #    1 = Client-optimized (balanced for UI responsiveness)
          #    2 = Server-optimized (aggressive caching, favors throughput)
          # 
          # This setting boosts performance on systems doing heavy file I/O:
          #    - large file transfers
          #    - Docker / WSL / VM workloads
          #    - development involving frequent read/write operations
          #
          # In short: Use 2 if you value throughput over UI snappiness.
  
  Clear-Host
  Write-Host "Disabling LastAccess timestamp updates..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  fsutil behavior set disablelastaccess 1 | Out-Null
  
          # Disables LastAccess timestamp updates on NTFS files.
          # NTFS normally updates the "last accessed" metadata every time a file or folder is opened,
          #    which causes unnecessary disk writes and hurts performance, especially on SSDs.
          #
          # fsutil behavior set disablelastaccess 1
          #    0 = Enable timestamp updates (default on older systems)
          #    1 = Disable updates for performance (recommended)
          #
          # Greatly improves file system performance on systems with:
          #    - lots of small file operations
          #    - development tools (compilers, git, WSL, Docker)
          #    - SSD/NVMe drives (limits write wear)
  
  Clear-Host
  Write-Host "Setting MFT zone reservation to level 2 (25%)..." -ForegroundColor Cyan
  fsutil behavior set mftzone 2 | Out-Null
  Start-Sleep -Seconds 3
  
          # Configures the reserved size of the MFT (Master File Table) zone on NTFS volumes.
          # The MFT is the internal NTFS database that tracks all files on disk.
          #     If it becomes fragmented due to insufficient space, performance drops significantly.
          #
          # fsutil behavior set mftzone X
          #    X = 0 to 4 (corresponds to approx. 12.5%, 25%, 37.5%, 50% of volume reserved for MFT)
          #    0 = Default (12.5%)
          #    1 = 12.5%   - conservative (default)
          #    2 = 25%     - recommended for systems with LOTS of files (dev envs, containers, git, etc.)
          #    3 = 37.5%
          #    4 = 50%     - only if you’re running a massive number of small files (e.g., mail servers)
  
  Clear-Host
  Write-Host ""
  Write-Host "Shrinking NTFS transaction logs on mounted volumes..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
          $volumes = Get-CimInstance Win32_Volume | Where-Object { $_.DriveLetter -and $_.FileSystem -eq "NTFS" }
  
          foreach ($vol in $volumes) {
              $drive = $vol.DriveLetter
              try {
                  Write-Host "Processing volume $drive..." -ForegroundColor Green
                  fsutil resource setavailable "$drive\" | Out-Null
                  fsutil resource setlog shrink 10 "$drive\" | Out-Null
              } catch {
                  Write-Host "Failed to optimize $drive. Error: $_" -ForegroundColor Red
              }
          }
  Disable-UnnecessaryServices -ServiceList @("WerSvc", "OneSyncSvc", "PcaSvc", "MessagingService", "RetailDemo", "diagnosticshub.standardcollector.service", "lfsvc", "AJRouter", "RemoteRegistry", "DUSMsvc", "DiagTrack", "MapsBroker", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc", "dmwappushservice", "DiagSvc", "wisvc", "PhoneSvc", "UnistoreSvc")
  
  Disable-UnwantedScheduledTasks -TaskList @("Microsoft\Windows\AppID\SmartScreenSpecific", "Microsoft\Windows\Application Experience\AitAgent", "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser", "Microsoft\Windows\Application Experience\ProgramDataUpdater", "Microsoft\Windows\Application Experience\StartupAppTask", "Microsoft\Windows\Autochk\Proxy", "Microsoft\Windows\CloudExperienceHost\CreateObjectTask", "Microsoft\Windows\Customer Experience Improvement Program\BthSQM", "Microsoft\Windows\Customer Experience Improvement Program\Consolidator", "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask", "Microsoft\Windows\Customer Experience Improvement Program\Uploader", "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip", "Microsoft\Windows\Maintenance\WinSAT", "Microsoft\Windows\PI\Sqm-Tasks", "Microsoft\Windows\Shell\FamilySafetyMonitor", "Microsoft\Windows\Shell\FamilySafetyRefresh", "Microsoft\Windows\Shell\FamilySafetyUpload", "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask", "Microsoft\Windows\Shell\FamilySafetyRefreshTask", "Microsoft\Windows\WindowsUpdate\Automatic App Update", "Microsoft\Windows\NetTrace\GatherNetworkInfo", "Microsoft\Windows\Maps\MapsUpdateTask", "Microsoft\Windows\Maps\MapsToastTask", "Microsoft\XblGameSave\XblGameSaveTask", "Microsoft\XblGameSave\XblGameSaveTaskLogon")
  
  Remove-BloatwarePackages -AppsList @("Microsoft.GetHelp", "Microsoft.People", "Microsoft.YourPhone", "Microsoft.GetStarted", "Microsoft.Messaging", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.SkypeApp", "Microsoft.CommsPhone", "Microsoft.Office.Sway", "Microsoft.WindowsFeedbackHub", "Microsoft.ConnectivityStore", "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", "Microsoft.BingTravel", "Microsoft.WindowsReadingList", "DB6EA5DB.MediaSuiteEssentialsforDell", "DB6EA5DB.Power2GoforDell", "DB6EA5DB.PowerDirectorforDell", "DB6EA5DB.PowerMediaPlayerforDell", "DellInc.DellDigitalDelivery", "*Disney*", "*EclipseManager*", "*ActiproSoftwareLLC*", "*AdobeSystemsIncorporated.AdobePhotoshopExpress*", "*Duolingo-LearnLanguagesforFree*", "*PandoraMediaInc*", "*CandyCrush*", "*BubbleWitch3Saga*", "*Wunderlist*", "*Flipboard*", "*Royal Revolt*", "*Sway*", "*Speed Test*", "46928bounde.EclipseManager", "613EBCEA.PolarrPhotoEditorAcademicEdition", "7EE7776C.LinkedInforWindows", "89006A2E.AutodeskSketchBook", "ActiproSoftwareLLC.562882FEEB491", "CAF9E577.Plex", "ClearChannelRadioDigital.iHeartRadio", "Drawboard.DrawboardPDF", "Fitbit.FitbitCoach", "Flipboard.Flipboard", "KeeperSecurityInc.Keeper", "Microsoft.BingNews", "TheNewYorkTimes.NYTCrossword", "WinZipComputing.WinZipUniversal", "A278AB0D.MarchofEmpires", "6Wunderkinder.Wunderlist", "A278AB0D.DisneyMagicKingdoms", "2FE3CB00.PicsArt-PhotoStudio", "D52A8D61.FarmVille2CountryEscape", "D5EA27B7.Duolingo-LearnLanguagesforFree", "DB6EA5DB.CyberLinkMediaSuiteEssentials", "GAMELOFTSA.Asphalt8Airborne", "NORDCURRENT.COOKINGFEVER", "PandoraMediaInc.29680B314EFC2", "Playtika.CaesarsSlotsFreeCasino", "ShazamEntertainmentLtd.Shazam", "ThumbmunkeysLtd.PhototasticCollage", "TuneIn.TuneInRadio", "XINGAG.XING", "flaregamesGmbH.RoyalRevolt2", "king.com.*", "king.com.BubbleWitch3Saga", "king.com.CandyCrushSaga", "king.com.CandyCrushSodaSaga", "*Clipchamp*", "*Solitaire*")
  
  schtasks /change /tn "Microsoft\Windows\WDI\ResolutionHost" /disable
  schtasks /change /tn "Microsoft\Windows\UNP\RunUpdateNotificationMgr" /disable
  schtasks /change /tn "Microsoft\Windows\DUSM\dusmtask" /disable
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
  #schtasks /change /tn "Microsoft\Windows\Sysmain\ResPriStaticDbSync" /disable
  #schtasks /change /tn "Microsoft\Windows\Sysmain\WsSwapAssessmentTask" /disable
  #schtasks /change /tn "Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate" /disable
  #schtasks /change /tn "Microsoft\Windows\Sysmain\HybridDriveCacheRebalance" /disable
  schtasks /change /tn "Microsoft\Windows\DiskCleanup\SilentCleanup" /disable
  schtasks /change /tn "Microsoft\Windows\MUI\LPRemove" /disable
  schtasks /change /tn "Microsoft\Windows\SpacePort\SpaceAgentTask" /disable
  schtasks /change /tn "Microsoft\Windows\SpacePort\SpaceManagerTask" /disable
  schtasks /change /tn "Microsoft\Windows\Speech\SpeechModelDownloadTask" /disable
  schtasks /change /tn "Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)" /disable
  schtasks /change /tn "Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" /disable
  schtasks /change /tn "Microsoft\Windows\Management\Provisioning\Logon" /disable
  schtasks /change /tn "Microsoft\Windows\Management\Provisioning\Cellular" /disable
  schtasks /change /tn "Microsoft\Windows\FileHistory\File History (maintenance mode)" /disable
  schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack" /disable
  schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn" /disable
  schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack2016" /disable
  schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /disable
  schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
  schtasks /change /tn "Mozilla\Firefox Default Browser Agent 308046B0AF4A39CB" /disable
  schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
  schtasks /change /tn "Mozilla\Firefox Default Browser Agent D2CEEC440E2074BD" /disable
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
  gpupdate /force | Out-Null

}