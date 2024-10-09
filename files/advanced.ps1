# Set initial keyboard indicators for specific user SIDs
Set-ItemProperty -Path "HKU\S-1-5-19\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value "2147483650" -Type String
Set-ItemProperty -Path "HKU\S-1-5-20\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value "2147483650" -Type String

# Automatic discovery IE11 proxy
Set-ItemProperty -Path "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "DefaultConnectionSettings" -Value ([byte[]](0x3c, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x31, 0x32, 0x37, 0x2e, 0x30, 0x2e, 0x30, 0x2e, 0x31, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0xd7, 0x5b, 0xde, 0x6f, 0x11, 0xc5, 0x01, 0x01, 0x00, 0x00, 0x00, 0xc2, 0x3f, 0x80, 0x6f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00))
Set-ItemProperty -Path "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "SavedLegacySettings" -Value ([byte[]](0x3c, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x31, 0x32, 0x37, 0x2e, 0x30, 0x2e, 0x30, 0x2e, 0x31, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0xd7, 0x5b, 0xde, 0x6f, 0x11, 0xc5, 0x01, 0x01, 0x00, 0x00, 0x00, 0xc2, 0x3f, 0x80, 0x6f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00))

# OneDrive cleaning that comes with Office install
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\SkyDrive" -Name "" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Classes\grvopen" -Name "" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Environment\OneDrive" -Force -ErrorAction SilentlyContinue

New-ItemProperty -Path "HKCU:\Software\Microsoft\Input\TIPC" -Name "Enabled" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Set the culture and UI culture to Croatian
$CultureInfo = New-Object System.Globalization.CultureInfo("hr-HR")

# Set the current culture
[System.Threading.Thread]::CurrentThread.CurrentCulture = $CultureInfo
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $CultureInfo

# Set the system culture
Set-WinSystemLocale "hr-HR"

# Set the user locale
Set-WinUserLanguageList -Language "hr-HR" -Force

# Set the region settings to Croatia
Set-WinHomeLocation -GeoId 191 # GeoId for Croatia

# Display current settings
Get-WinUserLanguageList
Get-WinSystemLocale

# Change currency "kn" to "EUR" for HR & EN (Croatia)
New-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sCurrency" -Value "EUR" -PropertyType String -Force -ErrorAction SilentlyContinue

# Disable automatic folder type discovery
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" -Name "FolderType" -Value "NotSpecified" -PropertyType String -Force -ErrorAction SilentlyContinue

# Registered owner & organization
# New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOrganization" -Value "(-_-)" -PropertyType String -Force -ErrorAction SilentlyContinue
# New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOwner" -Value "Gazda" -PropertyType String -Force -ErrorAction SilentlyContinue

# Enable DNS over HTTPS (DoH)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDoh" -Value 2 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Remove Auto run Defender
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "SecurityHealth" -Force -ErrorAction SilentlyContinue

# Disable autologger telemetry
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe" -Name "Start" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudExperienceHost" -Name "ETWLoggingEnabled" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Disable updates for Microsoft Office
schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
schtasks /change /tn "Microsoft\Office\Office Feature Updates Logon" /disable
schtasks /change /tn "Microsoft\Office\Office Feature Updates" /disable
schtasks /change /tn "Microsoft\Office\Office Automatic Updates 2.0" /disable

# Disable Firefox updates
schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable

# Delete the task "Cleaning Retail Demo content"
schtasks /delete /tn "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /f

# Cleanup
# Remove-Item -Path "$env:windir\PrilagodeniTasks.cmd" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft\Diagnosis\*.rbs" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft\Windows Defender\Scans\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:SystemRoot\Panther\*" -Force -ErrorAction SilentlyContinue
# Remove-Item -Path "$env:windir\Setup\Scripts" -Recurse -Force -ErrorAction SilentlyContinue

