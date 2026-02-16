function Remove-UWPApps {
  Clear-Host
  Write-Host "Removing UWP Apps..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  # CBS needed for Windows 11 Explorer
  Get-AppXPackage -AllUsers | Where-Object { $_.Name -notlike '*NVIDIA*' -and $_.Name -notlike '*CBS*' -and $_.Name -notlike '*Terminal*' } | Remove-AppxPackage -ErrorAction SilentlyContinue
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.HEVCVideoExtension* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.HEIFImageExtension* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.Paint* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.Windows.Photos* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.WindowsNotepad* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.WindowsStore* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.Microsoft.StorePurchaseApp* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.WindowsCalculator * | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Clear-Host
  Write-Host "UWP Apps removed." -ForegroundColor Green
}