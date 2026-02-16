function Install-DDU {
  Clear-Host
  Write-Host "Installing: DDU..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3

  Get-FileFromWeb -URL "https://github.com/fivance/files/raw/main/DDU.zip" -File "$env:TEMP\DDU.zip"
  Expand-Archive "$env:TEMP\DDU.zip" -DestinationPath "$env:TEMP\DDU" -ErrorAction SilentlyContinue

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
<RemoveINTELIGS>True</RemoveINTELIGS>
<RemoveOneAPI>True</RemoveOneAPI>
<RemoveEnduranceGaming>True</RemoveEnduranceGaming>
<RemoveIntelNpu>True</RemoveIntelNpu>
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
  Set-ItemProperty -Path "$env:TEMP\DDU\Settings\Settings.xml" -Name IsReadOnly -Value $true

  # Disable automatic driver install via Windows Update
  reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f | Out-Null

  $WshShell = New-Object -ComObject WScript.Shell

  $SafeModeShortcut = $WshShell.CreateShortcut("$Home\Desktop\Safe Mode Toggle.lnk")
  $SafeModeShortcut.TargetPath = "$env:SystemDrive\Windows\System32\msconfig.exe"
  $SafeModeShortcut.Save()

  $DDUShortcut = $WshShell.CreateShortcut("$Home\Desktop\Display Driver Uninstaller.lnk")
  $DDUShortcut.TargetPath = "$env:TEMP\DDU\Display Driver Uninstaller.exe"
  $DDUShortcut.Save()

  Clear-Host

  $response = Read-Host "Do you want to restart into Safe Mode now? (Y/N)"

  if ($response -match '^[Yy]') {
      Write-Host "Restarting into Safe Mode..." -ForegroundColor Cyan
      cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
      shutdown -r -t 00
  }
  else {
      Write-Host "Restart supressed." -ForegroundColor Cyan
  }
}
