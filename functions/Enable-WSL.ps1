function Enable-WSL {
  [CmdletBinding()]
  param()
  Clear-Host
  Write-Host "Enabling WSL..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
    $ts = Get-Date -Format "M/d/yyyy h:mm:ss tt"
    Write-Host " $ts - Checking and enabling required WSL features..." -ForegroundColor Cyan
    Write-Host ""
  
    $requiredFeatures = @(
      "Microsoft-Windows-Subsystem-Linux",
      "VirtualMachinePlatform"
    )
  
    foreach ($feature in $requiredFeatures) {
      $featureState = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
      if ($featureState -ne "Enabled") {
        Write-Host "$ts - Enabling feature: $feature" -ForegroundColor Cyan
        try {
          dism.exe /Online /Enable-Feature /FeatureName:$feature /All /NoRestart | Out-Null
          Write-Host "$ts - Successfully enabled: $feature." -ForegroundColor Green
        }
        catch {
          Write-Host "$ts - Failed to enable feature: $feature. Error: $_" -ForegroundColor Red
        }
      }
      else {
        Write-Host "$ts - Feature already enabled: $feature" -ForegroundColor Green
      }
    }
  
    Write-Host "$ts - Updating WSL kernel (via wsl --update)..." -ForegroundColor Cyan
    wsl --update
  
    Write-Host "$ts - Setting WSL default version to 2..." -ForegroundColor Cyan
    wsl --set-default-version 2
  
    Write-Host "$ts - WSL configuration completed. A reboot is recommended." -ForegroundColor Yellow
}