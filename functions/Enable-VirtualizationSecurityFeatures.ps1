function Enable-VirtualizationSecurityFeatures {
  Write-Host "Please note that enabling virtualization security features may induce performance hit in certain games." -ForegroundColor Yellow
  Start-Sleep -Seconds 3
  # Enable VBS
  New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
                   -Name "EnableVirtualizationBasedSecurity" -Value 1 -Type DWord
  Write-Host "VBS enabled." -ForegroundColor Green
  Start-Sleep -Seconds 2
  # Enable Credential Guard
  New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" `
                   -Name "Enabled" -Value 1 -Type DWord
  Write-Host "Credential Guard enabled." -ForegroundColor Green
  Start-Sleep -Seconds 2
  # Enable HVCI (Memory Integrity)
      New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Force | Out-Null
      Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" `
                       -Name "Enabled" -Value 1 -Type DWord
      Write-Host "[] HVCI (Memory Integrity) enabled." -ForegroundColor Green
  Start-Sleep -Seconds 2
  Write-Host ""
  Write-Host "[] $ts - All features enabled. A reboot is required for changes to take effect." -ForegroundColor Green
  Start-Sleep -Seconds 2
}