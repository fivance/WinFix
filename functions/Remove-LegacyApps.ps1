function Remove-LegacyApps {
  Clear-Host
  Write-Host "Uninstalling Legacy Apps..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  # Uninstall Microsoft Update Health Tools Windows 11
  cmd /c "MsiExec.exe /X{C6FD611E-7EFE-488C-A0E0-974C09EF6473} /qn >nul 2>&1"
  # Uninstall Microsoft Update Health Tools Windows 10
  cmd /c "MsiExec.exe /X{1FC1A6C2-576E-489A-9B4A-92D21F542136} /qn >nul 2>&1"
  # Clean Microsoft Update Health Tools Windows 10
  cmd /c "reg delete `"HKLM\SYSTEM\ControlSet001\Services\uhssvc`" /f >nul 2>&1"
  Unregister-ScheduledTask -TaskName PLUGScheduler -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  # Uninstall update for Windows 10 x64-based systems
  cmd /c "MsiExec.exe /X{B9A7A138-BFD5-4C73-A269-F78CCA28150E} /qn >nul 2>&1"
  cmd /c "MsiExec.exe /X{85C69797-7336-4E83-8D97-32A7C8465A3B} /qn >nul 2>&1"
  Stop-Process -Force -Name OneDrive -ErrorAction SilentlyContinue | Out-Null
  cmd /c "C:\Windows\SysWOW64\OneDriveSetup.exe -uninstall >nul 2>&1"
  Get-ScheduledTask | Where-Object {$_.Taskname -match 'OneDrive'} | Unregister-ScheduledTask -Confirm:$false
  cmd /c "C:\Windows\System32\OneDriveSetup.exe -uninstall >nul 2>&1"
  cmd /c "reg delete `"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Font Drivers`" /f >nul 2>&1"
  Start-Process "C:\Windows\System32\SnippingTool.exe" -ArgumentList "/Uninstall"
  Clear-Host
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
  Write-Host "Legacy Apps uninstalled." -ForegroundColor Green
}