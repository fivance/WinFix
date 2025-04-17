Write-Host "Installing: DDU..."
# download DDU
Get-FileFromWeb -URL "https://github.com/fivance/files/raw/main/DDU.zip" -File "$env:TEMP\DDU.zip"
# extract files
Expand-Archive "$env:TEMP\DDU.zip" -DestinationPath "$env:TEMP\DDU" -ErrorAction SilentlyContinue
# Create config for DDU
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
# Set config to read only
Set-ItemProperty -Path "$env:TEMP\DDU\Settings\Settings.xml" -Name IsReadOnly -Value $true
# Prevent downloads of drivers from windows update
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f | Out-Null
# Create msconfig shortcut
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
Write-Host "Restarting To Safe Mode: Press any key to restart..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Toggle safe mode
cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
# Restart
shutdown -r -t 00