# Disable activity log and clipboard
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowCrossDeviceClipboard" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Disable clipboard history
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowClipboardHistory" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Disable Windows Event Logging
# Check all policies: auditpol /get /Category:*
auditpol /set /subcategory:"Special Logon" /success:disable
auditpol /set /subcategory:"Audit Policy Change" /success:disable
auditpol /set /subcategory:"User Account Management" /success:disable

# Set password never expires
net.exe accounts /maxpwage:unlimited

# Disable telemetry (Unified Telemetry Client)
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Disable Defender auto run
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" -Name "SecurityHealth" -Value "$env:SystemRoot\system32\SecurityHealthSystray.exe" -PropertyType String -Force -ErrorAction SilentlyContinue

# Set IKEEXT service start type to manual (3)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\IKEEXT" -Name "Start" -Value 3 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

# Create scheduled task to run custom script
$taskAction = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$env:windir\PrilagodeniTasks.cmd`""
$taskTrigger = New-ScheduledTaskTrigger -AtStartup -RepeatInterval (New-TimeSpan -Hours 1) -RepeatDuration (New-TimeSpan -Days 1)
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -TaskName "PrilagodeniTasks" -Force

# Run the task
Start-ScheduledTask -TaskName "PrilagodeniTasks"
Start-Sleep -Seconds 5
Unregister-ScheduledTask -TaskName "PrilagodeniTasks" -Confirm:$false

# Set default DNS to Cloudflare
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object {
    $_.SetDNSServerSearchOrder("1.1.1.1", "1.0.0.1")
}

# Register DNS
ipconfig /registerdns

# Disable DNS functions (LLMNR, Resolution, Devolution, ParallelAandAAAA)
# netsh.exe winhttp reset proxy

# Disable NetBIOS over TCP/IP
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.TcpipNetbiosOptions -eq 0 } | ForEach-Object {
    $_.SetTcpipNetbios(2)
}

Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.TcpipNetbiosOptions -eq 1 } | ForEach-Object {
    $_.SetTcpipNetbios(2)
}

# Bootloader settings
bcdedit /timeout 4
bcdedit /set nointegritychecks off

# Disable hibernation
powercfg -h off

# Disable 8dot3 name creation
fsutil behavior set disable8dot3 1

# Disable BitLocker and encryption
fsutil behavior set disableencryption 1

# Update NTFS "Last Access" (User Managed, Last Access Updates Disabled)
fsutil behavior set disablelastaccess 1

# Increase memory for accessing NTFS files
fsutil behavior set memoryusage 2

# Disable .NET Core CLI telemetry
[Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")

# Disable automatic repair
fsutil repair set c: 0

# Disable tracking IPsec filters firewall (wfpdiag.etl)
netsh.exe wfp set options netevents = off

# Ensure passwords never expire
net.exe accounts /maxpwage:unlimited

# (Commented out: Uncomment if needed)
# regsvr32 /s "$env:SystemRoot\System32\DolbyDecMFT.dll"
# regsvr32 /s "$env:SystemRoot\SysWOW64\DolbyDecMFT.dll"

# Disable telemetry and diagnostics tasks
schtasks /change /tn "Microsoft\Windows\WDI\ResolutionHost" /disable
schtasks /change /tn "Microsoft\Windows\UNP\RunUpdateNotificationMgr" /disable
schtasks /change /tn "Microsoft\Windows\DUSM\dusmtask" /disable

# Disable extra tasks
$tasksToDisable = @(
    "Microsoft\Windows\SettingSync\BackgroundUpLoadTask",
    "Microsoft\Windows\SettingSync\NetworkStateChangeTask",
    "Microsoft\Windows\Device Setup\Metadata Refresh",
    "Microsoft\Windows\DeviceDirectoryClient\HandleCommand",
    "Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand",
    "Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck",
    "Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChanged",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange",
    "Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice",
    "Microsoft\Windows\Input\LocalUserSyncDataAvailable",
    "Microsoft\Windows\Input\MouseSyncDataAvailable",
    "Microsoft\Windows\Input\PenSyncDataAvailable",
    "Microsoft\Windows\Input\TouchpadSyncDataAvailable",
    "Microsoft\Windows\International\Synchronize Language Settings",
    "Microsoft\Windows\Sysmain\ResPriStaticDbSync",
    "Microsoft\Windows\Sysmain\WsSwapAssessmentTask",
    "Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate",
    "Microsoft\Windows\Sysmain\HybridDriveCacheRebalance",
    "Microsoft\Windows\DiskCleanup\SilentCleanup",
    "Microsoft\Windows\MUI\LPRemove",
    "Microsoft\Windows\SpacePort\SpaceAgentTask",
    "Microsoft\Windows\SpacePort\SpaceManagerTask",
    "Microsoft\Windows\Speech\SpeechModelDownloadTask",
    "Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)",
    "Microsoft\Windows\File Classification Infrastructure\Property Definition Sync",
    "Microsoft\Windows\Management\Provisioning\Logon",
    "Microsoft\Windows\Management\Provisioning\Cellular",
    "Microsoft\Windows\FileHistory\File History (maintenance mode)",
    "Microsoft\Office\OfficeTelemetryAgentFallBack",
    "Microsoft\Office\OfficeTelemetryAgentLogOn",
    "Microsoft\Office\OfficeTelemetryAgentFallBack2016",
    "Microsoft\Office\OfficeTelemetryAgentLogOn2016",
    "Microsoft\Office\Office ClickToRun Service Monitor",
    "Mozilla\Firefox Default Browser Agent 308046B0AF4A39CB",
    "Mozilla\Firefox Background Update 308046B0AF4A39CB",
    "Mozilla\Firefox Default Browser Agent D2CEEC440E2074BD",
    "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical",
    "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64",
    "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical",
    "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319",
    "Microsoft\Windows\Defrag\ScheduledDefrag",
    "Microsoft\Windows\Multimedia\SystemSoundsService",
    "Microsoft\Windows\NlaSvc\WiFiTask",
    "Microsoft\Windows\Printing\EduPrintProv",
    "Microsoft\Windows\Printing\PrinterCleanupTask",
    "Microsoft\Windows\Printing\PrintJobCleanupTask",
    "Microsoft\Windows\RecoveryEnvironment\VerifyWinRE",
    "Microsoft\Windows\Servicing\StartComponentCleanup",
    "Microsoft\Windows\Setup\SetupCleanupTask",
    "Microsoft\Windows\Shell\ThemesSyncedImageDownload",
    "Microsoft\Windows\Shell\UpdateUserPictureTask",
    "Microsoft\Windows\Storage Tiers Management\Storage Tiers Management Initialization",
    "Microsoft\Windows\Task Manager\Interactive",
    "Microsoft\Windows\TPM\Tpm-HASCertRetr",
    "Microsoft\Windows\TPM\Tpm-Maintenance",
    "Microsoft\Windows\UPnP\UPnPHostConfig",
    "Microsoft\Windows\WCM\WiFiTask",
    "Microsoft\Windows\WlanSvc\CDSSync",
    "Microsoft\Windows\WOF\WIM-Hash-Management",
    "Microsoft\Windows\WOF\WIM-Hash-Validation",
    "Microsoft\Windows\WwanSvc\NotificationTask",
    "Microsoft\Windows\WwanSvc\OobeDiscovery"
)

# Disable each task
foreach ($task in $tasksToDisable) {
    schtasks /change /tn $task /disable
}

# (Commented out: Uncomment if needed)
# Disable task "CloudExperienceHost"
# schtasks /change /tn "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /disable

# Disable MsCtfMonitor Task (keylogger needed for typing within settings)
# schtasks /change /tn "Microsoft\Windows\TextServicesFramework\MsCtfMonitor" /disable
exit
