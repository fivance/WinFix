function Set-ServicesManual {
  Clear-Host
  Write-Host "Applying manual startup for services..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  $services = Get-Service
  $servicesKeep = @(
        'AudioEndpointBuilder',
        'Audiosrv',
        'EventLog',
        'SysMain',
        'Themes',
        'WSearch',
        'NVDisplay.ContainerLocalSystem',
        'WlanSvc',
        'BFE', 
        'BrokerInfrastructure', 
        'CoreMessagingRegistrar', 
        'Dnscache', 
        'LSM', 
        'mpssvc', 
        'RpcEptMapper', 
        'Schedule', 
        'SystemEventsBroker', 
        'StateRepository', 
        'TextInputManagementService', 
        'sppsvc'
      )
     foreach ($service in $services) { 
        if ($service.StartType -like '*Auto*') {
          if ($servicesKeep -notcontains $service.Name) {
            try {
              Set-Service -Name $service.Name -StartupType Manual -ErrorAction Stop
            }
            catch {
              $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
              Set-ItemProperty -Path $regPath -Name 'Start' -Value 3 -ErrorAction SilentlyContinue
            }
         
      }         
    }
  }
  Clear-Host
  Write-Host "Sucessfully set services to manual" -ForegroundColor Green
  Start-Sleep -Seconds 3
  
}