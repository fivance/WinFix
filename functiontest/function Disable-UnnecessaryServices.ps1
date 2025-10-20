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
  Write-Host "Disabling unnecessary services..."
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
  #get bin path to revert later
  $service = Get-WmiObject -Class Win32_Service -Filter "Name='TrustedInstaller'"
  $DefaultBinPath = $service.PathName
  #make sure path is valid and the correct location
  $trustedInstallerPath = "$env:SystemRoot\servicing\TrustedInstaller.exe"
  if ($DefaultBinPath -ne $trustedInstallerPath) {
    $DefaultBinPath = $trustedInstallerPath
  }
  #convert command to base64 to avoid errors with spaces
  $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
  $base64Command = [Convert]::ToBase64String($bytes)
  #change bin to command
  sc.exe config TrustedInstaller binPath= "cmd.exe /c powershell.exe -encodedcommand $base64Command" | Out-Null
  #run the command
  sc.exe start TrustedInstaller | Out-Null
  #set bin back to default
  sc.exe config TrustedInstaller binpath= "`"$DefaultBinPath`"" | Out-Null
  try {
    Stop-Service -Name TrustedInstaller -Force -ErrorAction Stop -WarningAction Stop
  }
  catch {
    taskkill /im trustedinstaller.exe /f >$null
  }
  
}


Write-Host "Disabling Bluetooth, Printing and other services..."
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
  Write-Host "Disabling unnecessary scheduled tasks..."
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
  Write-Host "Removing packages..."
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
