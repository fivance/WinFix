function Remove-LegacyFeatures {
  Clear-Host
  Write-Host "Uninstalling Legacy Features..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  # .NET Framework 4.8 advanced services left out
  # Dism /Online /NoRestart /Disable-Feature /FeatureName:NetFx4-AdvSrvs | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:WCF-Services45 | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:WCF-TCP-PortSharing45 | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:MediaPlayback | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-PrintToPDFServices-Features | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-XPSServices-Features | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-Foundation-Features | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:Printing-Foundation-InternetPrinting-Client | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:MSRDC-Infrastructure | Out-Null
  # Breaks search
  # Dism /Online /NoRestart /Disable-Feature /FeatureName:SearchEngine-Client-Package | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:SMB1Protocol | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:SMB1Protocol-Client | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:SMB1Protocol-Deprecation | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:SmbDirect | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:Windows-Identity-Foundation | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2Root | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2 | Out-Null
  Dism /Online /NoRestart /Disable-Feature /FeatureName:WorkFolders-Client | Out-Null
  Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
  Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation -NoRestart
  Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart
  Clear-Host
  Write-Host "Legacy Features uninstalled." -ForegroundColor Green
}
