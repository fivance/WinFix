<#
.SYNOPSIS
WinFix automates the configuration, customization, hardening and optimisation of Windows system post-installation.

.DESCRIPTION
WinFix is a PowerShell script made to transform a freshly installed Windows system into a hardened, decluttered, operational, optimised environment.

It encapsulates system configuration, privacy and telemetry reduction, security enhancements (Defender, services, firewall) and the removal of non essential components and telemetry.

Tailored for developers, system administrators, security professionals, power users and just about anyone that wishes to have a fully optimized, clean, hardened and usable OS.

.INPUTS
None. All logic is internal or prompted contextually.

.OUTPUTS
Structured terminal output.

.REQUIREMENTS
- PowerShell 5.1 or higher
- Administrator privileges
- Internet access

.CREDITS
With inspiration from:  
- Zoicware - https://github.com/zoicware/ZOICWARE
- fr33thy - https://github.com/fr33thyfr33thy/Ultimate-Windows-Optimization-Guide
- Win11Debloat - https://github.com/Raphire/Win11Debloat  
- Harden-Windows-Security - https://github.com/HotCakeX/Harden-Windows-Security
- Win-PostInstall - https://github.com/franckferman/Win-PostInstall/

.EXAMPLE
PS C:\> Set-ExecutionPolicy Bypass -Scope Process -Force; .\WinFix.ps1

.NOTES
Author  : Fran Ivancevic 
Version : 1.0.0  
GitHub  : https://github.com/fivance/

.LINK
https://github.com/fivance/WinFix
#>


function Get-Admin {
  If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
  {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
  Exit}
  $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
  $Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
  $Host.PrivateData.ProgressForegroundColor = "White"
  Clear-Host
}

function Show-Progress {
  param (
      [Parameter(Mandatory)][Single]$TotalValue,
      [Parameter(Mandatory)][Single]$CurrentValue,
      [Parameter(Mandatory)][string]$ProgressText,
      [Parameter()][int]$BarSize = 10,
      [Parameter()][switch]$Complete
  )
  $percent = $CurrentValue / $TotalValue
  $percentComplete = $percent * 100
  if ($psISE) {
      Write-Progress "$ProgressText" -Id 0 -PercentComplete $percentComplete
  } else {
      Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % "
  }
}

function Get-FileFromWeb {
  param (
      [Parameter(Mandatory)][string]$URL,
      [Parameter(Mandatory)][string]$File
  )

  [System.IO.FileStream]$writer = $null
  [System.IO.Stream]$reader = $null

  try {
      $request = [System.Net.HttpWebRequest]::Create($URL)
      $response = $request.GetResponse()

      if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
          throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
      }

      if ($File -match '^\.\\') {
          $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1]
      }

      if ($File -and !(Split-Path $File)) {
          $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File
      }

      if ($File) {
          $fileDirectory = [System.IO.Path]::GetDirectoryName($File)
          if (!(Test-Path($fileDirectory))) {
              [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
          }
      }

      [long]$fullSize = $response.ContentLength
      [byte[]]$buffer = New-Object byte[] 1048576
      [long]$total = [long]$count = 0
      $reader = $response.GetResponseStream()
      $writer = New-Object System.IO.FileStream $File, 'Create'

      do {
          $count = $reader.Read($buffer, 0, $buffer.Length)
          $writer.Write($buffer, 0, $count)
          $total += $count
          if ($fullSize -gt 0) {
              Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText "Downloading $([System.IO.Path]::GetFileName($File))"
          }
      } while ($count -gt 0)
  }
  catch {
      Write-Host "An error occurred: $_" -ForegroundColor Red
  }
  finally {
      if ($reader) { $reader.Close() }
      if ($writer) { $writer.Close() }
  }
}
function Set-ConsoleOpacity {
  param(
      [ValidateRange(10, 100)]
      [int]$Opacity
  )

  try {
      $Win32Type = [Win32.WindowLayer]
  }
  catch {
      $Win32Type = Add-Type -MemberDefinition @'
              [DllImport("user32.dll")]
              public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
  
              [DllImport("user32.dll")]
              public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
  
              [DllImport("user32.dll")]
              public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);
'@ -Name WindowLayer -Namespace Win32 -PassThru
  }
  
  function color ($bc, $fc) {
      $a = (Get-Host).UI.RawUI
      $a.BackgroundColor = $bc
      $a.ForegroundColor = $fc 
      Clear-Host 
  } 

  color 'black' 'white'

  $consoleWidth = $Host.UI.RawUI.WindowSize.Width

  if ($consoleWidth -lt 21) {
      return
  }

  $padding = [Math]::Floor(($consoleWidth - 21) / 2)

  if ($padding -lt 0) {
      $padding = 0
  }

  $fullTitle = '-' * $padding + ' WinFix ' + '-' * $padding

  Write-Host $fullTitle -BackgroundColor White -ForegroundColor Black

  $OpacityValue = [int]($Opacity * 2.56) - 1

  $ThisProcess = Get-Process -Id $PID
  $WindowHandle = $ThisProcess.MainWindowHandle

  $GwlExStyle = -20
  $WsExLayered = 0x80000
  $LwaAlpha = 0x2

  if ($Win32Type::GetWindowLong($WindowHandle, -20) -band $WsExLayered -ne $WsExLayered) {
      [void]$Win32Type::SetWindowLong($WindowHandle, $GwlExStyle, $Win32Type::GetWindowLong($WindowHandle, $GwlExStyle) -bxor $WsExLayered)
  }

  [void]$Win32Type::SetLayeredWindowAttributes($WindowHandle, 0, $OpacityValue, $LwaAlpha)
}
Set-ConsoleOpacity -Opacity 95

function Invoke-Activation {
  $command = 'Invoke-RestMethod https://get.activated.win | Invoke-Expression'
  Start-Process powershell -ArgumentList  "-Command", $command
}

function Invoke-WinUtil {
  $command = 'irm christitus.com/win | iex'
  Start-Process powershell -ArgumentList "-Command", $command
}

function Install-DDU {
  Write-Host "Installing: DDU..."
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
      Write-Host "Restarting into Safe Mode..."
      cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
      shutdown -r -t 00
  }
  else {
      Write-Host "Restart supressed."
  }
}

function Install-NvidiaDriver {
  Clear-Host
  Write-Host "Installing latest Nvidia Driver..."
  Start-Sleep -Seconds 3

  Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver.exe" -ErrorAction SilentlyContinue | Out-Null
  Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver" -ErrorAction SilentlyContinue | Out-Null
  Remove-Item -Recurse -Force "$env:TEMP\7-Zip.exe" -ErrorAction SilentlyContinue | Out-Null
  $uri = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=120&pfid=929&osID=57&languageCode=1033&isWHQL=1&dch=1&sort1=0&numberOfResults=1'
  $response = Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing
  $payload = $response.Content | ConvertFrom-Json
  $version =  $payload.IDS[0].downloadInfo.Version
  $windowsVersion = if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {"win10-win11"} else {"win8-win7"}
  $windowsArchitecture = if ([Environment]::Is64BitOperatingSystem) {"64bit"} else {"32bit"}
  $url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-dch-whql.exe"
  Write-Output "Downloading: Nvidia Driver $version..."
  Get-FileFromWeb -URL $url -File "$env:TEMP\NvidiaDriver.exe"
  Clear-Host
  Write-Host "Installing: Nvidia Driver..."
  Get-FileFromWeb -URL "https://github.com/fivance/files/raw/main/7-Zip.exe" -File "$env:TEMP\7-Zip.exe"
  Start-Process -wait "$env:TEMP\7-Zip.exe" /S
  cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\NvidiaDriver.exe" -o"$env:TEMP\NvidiaDriver" -y | Out-Null
  Start-Process "$env:TEMP\NvidiaDriver\setup.exe"
  Clear-Host
  Read-Host 'Press any key to continue (only press after driver is installed)'
  Write-Host "Installing: NvidiaProfileInspector..."
  Get-FileFromWeb -URL "https://github.com/fivance/files/raw/main/Inspector.zip" -File "$env:TEMP\Inspector.zip"
  Expand-Archive "$env:TEMP\Inspector.zip" -DestinationPath "$env:TEMP\Inspector" -ErrorAction SilentlyContinue
$MultilineComment = @"
<?xml version="1.0" encoding="utf-16"?>
<ArrayOfProfile>
<Profile>
<ProfileName>Base Profile</ProfileName>
<Executeables />
<Settings>
  <ProfileSetting>
    <SettingNameInfo> </SettingNameInfo>
    <SettingID>390467</SettingID>
    <SettingValue>2</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Texture filtering - Negative LOD bias</SettingNameInfo>
    <SettingID>1686376</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Texture filtering - Trilinear optimization</SettingNameInfo>
    <SettingID>3066610</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Vertical Sync Tear Control</SettingNameInfo>
    <SettingID>5912412</SettingID>
    <SettingValue>2525368439</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Preferred refresh rate</SettingNameInfo>
    <SettingID>6600001</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Maximum pre-rendered frames</SettingNameInfo>
    <SettingID>8102046</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Texture filtering - Anisotropic filter optimization</SettingNameInfo>
    <SettingID>8703344</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Vertical Sync</SettingNameInfo>
    <SettingID>11041231</SettingID>
    <SettingValue>138504007</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Shader disk cache maximum size</SettingNameInfo>
    <SettingID>11306135</SettingID>
    <SettingValue>4294967295</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Texture filtering - Quality</SettingNameInfo>
    <SettingID>13510289</SettingID>
    <SettingValue>20</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Texture filtering - Anisotropic sample optimization</SettingNameInfo>
    <SettingID>15151633</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Display the VRR Indicator</SettingNameInfo>
    <SettingID>268604728</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Flag to control smooth AFR behavior</SettingNameInfo>
    <SettingID>270198627</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Anisotropic filtering setting</SettingNameInfo>
    <SettingID>270426537</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Power management mode</SettingNameInfo>
    <SettingID>274197361</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Antialiasing - Gamma correction</SettingNameInfo>
    <SettingID>276652957</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Antialiasing - Mode</SettingNameInfo>
    <SettingID>276757595</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>FRL Low Latency</SettingNameInfo>
    <SettingID>277041152</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Frame Rate Limiter</SettingNameInfo>
    <SettingID>277041154</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Frame Rate Limiter for NVCPL</SettingNameInfo>
    <SettingID>277041162</SettingID>
    <SettingValue>357</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Toggle the VRR global feature</SettingNameInfo>
    <SettingID>278196567</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>VRR requested state</SettingNameInfo>
    <SettingID>278196727</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>G-SYNC</SettingNameInfo>
    <SettingID>279476687</SettingID>
    <SettingValue>4</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Anisotropic filtering mode</SettingNameInfo>
    <SettingID>282245910</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Antialiasing - Setting</SettingNameInfo>
    <SettingID>282555346</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>CUDA Sysmem Fallback Policy</SettingNameInfo>
    <SettingID>283962569</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Enable G-SYNC globally</SettingNameInfo>
    <SettingID>294973784</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>OpenGL GDI compatibility</SettingNameInfo>
    <SettingID>544392611</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Threaded optimization</SettingNameInfo>
    <SettingID>549528094</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Preferred OpenGL GPU</SettingNameInfo>
    <SettingID>550564838</SettingID>
    <SettingValue>id,2.0:268410DE,00000100,GF - (400,2,161,24564) @ (0)</SettingValue>
    <ValueType>String</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo>Vulkan/OpenGL present method</SettingNameInfo>
    <SettingID>550932728</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
</Settings>
</Profile>
</ArrayOfProfile>
"@
  Set-Content -Path "$env:TEMP\Inspector\Inspector.nip" -Value $MultilineComment -Force
  Start-Process -wait "$env:TEMP\Inspector\nvidiaProfileInspector.exe" -ArgumentList "$env:TEMP\Inspector\Inspector.nip"
  
  (Get-ChildItem -Path "$env:windir\System32\DriverStore\FileRepository\nv_dispi*" -Directory).FullName | ForEach-Object { 
    takeown /f "$_\NvTelemetry64.dll" *>$null
    icacls "$_\NvTelemetry64.dll" /grant administrators:F /t *>$null
    Remove-Item "$_\NvTelemetry64.dll" -Force 
  }
  Get-ScheduledTask -TaskName '*NvDriverUpdateCheckDaily*' | Disable-ScheduledTask 
  Get-ScheduledTask -TaskName '*NVIDIA GeForce Experience SelfUpdate*' | Disable-ScheduledTask
  Get-ScheduledTask -TaskName '*NvProfileUpdaterDaily*' | Disable-ScheduledTask
  Get-ScheduledTask -TaskName '*NvProfileUpdaterOnLogon*' | Disable-ScheduledTask
  Get-ScheduledTask -TaskName '*NvTmRep_CrashReport1*' | Disable-ScheduledTask
  Get-ScheduledTask -TaskName '*NvTmRep_CrashReport2*' | Disable-ScheduledTask
  Get-ScheduledTask -TaskName '*NvTmRep_CrashReport3*' | Disable-ScheduledTask
  Get-ScheduledTask -TaskName '*NvTmRep_CrashReport4*' | Disable-ScheduledTask
  Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\FvSvc' /v 'Start' /t REG_DWORD /d '4' /f
  
$response = Read-Host "Do you want to enable P0 state for GPU? (yes/no)"

if ($response -match '^(y|yes)$') {
    Write-Host "Enabling P0 state for GPU..."
    Start-Sleep -Seconds 3
    
  Clear-Host
  $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
  foreach($key in $subkeys){
  if ($key -notlike '*Configuration'){
  # enable p0 state regedit
  reg add "$key" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f | Out-Null
}
}
Clear-Host
Write-Host "P0 State: On . . ."
  $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
  foreach($key in $subkeys){
  if ($key -notlike '*Configuration'){
  Get-ItemProperty -Path "Registry::$key" -Name 'DisableDynamicPstate'
}
}

} else {
    Write-Host "Skipping GPU P0 state enable."
}   
  Start-Process "shell:appsFolder\NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj!NVIDIACorp.NVIDIAControlPanel"
}



function Install-Dependencies {
  Clear-Host
  Write-Host "Installing: Direct X..."
  Start-Sleep -Seconds 3
  Get-FileFromWeb -URL "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -File "$env:TEMP\DirectX.exe"
  Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2301-x64.exe" -File "$env:TEMP\7-Zip.exe"
  Start-Process -wait "$env:TEMP\7-Zip.exe" /S
  cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\DirectX.exe" -o"$env:TEMP\DirectX" -y | Out-Null
  Start-Process "$env:TEMP\DirectX\DXSETUP.exe"
  Start-Sleep -Seconds 5
  Clear-Host
  
  Write-Host "Installing: C++..."
  Start-Sleep -Seconds 3
  Get-FileFromWeb -URL "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE" -File "$env:TEMP\vcredist2005_x86.exe"
  Get-FileFromWeb -URL "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE" -File "$env:TEMP\vcredist2005_x64.exe"
  Get-FileFromWeb -URL "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe" -File "$env:TEMP\vcredist2008_x86.exe"
  Get-FileFromWeb -URL "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" -File "$env:TEMP\vcredist2008_x64.exe"
  Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe" -File "$env:TEMP\vcredist2010_x86.exe" 
  Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" -File "$env:TEMP\vcredist2010_x64.exe"
  Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" -File "$env:TEMP\vcredist2012_x86.exe"
  Get-FileFromWeb -URL "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" -File "$env:TEMP\vcredist2012_x64.exe"
  Get-FileFromWeb -URL "https://aka.ms/highdpimfc2013x86enu" -File "$env:TEMP\vcredist2013_x86.exe"
  Get-FileFromWeb -URL "https://aka.ms/highdpimfc2013x64enu" -File "$env:TEMP\vcredist2013_x64.exe"
  Get-FileFromWeb -URL "https://aka.ms/vs/17/release/vc_redist.x86.exe" -File "$env:TEMP\vcredist2015_2017_2019_2022_x86.exe"
  Get-FileFromWeb -URL "https://aka.ms/vs/17/release/vc_redist.x64.exe" -File "$env:TEMP\vcredist2015_2017_2019_2022_x64.exe"
  Start-Process -wait "$env:TEMP\vcredist2005_x86.exe" -ArgumentList "/q"
  Start-Process -wait "$env:TEMP\vcredist2005_x64.exe" -ArgumentList "/q"
  Start-Process -wait "$env:TEMP\vcredist2008_x86.exe" -ArgumentList "/qb"
  Start-Process -wait "$env:TEMP\vcredist2008_x64.exe" -ArgumentList "/qb"
  Start-Process -wait "$env:TEMP\vcredist2010_x86.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2010_x64.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2012_x86.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2012_x64.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2013_x86.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2013_x64.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2015_2017_2019_2022_x86.exe" -ArgumentList "/passive /norestart"
  Start-Process -wait "$env:TEMP\vcredist2015_2017_2019_2022_x64.exe" -ArgumentList "/passive /norestart"
  
}

function Optimize-BasicTweaks {
  Clear-Host
  Write-Host "Applying basic settings..."
  Start-Sleep -Seconds 3 
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f | Out-Null
  Clear-Host

  Write-Host "Enabling MSI mode..."
  Start-Sleep -Seconds 3
  Clear-Host
  $gpuDevices = Get-PnpDevice -Class Display
  foreach ($gpu in $gpuDevices) {
  $instanceID = $gpu.InstanceId
  reg add "HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f | Out-Null
  }
  foreach ($gpu in $gpuDevices) {
  $instanceID = $gpu.InstanceId
  $regPath = "Registry::HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
  try {
  $msiSupported = Get-ItemProperty -Path $regPath -Name "MSISupported" -ErrorAction Stop
  Write-Output "$instanceID"
  Write-Output "MSISupported: $($msiSupported.MSISupported)"
  } catch {
  Write-Output "$instanceID"
  Write-Output "MSISupported: Not found or error accessing the registry."
  }
  }

  Clear-Host
  Write-Host "Cleaning start menu and taskbar..."
  Start-Sleep -Seconds 3
  cmd /c "reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1"
  Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer" -Name "Quick Launch" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -Name "User Pinned" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "TaskBar" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "ImplicitAppShortcuts" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk")
  $Shortcut.TargetPath = "explorer"
  $Shortcut.Save()
$MultilineComment = @"
Windows Registry Editor Version 5.00

; pin file explorer to taskbar
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband]
"Favorites"=hex:00,aa,01,00,00,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,\
52,87,d6,68,26,00,01,00,26,00,ef,be,10,00,00,00,f4,7e,76,fa,de,9d,da,01,40,\
61,5d,09,df,9d,da,01,19,b8,5f,09,df,9d,da,01,14,00,56,00,31,00,00,00,00,00,\
a4,58,a9,26,10,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,a4,58,a9,\
26,a4,58,a9,26,2e,00,00,00,de,9c,01,00,00,00,02,00,00,00,00,00,00,00,00,00,\
00,00,00,00,00,00,0c,f4,85,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,\
00,16,00,18,01,32,00,8a,04,00,00,a4,58,b6,26,20,00,46,49,4c,45,45,58,7e,31,\
2e,4c,4e,4b,00,00,54,00,09,00,04,00,ef,be,a4,58,b6,26,a4,58,b6,26,2e,00,00,\
00,b7,a8,01,00,00,00,04,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,c0,5a,\
1e,01,46,00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,\
00,72,00,2e,00,6c,00,6e,00,6b,00,00,00,1c,00,22,00,00,00,1e,00,ef,be,02,00,\
55,00,73,00,65,00,72,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,1c,00,12,\
00,00,00,2b,00,ef,be,19,b8,5f,09,df,9d,da,01,1c,00,74,00,00,00,1d,00,ef,be,\
02,00,7b,00,46,00,33,00,38,00,42,00,46,00,34,00,30,00,34,00,2d,00,31,00,44,\
00,34,00,33,00,2d,00,34,00,32,00,46,00,32,00,2d,00,39,00,33,00,30,00,35,00,\
2d,00,36,00,37,00,44,00,45,00,30,00,42,00,32,00,38,00,46,00,43,00,32,00,33,\
00,7d,00,5c,00,65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,\
78,00,65,00,00,00,1c,00,00,00,ff

; remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Dsh]
"AllowNewsAndInterests"=dword:00000000

; left taskbar alignment
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAl"=dword:00000000

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; remove task view from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowTaskViewButton"=dword:00000000

; remove chat from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000

; remove copilot from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000

; remove news and interests
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

; remove security taskbar icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
"SecurityHealth"=hex:07,00,00,00,05,db,8a,69,8a,49,d9,01

; Disable start menu tips and recommendations
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_IrisRecommendations"=dword:00000000

; Disable show recently added apps and recommendations
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start]
"ShowRecentList"=dword:00000000

; Remove pinned items in network and sound flyout
[HKEY_CURRENT_USER\Control Panel\Quick Actions\Control Center\Unpinned]
"Microsoft.QuickAction.BlueLightReduction"=hex(0):
"Microsoft.QuickAction.Accessibility"=hex(0):
"Microsoft.QuickAction.NearShare"=hex(0):
"Microsoft.QuickAction.Cast"=hex(0):
"Microsoft.QuickAction.ProjectL2"=hex(0):

; Disable WindowsCopilot
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; Disable suggested content in settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000

; Disable show whats new after update
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"SubscribedContent-310093Enabled"=dword:00000000

; Disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; Disable search highlights
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000000

; show all taskbar icons w10 only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"EnableAutoTray"=dword:00000000
"@
  Set-Content -Path "$env:TEMP\Taskbar Clean.reg" -Value $MultilineComment -Force
  Set-Location -Path "$env:TEMP"
  Regedit.exe /S "Taskbar Clean.reg"
  $progresspreference = 'silentlycontinue'
  Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin" -ErrorAction SilentlyContinue
  # Leaves only File Explorer and Settings pinned (Edge too if its installed)
$certContent = "-----BEGIN CERTIFICATE-----
4nrhSwH8TRucAIEL3m5RhU5aX0cAW7FJilySr5CE+V40mv9utV7aAZARAABc9u55
LN8F4borYyXEGl8Q5+RZ+qERszeqUhhZXDvcjTF6rgdprauITLqPgMVMbSZbRsLN
/O5uMjSLEr6nWYIwsMJkZMnZyZrhR3PugUhUKOYDqwySCY6/CPkL/Ooz/5j2R2hw
WRGqc7ZsJxDFM1DWofjUiGjDUny+Y8UjowknQVaPYao0PC4bygKEbeZqCqRvSgPa
lSc53OFqCh2FHydzl09fChaos385QvF40EDEgSO8U9/dntAeNULwuuZBi7BkWSIO
mWN1l4e+TZbtSJXwn+EINAJhRHyCSNeku21dsw+cMoLorMKnRmhJMLvE+CCdgNKI
aPo/Krizva1+bMsI8bSkV/CxaCTLXodb/NuBYCsIHY1sTvbwSBRNMPvccw43RJCU
KZRkBLkCVfW24ANbLfHXofHDMLxxFNUpBPSgzGHnueHknECcf6J4HCFBqzvSH1Tj
Q3S6J8tq2yaQ+jFNkxGRMushdXNNiTNjDFYMJNvgRL2lu606PZeypEjvPg7SkGR2
7a42GDSJ8n6HQJXFkOQPJ1mkU4qpA78U+ZAo9ccw8XQPPqE1eG7wzMGihTWfEMVs
K1nsKyEZCLYFmKwYqdIF0somFBXaL/qmEHxwlPCjwRKpwLOue0Y8fgA06xk+DMti
zWahOZNeZ54MN3N14S22D75riYEccVe3CtkDoL+4Oc2MhVdYEVtQcqtKqZ+DmmoI
5BqkECeSHZ4OCguheFckK5Eq5Yf0CKRN+RY2OJ0ZCPUyxQnWdnOi9oBcZsz2NGzY
g8ifO5s5UGscSDMQWUxPJQePDh8nPUittzJ+iplQqJYQ/9p5nKoDukzHHkSwfGms
1GiSYMUZvaze7VSWOHrgZ6dp5qc1SQy0FSacBaEu4ziwx1H7w5NZj+zj2ZbxAZhr
7Wfvt9K1xp58H66U4YT8Su7oq5JGDxuwOEbkltA7PzbFUtq65m4P4LvS4QUIBUqU
0+JRyppVN5HPe11cCPaDdWhcr3LsibWXQ7f0mK8xTtPkOUb5pA2OUIkwNlzmwwS1
Nn69/13u7HmPSyofLck77zGjjqhSV22oHhBSGEr+KagMLZlvt9pnD/3I1R1BqItW
KF3woyb/QizAqScEBsOKj7fmGA7f0KKQkpSpenF1Q/LNdyyOc77wbu2aywLGLN7H
BCdwwjjMQ43FHSQPCA3+5mQDcfhmsFtORnRZWqVKwcKWuUJ7zLEIxlANZ7rDcC30
FKmeUJuKk0Upvhsz7UXzDtNmqYmtg6vY/yPtG5Cc7XXGJxY2QJcbg1uqYI6gKtue
00Mfpjw7XpUMQbIW9rXMA9PSWX6h2ln2TwlbrRikqdQXACZyhtuzSNLK7ifSqw4O
JcZ8JrQ/xePmSd0z6O/MCTiUTFwG0E6WS1XBV1owOYi6jVif1zg75DTbXQGTNRvK
KarodfnpYg3sgTe/8OAI1YSwProuGNNh4hxK+SmljqrYmEj8BNK3MNCyIskCcQ4u
cyoJJHmsNaGFyiKp1543PktIgcs8kpF/SN86/SoB/oI7KECCCKtHNdFV8p9HO3t8
5OsgGUYgvh7Z/Z+P7UGgN1iaYn7El9XopQ/XwK9zc9FBr73+xzE5Hh4aehNVIQdM
Mb+Rfm11R0Jc4WhqBLCC3/uBRzesyKUzPoRJ9IOxCwzeFwGQ202XVlPvklXQwgHx
BfEAWZY1gaX6femNGDkRldzImxF87Sncnt9Y9uQty8u0IY3lLYNcAFoTobZmFkAQ
vuNcXxObmHk3rZNAbRLFsXnWUKGjuK5oP2TyTNlm9fMmnf/E8deez3d8KOXW9YMZ
DkA/iElnxcCKUFpwI+tWqHQ0FT96sgIP/EyhhCq6o/RnNtZvch9zW8sIGD7Lg0cq
SzPYghZuNVYwr90qt7UDekEei4CHTzgWwlSWGGCrP6Oxjk1Fe+KvH4OYwEiDwyRc
l7NRJseqpW1ODv8c3VLnTJJ4o3QPlAO6tOvon7vA1STKtXylbjWARNcWuxT41jtC
CzrAroK2r9bCij4VbwHjmpQnhYbF/hCE1r71Z5eHdWXqpSgIWeS/1avQTStsehwD
2+NGFRXI8mwLBLQN/qi8rqmKPi+fPVBjFoYDyDc35elpdzvqtN/mEp+xDrnAbwXU
yfhkZvyo2+LXFMGFLdYtWTK/+T/4n03OJH1gr6j3zkoosewKTiZeClnK/qfc8YLw
bCdwBm4uHsZ9I14OFCepfHzmXp9nN6a3u0sKi4GZpnAIjSreY4rMK8c+0FNNDLi5
DKuck7+WuGkcRrB/1G9qSdpXqVe86uNojXk9P6TlpXyL/noudwmUhUNTZyOGcmhJ
EBiaNbT2Awx5QNssAlZFuEfvPEAixBz476U8/UPb9ObHbsdcZjXNV89WhfYX04DM
9qcMhCnGq25sJPc5VC6XnNHpFeWhvV/edYESdeEVwxEcExKEAwmEZlGJdxzoAH+K
Y+xAZdgWjPPL5FaYzpXc5erALUfyT+n0UTLcjaR4AKxLnpbRqlNzrWa6xqJN9NwA
+xa38I6EXbQ5Q2kLcK6qbJAbkEL76WiFlkc5mXrGouukDvsjYdxG5Rx6OYxb41Ep
1jEtinaNfXwt/JiDZxuXCMHdKHSH40aZCRlwdAI1C5fqoUkgiDdsxkEq+mGWxMVE
Zd0Ch9zgQLlA6gYlK3gt8+dr1+OSZ0dQdp3ABqb1+0oP8xpozFc2bK3OsJvucpYB
OdmS+rfScY+N0PByGJoKbdNUHIeXv2xdhXnVjM5G3G6nxa3x8WFMJsJs2ma1xRT1
8HKqjX9Ha072PD8Zviu/bWdf5c4RrphVqvzfr9wNRpfmnGOoOcbkRE4QrL5CqrPb
VRujOBMPGAxNlvwq0w1XDOBDawZgK7660yd4MQFZk7iyZgUSXIo3ikleRSmBs+Mt
r+3Og54Cg9QLPHbQQPmiMsu21IJUh0rTgxMVBxNUNbUaPJI1lmbkTcc7HeIk0Wtg
RxwYc8aUn0f/V//c+2ZAlM6xmXmj6jIkOcfkSBd0B5z63N4trypD3m+w34bZkV1I
cQ8h7SaUUqYO5RkjStZbvk2IDFSPUExvqhCstnJf7PZGilbsFPN8lYqcIvDZdaAU
MunNh6f/RnhFwKHXoyWtNI6yK6dm1mhwy+DgPlA2nAevO+FC7Vv98Sl9zaVjaPPy
3BRyQ6kISCL065AKVPEY0ULHqtIyfU5gMvBeUa5+xbU+tUx4ZeP/BdB48/LodyYV
kkgqTafVxCvz4vgmPbnPjm/dlRbVGbyygN0Noq8vo2Ea8Z5zwO32coY2309AC7wv
Pp2wJZn6LKRmzoLWJMFm1A1Oa4RUIkEpA3AAL+5TauxfawpdtTjicoWGQ5gGNwum
+evTnGEpDimE5kUU6uiJ0rotjNpB52I+8qmbgIPkY0Fwwal5Z5yvZJ8eepQjvdZ2
UcdvlTS8oA5YayGi+ASmnJSbsr/v1OOcLmnpwPI+hRgPP+Hwu5rWkOT+SDomF1TO
n/k7NkJ967X0kPx6XtxTPgcG1aKJwZBNQDKDP17/dlZ869W3o6JdgCEvt1nIOPty
lGgvGERC0jCNRJpGml4/py7AtP0WOxrs+YS60sPKMATtiGzp34++dAmHyVEmelhK
apQBuxFl6LQN33+2NNn6L5twI4IQfnm6Cvly9r3VBO0Bi+rpjdftr60scRQM1qw+
9dEz4xL9VEL6wrnyAERLY58wmS9Zp73xXQ1mdDB+yKkGOHeIiA7tCwnNZqClQ8Mf
RnZIAeL1jcqrIsmkQNs4RTuE+ApcnE5DMcvJMgEd1fU3JDRJbaUv+w7kxj4/+G5b
IU2bfh52jUQ5gOftGEFs1LOLj4Bny2XlCiP0L7XLJTKSf0t1zj2ohQWDT5BLo0EV
5rye4hckB4QCiNyiZfavwB6ymStjwnuaS8qwjaRLw4JEeNDjSs/JC0G2ewulUyHt
kEobZO/mQLlhso2lnEaRtK1LyoD1b4IEDbTYmjaWKLR7J64iHKUpiQYPSPxcWyei
o4kcyGw+QvgmxGaKsqSBVGogOV6YuEyoaM0jlfUmi2UmQkju2iY5tzCObNQ41nsL
dKwraDrcjrn4CAKPMMfeUSvYWP559EFfDhDSK6Os6Sbo8R6Zoa7C2NdAicA1jPbt
5ENSrVKf7TOrthvNH9vb1mZC1X2RBmriowa/iT+LEbmQnAkA6Y1tCbpzvrL+cX8K
pUTOAovaiPbab0xzFP7QXc1uK0XA+M1wQ9OF3XGp8PS5QRgSTwMpQXW2iMqihYPv
Hu6U1hhkyfzYZzoJCjVsY2xghJmjKiKEfX0w3RaxfrJkF8ePY9SexnVUNXJ1654/
PQzDKsW58Au9QpIH9VSwKNpv003PksOpobM6G52ouCFOk6HFzSLfnlGZW0yyUQL3
RRyEE2PP0LwQEuk2gxrW8eVy9elqn43S8CG2h2NUtmQULc/IeX63tmCOmOS0emW9
66EljNdMk/e5dTo5XplTJRxRydXcQpgy9bQuntFwPPoo0fXfXlirKsav2rPSWayw
KQK4NxinT+yQh//COeQDYkK01urc2G7SxZ6H0k6uo8xVp9tDCYqHk/lbvukoN0RF
tUI4aLWuKet1O1s1uUAxjd50ELks5iwoqLJ/1bzSmTRMifehP07sbK/N1f4hLae+
jykYgzDWNfNvmPEiz0DwO/rCQTP6x69g+NJaFlmPFwGsKfxP8HqiNWQ6D3irZYcQ
R5Mt2Iwzz2ZWA7B2WLYZWndRCosRVWyPdGhs7gkmLPZ+WWo/Yb7O1kIiWGfVuPNA
MKmgPPjZy8DhZfq5kX20KF6uA0JOZOciXhc0PPAUEy/iQAtzSDYjmJ8HR7l4mYsT
O3Mg3QibMK8MGGa4tEM8OPGktAV5B2J2QOe0f1r3vi3QmM+yukBaabwlJ+dUDQGm
+Ll/1mO5TS+BlWMEAi13cB5bPRsxkzpabxq5kyQwh4vcMuLI0BOIfE2pDKny5jhW
0C4zzv3avYaJh2ts6kvlvTKiSMeXcnK6onKHT89fWQ7Hzr/W8QbR/GnIWBbJMoTc
WcgmW4fO3AC+YlnLVK4kBmnBmsLzLh6M2LOabhxKN8+0Oeoouww7g0HgHkDyt+MS
97po6SETwrdqEFslylLo8+GifFI1bb68H79iEwjXojxQXcD5qqJPxdHsA32eWV0b
qXAVojyAk7kQJfDIK+Y1q9T6KI4ew4t6iauJ8iVJyClnHt8z/4cXdMX37EvJ+2BS
YKHv5OAfS7/9ZpKgILT8NxghgvguLB7G9sWNHntExPtuRLL4/asYFYSAJxUPm7U2
xnp35Zx5jCXesd5OlKNdmhXq519cLl0RGZfH2ZIAEf1hNZqDuKesZ2enykjFlIec
hZsLvEW/pJQnW0+LFz9N3x3vJwxbC7oDgd7A2u0I69Tkdzlc6FFJcfGabT5C3eF2
EAC+toIobJY9hpxdkeukSuxVwin9zuBoUM4X9x/FvgfIE0dKLpzsFyMNlO4taCLc
v1zbgUk2sR91JmbiCbqHglTzQaVMLhPwd8GU55AvYCGMOsSg3p952UkeoxRSeZRp
jQHr4bLN90cqNcrD3h5knmC61nDKf8e+vRZO8CVYR1eb3LsMz12vhTJGaQ4jd0Kz
QyosjcB73wnE9b/rxfG1dRactg7zRU2BfBK/CHpIFJH+XztwMJxn27foSvCY6ktd
uJorJvkGJOgwg0f+oHKDvOTWFO1GSqEZ5BwXKGH0t0udZyXQGgZWvF5s/ojZVcK3
IXz4tKhwrI1ZKnZwL9R2zrpMJ4w6smQgipP0yzzi0ZvsOXRksQJNCn4UPLBhbu+C
eFBbpfe9wJFLD+8F9EY6GlY2W9AKD5/zNUCj6ws8lBn3aRfNPE+Cxy+IKC1NdKLw
eFdOGZr2y1K2IkdefmN9cLZQ/CVXkw8Qw2nOr/ntwuFV/tvJoPW2EOzRmF2XO8mQ
DQv51k5/v4ZE2VL0dIIvj1M+KPw0nSs271QgJanYwK3CpFluK/1ilEi7JKDikT8X
TSz1QZdkum5Y3uC7wc7paXh1rm11nwluCC7jiA==
-----END CERTIFICATE-----
"
  New-Item "$env:TEMP\start2.txt" -Value $certContent -Force | Out-Null
  certutil.exe -decode "$env:TEMP\start2.txt" "$env:TEMP\start2.bin" >$null
  Copy-Item "$env:TEMP\start2.bin" -Destination "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState" -Force | Out-Null

Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null

$MultilineComment = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
<LayoutOptions StartTileGroupCellWidth="6" />
<DefaultLayoutOverride>
    <StartLayoutCollection>
        <defaultlayout:StartLayout GroupCellWidth="6" />
    </StartLayoutCollection>
</DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
  Set-Content -Path "C:\Windows\StartMenuLayout.xml" -Value $MultilineComment -Force -Encoding ASCII
  
  $layoutFile="C:\Windows\StartMenuLayout.xml"
  $regAliases = @("HKLM", "HKCU")
  foreach ($regAlias in $regAliases){
  $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
  $keyPath = $basePath + "\Explorer"
  IF(!(Test-Path -Path $keyPath)) {
  New-Item -Path $basePath -Name "Explorer" | Out-Null
  }
  Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1 | Out-Null
  Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile | Out-Null
  }
  Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
  Timeout /T 5 | Out-Null
  
  foreach ($regAlias in $regAliases){
  $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
  $keyPath = $basePath + "\Explorer"
  Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
  }
  Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
  Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
  Clear-Host

  $stop = "MicrosoftEdgeUpdate", "OneDrive", "WidgetService", "Widgets", "msedge", "msedgewebview2"
  $stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
  Get-AppxPackage -allusers *Microsoft.Windows.Ai.Copilot.Provider* | Remove-AppxPackage
  reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d "1" /f | Out-Null
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d "1" /f | Out-Null
  Clear-Host
  reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" /v "value" /t REG_DWORD /d "0" /f | Out-Null
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f | Out-Null
  Stop-Process -Force -Name Widgets -ErrorAction SilentlyContinue | Out-Null
  Stop-Process -Force -Name WidgetService -ErrorAction SilentlyContinue | Out-Null
  Clear-Host
  Write-Host "Disabling Xbox Gamebar..."
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f | Out-Null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f | Out-Null
  reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Services\GameInputSvc" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Services\BcastDVRUserService" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Services\XblAuthManager" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Services\XblGameSave" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
  Stop-Process -Force -Name GameBar -ErrorAction SilentlyContinue | Out-Null
  Get-AppxPackage -allusers *Microsoft.GamingApp* | Remove-AppxPackage
  Get-AppxPackage -allusers *Microsoft.Xbox.TCUI* | Remove-AppxPackage
  Get-AppxPackage -allusers *Microsoft.XboxApp* | Remove-AppxPackage
  Get-AppxPackage -allusers *Microsoft.XboxGameOverlay* | Remove-AppxPackage
  Get-AppxPackage -allusers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage
  Get-AppxPackage -allusers *Microsoft.XboxIdentityProvider* | Remove-AppxPackage
  Get-AppxPackage -allusers *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage
  Clear-Host
  Write-Host "Basic optimizations done."
}

function Optimize-Powerplan {
Write-Host "Installing optimised powerplan..."
  Start-Sleep -Seconds 3
  cmd /c "powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 99999999-9999-9999-9999-999999999999 >nul 2>&1"
  cmd /c "powercfg /SETACTIVE 99999999-9999-9999-9999-999999999999 >nul 2>&1"
  $output = powercfg /L
  $powerPlans = @()
  foreach ($line in $output) {
  if ($line -match ':') {
  $parse = $line -split ':'
  $index = $parse[1].Trim().indexof('(')
  $guid = $parse[1].Trim().Substring(0, $index)
  $powerPlans += $guid
  }
  }
  foreach ($plan in $powerPlans) {
  cmd /c "powercfg /delete $plan" | Out-Null
  }
  Clear-Host
  powercfg /hibernate off
  cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power`" /v `"HibernateEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power`" /v `"HibernateEnabledDefault`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings`" /v `"ShowLockOption`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings`" /v `"ShowSleepOption`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power`" /v `"HiberbootEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583`" /v `"ValueMax`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling`" /v `"PowerThrottlingOff`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683`" /v `"Attributes`" /t REG_DWORD /d `"2`" /f >nul 2>&1"
  cmd /c "reg add `"HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009`" /v `"Attributes`" /t REG_DWORD /d `"2`" /f >nul 2>&1"
  
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 001
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 001
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 002
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 002
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 001
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 001
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 0x00000064
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 0x00000064
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 0x00000064
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 0x00000064
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 001
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 001
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002
  Clear-Host
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002
  Clear-Host
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 c763b4ec-0e50-4b6b-9bed-2b92a6ee884e 7ec1751b-60ed-4588-afb5-9819d3d77d90 003
  Clear-Host
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 c763b4ec-0e50-4b6b-9bed-2b92a6ee884e 7ec1751b-60ed-4588-afb5-9819d3d77d90 003
  Clear-Host
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 f693fb01-e858-4f00-b20f-f30e12ac06d6 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 001
  Clear-Host
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 f693fb01-e858-4f00-b20f-f30e12ac06d6 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 001
  Clear-Host
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e276e160-7cb0-43c6-b20b-73f5dce39954 a1662ab2-9d34-4e53-ba8b-2639b9e20857 003
  Clear-Host
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e276e160-7cb0-43c6-b20b-73f5dce39954 a1662ab2-9d34-4e53-ba8b-2639b9e20857 003
  Clear-Host
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 0x00000000
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 0x00000000
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da 13d09884-f74e-474a-a852-b6bde8ad03a8 0x00000064
  Clear-Host
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da 13d09884-f74e-474a-a852-b6bde8ad03a8 0x00000064
  Clear-Host
  powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0x00000000
  Clear-Host
  powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0x00000000
  Clear-Host
  Write-Host "Powerplan optimised."
}


function Optimize-Registry {
  Write-Host "Optimising registry..."
  Start-Sleep -Seconds 3
  $MultilineComment = @"
Windows Registry Editor Version 5.00

; --LEGACY CONTROL PANEL--

; EASE OF ACCESS
; Disable Narrator
[HKEY_CURRENT_USER\Software\Microsoft\Narrator\NoRoam]
"DuckAudio"=dword:00000000
"WinEnterLaunchEnabled"=dword:00000000
"ScriptingEnabled"=dword:00000000
"OnlineServicesEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Narrator]
"NarratorCursorHighlight"=dword:00000000
"CoupleNarratorCursorKeyboard"=dword:00000000

; Disable Ease of Access Settings 
[HKEY_CURRENT_USER\Software\Microsoft\Ease of Access]
"selfvoice"=dword:00000000
"selfscan"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility]
"Sound on Activation"=dword:00000000
"Warning Sounds"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\HighContrast]
"Flags"="4194"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
"Flags"="2"
"AutoRepeatRate"="0"
"AutoRepeatDelay"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys]
"Flags"="130"
"MaximumSpeed"="39"
"TimeToMaximumSpeed"="3000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
"Flags"="2"

[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
"Flags"="34"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry]
"Flags"="0"
"FSTextEffect"="0"
"TextEffect"="0"
"WindowsEffect"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SlateLaunch]
"ATapp"=""
"LaunchAT"=dword:00000000




; CLOCK AND REGION
; Disable notify me when the clock changes
[HKEY_CURRENT_USER\Control Panel\TimeDate]
"DstNotification"=dword:00000000




; APPEARANCE AND PERSONALIZATION
; Open file explorer to this pc
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001

; Disable Share App Experinces
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CDP]
"RomeSdkChannelUserAuthzPolicy"=dword:00000000
"NearShareChannelUserAuthzPolicy"=dword:00000000
"CdpSessionUserAuthzPolicy"=dword:00000000

; Hide frequent folders in quick access
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowFrequent"=dword:00000000

; Show file name extensions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000

; Disable search history
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDeviceSearchHistoryEnabled"=dword:00000000

; Disable show files from office.com
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowCloudFilesInQuickAccess"=dword:00000000

; Enable display full path in the title bar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState]
"FullPath"=dword:00000001

; Disable show pop-up description for folder and desktop items
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowInfoTip"=dword:00000000

; Disable show preview handlers in preview pane
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowPreviewHandlers"=dword:00000000

; Disable show sync provider notifications
;[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
;"ShowSyncProviderNotifications"=dword:00000000

; Disable use sharing wizard
;[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
;"SharingWizardOn"=dword:00000000





; HARDWARE AND SOUND
; Disable lock
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
"ShowLockOption"=dword:00000000

; Disable sleep
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
"ShowSleepOption"=dword:00000000

; Sound communications do nothing
[HKEY_CURRENT_USER\Software\Microsoft\Multimedia\Audio]
"UserDuckingPreference"=dword:00000003

; Disable startup sound
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation]
"DisableStartupSound"=dword:00000001

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\EditionOverrides]
"UserSetting_DisableStartupSound"=dword:00000001

; Sound scheme none
[HKEY_CURRENT_USER\AppEvents\Schemes]
@=".None"

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\.Default\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\CriticalBatteryAlarm\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\DeviceConnect\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\DeviceDisconnect\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\DeviceFail\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\FaxBeep\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\LowBatteryAlarm\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\MailBeep\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\MessageNudge\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Default\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.IM\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Mail\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Proximity\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.Reminder\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\Notification.SMS\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\ProximityConnection\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemAsterisk\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemExclamation\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemHand\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\SystemNotification\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\WindowsUAC\.Current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\DisNumbersSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\HubOffSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\HubOnSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\HubSleepSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\MisrecoSound\.current]
@=""

[HKEY_CURRENT_USER\AppEvents\Schemes\Apps\sapisvr\PanelSound\.current]
@=""

; Disable autoplay
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers]
"DisableAutoplay"=dword:00000001

; Disable enhance pointer precision
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"

; Mouse pointers scheme none
[HKEY_CURRENT_USER\Control Panel\Cursors]
"AppStarting"=hex(2):00,00
"Arrow"=hex(2):00,00
"ContactVisualization"=dword:00000000
"Crosshair"=hex(2):00,00
"GestureVisualization"=dword:00000000
"Hand"=hex(2):00,00
"Help"=hex(2):00,00
"IBeam"=hex(2):00,00
"No"=hex(2):00,00
"NWPen"=hex(2):00,00
"Scheme Source"=dword:00000000
"SizeAll"=hex(2):00,00
"SizeNESW"=hex(2):00,00
"SizeNS"=hex(2):00,00
"SizeNWSE"=hex(2):00,00
"SizeWE"=hex(2):00,00
"UpArrow"=hex(2):00,00
"Wait"=hex(2):00,00
@=""

; Disable device installation settings
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=dword:00000001


; NETWORK AND INTERNET
; Disable allow other network users to control or disable the shared internet connection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Network\SharedAccessConnection]
"EnableControl"=dword:00000000


; SYSTEM AND SECURITY

; Disable core isolation (turned it off for default settings)
;[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity]
;"Enabled"=dword:00000000

; Disable ai insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"InsightsEnabled"=dword:00000000

; Disable pre installed apps
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"OemPreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEnabled"=dword:00000000
"SilentInstalledAppsEnabled"=dword:00000000
"SoftLandingEnabled"=dword:00000000
"ContentDeliveryAllowed"=dword:00000000
"PreInstalledAppsEverEnabled"=dword:00000000
"SubscribedContentEnabled"=dword:00000000

[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions]



; Set appearance options to custom
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:3

; Disable animate controls and elements inside windows
; Disable fade or slide menus into view
; Disable fade or slide tooltips into view
; Disable fade out menu items after clicking
; Disable show shadows under mouse pointer
; Disable show shadows under windows
; Disable slide open combo boxes
; Disable smooth-scroll list boxes
[HKEY_CURRENT_USER\Control Panel\Desktop]
"UserPreferencesMask"=hex(2):90,12,03,80,10,00,00,00

; Disable animate windows when minimizing and maximizing
;[HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics]
;"MinAnimate"="0"

; Disable animations in the taskbar
;[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
;"TaskbarAnimations"=dword:0

; Disable enable peek
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"EnableAeroPeek"=dword:0

; Disable save taskbar thumbnail previews
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"AlwaysHibernateThumbnails"=dword:0

; Enable end task in taskbar right click menu
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings]
"TaskbarEndTask"=dword:00000001

; Enable show thumbnails instead of icons
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"IconsOnly"=dword:0

; Disable show translucent selection rectangle
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ListviewAlphaSelect"=dword:0

; Disable show window contents while dragging
;[HKEY_CURRENT_USER\Control Panel\Desktop]
;"DragFullWindows"="0"

; Enable smooth edges of screen fonts
[HKEY_CURRENT_USER\Control Panel\Desktop]
"FontSmoothing"="2"

; Disable use drop shadows for icon labels on the desktop
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ListviewShadow"=dword:0

; This registry value tells the windows scheduler how much cpu time a process should get. While there is lots of options outside of the two "Adjust for best performance: programs or background services" in legacy control panel, the default value when using "Programs" gives the scheduler the ideal cpu time for boosting foreground apps (longer cpu time). NOTE This will not affect input lag in anyway as I/O are received as interrupts and take cpu priority
; Adjust for best performance of programs
;[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
;"Win32PrioritySeparation"=dword:00000026

; Disable remote assistance
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000000

; Games scheduling High Priority
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
"Affinity"=dword:00000000
"Background Only"="False"
"Clock Rate"=dword:00002710
"GPU Priority"=dword:00000008
"Priority"=dword:00000006
"Scheduling Category"="High"
"SFIO Priority"="High"

; TROUBLESHOOTING
; Disable automatic maintenance
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance]
"MaintenanceDisabled"=dword:00000001




; SECURITY AND MAINTENANCE
; Disable report problems - no logs when you encounter a BSOD screen so not being applied
;[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting]
;"Disabled"=dword:00000001




; --IMMERSIVE CONTROL PANEL--




; WINDOWS UPDATE
; Disable delivery optimization
[HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings]
"DownloadMode"=dword:00000000




; PRIVACY
; Disable show me notification in the settings app
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
"EnableAccountNotifications"=dword:00000000

; Disable location
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
"Value"="Deny"

; Disable allow location override
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CPSS\Store\UserLocationOverridePrivacySetting]
"Value"=dword:00000000

; Enable camera
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam]
"Value"="Allow"

; Enable microphone 
[Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone]
"Value"="Allow"

; Disable voice activation
[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationEnabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationLastUsed"=dword:00000000

; Disable notifications
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener]
"Value"="Deny"

; Disable account info
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
"Value"="Deny"

; Disable contacts
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts]
"Value"="Deny"

; Disable calendar
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments]
"Value"="Deny"

; Disable phone calls
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall]
"Value"="Deny"

; Disable call history
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory]
"Value"="Deny"

; Disable email
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email]
"Value"="Deny"

; Disable tasks
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks]
"Value"="Deny"

; Disable messaging
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat]
"Value"="Deny"

; Disable radios
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios]
"Value"="Deny"

; Disable other devices 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync]
"Value"="Deny"

; App diagnostics 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics]
"Value"="Deny"

; Disable documents
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary]
"Value"="Deny"

; Disable downloads folder 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder]
"Value"="Deny"

; Disable music library
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary]
"Value"="Deny"

; Disable pictures
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary]
"Value"="Deny"

; Disable videos
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary]
"Value"="Deny"

; Disable file system
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess]
"Value"="Deny"

; Disable let websites show me locally relevant content by accessing my language list 
[HKEY_CURRENT_USER\Control Panel\International\User Profile]
"HttpAcceptLanguageOptOut"=dword:00000001

; Disable let windows improve start and search results by tracking app launches  
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

; Disable personal inking and typing dictionary
[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
"RestrictImplicitInkCollection"=dword:00000001
"RestrictImplicitTextCollection"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
"HarvestContacts"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
"AcceptedPrivacyPolicy"=dword:00000000

; Disable sending required data
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000

; Feedback frequency never
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules]
"NumberOfSIUFInPeriod"=dword:00000000
"PeriodInNanoSeconds"=-

; Disable store my activity history on this device 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
"PublishUserActivities"=dword:00000000




; SEARCH
; Disable search highlights
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000000

; Disable safe search
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings]
"SafeSearchMode"=dword:00000000

; Disable cloud content search for work or school account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsAADCloudSearchEnabled"=dword:00000000

; Disable cloud content search for microsoft account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsMSACloudSearchEnabled"=dword:00000000




; EASE OF ACCESS
; Disable magnifier settings 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ScreenMagnifier]
"FollowCaret"=dword:00000000
"FollowNarrator"=dword:00000000
"FollowMouse"=dword:00000000
"FollowFocus"=dword:00000000

; Disable narrator settings
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator]
"IntonationPause"=dword:00000000
"ReadHints"=dword:00000000
"ErrorNotificationType"=dword:00000000
"EchoChars"=dword:00000000
"EchoWords"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NarratorHome]
"MinimizeType"=dword:00000000
"AutoStart"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NoRoam]
"EchoToggleKeys"=dword:00000000

; GAMING
; Disable game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000

; Disable enable open xbox game bar using game controller
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=dword:00000000

; Enable game mode
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"AutoGameModeEnabled"=dword:00000001

; Other settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AudioEncodingBitrate"=dword:0001f400
"AudioCaptureEnabled"=dword:00000000
"CustomVideoEncodingBitrate"=dword:003d0900
"CustomVideoEncodingHeight"=dword:000002d0
"CustomVideoEncodingWidth"=dword:00000500
"HistoricalBufferLength"=dword:0000001e
"HistoricalBufferLengthUnit"=dword:00000001
"HistoricalCaptureEnabled"=dword:00000000
"HistoricalCaptureOnBatteryAllowed"=dword:00000001
"HistoricalCaptureOnWirelessDisplayAllowed"=dword:00000001
"MaximumRecordLength"=hex(b):00,D0,88,C3,10,00,00,00
"VideoEncodingBitrateMode"=dword:00000002
"VideoEncodingResolutionMode"=dword:00000002
"VideoEncodingFrameRateMode"=dword:00000000
"EchoCancellationEnabled"=dword:00000001
"CursorCaptureEnabled"=dword:00000000
"VKToggleGameBar"=dword:00000000
"VKMToggleGameBar"=dword:00000000
"VKSaveHistoricalVideo"=dword:00000000
"VKMSaveHistoricalVideo"=dword:00000000
"VKToggleRecording"=dword:00000000
"VKMToggleRecording"=dword:00000000
"VKTakeScreenshot"=dword:00000000
"VKMTakeScreenshot"=dword:00000000
"VKToggleRecordingIndicator"=dword:00000000
"VKMToggleRecordingIndicator"=dword:00000000
"VKToggleMicrophoneCapture"=dword:00000000
"VKMToggleMicrophoneCapture"=dword:00000000
"VKToggleCameraCapture"=dword:00000000
"VKMToggleCameraCapture"=dword:00000000
"VKToggleBroadcast"=dword:00000000
"VKMToggleBroadcast"=dword:00000000
"MicrophoneCaptureEnabled"=dword:00000000
"SystemAudioGain"=hex(b):10,27,00,00,00,00,00,00
"MicrophoneGain"=hex(b):10,27,00,00,00,00,00,00




; TIME & LANGUAGE 
; Disable show the voice typing mic button
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"IsVoiceTypingKeyEnabled"=dword:00000000

; Disable capitalize the first letter of each sentence
; Disable play key sounds as i type
; Disable add a period after i double-tap the spacebar
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"EnableAutoShiftEngage"=dword:00000000
"EnableKeyAudioFeedback"=dword:00000000
"EnableDoubleTapSpace"=dword:00000000

; Disable typing insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"InsightsEnabled"=dword:00000000




; ACCOUNTS
; Disable use my sign in info after restart
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"DisableAutomaticRestartSignOn"=dword:00000001




; APPS
; Disable automatically update maps
[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
"AutoUpdateEnabled"=dword:00000000

; Disable archive apps 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Appx]
"AllowAutomaticAppArchiving"=dword:00000000




; PERSONALIZATION
; Solid color personalize your background
[HKEY_CURRENT_USER\Control Panel\Desktop]
"Wallpaper"=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers]
"BackgroundType"=dword:00000001

; Dark theme 
;[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
;"AppsUseLightTheme"=dword:00000000
;"SystemUsesLightTheme"=dword:00000000

;[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
;"AppsUseLightTheme"=dword:00000000

;[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent]
;"StartColorMenu"=dword:ff3d3f41
;"AccentColorMenu"=dword:ff484a4c
;"AccentPalette"=hex(3):DF,DE,DC,00,A6,A5,A1,00,68,65,62,00,4C,4A,48,00,41,\
;3F,3D,00,27,25,24,00,10,0D,0D,00,10,7C,10,00

;[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
;"EnableWindowColorization"=dword:00000001
;"AccentColor"=dword:ff484a4c
;"ColorizationColor"=dword:c44c4a48
;"ColorizationAfterglow"=dword:c44c4a48

; Disable transparency
;[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]
;"EnableTransparency"=dword:00000000

; Always hide most used list in start menu
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"ShowOrHideMostUsedApps"=dword:00000002

[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"ShowOrHideMostUsedApps"=-

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-
; start menu hide recommended 11
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
"HideRecommendedSection"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Education]
"IsEducationEnvironment"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"HideRecommendedSection"=dword:00000001

; More pins personalization start
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_Layout"=dword:00000001

; Disable show recently added apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"HideRecentlyAddedApps"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideRecentlyAddedApps"=dword:00000001

; Disable show account-related notifications
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_AccountNotifications"=dword:00000000

; Disable show recently opened items in start, jump lists and file explorer
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_TrackDocs"=dword:00000000 

; Left taskbar alignment
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAl"=dword:00000000

; Remove chat from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000

; Remove task view from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowTaskViewButton"=dword:00000000

; Remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; Remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh] 
"AllowNewsAndInterests"=dword:00000000

; Remove copilot from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000

; Remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

; Remove news and interests
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; Show all taskbar icons
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"EnableAutoTray"=dword:00000000

; Remove security taskbar icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
"SecurityHealth"=hex(3):07,00,00,00,05,DB,8A,69,8A,49,D9,01

; Disable use dynamic lighting on my devices
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000

; Disable compatible apps in the forground always control lighting 
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"ControlledByForegroundApp"=dword:00000000

; Disable match my windows accent color 
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"UseSystemAccentColor"=dword:00000000

; Disable show key background
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"IsKeyBackgroundEnabled"=dword:00000000

; Disable show recommendations for tips shortcuts new apps and more
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_IrisRecommendations"=dword:00000000

; Disable share any window from my taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarSn"=dword:00000000




; DEVICES
; Disable usb issues notify
[HKEY_CURRENT_USER\Software\Microsoft\Shell\USB]
"NotifyOnUsbErrors"=dword:00000000

; Disable let windows manage my default printer
[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Windows]
"LegacyDefaultPrinterMode"=dword:00000001

; Disable write with your fingertip
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\EmbeddedInkControl]
"EnableInkingWithTouch"=dword:00000000




; SYSTEM
; 100% DPI scaling
[HKEY_CURRENT_USER\Control Panel\Desktop]
"LogPixels"=dword:00000060
"Win8DpiScaling"=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\DWM]
"UseDpiScaling"=dword:00000000

; Disable fix scaling for apps
[HKEY_CURRENT_USER\Control Panel\Desktop]
"EnablePerProcessSystemDPI"=dword:00000000

; Turn on hardware accelerated gpu scheduling
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers]
"HwSchMode"=dword:00000002

; Disable variable refresh rate & enable optimizations for windowed games
[HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences]
"DirectXUserGlobalSettings"="SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;"

; Disable notifications
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications]
"ToastEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"SubscribedContent-338389Enabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
"ScoobeSystemSettingEnabled"=dword:00000000

; Disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; Disable focus assist
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\??windows.data.notifications.quiethourssettings\Current]
"Data"=hex(3):02,00,00,00,B4,67,2B,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,14,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,55,00,6E,00,72,00,65,00,73,00,74,00,72,\
00,69,00,63,00,74,00,65,00,64,00,CA,28,D0,14,02,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentfullscreen?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,97,1D,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,26,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,41,00,6C,00,61,00,72,00,6D,00,73,00,4F,\
00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentgame?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,6C,39,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,50,00,72,00,69,00,6F,00,72,00,69,00,74,\
00,79,00,4F,00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentpostoobe?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,06,54,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,50,00,72,00,69,00,6F,00,72,00,69,00,74,\
00,79,00,4F,00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentpresentation?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,83,6E,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,26,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,41,00,6C,00,61,00,72,00,6D,00,73,00,4F,\
00,6E,00,6C,00,79,00,C2,28,01,CA,50,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\?quietmomentscheduled?windows.data.notifications.quietmoment\Current]
"Data"=hex(3):02,00,00,00,2E,8A,2D,68,F0,0B,D8,01,00,00,00,00,43,42,01,00,\
C2,0A,01,D2,1E,28,4D,00,69,00,63,00,72,00,6F,00,73,00,6F,00,66,00,74,00,2E,\
00,51,00,75,00,69,00,65,00,74,00,48,00,6F,00,75,00,72,00,73,00,50,00,72,00,\
6F,00,66,00,69,00,6C,00,65,00,2E,00,50,00,72,00,69,00,6F,00,72,00,69,00,74,\
00,79,00,4F,00,6E,00,6C,00,79,00,C2,28,01,D1,32,80,E0,AA,8A,99,30,D1,3C,80,\
E0,F6,C5,D5,0E,CA,50,00,00

; Battery options optimize for video quality
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
"VideoQualityOnBattery"=dword:00000001

; Disable storage sense
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\StorageSense]
"AllowStorageSenseGlobal"=dword:00000000

; Disable snap window settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"SnapAssist"=dword:00000000
"DITest"=dword:00000000
"EnableSnapBar"=dword:00000000
"EnableTaskGroups"=dword:00000000
"EnableSnapAssistFlyout"=dword:00000000
"SnapFill"=dword:00000000
"JointResize"=dword:00000000

; Alt tab open windows only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"MultiTaskingAltTabFilter"=dword:00000003

; Disable share across devices
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP]
"RomeSdkChannelUserAuthzPolicy"=dword:00000000
"CdpSessionUserAuthzPolicy"=dword:00000000

; Disable Search Web Results
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search]
"BingSearchEnabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001

; Fix WSearch
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch]
"DelayedAutoStart"=dword:00000000

; Prevent MSDT Exploit
[-HKEY_CLASSES_ROOT\ms-msdt]

; Task Manager Always On Top
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager]
"Preferences"=hex:0d,00,00,00,60,00,00,00,60,00,00,00,82,00,00,00,82,00,00,00,\
  fd,01,00,00,f6,01,00,00,00,00,00,00,00,00,00,80,00,00,00,80,d8,01,00,80,df,\
  01,00,80,01,01,00,01,8f,02,00,00,52,00,00,00,54,06,00,00,cd,03,00,00,e8,03,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,0f,00,00,00,01,00,00,00,00,00,00,\
  00,68,aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,ea,00,00,00,\
  1e,00,00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,0d,\
  00,00,00,00,00,00,00,a8,aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,\
  ff,ff,96,00,00,00,1e,00,00,00,8b,90,00,00,01,00,00,00,00,00,00,00,00,10,10,\
  01,00,00,00,00,03,00,00,00,00,00,00,00,c0,aa,bf,d3,f6,7f,00,00,00,00,00,00,\
  00,00,00,00,ff,ff,ff,ff,78,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,\
  00,00,00,01,02,12,00,00,00,00,00,04,00,00,00,00,00,00,00,d8,aa,bf,d3,f6,7f,\
  00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,96,00,00,00,1e,00,00,00,8d,90,00,\
  00,03,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,02,00,00,00,00,00,00,00,\
  f8,aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,32,00,00,00,1e,\
  00,00,00,8a,90,00,00,04,00,00,00,00,00,00,00,00,08,20,01,00,00,00,00,05,00,\
  00,00,00,00,00,00,10,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,\
  ff,c8,00,00,00,1e,00,00,00,8e,90,00,00,05,00,00,00,00,00,00,00,00,01,10,01,\
  00,00,00,00,06,00,00,00,00,00,00,00,38,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,\
  00,00,00,ff,ff,ff,ff,04,01,00,00,1e,00,00,00,8f,90,00,00,06,00,00,00,00,00,\
  00,00,00,01,10,01,00,00,00,00,07,00,00,00,00,00,00,00,60,ab,bf,d3,f6,7f,00,\
  00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,90,90,00,00,\
  07,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,08,00,00,00,00,00,00,00,90,\
  aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,\
  00,00,91,90,00,00,08,00,00,00,01,00,00,00,00,04,25,00,00,00,00,00,09,00,00,\
  00,00,00,00,00,80,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,\
  49,00,00,00,49,00,00,00,92,90,00,00,09,00,00,00,00,00,00,00,00,04,25,08,00,\
  00,00,00,0a,00,00,00,00,00,00,00,98,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,\
  00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,93,90,00,00,0a,00,00,00,00,00,00,\
  00,00,04,25,08,00,00,00,00,0b,00,00,00,00,00,00,00,b8,ab,bf,d3,f6,7f,00,00,\
  00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,39,a0,00,00,0b,\
  00,00,00,00,00,00,00,00,04,25,09,00,00,00,00,1c,00,00,00,00,00,00,00,d8,ab,\
  bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,c8,00,00,00,49,00,00,\
  00,3a,a0,00,00,0c,00,00,00,00,00,00,00,00,01,10,09,00,00,00,00,1d,00,00,00,\
  00,00,00,00,00,ac,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,\
  00,00,00,49,00,00,00,4c,a0,00,00,0d,00,00,00,00,00,00,00,00,02,15,08,00,00,\
  00,00,1e,00,00,00,00,00,00,00,20,ac,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,\
  00,ff,ff,ff,ff,64,00,00,00,49,00,00,00,4d,a0,00,00,0e,00,00,00,00,00,00,00,\
  00,02,15,08,00,00,00,00,03,00,00,00,0a,00,00,00,01,00,00,00,00,00,00,00,68,\
  aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,d7,00,00,00,1e,00,\
  00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,04,00,00,\
  00,00,00,00,00,d8,aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,01,00,00,00,\
  96,00,00,00,1e,00,00,00,8d,90,00,00,01,00,00,00,00,00,00,00,01,01,10,00,00,\
  00,00,00,03,00,00,00,00,00,00,00,c0,aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,\
  00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,00,00,\
  00,00,02,10,00,00,00,00,00,0c,00,00,00,00,00,00,00,50,ac,bf,d3,f6,7f,00,00,\
  00,00,00,00,00,00,00,00,03,00,00,00,64,00,00,00,1e,00,00,00,94,90,00,00,03,\
  00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,0d,00,00,00,00,00,00,00,78,ac,\
  bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,\
  00,95,90,00,00,04,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,0e,00,00,00,\
  00,00,00,00,a0,ac,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,32,\
  00,00,00,1e,00,00,00,96,90,00,00,05,00,00,00,00,00,00,00,01,04,20,01,00,00,\
  00,00,0f,00,00,00,00,00,00,00,c8,ac,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,\
  00,06,00,00,00,32,00,00,00,1e,00,00,00,97,90,00,00,06,00,00,00,00,00,00,00,\
  01,04,20,01,00,00,00,00,10,00,00,00,00,00,00,00,e8,ac,bf,d3,f6,7f,00,00,00,\
  00,00,00,00,00,00,00,07,00,00,00,46,00,00,00,1e,00,00,00,98,90,00,00,07,00,\
  00,00,00,00,00,00,01,01,10,01,00,00,00,00,11,00,00,00,00,00,00,00,08,ad,bf,\
  d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,\
  99,90,00,00,08,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,06,00,00,00,00,\
  00,00,00,38,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,04,01,\
  00,00,1e,00,00,00,8f,90,00,00,09,00,00,00,00,00,00,00,01,01,10,01,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,04,00,00,00,0b,00,00,00,01,00,00,00,00,00,00,00,68,aa,bf,\
  d3,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,d7,00,00,00,00,00,00,00,\
  9e,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,12,00,00,00,00,\
  00,00,00,30,ad,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,2d,00,\
  00,00,00,00,00,00,9b,90,00,00,01,00,00,00,00,00,00,00,00,04,20,01,00,00,00,\
  00,14,00,00,00,00,00,00,00,50,ad,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,\
  ff,ff,ff,ff,64,00,00,00,00,00,00,00,9d,90,00,00,02,00,00,00,00,00,00,00,00,\
  01,10,01,00,00,00,00,13,00,00,00,00,00,00,00,78,ad,bf,d3,f6,7f,00,00,00,00,\
  00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,00,00,00,00,9c,90,00,00,03,00,00,\
  00,00,00,00,00,00,01,10,01,00,00,00,00,03,00,00,00,00,00,00,00,c0,aa,bf,d3,\
  f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,00,00,00,00,8c,\
  90,00,00,04,00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,07,00,00,00,00,00,\
  00,00,60,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,49,00,00,\
  00,49,00,00,00,90,90,00,00,05,00,00,00,00,00,00,00,01,04,21,00,00,00,00,00,\
  08,00,00,00,00,00,00,00,90,aa,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,06,\
  00,00,00,49,00,00,00,49,00,00,00,91,90,00,00,06,00,00,00,00,00,00,00,01,04,\
  21,00,00,00,00,00,09,00,00,00,00,00,00,00,80,ab,bf,d3,f6,7f,00,00,00,00,00,\
  00,00,00,00,00,07,00,00,00,49,00,00,00,49,00,00,00,92,90,00,00,07,00,00,00,\
  00,00,00,00,01,04,21,08,00,00,00,00,0a,00,00,00,00,00,00,00,98,ab,bf,d3,f6,\
  7f,00,00,00,00,00,00,00,00,00,00,08,00,00,00,49,00,00,00,49,00,00,00,93,90,\
  00,00,08,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,0b,00,00,00,00,00,00,\
  00,b8,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,49,00,00,00,\
  49,00,00,00,39,a0,00,00,09,00,00,00,00,00,00,00,01,04,21,09,00,00,00,00,1c,\
  00,00,00,00,00,00,00,d8,ab,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,0a,00,\
  00,00,64,00,00,00,00,00,00,00,3a,a0,00,00,0a,00,00,00,00,00,00,00,00,01,10,\
  09,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,02,00,00,00,08,00,00,00,01,00,00,00,00,00,00,00,68,aa,bf,d3,f6,\
  7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,c6,00,00,00,00,00,00,00,b0,90,\
  00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,15,00,00,00,00,00,00,\
  00,98,ad,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,\
  00,00,00,00,b1,90,00,00,01,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,16,\
  00,00,00,00,00,00,00,c8,ad,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,\
  ff,ff,6b,00,00,00,00,00,00,00,b2,90,00,00,02,00,00,00,00,00,00,00,00,04,25,\
  00,00,00,00,00,18,00,00,00,00,00,00,00,f0,ad,bf,d3,f6,7f,00,00,00,00,00,00,\
  00,00,00,00,ff,ff,ff,ff,6b,00,00,00,00,00,00,00,b4,90,00,00,03,00,00,00,00,\
  00,00,00,00,04,25,00,00,00,00,00,17,00,00,00,00,00,00,00,18,ae,bf,d3,f6,7f,\
  00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,00,00,00,00,b3,90,00,\
  00,04,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,19,00,00,00,00,00,00,00,\
  50,ae,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,a0,00,00,00,00,\
  00,00,00,b5,90,00,00,05,00,00,00,00,00,00,00,00,04,20,01,00,00,00,00,1a,00,\
  00,00,00,00,00,00,80,ae,bf,d3,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,\
  ff,7d,00,00,00,00,00,00,00,b6,90,00,00,06,00,00,00,00,00,00,00,00,04,20,01,\
  00,00,00,00,1b,00,00,00,00,00,00,00,b0,ae,bf,d3,f6,7f,00,00,00,00,00,00,00,\
  00,00,00,ff,ff,ff,ff,7d,00,00,00,00,00,00,00,b7,90,00,00,07,00,00,00,00,00,\
  00,00,00,04,20,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,01,00,00,04,00,00,00,00,00,00,00,00,00,00,00,30,00,5f,00,37,00,62,\
  00,65,00,33,00,5f,00,30,00,00,00,00,00,32,00,37,00,36,00,39,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,da,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,9d,20,00,00,20,00,00,00,91,00,00,00,64,00,00,00,32,00,00,00,b4,\
  01,00,00,50,00,00,00,32,00,00,00,32,00,00,00,28,00,00,00,50,00,00,00,3c,00,\
  00,00,50,00,00,00,50,00,00,00,32,00,00,00,50,00,00,00,50,00,00,00,50,00,00,\
  00,50,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,28,00,00,00,50,00,00,00,\
  23,00,00,00,23,00,00,00,23,00,00,00,23,00,00,00,50,00,00,00,50,00,00,00,50,\
  00,00,00,32,00,00,00,32,00,00,00,32,00,00,00,78,00,00,00,78,00,00,00,50,00,\
  00,00,3c,00,00,00,50,00,00,00,64,00,00,00,78,00,00,00,32,00,00,00,78,00,00,\
  00,78,00,00,00,32,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,\
  c8,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,05,\
  00,00,00,06,00,00,00,07,00,00,00,08,00,00,00,09,00,00,00,0a,00,00,00,0b,00,\
  00,00,0c,00,00,00,0d,00,00,00,0e,00,00,00,0f,00,00,00,10,00,00,00,11,00,00,\
  00,12,00,00,00,13,00,00,00,14,00,00,00,15,00,00,00,16,00,00,00,17,00,00,00,\
  18,00,00,00,19,00,00,00,1a,00,00,00,1b,00,00,00,1c,00,00,00,1d,00,00,00,1e,\
  00,00,00,1f,00,00,00,20,00,00,00,21,00,00,00,22,00,00,00,23,00,00,00,24,00,\
  00,00,25,00,00,00,26,00,00,00,27,00,00,00,28,00,00,00,29,00,00,00,2a,00,00,\
  00,2b,00,00,00,2c,00,00,00,2d,00,00,00,2e,00,00,00,2f,00,00,00,00,00,00,00,\
  00,00,00,00,1f,00,00,00,00,00,00,00,64,00,00,00,32,00,00,00,78,00,00,00,50,\
  00,00,00,50,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

; Disable Web Search
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search]
"ConnectedSearchUseWeb"=dword:00000000
"DisableWebSearch"=dword:00000001

; Disable Backup Notifications
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder]
"Enabled"=dword:00000000

; Disable Low Disk Notifications
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.LowDisk]
"Enabled"=dword:00000000

; Disable Co Installers
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer]
"DisableCoInstallers"=dword:00000001

; Disable Hardware Accel Steam
[HKEY_CURRENT_USER\SOFTWARE\Valve\Steam]
"GPUAccelWebViewsV2"=dword:00000000
"H264HWAccel"=dword:00000000

; Disable Windows Automatic Folder Type 
[HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
"FolderType"="NotSpecified"

; Disable Last Access Time
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
"NtfsDisableLastAccessUpdate"=dword:00000001
`'@

    New-Item "$env:TEMP\RegTweaks.reg" -Value $regContent -Force | Out-Null

    $OS = Get-CimInstance Win32_OperatingSystem
    if ($OS.Caption -like '*Windows 11*') {
        $regContent11 = @'
  



; --OTHER--

; STORE
; Disable update apps automatically
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore]
"AutoDownload"=dword:00000002




; EDGE
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
"StartupBoostEnabled"=dword:00000000
"HardwareAccelerationModeEnabled"=dword:00000000
"BackgroundModeEnabled"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\edgeupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\edgeupdatem]
"Start"=dword:00000004




; CHROME
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome]
"StartupBoostEnabled"=dword:00000000
"HardwareAccelerationModeEnabled"=dword:00000000
"BackgroundModeEnabled"=dword:00000000
"HighEfficiencyModeEnabled"=dword:00000001

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdatem]
"Start"=dword:00000004




; NVIDIA
; Disable nvidia tray icon
[HKEY_CURRENT_USER\Software\NVIDIA Corporation\NvTray]
"StartOnLogin"=dword:00000000

; Disable OneDrive notifications
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop]
"Enabled"=dword:00000000


; --CAN'T DO NATIVELY--




; UWP APPS
; Disable background apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000002

; Disable background apps win 11
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
"GlobalUserDisabled"=dword:00000001

; Disable windows input experience preload
[HKEY_CURRENT_USER\Software\Microsoft\input]
"IsInputAppPreloadEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Dsh]
"IsPrelaunchEnabled"=dword:00000000

; Disable web search in start menu 
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001

; Disable copilot
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; Disable widgets
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
"value"=dword:00000000




; NVIDIA
; Enable old nvidia legacy sharpening
; Old location
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS]
"EnableGR535"=dword:00000000

; New location
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters\FTS]
"EnableGR535"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters\FTS]
"EnableGR535"=dword:00000000




; POWER
; Unpark cpu cores 
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583]
"ValueMax"=dword:00000000

; Disable power throttling
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
"PowerThrottlingOff"=dword:00000001

; Disable hibernate
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power]
"HibernateEnabled"=dword:00000000
"HibernateEnabledDefault"=dword:00000000

; Disable fast boot
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power]
"HiberbootEnabled"=dword:00000000




; DISABLE ADVERTISING & PROMOTIONAL
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"ContentDeliveryAllowed"=dword:00000000
"FeatureManagementEnabled"=dword:00000000
"OemPreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEverEnabled"=dword:00000000
"RotatingLockScreenEnabled"=dword:00000000
"RotatingLockScreenOverlayEnabled"=dword:00000000
"SilentInstalledAppsEnabled"=dword:00000000
"SlideshowEnabled"=dword:00000000
"SoftLandingEnabled"=dword:00000000
"SubscribedContent-310093Enabled"=dword:00000000
"SubscribedContent-314563Enabled"=dword:00000000
"SubscribedContent-338388Enabled"=dword:00000000
"SubscribedContent-338389Enabled"=dword:00000000
"SubscribedContent-338389Enabled"=dword:00000000
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000
"SubscribedContent-353698Enabled"=dword:00000000
"SubscribedContentEnabled"=dword:00000000
"SystemPaneSuggestionsEnabled"=dword:00000000




; OTHER
; Remove 3d objects
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

[-HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

; Remove quick access
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
"HubMode"=dword:00000001

; Remove home
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]

; Remove gallery
[HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
"System.IsPinnedToNameSpaceTree"=dword:00000000

; Remove gallery shortcut from file explorer
[-HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]

; Restore the classic context menu
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; Disable menu show delay
[HKEY_CURRENT_USER\Control Panel\Desktop]
"MenuShowDelay"="0"

; Disable driver searching & updates
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"SearchOrderConfig"=dword:00000000

; Mouse fix (no accel with epp on)
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSensitivity"="10"
"SmoothMouseXCurve"=hex:\
00,00,00,00,00,00,00,00,\
C0,CC,0C,00,00,00,00,00,\
80,99,19,00,00,00,00,00,\
40,66,26,00,00,00,00,00,\
00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:\
00,00,00,00,00,00,00,00,\
00,00,38,00,00,00,00,00,\
00,00,70,00,00,00,00,00,\
00,00,A8,00,00,00,00,00,\
00,00,E0,00,00,00,00,00

[HKEY_USERS\.DEFAULT\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"
"@
  Set-Content -Path "$env:TEMP\Registry Optimize.reg" -Value $MultilineComment -Force
  $path = "$env:TEMP\Registry Optimize.reg"
  (Get-Content $path) -replace "\?","$" | Out-File $path
  Regedit.exe /S "$env:TEMP\Registry Optimize.reg"
  Clear-Host
  
  #Disable Online tips in Settings
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "AllowOnlineTips" -Value 0 -Type DWord
  #Remove Health Check
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\PCHC" -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PCHC" -Name "PreviousUninstall" -Value 1 -Type DWord
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\PCHealthCheck" -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PCHealthCheck" -Name "installed" -Value 1 -Type DWord
  # Disable Windows Spotlight
  $RegKeyCloudContent = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
  $RegKeyPersonalization = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
  New-Item -Path $RegKeyCloudContent -Force | Out-Null
  New-Item -Path $RegKeyPersonalization -Force | Out-Null
  Set-ItemProperty -Path $RegKeyCloudContent -Name "DisableWindowsSpotlightWindowsWelcomeExperience" -Value 1 -Type DWord
  Set-ItemProperty -Path $RegKeyPersonalization -Name "NoChangingLockScreen" -Value 0 -Type DWord
  Set-ItemProperty -Path $RegKeyCloudContent -Name "DisableWindowsSpotlightFeatures" -Value 1 -Type DWord
  Set-ItemProperty -Path $RegKeyCloudContent -Name "DisableWindowsSpotlightOnActionCenter" -Value 1 -Type DWord
  Set-ItemProperty -Path $RegKeyCloudContent -Name "DisableWindowsSpotlightOnSettings" -Value 1 -Type DWord
  Set-ItemProperty -Path $RegKeyCloudContent -Name "DisableThirdPartySuggestions" -Value 1 -Type DWord

  #Set 24h time for lockscreen
  Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "HH:mm"
  Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss"
  $exportFile = "$env:TEMP\intl.reg"
  reg export "HKCU\Control Panel\International" $exportFile /y
  reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
  reg import $exportFile
  reg unload "HKU\DefaultUser"
  reg load "HKU\DefaultSystem" "C:\Windows\System32\config\systemprofile\NTUSER.DAT"
  reg import $exportFile
  reg unload "HKU\DefaultSystem"
  Remove-Item $exportFile

  Write-Host "Applying compact mode for explorer and small icons for desktop..."
  Start-Sleep -Seconds 3
  reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseCompactMode" /t REG_DWORD /d "1" /f | Out-Null
  Clear-Host
  
  $desktopIconSizeKey = "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop"
  $iconSizeValue = 32
  
  If (-not (Test-Path $desktopIconSizeKey)) {
  New-Item -Path $desktopIconSizeKey -Force
  }
  Set-ItemProperty -Path $desktopIconSizeKey -Name IconSize -Value $iconSizeValue
  
  Stop-Process -Name explorer -Force
  Start-Process explorer
  Clear-Host
  
  Write-Host "Removing OneDrive..."
  Start-Sleep -Seconds 3
  taskkill.exe /F /IM "OneDrive.exe"
  taskkill.exe /F /IM "explorer.exe"
  
  if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
      & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
  }
  if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
      & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
  }
  
  Write-Output "Removing OneDrive leftovers..."
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
  If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
  }
  
  
  Write-Output "Removing Onedrive from explorer sidebar..."
  New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
  mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
  Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
  mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
  Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
  Remove-PSDrive "HKCR"
  
  reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
  reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
  reg unload "hku\Default"
  
  Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
  
  Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
  
  Start-Sleep -Seconds 1
  Start-Process "explorer.exe"
  Start-Sleep 3
  Clear-Host
  Write-Host "Registry tweaks applied."
  }

function Remove-UWPApps {
  Clear-Host
  Write-Host "Removing UWP Apps... (sometimes closes script on first run -> Run it twice)"
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  # CBS needed for Windows 11 Explorer
  Get-AppXPackage -AllUsers | Where-Object { $_.Name -notlike '*NVIDIA*' -and $_.Name -notlike '*CBS*' } | Remove-AppxPackage -ErrorAction SilentlyContinue
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
  Get-AppXPackage -AllUsers *Microsoft.Microsoft.StorePurchaseApp * | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Get-AppXPackage -AllUsers *Microsoft.WindowsCalculator * | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
  Timeout /T 2 | Out-Null
  Clear-Host
  Write-Host "UWP Apps removed."
}

function Remove-UWPFeatures {
  Clear-Host
  Write-Host "Removing UWP Features..."
  Start-Sleep -Seconds 3
  Remove-WindowsCapability -Online -Name "App.StepsRecorder~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "App.Support.QuickAssist~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Browser.InternetExplorer~~~~0.0.11.0" | Out-Null
  Remove-WindowsCapability -Online -Name "DirectX.Configuration.Database~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Hello.Face.18967~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Hello.Face.20134~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "MathRecognizer~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Media.WindowsMediaPlayer~~~~0.0.12.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Microsoft.Wallpapers.Extended~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Microsoft.Windows.MSPaint~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Microsoft.Windows.WordPad~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "OneCoreUAP.OneSync~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Print.Fax.Scan~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "Print.Management.Console~~~~0.0.1.0" | Out-Null
  Remove-WindowsCapability -Online -Name "WMIC~~~~" | Out-Null
  Remove-WindowsCapability -Online -Name "Windows.Kernel.LA57~~~~0.0.1.0" | Out-Null
  Clear-Host
  Write-Host "UWP Features removed."
}

function Remove-LegacyFeatures {
  Clear-Host
  Write-Host "Uninstalling Legacy Features..."
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
  Write-Host "Legacy Features uninstalled."
}

function Remove-LegacyApps {
  Clear-Host
  Write-Host "Uninstalling Legacy Apps..."
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
  Write-Host "Legacy Apps uninstalled."
}

function Optimize-Network {
  Clear-Host
  Write-Host "Optimizing network adapter settings..."
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  # Disable all adapter settings keep ipv4
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
  Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue
  # Rerun so settings stick
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
  Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue
  
  Clear-Host
  Write-Host "Applying Cloudflare DNS servers for adapter..."
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1","1.0.0.1")
  
  Clear-Host
  Write-Host 'Applying network settings to limit upload bandwidth and improve latency under load...'
      Start-Sleep -Seconds 3
     
      $NIC = @()
      foreach ($a in Get-NetAdapter -Physical | Select-Object DeviceID, Name) { 
        $NIC += @{ $($a | Select-Object Name -ExpandProperty Name) = $($a | Select-Object DeviceID -ExpandProperty DeviceID) }
      }
      
  
      $enableQos = {    
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' 'Do not use NLA' 1 -type string -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' DisableUserTOSSetting 0 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' NonBestEffortLimit 80 -type dword -force -ea 0 
        Get-NetQosPolicy | Remove-NetQosPolicy -Confirm:$False -ea 0
        Remove-NetQosPolicy 'Bufferbloat' -Confirm:$False -ea 0
        New-NetQosPolicy 'Bufferbloat' -Precedence 254 -DSCPAction 46 -NetworkProfile Public -Default -MinBandwidthWeightAction 25
      }
      &$enableQos *>$null
  
      $tcpTweaks = {
        $NIC.Values | ForEach-Object {
          Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$_" TcpAckFrequency 2 -type dword -force -ea 0  
          Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$_" TcpNoDelay 1 -type dword -force -ea 0
        }
        if (Get-Item 'HKLM:\SOFTWARE\Microsoft\MSMQ') { Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters' TCPNoDelay 1 -type dword -force -ea 0 }
        Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' NetworkThrottlingIndex 0xffffffff -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' SystemResponsiveness 10 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' NonBestEffortLimit 80 -type dword -force -ea 0 
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' LargeSystemCache 0 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' Size 3 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' DefaultTTL 64 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' MaxUserPort 65534 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' TcpTimedWaitDelay 30 -type dword -force -ea 0
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' 'Do not use NLA' 1 -type string -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' DnsPriority 6 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' HostsPriority 5 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' LocalPriority 4 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' NetbtPriority 7 -type dword -force -ea 0
        Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' DisableTaskOffload -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' MaximumReassemblyHeaders 0xffff -type dword -force -ea 0 
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters' FastSendDatagramThreshold 1500 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters' DefaultReceiveWindow $(2048 * 4096) -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters' DefaultSendWindow $(2048 * 4096) -type dword -force -ea 0
      }
      &$tcpTweaks *>$null
  
  
      $NIC.Keys | ForEach-Object { Disable-NetAdapter -InterfaceAlias "$_" -Confirm:$False }
  
      $netAdaptTweaks = {
        foreach ($key in $NIC.Keys) {
          $netProperty = Get-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'NetworkAddress' -ErrorAction SilentlyContinue
          if ($null -ne $netProperty.RegistryValue -and $netProperty.RegistryValue -ne ' ') {
            $mac = $netProperty.RegistryValue 
          }
          Get-NetAdapter -Name "$key" | Reset-NetAdapterAdvancedProperty -DisplayName '*'
          if ($null -ne $mac) { 
            Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'NetworkAddress' -RegistryValue $mac 
          }
          $rx = (Get-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*ReceiveBuffers').NumericParameterMaxValue  
          $tx = (Get-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*TransmitBuffers').NumericParameterMaxValue
          if ($null -ne $rx -and $null -ne $tx) {
            Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*ReceiveBuffers' -RegistryValue $rx # $rx 1024 320
            Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*TransmitBuffers' -RegistryValue $tx # $tx 2048 160
          }
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*InterruptModeration' -RegistryValue 0 # Off 0 On 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'ITR' -RegistryValue 0 # Off 0 Adaptive 65535
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*RSS' -RegistryValue 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*NumRssQueues' -RegistryValue 2
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*PriorityVLANTag' -RegistryValue 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*FlowControl' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*JumboPacket' -RegistryValue 1514
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*HeaderDataSplit' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'TcpSegmentation' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'RxOptimizeThreshold' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'WaitAutoNegComplete' -RegistryValue 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'PowerSavingMode' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*SelectiveSuspend' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'EnableGreenEthernet' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'AdvancedEEE' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'EEE' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*EEE' -RegistryValue 0
        }
  
      }
      &$netAdaptTweaks *>$null
  
  
      $netAdaptTweaks2 = { $NIC.Keys | ForEach-Object {
          Set-NetAdapterRss -Name "$_" -NumberOfReceiveQueues 2 -MaxProcessorNumber 4 -Profile 'NUMAStatic' -Enabled $true -ea 0
          Enable-NetAdapterQos -Name "$_" -ea 0
          Enable-NetAdapterChecksumOffload -Name "$_" -ea 0
          Disable-NetAdapterRsc -Name "$_" -ea 0
          Disable-NetAdapterUso -Name "$_" -ea 0
          Disable-NetAdapterLso -Name "$_" -ea 0
          Disable-NetAdapterIPsecOffload -Name "$_" -ea 0
          Disable-NetAdapterEncapsulatedPacketTaskOffload -Name "$_" -ea 0
        }
          
        Set-NetOffloadGlobalSetting -TaskOffload Enabled
        Set-NetOffloadGlobalSetting -Chimney Disabled
        Set-NetOffloadGlobalSetting -PacketCoalescingFilter Disabled
        Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing Disabled
        Set-NetOffloadGlobalSetting -ReceiveSideScaling Enabled
        Set-NetOffloadGlobalSetting -NetworkDirect Enabled
        Set-NetOffloadGlobalSetting -NetworkDirectAcrossIPSubnets Allowed -ea 0
      }
      &$netAdaptTweaks2 *>$null
  
      $NIC.Keys | ForEach-Object { Enable-NetAdapter -InterfaceAlias "$_" -Confirm:$False }
  
      $netShTweaks = {
        netsh winsock set autotuning on                                    # Winsock send autotuning
        netsh int udp set global uro=disabled                              # UDP Receive Segment Coalescing Offload - 11 24H2
        netsh int tcp set heuristics wsh=disabled forcews=enabled          # Window Scaling heuristics
        netsh int tcp set supplemental internet minrto=300                 # Controls TCP retransmission timeout. 20 to 300 msec.
        netsh int tcp set supplemental internet icw=10                     # Controls initial congestion window. 2 to 64 MSS
        netsh int tcp set supplemental internet congestionprovider=newreno # Controls the congestion provider. Default: cubic
        netsh int tcp set supplemental internet enablecwndrestart=disabled # Controls whether congestion window is restarted.
        netsh int tcp set supplemental internet delayedacktimeout=40       # Controls TCP delayed ack timeout. 10 to 600 msec.
        netsh int tcp set supplemental internet delayedackfrequency=2      # Controls TCP delayed ack frequency. 1 to 255.
        netsh int tcp set supplemental internet rack=enabled               # Controls whether RACK time based recovery is enabled.
        netsh int tcp set supplemental internet taillossprobe=enabled      # Controls whether Tail Loss Probe is enabled.
        netsh int tcp set security mpp=disabled                            # Memory pressure protection (SYN flood drop)
        netsh int tcp set security profiles=disabled                       # Profiles protection (private vs domain)
  
        netsh int tcp set global rss=enabled                    # Enable receive-side scaling.
        netsh int tcp set global autotuninglevel=Normal         # Fix the receive window at its default value
        netsh int tcp set global ecncapability=enabled          # Enable/disable ECN Capability.
        netsh int tcp set global timestamps=enabled             # Enable/disable RFC 1323 timestamps.
        netsh int tcp set global initialrto=1000                # Connect (SYN) retransmit time (in ms).
        netsh int tcp set global rsc=disabled                   # Enable/disable receive segment coalescing.
        netsh int tcp set global nonsackrttresiliency=disabled  # Enable/disable rtt resiliency for non sack clients.
        netsh int tcp set global maxsynretransmissions=4        # Connect retry attempts using SYN packets.
        netsh int tcp set global fastopen=enabled               # Enable/disable TCP Fast Open.
        netsh int tcp set global fastopenfallback=enabled       # Enable/disable TCP Fast Open fallback.
        netsh int tcp set global hystart=enabled                # Enable/disable the HyStart slow start algorithm.
        netsh int tcp set global prr=enabled                    # Enable/disable the Proportional Rate Reduction algorithm.
        netsh int tcp set global pacingprofile=off              # Set the periods during which pacing is enabled. off: Never pace.
  
        netsh int ip set global loopbacklargemtu=enable         # Loopback Large Mtu
        netsh int ip set global loopbackworkercount=4           # Loopback Worker Count 1 2 4
        netsh int ip set global loopbackexecutionmode=inline    # Loopback Execution Mode adaptive|inline|worker
        netsh int ip set global reassemblylimit=267748640       # Reassembly Limit 267748640|0
        netsh int ip set global reassemblyoutoforderlimit=48    # Reassembly Out Of Order Limit 32
        netsh int ip set global sourceroutingbehavior=drop      # Source Routing Behavior drop|dontforward
        netsh int ip set dynamicport tcp start=32769 num=32766  # DynamicPortRange tcp
        netsh int ip set dynamicport udp start=32769 num=32766  # DynamicPortRange udp
      }
      &$netShTweaks *>$null
      Write-Host "Successfully applied network tweaks." -ForegroundColor Green
      Start-Sleep -Seconds 3  
}
  


function Update-Hostsfile {
  Clear-Host
  Write-Host "Updating hosts file... (Breaks Microsoft Store Installs and some Microsoft sites)"
  Start-Sleep -Seconds 3
  
  
  $hostsFile = "$env:windir\System32\drivers\etc\hosts"
  
$hostEntries = @"
127.0.0.1 activity.windows.com
127.0.0.1 tile-service.weather.microsoft.com
127.0.0.1 evoke-windowsservices-tas.msedge.net
127.0.0.1 cdn.onenote.net
#127.0.0.1  spclient.wg.spotify.com
127.0.0.1 ctldl.windowsupdate.com
127.0.0.1 www.bing.com
127.0.0.1 fp.msedge.net
127.0.0.1 k-ring.msedge.net
127.0.0.1 b-ring.msedge.net
127.0.0.1 www.bing.com
#127.0.0.1  login.live.com
127.0.0.1 cs.dds.microsoft.com
127.0.0.1 dmd.metaservices.microsoft.com
127.0.0.1 v10.events.data.microsoft.com
127.0.0.1 watson.telemetry.microsoft.com
127.0.0.1 fs.microsoft.com
127.0.0.1 licensing.mp.microsoft.com
127.0.0.1 inference.location.live.net
127.0.0.1 maps.windows.com
127.0.0.1 ssl.ak.dynamic.tiles.virtualearth.net
127.0.0.1 ssl.ak.tiles.virtualearth.net
127.0.0.1 dev.virtualearth.net
127.0.0.1 ecn.dev.virtualearth.net
127.0.0.1 ssl.bing.com
#127.0.0.1  login.live.com
127.0.0.1 edge.activity.windows.com
127.0.0.1 edge.microsoft.com
127.0.0.1 msedge.api.cdp.microsoft.com
#127.0.0.1  go.microsoft.com/fwlink
#127.0.0.1  go.microsoft.com
127.0.0.1 img-prod-cms-rt-microsoft-com.akamaized.net
127.0.0.1 wns.windows.com
127.0.0.1 storecatalogrevocation.storequality.microsoft.com
127.0.0.1 displaycatalog.mp.microsoft.com
127.0.0.1 storesdk.dsx.mp.microsoft.com
127.0.0.1 pti.store.microsoft.com
127.0.0.1 manage.devcenter.microsoft.com
127.0.0.1 store-images.s-microsoft.com
127.0.0.1 www.msftconnecttest.com
127.0.0.1 outlook.office365.com
127.0.0.1 office.com
127.0.0.1 blobs.officehome.msocdn.com
127.0.0.1 officehomeblobs.blob.core.windows.net
127.0.0.1 blob.core.windows.net
127.0.0.1 self.events.data.microsoft.com
127.0.0.1 outlookmobile-office365-tas.msedge.net
127.0.0.1 roaming.officeapps.live.com
127.0.0.1 substrate.office.com
127.0.0.1 g.live.com
127.0.0.1 oneclient.sfx.ms
127.0.0.1 logincdn.msauth.net
127.0.0.1 windows.policies.live.net
127.0.0.1 api.onedrive.com
127.0.0.1 skydrivesync.policies.live.net
127.0.0.1 storage.live.com
127.0.0.1 settings.live.net
127.0.0.1 settings.data.microsoft.com
127.0.0.1 settings-win.data.microsoft.com
127.0.0.1 pipe.aria.microsoft.com
127.0.0.1 config.edge.skype.com
127.0.0.1 config.teams.microsoft.com
127.0.0.1 wdcp.microsoft.com
127.0.0.1 smartscreen-prod.microsoft.com
127.0.0.1 definitionupdates.microsoft.com
127.0.0.1 smartscreen.microsoft.com
127.0.0.1 checkappexec.microsoft.com
127.0.0.1 arc.msn.com
127.0.0.1 ris.api.iris.microsoft.com
127.0.0.1 mucp.api.account.microsoft.com
127.0.0.1 prod.do.dsp.mp.microsoft.com
127.0.0.1 emdl.ws.microsoft.com
127.0.0.1 dl.delivery.mp.microsoft.com
127.0.0.1 windowsupdate.com
127.0.0.1 delivery.mp.microsoft.com
127.0.0.1 update.microsoft.com
127.0.0.1 adl.windows.com
127.0.0.1 tsfe.trafficshaping.dsp.mp.microsoft.com
127.0.0.1 dlassets-ssl.xboxlive.com
127.0.0.1 da.xboxservices.com
127.0.0.1 www.xboxab.com
0.0.0.0     accounts.firefox.com
0.0.0.0     accounts-static.cdn.mozilla.net
0.0.0.0     activations.cdn.mozilla.net
0.0.0.0     api.accounts.firefox.com
0.0.0.0     autopush.prod.mozaws.net
0.0.0.0     blocklist.addons.mozilla.org
0.0.0.0     blocklists.settings.services.mozilla.com
0.0.0.0     classify-client.services.mozilla.com
0.0.0.0     code.cdn.mozilla.net
0.0.0.0     color.firefox.com
0.0.0.0     content.cdn.mozilla.net
0.0.0.0     content-signature-2.cdn.mozilla.net
0.0.0.0     content-signature.cdn.mozilla.net
0.0.0.0     coverage.mozilla.org
0.0.0.0     crash-reports.mozilla.com
0.0.0.0     crash-stats.mozilla.com
0.0.0.0     discovery.addons.mozilla.org
0.0.0.0     experiments.mozilla.org
0.0.0.0     fastestfirefox.com
0.0.0.0     fhr.cdn.mozilla.net
0.0.0.0     firefox.settings.services.mozilla.com
0.0.0.0     firefoxusercontent.com
0.0.0.0     getpocket.cdn.mozilla.net
0.0.0.0     img-getpocket.cdn.mozilla.net
0.0.0.0     incoming.telemetry.mozilla.org
0.0.0.0     input.mozilla.org
0.0.0.0     install.mozilla.org
0.0.0.0     location.services.mozilla.com
0.0.0.0     mitmdetection.services.mozilla.com
0.0.0.0     normandy.cdn.mozilla.net
0.0.0.0     normandy-cloudfront.cdn.mozilla.net
0.0.0.0     oauth.accounts.firefox.com
0.0.0.0     onyx_tiles.stage.mozaws.net
0.0.0.0     ostats.mozilla.com
0.0.0.0     outgoing.prod.mozaws.net
0.0.0.0     profile.accounts.firefox.com
0.0.0.0     profiler.firefox.com
0.0.0.0     push.services.mozilla.com
0.0.0.0     qsurvey.mozilla.com
0.0.0.0     search.services.mozilla.com
0.0.0.0     self-repair.mozilla.org
0.0.0.0     sentry.prod.mozaws.net
0.0.0.0     shavar.services.mozilla.com
0.0.0.0     snippets.cdn.mozilla.net
0.0.0.0     sync.services.mozilla.com
0.0.0.0     telemetry-coverage.mozilla.org
0.0.0.0     telemetry-experiment.cdn.mozilla.net
0.0.0.0     telemetry.mozilla.org
0.0.0.0     testpilot.firefox.com
0.0.0.0     tiles-cloudfront.cdn.mozilla.net
0.0.0.0     tiles.services.mozilla.com
0.0.0.0     token.services.mozilla.com
0.0.0.0     token.services.mozilla.org
0.0.0.0     tracking-protection.cdn.mozilla.net
0.0.0.0     start.thunderbird.net
0.0.0.0     live.mozillamessaging.com
0.0.0.0     live.thunderbird.net
0.0.0.0     broker-live.mozillamessaging.com
"@
  
  Copy-Item $hostsFile "$hostsFile.bak" -Force
  Add-Content -Path $hostsFile -Value "`n$hostEntries" -Force
  
  Write-Host "Hosts file updated successfully."
  Start-Sleep -Seconds 3
}

function Install-ContextMenus {
  Clear-Host
  Write-Host "Installing ContextMenu entries..."
  Start-Sleep -Seconds 3
    $MultilineComment = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\admintools]
@="Administrative Tools"
"icon"="imageres.dll,109"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\admintools\command]
@="control admintools"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\advancedoptions]
@="Pokrenite sa naprednim opcijama"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\advancedoptions\command]
@="Shutdown -r -o -f -t 00"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz]
@="Programs and Features"
"icon"="appwiz.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz\command]
@="control appwiz.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cleanmgr]
@="Disk Cleanup"
"icon"="cleanmgr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cleanmgr\command]
@="cleanmgr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\control]
@="Control Panel"
"icon"="control.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\control\command]
@="control.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\datetime]
@="Change Date and Time"
"icon"="timedate.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\datetime\command]
@="control timedate.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\devmgr]
@="Device Manager"
"Icon"=hex(2):64,00,65,00,76,00,6d,00,67,00,72,00,2e,00,64,00,6c,00,6c,00,00,\
  00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\devmgr\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,6d,00,\
  63,00,2e,00,65,00,78,00,65,00,20,00,2f,00,73,00,20,00,25,00,53,00,79,00,73,\
  00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,\
  74,00,65,00,6d,00,33,00,32,00,5c,00,64,00,65,00,76,00,6d,00,67,00,6d,00,74,\
  00,2e,00,6d,00,73,00,63,00,00,00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\event]
@="Event Viewer"
"icon"="eventvwr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\event\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,6d,00,\
  63,00,2e,00,65,00,78,00,65,00,20,00,2f,00,73,00,20,00,25,00,53,00,79,00,73,\
  00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,\
  74,00,65,00,6d,00,33,00,32,00,5c,00,65,00,76,00,65,00,6e,00,74,00,76,00,77,\
  00,72,00,2e,00,6d,00,73,00,63,00,00,00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\flip3d]
@="Window Switcher"
"icon"="imageres.dll,0"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\flip3d\command]
@="explorer shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folderoptions]
@="Folder Options"
"icon"="explorer.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folderoptions\command]
@="control folders"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\gmode]
@="God Mode"
"icon"="control.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\gmode\command]
@="explorer shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\internetoptions]
@="Internet Options"
"icon"="inetcpl.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\internetoptions\command]
@="control inetcpl.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lock]
@="Zakljucaj"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lock\command]
@="Rundll32 User32.dll,LockWorkStation"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff]
@="Odjava"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff\command]
@="Shutdown -l"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig]
@="System Configuration"
"icon"="msconfig.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig\command]
@="msconfig.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\network]
@="Network Connections"
"icon"="ncpa.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\network\command]
@="control ncpa.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\power]
@="Power Options"
"icon"="powercfg.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\power\command]
@="control powercfg.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rbin]
@="Recycle Bin"
"icon"="imageres.dll,50"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rbin\command]
@="explorer shell:::{645FF040-5081-101B-9F08-00AA002F954E}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regedit]
@="Registry Editor"
"icon"="regedit.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regedit\command]
@="regedit.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regional]
@="Change Regional Settings"
"icon"="intl.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regional\command]
@="control intl.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\restart]
@="Ponovno pokreni"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\restart\command]
@="Shutdown -r -f -t 00"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\run]
@="Run"
"icon"="shell32.dll,24"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\run\command]
@="explorer shell:::{2559A1F3-21D7-11D4-BDAF-00C04F60B9F0}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\search]
@="Search"
"icon"="shell32.dll,22"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\search\command]
@="explorer shell:::{2559A1F0-21D7-11D4-BDAF-00C04F60B9F0}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\secctr]
@="Security Center"
"icon"="wscui.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\secctr\command]
@="control wscui.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services]
@="Services"
"icon"="filemgmt.dll"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,6d,00,\
  63,00,2e,00,65,00,78,00,65,00,20,00,2f,00,73,00,20,00,25,00,53,00,79,00,73,\
  00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,\
  74,00,65,00,6d,00,33,00,32,00,5c,00,73,00,65,00,72,00,76,00,69,00,63,00,65,\
  00,73,00,2e,00,6d,00,73,00,63,00,00,00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\shutdown]
@="Iskljuci racunalo"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\shutdown\command]
@="Shutdown -s -f -t 00"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sleep]
@="Stanje mirovanja"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sleep\command]
@="rundll32.exe powrprof.dll,SetSuspendState Sleep"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\switch]
@="Promijeni korisnika"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\switch\command]
@="tsdiscon.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdm]
@="System Properties"
"icon"="sysdm.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdm\command]
@="control sysdm.cpl"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskmgr]
@="Task Manager"
"icon"="taskmgr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskmgr\command]
@="taskmgr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskschd]
@="Task Scheduler"
"icon"="miguiresource.dll,1"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskschd\command]
@="Control schedtasks"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\user]
@="User Accounts"
"icon"="imageres.dll,74"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\user\command]
@="Control userpasswords"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\user2]
@="User Accounts Classic"
"icon"="shell32.dll,111"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\user2\command]
@="Control userpasswords2"

[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemShortcuts]
"MUIVerb"="System Shortcuts"
"SubCommands"="admintools;datetime;regional;folderoptions;gmode;internetoptions;network;power;appwiz;rbin;run;search;services;sysdm;user;user2;flip3d"
"icon"="sysdm.cpl"

[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemTools]
"MUIVerb"="System Tools"
"SubCommands"="control;cleanmgr;devmgr;event;regedit;secctr;msconfig;taskmgr;taskschd;wu"
"icon"="imageres.dll,104"
"@

    $regFile = Join-Path $env:TEMP "ContextMenu.reg"
    Set-Content -Path $regFile -Value $MultilineComment -Force -Encoding Unicode

    Start-Process regedit.exe -ArgumentList "/s `"$regFile`"" -Wait -NoNewWindow
  
  # Add "Copy as Path" to Right Click Context Menu
  if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath") -ne $true) {New-Item "HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath" -Force | Out-Null}
  New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath' -Name '(default)' -Value 'Copy &as path' -PropertyType String -Force | Out-Null
  New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath' -Name 'InvokeCommandOnSelection' -Value "1" -PropertyType DWord -Force | Out-Null
  New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath' -Name 'VerbHandler' -Value '{f3d06e7c-1e45-4a26-847e-f9fcdee59be0}' -PropertyType String -Force | Out-Null
  New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath' -Name 'VerbName' -Value 'copyaspath' -PropertyType String -Force | Out-Null
  New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Allfilesystemobjects\shell\windows.copyaspath' -Name 'Icon' -Value 'imageres.dll,-5302' -PropertyType String -Force | Out-Null
  Write-Host "Explorer: 'Copy as Path' - Right Click Context Menu [ADDED]" -ForegroundColor Green
  
  $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"

if (-not (Test-Path $pwshPath)) {
    Write-Host "PowerShell 7 not found. Installing with winget..." -ForegroundColor Yellow
    Start-Process "winget" -ArgumentList "install --id Microsoft.Powershell --source winget --silent --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
}

$keys = @(
    "HKLM:\SOFTWARE\Classes\Directory\Background\shell\PowerShell7AsAdmin",
    "HKLM:\SOFTWARE\Classes\Directory\Background\shell\PowerShell7AsAdmin\command",
    "HKLM:\SOFTWARE\Classes\Directory\shell\PowerShell7AsAdmin",
    "HKLM:\SOFTWARE\Classes\Directory\shell\PowerShell7AsAdmin\command",
    "HKLM:\SOFTWARE\Classes\Drive\shell\PowerShell7AsAdmin",
    "HKLM:\SOFTWARE\Classes\Drive\shell\PowerShell7AsAdmin\command"
)

foreach ($key in $keys) {
    if (-not (Test-Path $key)) {
        New-Item $key -Force | Out-Null
    }
}

Remove-Item -LiteralPath "HKLM:\SOFTWARE\Classes\LibraryFolder\Background\shell\PowerShell7AsAdmin" -Force -ErrorAction SilentlyContinue | Out-Null

$menuName = "Open with PowerShell 7 (Admin)"
$command = 'powershell -WindowStyle Hidden -NoProfile -Command "Start-Process -Verb RunAs pwsh.exe -ArgumentList ''-NoExit'',''-Command'',''Push-Location \"\"%V\"\"''"'


New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\PowerShell7AsAdmin' -Name '(default)' -Value $menuName -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\PowerShell7AsAdmin' -Name 'HasLUAShield' -Value '' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\PowerShell7AsAdmin' -Name 'Icon' -Value 'pwsh.exe' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\PowerShell7AsAdmin\command' -Name '(default)' -Value $command -Force | Out-Null

New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\shell\PowerShell7AsAdmin' -Name '(default)' -Value $menuName -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\shell\PowerShell7AsAdmin' -Name 'HasLUAShield' -Value '' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\shell\PowerShell7AsAdmin' -Name 'Icon' -Value 'pwsh.exe' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\shell\PowerShell7AsAdmin\command' -Name '(default)' -Value $command -Force | Out-Null

New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Drive\shell\PowerShell7AsAdmin' -Name '(default)' -Value $menuName -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Drive\shell\PowerShell7AsAdmin' -Name 'HasLUAShield' -Value '' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Drive\shell\PowerShell7AsAdmin' -Name 'Icon' -Value 'pwsh.exe' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Classes\Drive\shell\PowerShell7AsAdmin\command' -Name '(default)' -Value $command -Force | Out-Null

Write-Host "Explorer: '$menuName' - Right Click Context Menu [ADDED]" -ForegroundColor Green
  Start-Sleep -Seconds 3
}


function Remove-ScheduledTasks {
  Clear-Host
  Write-Host "Removing unnecessary scheduled tasks..."
  Start-Sleep -Seconds 3
  $services = Get-Service
  $servicesKeep = 'AudioEndpointBuilder
  Audiosrv
  EventLog
  SysMain
  Themes
  WSearch
  NVDisplay.ContainerLocalSystem
  WlanSvc'
  foreach ($service in $services) { 
    if ($service.StartType -like '*Auto*') {
      if (!($servicesKeep -match $service.Name)) {
          
        Set-Service -Name $service.Name -StartupType Manual -ErrorAction SilentlyContinue
         
      }         
    }
  }
  Clear-Host
  Start-Sleep -Seconds 3
  
}

function Optimize-AdvancedTweaks {
  Clear-Host
  Start-Sleep -Seconds 3

  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security' /V 'DisableSecuritySettingsCheck' /T 'REG_DWORD' /D '00000001' /F
  Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3' /V '1806' /T 'REG_DWORD' /D '00000000' /F
  Reg.exe add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3' /V '1806' /T 'REG_DWORD' /D '00000000' /F


  Write-Host 'Showing All Apps on Taskbar'
  Start-Sleep -Seconds 3
  Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer' /v 'EnableAutoTray' /t REG_DWORD /d '0' /f
  $keys = Get-ChildItem -Path 'registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings' -Recurse -Force
  foreach ($key in $keys) {
    Set-ItemProperty -Path "registry::$key" -Name 'IsPromoted' -Value 1 -Force

  }

  $scriptContent = @"
`$keys = Get-ChildItem -Path 'registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings' -Recurse -Force

foreach (`$key in `$keys) {
# If the value is set to 0 do not set it to 1
# Set 1 when no reg key is there (new apps)
if ((Get-ItemProperty -Path "registry::`$key").IsPromoted -eq 0) {
}
else {
    Set-ItemProperty -Path "registry::`$key" -Name 'IsPromoted' -Value 1 -Force
}
}
"@

  $scriptPath = "$env:ProgramData\UpdateTaskTrayIcons.ps1"
  Set-Content -Path $scriptPath -Value $scriptContent -Force

  $currentUserName = $env:COMPUTERNAME + '\' + $env:USERNAME
  $username = Get-LocalUser -Name $env:USERNAME | Select-Object -ExpandProperty sid

  $content = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo>
<Date>2024-05-20T12:59:50.8741407</Date>
<Author>$currentUserName</Author>
<URI>\UpdateTaskTray</URI>
</RegistrationInfo>
<Triggers>
<LogonTrigger>
  <Enabled>true</Enabled>
</LogonTrigger>
</Triggers>
<Principals>
<Principal id="Author">
  <UserId>$username</UserId>
  <LogonType>InteractiveToken</LogonType>
  <RunLevel>HighestAvailable</RunLevel>
</Principal>
</Principals>
<Settings>
<MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
<DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
<StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
<AllowHardTerminate>true</AllowHardTerminate>
<StartWhenAvailable>false</StartWhenAvailable>
<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
<IdleSettings>
  <StopOnIdleEnd>true</StopOnIdleEnd>
  <RestartOnIdle>false</RestartOnIdle>
</IdleSettings>
<AllowStartOnDemand>true</AllowStartOnDemand>
<Enabled>true</Enabled>
<Hidden>false</Hidden>
<RunOnlyIfIdle>false</RunOnlyIfIdle>
<WakeToRun>false</WakeToRun>
<ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
<Priority>7</Priority>
</Settings>
<Actions Context="Author">
<Exec>
  <Command>PowerShell.exe</Command>
  <Arguments>-ExecutionPolicy Bypass -WindowStyle Hidden -File C:\ProgramData\UpdateTaskTrayIcons.ps1</Arguments>
</Exec>
</Actions>
</Task>
"@
  Set-Content -Path "$env:TEMP\UpdateTaskTray" -Value $content -Force

  schtasks /Create /XML "$env:TEMP\UpdateTaskTray" /TN '\UpdateTaskTray' /F | Out-Null 

  Remove-Item -Path "$env:TEMP\UpdateTaskTray" -Force -ErrorAction SilentlyContinue
  Write-Host 'Update Task Tray Created...New Apps Will Be Shown Upon Restarting'


  $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
  
  if (Test-Path $registryPath) {
      Set-ItemProperty -Path $registryPath -Name "RotatingLockScreenEnabled" -Value 0
      Set-ItemProperty -Path $registryPath -Name "RotatingLockScreenOverlayEnabled" -Value 0
      Set-ItemProperty -Path $registryPath -Name "SubscribedContent-338389Enabled" -Value 0
      Write-Output "'Learn more about this picture' has been disabled for the desktop background."
  } else {
      Write-Output "The registry path for ContentDeliveryManager does not exist."
  }
  
  $registryPathDesktop = "HKCU:\Control Panel\Desktop"
  Set-ItemProperty -Path $registryPathDesktop -Name "Wallpaper" -Value ""
  Set-ItemProperty -Path $registryPathDesktop -Name "WallpaperStyle" -Value 0
  Set-ItemProperty -Path $registryPathDesktop -Name "BackgroundType" -Value 1
  Set-ItemProperty -Path $registryPathDesktop -Name "SingleColor" -Value "000000"
  
  RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters ,1 ,True
  
  Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:USERPROFILE\AppData\Local" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  Remove-Item -Path "$env:SystemDrive\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
  New-Item -Path "$env:SystemDrive\Windows" -Name "Temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

  Clear-Host
  Start-Process cmd.exe /c
  reg add "HKU\S-1-5-19\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f $nul
  reg add "HKU\S-1-5-20\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d "3c0000000f0000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d "3c000000040000000100000000000000090000003132372e302e302e3100000000010000000000000010d75bde6f11c50101000000c23f806f0000000000000000" /f
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 0 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\1527c705-839a-4832-9118-54d4Bd6a0c89_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\1527c705-839a-4832-9118-54d4Bd6a0c89_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\c5e2524a-ea46-4f67-841f-6a9465d9d515_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\c5e2524a-ea46-4f67-841f-6a9465d9d515_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\E2A4F912-2574-4A75-9BB0-0D023378592B_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\E2A4F912-2574-4A75-9BB0-0D023378592B_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AccountsControl_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AccountsControl_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AsyncTextService_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.AsyncTextService_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BioEnrollment_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BioEnrollment_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CredDialogHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CredDialogHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ECApp_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ECApp_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.LockApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.LockApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Win32WebViewHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Win32WebViewHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.AssignedAccessLockApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.AssignedAccessLockApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CapturePicker_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CapturePicker_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkCaptivePortal_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkCaptivePortal_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkConnectionFlow_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.OOBENetworkConnectionFlow_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ParentalControls_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ParentalControls_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PinningConfirmationDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PinningConfirmationDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PrintQueueActionCenter_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.PrintQueueActionCenter_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Search_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Search_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.XGpuEjectDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.XGpuEjectDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.UndockedDevKit_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.UndockedDevKit_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NcsiUwpApp_8wekyb3d8bbwe" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NcsiUwpApp_8wekyb3d8bbwe" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.CBSPreview_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.CBSPreview_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.PrintDialog_cw5n1h2txyewy" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Windows.PrintDialog_cw5n1h2txyewy" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_7njy0v32s6xk6" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_7njy0v32s6xk6" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_d9ma7nkbkv4rp" /v "Disabled" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\WinRAR.ShellExtension_d9ma7nkbkv4rp" /v "DisabledByUser" /t REG_DWORD /d 1 /f $nul
  reg delete "HKCU\Software\Microsoft\OneDrive" /f $nul
  reg delete "HKCU\Software\Microsoft\SkyDrive" /f $nul
  reg delete "HKCU\Software\Classes\grvopen" /f $nul
  reg delete "HKCU\Environment" /v "OneDrive" /f $nul
  reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f $nul
  reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f $nul
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f $nul
  reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "EUR" /f $nul
  reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d NotSpecified /f $nul
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d 2 /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f $nul
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe" /v "Start" /t REG_DWORD /d 0 /f $nul
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudExperienceHost" /v "ETWLoggingEnabled" /t REG_DWORD /d 0 /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive1" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive2" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive3" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive4" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive5" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive6" /f $nul
  reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive7" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive1" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive2" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive3" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive4" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive5" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive6" /f $nul
  reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ OneDrive7" /f $nul
  schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
  schtasks /change /tn "Microsoft\Office\Office Feature Updates Logon" /disable
  schtasks /change /tn "Microsoft\Office\Office Feature Updates" /disable
  schtasks /change /tn "Microsoft\Office\Office Automatic Updates 2.0" /disable
  schtasks /change /tn "Mozilla\Firefox Background Update 308046B0AF4A39CB" /disable
  schtasks /delete /tn "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /f

  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowClipboardHistory" /t REG_DWORD /d 0 /f
  
  auditpol /set /subcategory:"Special Logon" /success:disable
  auditpol /set /subcategory:"Audit Policy Change" /success:disable
  auditpol /set /subcategory:"User Account Management" /success:disable
  net.exe accounts /maxpwage:unlimited
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemtry" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemtry" /t REG_DWORD /d 0 /f
  reg add "HKCU\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemtry" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "SecurityHealth" /t REG_EXPAND_SZ /d "%%SystemRoot%%\system32\SecurityHealthSystray.exe" /f
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT" /v "Start" /t REG_DWORD /d 3 /f
  
  schtasks /Create /F /RU "SYSTEM" /RL HIGHEST /SC HOURLY /TN PrilagodeniTasks /TR "cmd /c %windir%\PrilagodeniTasks.cmd"
  schtasks /Run /I /TN PrilagodeniTasks
  timeout /T 5
  schtasks /delete /F /TN PrilagodeniTasks

            
                                         
  ipconfig /registerdns
  netsh.exe winhttp reset proxy
  netsh interface teredo set state disabled
  bcdedit /timeout 4
  bcdedit /set nointegritychecks off
  powercfg -h off
  fsutil behavior set disable8dot3 1
  fsutil behavior set disableencryption 1
  fsutil behavior set disablelastaccess 1
  fsutil behavior set memoryusage 2
  setx DOTNET_CLI_TELEMETRY_OPTOUT 1
  fsutil repair set c: 0
  netsh.exe wfp set options netevents = off
  net.exe accounts /maxpwage:unlimited
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" `
        -Name "RealTimeIsUniversal" `
        -Type DWord `
        -Value 1 -Force | Out-Null
    $timeService = Get-Service "W32Time" -ErrorAction SilentlyContinue
    if ($timeService.Status -ne "Running") {
  net start "W32Time" | Out-Null
  w32tm /resync | Out-Null

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

}
}

function Enable-WSL {
  [CmdletBinding()]
  param()
  Clear-Host
  Write-Host "Enabling WSL..."
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

function Remove-AI {
  Clear-Host
  Write-Host "Removing AI/Copilot/Recall..."
  Start-Sleep -Seconds 3
  
  If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit	
}

function Start-Trusted([String]$command) {

    try {
        Stop-Service -Name TrustedInstaller -Force -ErrorAction Stop -WarningAction Stop
    }
    catch {
        taskkill /im trustedinstaller.exe /f >$null
    }
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='TrustedInstaller'"
    $DefaultBinPath = $service.PathName
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    $base64Command = [Convert]::ToBase64String($bytes)
    sc.exe config TrustedInstaller binPath= "cmd.exe /c powershell.exe -encodedcommand $base64Command" | Out-Null
    sc.exe start TrustedInstaller | Out-Null
    sc.exe config TrustedInstaller binpath= "`"$DefaultBinPath`"" | Out-Null
    try {
        Stop-Service -Name TrustedInstaller -Force -ErrorAction Stop -WarningAction Stop
    }
    catch {
        taskkill /im trustedinstaller.exe /f >$null
    }
    
}

function Write-Status {
    param(
        [string]$msg,
        [bool]$errorOutput = $false
    )
    if ($errorOutput) {
        Write-Host "[ ! ] $msg" -ForegroundColor Red
    }
    else {
        Write-Host "[ + ] $msg" -ForegroundColor Cyan
    }
   
    
}

  Write-Status -msg 'Disabling Copilot and Recall...'
  $hives = @('HKLM', 'HKCU')
  foreach ($hive in $hives) {
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v 'TurnOffWindowsCopilot' /t REG_DWORD /d '1' /f *>$null
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableAIDataAnalysis' /t REG_DWORD /d '1' /f *>$null
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'AllowRecallEnablement' /t REG_DWORD /d '0' /f *>$null
      Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableClickToDo' /t REG_DWORD /d '1' /f *>$null
  }
  Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'ShowCopilotButton' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKCU\Software\Microsoft\input\Settings' /v 'InsightsEnabled' /t REG_DWORD /d '0' /f *>$null
  Write-Status -msg 'Disabling Copilot In Windows Search...'
  Reg.exe add 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer' /v 'DisableSearchBoxSuggestions' /t REG_DWORD /d '1' /f *>$null
  Write-Status -msg 'Disabling Copilot In Edge...'
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotCDPPageContext' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotPageContext' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'HubsSidebarEnabled' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat' /v 'IsUserEligible' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKCU\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat' /v 'IsUserEligible' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings' /v 'AutoOpenCopilotLargeScreens' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\generativeAI' /v 'Value' /t REG_SZ /d 'Deny' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' /v 'LetAppsAccessGenerativeAI' /t REG_DWORD /d '2' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' /v 'LetAppsAccessSystemAIModels' /t REG_DWORD /d '2' /f *>$null
  Write-Status -msg 'Disabling Image Creator In Paint...'
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'Behavior' /t REG_DWORD /d '1056800' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'highrange' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'lowrange' /t REG_DWORD /d '0' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'mergealgorithm' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'policytype' /t REG_DWORD /d '4' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'RegKeyPathRedirect' /t REG_SZ /d 'Software\Microsoft\Windows\CurrentVersion\Policies\Paint' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'RegValueNameRedirect' /t REG_SZ /d 'DisableImageCreator' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsAI\DisableImageCreator' /v 'value' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableImageCreator' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableCocreator' /t REG_DWORD /d '1' /f *>$null
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableGenerativeFill' /t REG_DWORD /d '1' /f *>$null
  Write-Status -msg 'Applying Registry Changes...'
  gpupdate /force >$null

  Write-Status -msg 'Removing Copilot Nudges Registry Keys...'
  $keys = @(
      'registry::HKCR\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.wwa',
      'registry::HKCR\Extensions\ContractId\Windows.Launch\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.wwa',
      'registry::HKCR\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\Applications\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
      'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\Applications\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
      'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
      'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.wwa',
      'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.mca',
      'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.Launch\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.wwa'
  )
  $fullkey = @()
  foreach ($key in $keys) {
      try {
          $fullKey = Get-Item -Path $key -ErrorAction Stop
          if ($null -eq $fullkey) { continue }
          if ($fullkey.Length -gt 1) {
              foreach ($multikey in $fullkey) {
                  $command = "Remove-Item -Path `"registry::$multikey`" -Force -Recurse"
                  Start-Trusted -command $command
                  Start-Sleep 1
                  Remove-Item -Path "registry::$multikey" -Force -Recurse -ErrorAction SilentlyContinue
              }
          }
          else {
              $command = "Remove-Item -Path `"registry::$fullKey`" -Force -Recurse"
              Start-Trusted -command $command
              Start-Sleep 1
              Remove-Item -Path "registry::$fullKey" -Force -Recurse -ErrorAction SilentlyContinue
          }
          
      }
      catch {
          continue
      }
  }
  $JSONPath = "$env:windir\System32\IntegratedServicesRegionPolicySet.json"
  if (Test-Path $JSONPath) {
      Write-Host 'Disabling CoPilot Policies in ' -NoNewline
      Write-Host "[$JSONPath]" -ForegroundColor Yellow
  
      takeown /f $JSONPath *>$null
      icacls $JSONPath /grant administrators:F /t *>$null
  
      $jsonContent = Get-Content $JSONPath | ConvertFrom-Json
      try {
          $copilotPolicies = $jsonContent.policies | Where-Object { $_.'$comment' -like '*CoPilot*' }
          foreach ($policies in $copilotPolicies) {
              $policies.defaultState = 'disabled'
          }
          $newJSONContent = $jsonContent | ConvertTo-Json -Depth 100
          Set-Content $JSONPath -Value $newJSONContent -Force
          Write-Status -msg "$($copilotPolicies.count) CoPilot Policies Disabled"
      }
      catch {
          Write-Status -msg 'CoPilot Not Found in IntegratedServicesRegionPolicySet' -errorOutput $true
      }
  
      
  }
  $packageRemovalPath = "$env:TEMP\aiPackageRemoval.ps1"
  if (!(test-path $packageRemovalPath)) {
      New-Item $packageRemovalPath -Force | Out-Null
  }
  $aipackages = @(
      'MicrosoftWindows.Client.Photon'
      'MicrosoftWindows.Client.AIX'
      'MicrosoftWindows.Client.CoPilot'
      'Microsoft.Windows.Ai.Copilot.Provider'
      'Microsoft.Copilot'
      'Microsoft.MicrosoftOfficeHub'
      'MicrosoftWindows.Client.CoreAI'
  )
  
$code = @'
$aipackages = @(
    'MicrosoftWindows.Client.Photon'
    'MicrosoftWindows.Client.AIX'
    'MicrosoftWindows.Client.CoPilot'
    'Microsoft.Windows.Ai.Copilot.Provider'
    'Microsoft.Copilot'
    'Microsoft.MicrosoftOfficeHub'
    'MicrosoftWindows.Client.CoreAI'
)

$provisioned = get-appxprovisionedpackage -online 
$appxpackage = get-appxpackage -allusers
$eol = @()
$store = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
$users = @('S-1-5-18'); if (test-path $store) { $users += $((Get-ChildItem $store -ea 0 | Where-Object { $_ -like '*S-1-5-21*' }).PSChildName) }

foreach ($choice in $aipackages) {
    foreach ($appx in $($provisioned | Where-Object { $_.PackageName -like "*$choice*" })) {

        $PackageName = $appx.PackageName 
        $PackageFamilyName = ($appxpackage | Where-Object { $_.Name -eq $appx.DisplayName }).PackageFamilyName

        New-Item "$store\Deprovisioned\$PackageFamilyName" -force
     
        Set-NonRemovableAppsPolicy -Online -PackageFamilyName $PackageFamilyName -NonRemovable 0
       
        foreach ($sid in $users) { 
            New-Item "$store\EndOfLife\$sid\$PackageName" -force
        }  
        $eol += $PackageName
        remove-appxprovisionedpackage -packagename $PackageName -online -allusers
    }
    foreach ($appx in $($appxpackage | Where-Object { $_.PackageFullName -like "*$choice*" })) {

        $PackageFullName = $appx.PackageFullName
        $PackageFamilyName = $appx.PackageFamilyName
        New-Item "$store\Deprovisioned\$PackageFamilyName" -force
        
        Set-NonRemovableAppsPolicy -Online -PackageFamilyName $PackageFamilyName -NonRemovable 0
       
        $inboxApp = "$store\InboxApplications\$PackageFullName"
        Remove-Item -Path $inboxApp -Force
       
        # Get all installed user sids for package due to not all showing up in reg
        foreach ($user in $appx.PackageUserInformation) { 
            $sid = $user.UserSecurityID.SID
            if ($users -notcontains $sid) {
                $users += $sid
            }
            New-Item "$store\EndOfLife\$sid\$PackageFullName" -force
            remove-appxpackage -package $PackageFullName -User $sid 
        } 
        $eol += $PackageFullName
        remove-appxpackage -package $PackageFullName -allusers
    }
}
'@
  Set-Content -Path $packageRemovalPath -Value $code -Force 
  try {
      Set-ExecutionPolicy Unrestricted -Force -ErrorAction Stop
  }
  catch {
      $ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Name 'ExecutionPolicy' -ErrorAction SilentlyContinue
      Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'EnableScripts' /t REG_DWORD /d '1' /f >$null
      Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
  }


  Write-Status -msg 'Removing AI Appx Packages...'
  $command = "&$env:TEMP\aiPackageRemoval.ps1"
  Start-Trusted -command $command
  
  do {
      Start-Sleep 1
      $packages = get-appxpackage -AllUsers | Where-Object { $aipackages -contains $_.Name }
      foreach ($package in $packages) {
          if ($package.PackageUserInformation -like '*pending removal*') {
              $ProgressPreference = 'SilentlyContinue'
              &$env:TEMP\aiPackageRemoval.ps1 *>$null
          }
      }
      
  }while ($packages)
  
  Write-Status -msg 'Packages Removed Sucessfully...'
  Remove-Item $packageRemovalPath -Force
  if ($ogExecutionPolicy) {
      Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d $ogExecutionPolicy /f >$null
  }
  
  $eolPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife'
  $eolKeys = (Get-ChildItem $eolPath).Name
  foreach ($path in $eolKeys) {
      Remove-Item "registry::$path" -Recurse -Force -ErrorAction SilentlyContinue
  }

  $ProgressPreference = 'SilentlyContinue'
  try {
      Write-Status -msg 'Removing Recall Optional Feature...'
      Disable-WindowsOptionalFeature -Online -FeatureName 'Recall' -Remove -NoRestart -ErrorAction Stop *>$null
  }
  catch {
      
  }
  Write-Status -msg 'Removing Appx Package Files...'
  $appsPath = 'C:\Windows\SystemApps'
  $appsPath2 = 'C:\Program Files\WindowsApps'
  $pathsSystemApps = (Get-ChildItem -Path $appsPath -Directory -Force).FullName 
  $pathsWindowsApps = (Get-ChildItem -Path $appsPath2 -Directory -Force).FullName 

  $packagesPath = @()
  foreach ($package in $aipackages) {
  
      foreach ($path in $pathsSystemApps) {
          if ($path -like "*$package*") {
              $packagesPath += $path
          }
      }
  
      foreach ($path in $pathsWindowsApps) {
          if ($path -like "*$package*") {
              $packagesPath += $path
          }
      }
  
  }
  
  
  foreach ($Path in $packagesPath) {
      if ($path -like '*Photon*') {
          $command = "`$dlls = (Get-ChildItem -Path $Path -Filter *.dll).FullName; foreach(`$dll in `$dlls){Remove-item ""`$dll"" -force}"
          Start-Trusted -command $command
          Start-Sleep 1
      }
      else {
          $command = "Remove-item ""$Path"" -force -recurse"
          Start-Trusted -command $command
          Start-Sleep 1
      }
  }

  Write-Status -msg 'Removing Hidden Copilot Installers...'
  $dir = "${env:ProgramFiles(x86)}\Microsoft"
  $folders = @(
      'Edge',
      'EdgeCore',
      'EdgeWebView'
  )
  foreach ($folder in $folders) {
      if ($folder -eq 'EdgeCore') {
          $fullPath = (Get-ChildItem -Path "$dir\$folder\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
          
      }
      else {
          $fullPath = (Get-ChildItem -Path "$dir\$folder\Application\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
      }
      if ($fullPath -ne $null) { Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue }
  }

  $inboxapps = 'C:\Windows\InboxApps'
  $installers = Get-ChildItem -Path $inboxapps -Filter '*Copilot*'
  foreach ($installer in $installers) {
      takeown /f $installer.FullName *>$null
      icacls $installer.FullName /grant administrators:F /t *>$null
      try {
          Remove-Item -Path $installer.FullName -Force -ErrorAction Stop
      }
      catch {
          $command = "Remove-Item -Path $($installer.FullName) -Force"
          Start-Trusted -command $command 
      }
      
  }

  Write-Status -msg 'Hiding Ai Components in Settings...'
  Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v 'SettingsPageVisibility' /t REG_SZ /d 'hide:aicomponents;' /f >$null
  
  Write-Status -msg 'Disabling Rewrite Ai Feature for Notepad...'
  reg load HKU\TEMP "$env:LOCALAPPDATA\Packages\Microsoft.WindowsNotepad_8wekyb3d8bbwe\Settings\settings.dat" >$null
$regContent = @'
Windows Registry Editor Version 5.00

[HKEY_USERS\TEMP\LocalState]
"RewriteEnabled"=hex(5f5e10b):00,e0,d1,c5,7f,ee,83,db,01
'@
  New-Item "$env:TEMP\DisableRewrite.reg" -Value $regContent -Force | Out-Null
  regedit.exe /s "$env:TEMP\DisableRewrite.reg"
  Start-Sleep 1
  reg unload HKU\TEMP >$null
  Remove-Item "$env:TEMP\DisableRewrite.reg" -Force -ErrorAction SilentlyContinue
  Reg.exe add 'HKLM\SOFTWARE\Policies\WindowsNotepad' /v 'DisableAIFeatures' /t REG_DWORD /d '1' /f *>$null
  
  Write-Status -msg 'Removing Any Screenshots By Recall...'
  Remove-Item -Path "$env:LOCALAPPDATA\CoreAIPlatform*" -Force -Recurse -ErrorAction SilentlyContinue

}

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

function Set-DefenderConfig {
    try {
        Clear-Host    
        Write-Host ""
        Write-Host "Enabling and Setting Defender..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3

        # https://www.powershellgallery.com/packages/WindowsDefender_InternalEvaluationSetting
        # https://social.technet.microsoft.com/wiki/contents/articles/52251.manage-windows-defender-using-powershell.aspx
        # https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=windowsserver2019-ps

        $mpPreference = Get-MpPreference
        $mpPreference.DisableRealtimeMonitoring = $false
        $mpPreference.MAPSReporting = "0"
        $mpPreference.SubmitSamplesConsent = "AlwaysPrompt"
        $mpPreference.CheckForSignaturesBeforeRunningScan = 1
        $mpPreference.DisableBehaviorMonitoring = $false
        $mpPreference.DisableIOAVProtection = $false
        $mpPreference.DisableScriptScanning = $false
        $mpPreference.DisableRemovableDriveScanning = $false
        $mpPreference.DisableBlockAtFirstSeen = $false
        $mpPreference.PUAProtection = 1
        $mpPreference.DisableArchiveScanning = $false
        $mpPreference.DisableEmailScanning = $false
        $mpPreference.EnableFileHashComputation = $true
        $mpPreference.DisableIntrusionPreventionSystem = $false
        $mpPreference.DisableSshParsing = $false
        $mpPreference.DisableDnsParsing = $false
        $mpPreference.DisableDnsOverTcpParsing = $false
        $mpPreference.EnableDnsSinkhole = $true
        $mpPreference.EnableControlledFolderAccess = "Enabled"
        $mpPreference.EnableNetworkProtection = "Enabled"
        $mpPreference.MP_FORCE_USE_SANDBOX = 1
        $mpPreference.CloudBlockLevel = "High"
        $mpPreference.CloudExtendedTimeout = 50
        $mpPreference.SignatureDisableUpdateOnStartupWithoutEngine = $false
        $mpPreference.DisableArchiveScanningAlternateDataStream = $false
        $mpPreference.DisableBehaviorMonitoringAlternateDataStream = $false
        $mpPreference.ScanArchiveFilesWithPassword = $true
        $mpPreference.ScanDownloads = 2
        $mpPreference.ScanNetworkFiles = 2
        $mpPreference.ScanIncomingMail = 2
        $mpPreference.ScanMappedNetworkDrivesDuringFullScan = $true
        $mpPreference.ScanRemovableDrivesDuringFullScan = $true
        $mpPreference.ScanScriptsLoadedInInternetExplorer = $true
        $mpPreference.ScanScriptsLoadedInOfficeApplications = $true
        $mpPreference.ScanSubDirectoriesDuringQuickScan = $true
        $mpPreference.ScanRemovableDrivesDuringQuickScan = $true
        $mpPreference.ScanMappedNetworkDrivesDuringQuickScan = $true
        $mpPreference.DisableBehaviorMonitoringMemoryDoubleFree = $false
        $mpPreference.DisableBehaviorMonitoringNonSystemSigned = $false
        $mpPreference.DisableBehaviorMonitoringUnsigned = $false
        $mpPreference.DisableBehaviorMonitoringPowershellScripts = $false
        $mpPreference.DisableBehaviorMonitoringNonMsSigned = $false
        $mpPreference.DisableBehaviorMonitoringNonMsSystem = $false
        $mpPreference.DisableBehaviorMonitoringNonMsSystemProtected = $false
        $mpPreference.EnableControlledFolderAccessMemoryProtection = $true
        $mpPreference.EnableControlledFolderAccessNonScriptableDlls = $true
        $mpPreference.EnableControlledFolderAccessNonMsSigned = $true
        $mpPreference.EnableControlledFolderAccessNonMsSystem = $true
        $mpPreference.EnableControlledFolderAccessNonMsSystemProtected = $true
        $mpPreference.ScanRemovableDriveDuringFullScan = $true
        $mpPreference.ScanNetworkFilesDuringFullScan = $true
        $mpPreference.ScanNetworkFilesDuringQuickScan = $true
        $mpPreference.EnableNetworkProtectionRealtimeInspection = $true
        $mpPreference.EnableNetworkProtectionExploitInspection = $true
        $mpPreference.EnableNetworkProtectionControlledFolderAccessInspection = $true
        $mpPreference.SignatureDisableUpdateOnStartupWithoutEngine = $false
        $mpPreference.SignatureDisableUpdateOnStartupWithoutEngine = $false
        
        Set-MpPreference -PreferenceObject $mpPreference

        Write-Host "Defender preferences set successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to apply Defender preferences: $_" -ForegroundColor Red
    }

      Write-Host "Disabling Account Prompts" -ForegroundColor Cyan
      $accountProtectionKeyPath = "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State\AccountProtection_MicrosoftAccount_Disconnected"

      if (!(Test-Path -Path $accountProtectionKeyPath)) {
          New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -Name "AccountProtection_MicrosoftAccount_Disconnected" -PropertyType DWORD -Value 1 -Force
      } else {
          Set-ItemProperty -Path $accountProtectionKeyPath -Name "AccountProtection_MicrosoftAccount_Disconnected" -Value 1
      }

    Write-Host "Configure Cloud-delivered Protections" -ForegroundColor Cyan
    Set-MpPreference -MAPSReporting 0
    Set-MpPreference -SubmitSamplesConsent AlwaysPrompt
  
}

function Initialize-DiskCleanup {
  Clear-Host
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  [System.Windows.Forms.Application]::EnableVisualStyles()
  
  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'Ultimate Cleanup'
  $form.Size = New-Object System.Drawing.Size(450, 400)
  $form.StartPosition = 'CenterScreen'
  $form.BackColor = 'Black'
  
  $label = New-Object System.Windows.Forms.Label
  $label.Location = New-Object System.Drawing.Point(60, 10)
  $label.Size = New-Object System.Drawing.Size(250, 25)
  $label.Text = 'Disk Cleanup Options'
  $label.ForeColor = 'White'
  $label.Font = New-Object System.Drawing.Font('segoe ui', 10) 
  $form.Controls.Add($label)
  
  $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
  $checkedListBox.Location = New-Object System.Drawing.Point(40, 60)
  $checkedListBox.Size = New-Object System.Drawing.Size(200, 300)
  $checkedListBox.BackColor = 'Black'
  $checkedListBox.ForeColor = 'White'
  $options = @(
      'Active Setup Temp Folders'
      'Thumbnail Cache'
      'Delivery Optimization Files'
      'D3D Shader Cache'
      'Downloaded Program Files'
      'Internet Cache Files'
      'Setup Log Files'
      'Temporary Files'
      'Windows Error Reporting Files'
      'Offline Pages Files'
      'Recycle Bin'
      'Temporary Setup Files'
      'Update Cleanup'
      'Upgrade Discarded Files'
      'Windows Defender'
      'Windows ESD installation files'
      'Windows Reset Log Files'
      'Windows Upgrade Log Files'
      'Previous Installations'
      'Old ChkDsk Files'
      'Feedback Hub Archive log files'
      'Diagnostic Data Viewer database files'
      'Device Driver Packages'
  )
  foreach ($option in $options) {
      $checkedListBox.Items.Add($option, $false) | Out-Null
  }
  
  $checkBox1 = New-Object System.Windows.Forms.CheckBox
  $checkBox1.Text = 'Clear Event Viewer Logs'
  $checkBox1.Location = New-Object System.Drawing.Point(250, 70)
  $checkBox1.ForeColor = 'White'
  $checkBox1.AutoSize = $true
  
  $checkBox2 = New-Object System.Windows.Forms.CheckBox
  $checkBox2.Text = 'Clear Windows Logs'
  $checkBox2.Location = New-Object System.Drawing.Point(250, 100)
  $checkBox2.ForeColor = 'White'
  $checkBox2.AutoSize = $true
  
  $checkBox3 = New-Object System.Windows.Forms.CheckBox
  $checkBox3.Text = 'Clear TEMP Cache'
  $checkBox3.Location = New-Object System.Drawing.Point(250, 130)
  $checkBox3.ForeColor = 'White'
  $checkBox3.AutoSize = $true
  
  $buttonClean = New-Object System.Windows.Forms.Button
  $buttonClean.Text = 'Clean'
  $buttonClean.Location = New-Object System.Drawing.Point(250, 200)
  $buttonClean.Size = New-Object System.Drawing.Size(100, 30)
  $buttonClean.ForeColor = 'White'
  $buttonClean.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
  $buttonClean.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $buttonClean.Add_MouseEnter({
          $buttonClean.BackColor = [System.Drawing.Color]::FromArgb(64, 64, 64)
      })
  
  $buttonClean.Add_MouseLeave({
          $buttonClean.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
      })
    
  $checkALL = New-Object System.Windows.Forms.CheckBox
  $checkALL.Text = 'Check All'
  $checkALL.Location = New-Object System.Drawing.Point(40, 40)
  $checkALL.ForeColor = 'White'
  $checkALL.AutoSize = $true
  $checkALL.add_CheckedChanged({
          if ($checkALL.Checked) {
              $i = 0
              foreach ($option in $options) {
                  $checkedListBox.SetItemChecked($i, $true)
                  $i++
              }
          }
          else {
              $i = 0
              foreach ($option in $options) {
                  $checkedListBox.SetItemChecked($i, $false)
                  $i++
              }
          }
      })
  $form.Controls.Add($checkALL)
    
  $form.Controls.Add($checkedListBox)
  $form.Controls.Add($checkBox1)
  $form.Controls.Add($checkBox2)
  $form.Controls.Add($checkBox3)
  $form.Controls.Add($buttonClean)
  
  $result = $form.ShowDialog()
  
  
  if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
      $driveletter = $env:SystemDrive -replace ':', ''
      $drive = Get-PSDrive $driveletter
      $usedInGB = [math]::Round($drive.Used / 1GB, 4)
      Write-Host 'BEFORE CLEANING' -ForegroundColor Red
      Write-Host "Used space on $($drive.Name):\ $usedInGB GB" -ForegroundColor Red
      
  
  
      if ($checkBox1.Checked) {
          Write-Host 'Clearing Event Viewer Logs...'
          wevtutil el | Foreach-Object { wevtutil cl "$_" >$null 2>&1 } 
      }
      if ($checkBox2.Checked) {
          Write-Host 'Clearing Windows Log Files...'
          Remove-Item -Path $env:SystemRoot\DtcInstall.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\comsetup.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\PFRO.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\setupact.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\setuperr.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\setupapi.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\Panther\* -Force -Recurse -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\inf\setupapi.app.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\inf\setupapi.dev.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\inf\setupapi.offline.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\Performance\WinSAT\winsat.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\debug\PASSWD.LOG -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\Logs\CBS\CBS.log -Force -ErrorAction SilentlyContinue  
          Remove-Item -Path $env:SystemRoot\Logs\DISM\DISM.log -Force -ErrorAction SilentlyContinue  
          Remove-Item -Path "$env:SystemRoot\Logs\SIH\*" -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path "$env:LocalAppData\Microsoft\CLR_v4.0\UsageTraces\*" -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path "$env:LocalAppData\Microsoft\CLR_v4.0_32\UsageTraces\*" -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path "$env:SystemRoot\Logs\NetSetup\*" -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path "$env:SystemRoot\System32\LogFiles\setupcln\*" -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\Temp\CBS\* -Force -ErrorAction SilentlyContinue 
          takeown /f $env:SystemRoot\Logs\waasmedic /r -Value y *>$null
          icacls $env:SystemRoot\Logs\waasmedic /grant administrators:F /t *>$null
          Remove-Item -Path $env:SystemRoot\Logs\waasmedic -Recurse -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\System32\catroot2\dberr.txt -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\System32\catroot2.log -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\System32\catroot2.jrs -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\System32\catroot2.edb -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path $env:SystemRoot\System32\catroot2.chk -Force -ErrorAction SilentlyContinue 
          Remove-Item -Path "$env:SystemRoot\Traces\WindowsUpdate\*" -Force -ErrorAction SilentlyContinue 
      }
      if ($checkBox3.Checked) {
          Write-Host 'Clearing TEMP Files...'
          $temp1 = 'C:\Windows\Temp'
          $temp2 = $env:TEMP
          $tempFiles = (Get-ChildItem -Path $temp1 , $temp2 -Recurse -Force).FullName
          foreach ($file in $tempFiles) {
              Remove-Item -Path $file -Recurse -Force -ErrorAction SilentlyContinue
          }
      }
      if ($checkedListBox.CheckedItems) {
          $key = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
          foreach ($item in $checkedListBox.CheckedItems) {
              reg.exe add "$key\$item" /v StateFlags0069 /t REG_DWORD /d 00000002 /f >$nul 2>&1
          }
          Write-Host 'Running Disk Cleanup...'
          Start-Process cleanmgr.exe -ArgumentList '/sagerun:69 /autoclean' -Wait
      }
  
      $drive = Get-PSDrive $driveletter
      $usedInGB = [math]::Round($drive.Used / 1GB, 4)
      Write-Host 'AFTER CLEANING' -ForegroundColor Green
      Write-Host "Used space on $($drive.Name):\ $usedInGB GB" -ForegroundColor Green
      
  }
}

function Remove-Defender {
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    function RunAsTI($cmd, $arg) {
    $id = 'RunAsTI'; $key = "Registry::HKU\$(((whoami /user)-split' ')[-1])\Volatile Environment"; $code = @'
    $I=[int32]; $M=$I.module.gettype("System.Runtime.Interop`Services.Mar`shal"); $P=$I.module.gettype("System.Int`Ptr"); $S=[string]
    $D=@(); $T=@(); $DM=[AppDomain]::CurrentDomain."DefineDynami`cAssembly"(1,1)."DefineDynami`cModule"(1); $Z=[uintptr]::size
    0..5|% {$D += $DM."Defin`eType"("AveYo_$_",1179913,[ValueType])}; $D += [uintptr]; 4..6|% {$D += $D[$_]."MakeByR`efType"()}
    $F='kernel','advapi','advapi', ($S,$S,$I,$I,$I,$I,$I,$S,$D[7],$D[8]), ([uintptr],$S,$I,$I,$D[9]),([uintptr],$S,$I,$I,[byte[]],$I)
    0..2|% {$9=$D[0]."DefinePInvok`eMethod"(('CreateProcess','RegOpenKeyEx','RegSetValueEx')[$_],$F[$_]+'32',8214,1,$S,$F[$_+3],1,4)}
    $DF=($P,$I,$P),($I,$I,$I,$I,$P,$D[1]),($I,$S,$S,$S,$I,$I,$I,$I,$I,$I,$I,$I,[int16],[int16],$P,$P,$P,$P),($D[3],$P),($P,$P,$I,$I)
    1..5|% {$k=$_; $n=1; $DF[$_-1]|% {$9=$D[$k]."Defin`eField"('f' + $n++, $_, 6)}}; 0..5|% {$T += $D[$_]."Creat`eType"()}
    0..5|% {nv "A$_" ([Activator]::CreateInstance($T[$_])) -fo}; function F ($1,$2) {$T[0]."G`etMethod"($1).invoke(0,$2)}
    $TI=(whoami /groups)-like'*1-16-16384*'; $As=0; if(!$cmd) {$cmd='control';$arg='admintools'}; if ($cmd-eq'This PC'){$cmd='file:'}
    if (!$TI) {'TrustedInstaller','lsass','winlogon'|% {if (!$As) {$9=sc.exe start $_; $As=@(get-process -name $_ -ea 0|% {$_})[0]}}
    function M ($1,$2,$3) {$M."G`etMethod"($1,[type[]]$2).invoke(0,$3)}; $H=@(); $Z,(4*$Z+16)|% {$H += M "AllocHG`lobal" $I $_}
    M "WriteInt`Ptr" ($P,$P) ($H[0],$As.Handle); $A1.f1=131072; $A1.f2=$Z; $A1.f3=$H[0]; $A2.f1=1; $A2.f2=1; $A2.f3=1; $A2.f4=1
    $A2.f6=$A1; $A3.f1=10*$Z+32; $A4.f1=$A3; $A4.f2=$H[1]; M "StructureTo`Ptr" ($D[2],$P,[boolean]) (($A2 -as $D[2]),$A4.f2,$false)
    $Run=@($null, "powershell -win 1 -nop -c iex `$env:R; # $id", 0, 0, 0, 0x0E080600, 0, $null, ($A4 -as $T[4]), ($A5 -as $T[5]))
    F 'CreateProcess' $Run; return}; $env:R=''; rp $key $id -force; $priv=[diagnostics.process]."GetM`ember"('SetPrivilege',42)[0]
    'SeSecurityPrivilege','SeTakeOwnershipPrivilege','SeBackupPrivilege','SeRestorePrivilege' |% {$priv.Invoke($null, @("$_",2))}
    $HKU=[uintptr][uint32]2147483651; $NT='S-1-5-18'; $reg=($HKU,$NT,8,2,($HKU -as $D[9])); F 'RegOpenKeyEx' $reg; $LNK=$reg[4]
    function L ($1,$2,$3) {sp 'HKLM:\Software\Classes\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}' 'RunAs' $3 -force -ea 0
    $b=[Text.Encoding]::Unicode.GetBytes("\Registry\User\$1"); F 'RegSetValueEx' @($2,'SymbolicLinkValue',0,6,[byte[]]$b,$b.Length)}
    function Q {[int](gwmi win32_process -filter 'name="explorer.exe"'|?{$_.getownersid().sid-eq$NT}|select -last 1).ProcessId}
    $11bug=($((gwmi Win32_OperatingSystem).BuildNumber)-eq'22000')-AND(($cmd-eq'file:')-OR(test-path -lit $cmd -PathType Container))
    if ($11bug) {'System.Windows.Forms','Microsoft.VisualBasic' |% {[Reflection.Assembly]::LoadWithPartialName("'$_")}}
    if ($11bug) {$path='^(l)'+$($cmd -replace '([\+\^\%\~\(\)\[\]])','{$1}')+'{ENTER}'; $cmd='control.exe'; $arg='admintools'}
    L ($key-split'\\')[1] $LNK ''; $R=[diagnostics.process]::start($cmd,$arg); if ($R) {$R.PriorityClass='High'; $R.WaitForExit()}
    if ($11bug) {$w=0; do {if($w-gt40){break}; sleep -mi 250;$w++} until (Q); [Microsoft.VisualBasic.Interaction]::AppActivate($(Q))}
    if ($11bug) {[Windows.Forms.SendKeys]::SendWait($path)}; do {sleep 7} while(Q); L '.Default' $LNK 'Interactive User'
'@; $V = ''; 'cmd', 'arg', 'id', 'key' | ForEach-Object { $V += "`n`$$_='$($(Get-Variable $_ -val)-replace"'","''")';" }; Set-ItemProperty $key $id $($V, $code) -type 7 -force -ea 0
    Start-Process powershell -args "-win 1 -nop -c `n$V `$env:R=(gi `$key -ea 0).getvalue(`$id)-join''; iex `$env:R" -verb runas -Wait
    }

    Write-Host "1. Security: Off"
    Write-Host "2. Security: On"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {
    Clear-Host
    Write-Host "1. Step: One"
    Write-Host "2. Step: Two (Im In Safe Mode)"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "This script intentionally disables all Windows Security:" -ForegroundColor Red
Write-Host "-Defender Windows Security Settings" -ForegroundColor Red
Write-Host "-Smartscreen" -ForegroundColor Red
Write-Host "-Defender Services" -ForegroundColor Red
Write-Host "-Defender Drivers" -ForegroundColor Red
Write-Host "-Windows Defender Firewall" -ForegroundColor Red
Write-Host "-User Account Control" -ForegroundColor Red
Write-Host "-Spectre Meltdown" -ForegroundColor Red
Write-Host "-Data Execution Prevention" -ForegroundColor Red
Write-Host "-Powershell Script Execution" -ForegroundColor Red
Write-Host "-Open File Security Warning" -ForegroundColor Red
Write-Host "-Windows Defender Default Definitions" -ForegroundColor Red
Write-Host "-Windows Defender Applicationguard" -ForegroundColor Red
Write-Host ""
Write-Host "This will leave the PC completely vulnerable." -ForegroundColor Red
Write-Host "If uncomfortable, please close this window!" -ForegroundColor Red
Write-Host ""
Pause
Clear-Host
Write-Host "Step: One. Please wait . . ."
# disable exploit protection, leaving control flow guard cfg on for vanguard anticheat
cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Control\Session Manager\kernel`" /v `"MitigationOptions`" /t REG_BINARY /d `"222222000001000000000000000000000000000000000000`" /f >nul 2>&1"
Timeout /T 2 | Out-Null
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; DISABLE WINDOWS SECURITY SETTINGS
; Real time protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection]
"DisableRealtimeMonitoring"=dword:00000001

; Dev drive protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection]
"DisableAsyncScanOnOpen"=dword:00000001

; Cloud delivered protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Spynet]
"SpyNetReporting"=dword:00000000

; Automatic sample submission
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Spynet]
"SubmitSamplesConsent"=dword:00000000

; Tamper protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features]
"TamperProtection"=dword:00000004

; Controlled folder access 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access]
"EnableControlledFolderAccess"=dword:00000000

; Firewall notifications
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications]
"DisableEnhancedNotifications"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection]
"NoActionNotificationDisabled"=dword:00000001
"SummaryNotificationDisabled"=dword:00000001
"FilesBlockedNotificationDisabled"=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows Defender Security Center\Account protection]
"DisableNotifications"=dword:00000001
"DisableDynamiclockNotifications"=dword:00000001
"DisableWindowsHelloNotifications"=dword:00000001

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Epoch]
"Epoch"=dword:000004cf

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile]
"DisableNotifications"=dword:00000001

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile]
"DisableNotifications"=dword:00000001

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile]
"DisableNotifications"=dword:00000001

; Smart app control
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender]
"VerifiedAndReputableTrustModeEnabled"=dword:00000000
"SmartLockerMode"=dword:00000000
"PUAProtection"=dword:00000000

[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\AppID\Configuration\SMARTLOCKER]
"START_PENDING"=dword:00000000
"ENABLED"=hex(b):00,00,00,00,00,00,00,00

[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\CI\Policy]
"VerifiedAndReputablePolicyState"=dword:00000000

; Check apps and files
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
"SmartScreenEnabled"="Off"

; Smartscreen for Microsoft Edge
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge\SmartScreenEnabled]
@=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge\SmartScreenPuaEnabled]
@=dword:00000000

; Phishing protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WTDS\Components]
"CaptureThreatWindow"=dword:00000000
"NotifyMalicious"=dword:00000000
"NotifyPasswordReuse"=dword:00000000
"NotifyUnsafeApp"=dword:00000000
"ServiceEnabled"=dword:00000000

; Potentially unwanted app blocking
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender]
"PUAProtection"=dword:00000000

; Smartscreen for Microsoft Store apps
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost]
"EnableWebContentEvaluation"=dword:00000000

; Exploit protection - leaving control flow guard cfg on for Vanguard anticheat
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Session Manager\kernel]
"MitigationOptions"=hex:22,22,22,00,00,01,00,00,00,00,00,00,00,00,00,00,\
00,00,00,00,00,00,00,00

; Core isolation 
; Memory integrity 
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity]
"ChangedInBootCycle"=-
"Enabled"=dword:00000000
"WasEnabledBy"=-

; Kernel-mode hardware-enforced stack protection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\DeviceGuard\Scenarios\KernelShadowStacks]
"ChangedInBootCycle"=-
"Enabled"=dword:00000000
"WasEnabledBy"=-

; Microsoft vulnerable driver blocklist
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\CI\Config]
"VulnerableDriverBlocklistEnable"=dword:00000000

; DISABLE DEFENDER SERVICES
; Microsoft Defender Antivirus network inspection service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisSvc]
"Start"=dword:00000004

; Microsoft Defender antivirus service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinDefend]
"Start"=dword:00000004

; Microsoft Defender core service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MDCoreSvc]
"Start"=dword:00000004

; Security center
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wscsvc]
"Start"=dword:00000004

; Web threat defense service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\webthreatdefsvc]
"Start"=dword:00000004

; Web threat defense user service_XXXXX
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\webthreatdefusersvc]
"Start"=dword:00000004

; Windows Defender advanced threat protection service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sense]
"Start"=dword:00000004

; Windows security service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SecurityHealthService]
"Start"=dword:00000004

; DISABLE DEFENDER DRIVERS
; Microsoft Defender antivirus boot driver
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdBoot]
"Start"=dword:00000004

; Microsoft Defender Antivirus mini-filter driver
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdFilter]
"Start"=dword:00000004

; Microsoft Defender Antivirus network inspection system driver
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisDrv]
"Start"=dword:00000004

; DISABLE OTHER
; Windows Defender firewall
[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile]
"EnableFirewall"=dword:00000000

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile]
"EnableFirewall"=dword:00000000

; UAC
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"EnableLUA"=dword:00000000

; Spectre and Meltdown mitigations
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management]
"FeatureSettingsOverrideMask"=dword:00000003
"FeatureSettingsOverride"=dword:00000003

; Defender context menu handlers
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP]


[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\EPP]


[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP]

; Disable open file - security warning prompt
; Launching applications and unsafe files (not secure) - enable (not secure)
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1]
"2707"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2]
"270B"=dword:00000000
"2709"=dword:00000003
"2708"=dword:00000003
"2704"=dword:00000000
"2703"=dword:00000000
"2702"=dword:00000000
"2701"=dword:00000000
"2700"=dword:00000003
"2600"=dword:00000000
"2402"=dword:00000000
"2401"=dword:00000000
"2400"=dword:00000000
"2302"=dword:00000003
"2301"=dword:00000000
"2300"=dword:00000001
"2201"=dword:00000003
"2200"=dword:00000003
"2108"=dword:00000003
"2107"=dword:00000000
"2106"=dword:00000000
"2105"=dword:00000000
"2104"=dword:00000000
"2103"=dword:00000000
"2102"=dword:00000003
"2101"=dword:00000000
"2100"=dword:00000000
"2007"=dword:00010000
"2005"=dword:00000000
"2004"=dword:00000000
"2001"=dword:00000000
"2000"=dword:00000000
"1C00"=dword:00010000
"1A10"=dword:00000001
"1A06"=dword:00000000
"1A05"=dword:00000001
"2500"=dword:00000003
"270C"=dword:00000003
"1A02"=dword:00000000
"1A00"=dword:00020000
"1812"=dword:00000000
"1809"=dword:00000000
"1804"=dword:00000001
"1803"=dword:00000000
"1802"=dword:00000000
"160B"=dword:00000000
"160A"=dword:00000000
"1609"=dword:00000001
"1608"=dword:00000000
"1607"=dword:00000003
"1606"=dword:00000000
"1605"=dword:00000000
"1604"=dword:00000000
"1601"=dword:00000000
"140D"=dword:00000000
"140C"=dword:00000000
"140A"=dword:00000000
"1409"=dword:00000000
"1408"=dword:00000000
"1407"=dword:00000001
"1406"=dword:00000003
"1405"=dword:00000000
"1402"=dword:00000000
"120C"=dword:00000000
"120B"=dword:00000000
"120A"=dword:00000003
"1209"=dword:00000003
"1208"=dword:00000000
"1207"=dword:00000000
"1206"=dword:00000003
"1201"=dword:00000003
"1004"=dword:00000003
"1001"=dword:00000001
"1A03"=dword:00000000
"270D"=dword:00000000
"2707"=dword:00000000
"1A04"=dword:00000003

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
"2000"=dword:00000000
"2707"=dword:00000000
"2500"=dword:00000000
"1A00"=dword:00020000
"1402"=dword:00000000
"1409"=dword:00000000
"2105"=dword:00000003
"2103"=dword:00000003
"1407"=dword:00000001
"2101"=dword:00000000
"1606"=dword:00000000
"2301"=dword:00000000
"1809"=dword:00000000
"1601"=dword:00000000
"270B"=dword:00000003
"1607"=dword:00000003
"1804"=dword:00000001
"1806"=dword:00000000
"160A"=dword:00000003
"2100"=dword:00000000
"1802"=dword:00000000
"1A04"=dword:00000003
"1609"=dword:00000001
"2104"=dword:00000003
"2300"=dword:00000001
"120C"=dword:00000003
"2102"=dword:00000003
"1206"=dword:00000003
"1608"=dword:00000000
"2708"=dword:00000003
"2709"=dword:00000003
"1406"=dword:00000003
"2600"=dword:00000000
"1604"=dword:00000000
"1803"=dword:00000000
"1405"=dword:00000000
"270C"=dword:00000000
"120B"=dword:00000003
"1201"=dword:00000003
"1004"=dword:00000003
"1001"=dword:00000001
"120A"=dword:00000003
"2201"=dword:00000003
"1209"=dword:00000003
"1208"=dword:00000003
"2702"=dword:00000000
"2001"=dword:00000003
"2004"=dword:00000003
"2007"=dword:00010000
"2401"=dword:00000000
"2400"=dword:00000003
"2402"=dword:00000003
"CurrentLevel"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4]
"270C"=dword:00000000
"1A05"=dword:00000003
"1A04"=dword:00000003
"1A03"=dword:00000003
"1A02"=dword:00000003
"1A00"=dword:00010000
"1812"=dword:00000001
"180B"=dword:00000001
"1809"=dword:00000000
"1804"=dword:00000003
"1803"=dword:00000003
"1802"=dword:00000001
"160B"=dword:00000000
"160A"=dword:00000003
"1609"=dword:00000001
"1608"=dword:00000003
"1607"=dword:00000003
"1606"=dword:00000003
"1605"=dword:00000000
"1604"=dword:00000003
"1601"=dword:00000001
"140D"=dword:00000000
"140C"=dword:00000003
"140A"=dword:00000000
"1409"=dword:00000000
"1408"=dword:00000003
"1407"=dword:00000003
"1406"=dword:00000003
"1405"=dword:00000003
"1402"=dword:00000003
"120C"=dword:00000003
"120B"=dword:00000003
"120A"=dword:00000003
"1209"=dword:00000003
"1208"=dword:00000003
"1207"=dword:00000003
"1206"=dword:00000003
"1201"=dword:00000003
"1004"=dword:00000003
"1001"=dword:00000003
"1A10"=dword:00000003
"1C00"=dword:00000000
"2000"=dword:00000003
"2001"=dword:00000003
"2004"=dword:00000003
"2005"=dword:00000003
"2007"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"2300"=dword:00000003
"2301"=dword:00000000
"2302"=dword:00000003
"2400"=dword:00000003
"2401"=dword:00000003
"2402"=dword:00000003
"2600"=dword:00000003
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2704"=dword:00000003
"2708"=dword:00000003
"2709"=dword:00000003
"270B"=dword:00000003
"1A06"=dword:00000003
"270D"=dword:00000003
"2707"=dword:00000000
"2500"=dword:00000000

; POWERSHELL
; Allow powershell scripts
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell]
"ExecutionPolicy"="Unrestricted"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell]
"ExecutionPolicy"="Unrestricted"
"@
Set-Content -Path "$env:TEMP\SecurityOff.reg" -Value $MultilineComment -Force
# disable scheduled tasks
schtasks /Change /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /Disable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable | Out-Null
Clear-Host
Write-Host "Restarting To Safe Mode: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# toggle safe boot
cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
# restart
shutdown -r -t 00
exit

    }
    2 {

Clear-Host
Write-Host "This script intentionally disables all Windows Security:" -ForegroundColor Red
Write-Host "-Defender Windows Security Settings" -ForegroundColor Red
Write-Host "-Smartscreen" -ForegroundColor Red
Write-Host "-Defender Services" -ForegroundColor Red
Write-Host "-Defender Drivers" -ForegroundColor Red
Write-Host "-Windows Defender Firewall" -ForegroundColor Red
Write-Host "-User Account Control" -ForegroundColor Red
Write-Host "-Spectre Meltdown" -ForegroundColor Red
Write-Host "-Data Execution Prevention" -ForegroundColor Red
Write-Host "-Powershell Script Execution" -ForegroundColor Red
Write-Host "-Open File Security Warning" -ForegroundColor Red
Write-Host "-Windows Defender Default Definitions" -ForegroundColor Red
Write-Host "-Windows Defender Applicationguard" -ForegroundColor Red
Write-Host ""
Write-Host "This will leave the PC completely vulnerable." -ForegroundColor Red
Write-Host "If uncomfortable, please close this window!" -ForegroundColor Red
Write-Host ""
Pause
Clear-Host
Write-Host "Step: Two. Please wait . . ."
# Import reg file
Regedit.exe /S "$env:TEMP\SecurityOff.reg"
Timeout /T 5 | Out-Null
# Import reg file RunAsTI
$SecurityOff = @'
Regedit.exe /S "$env:TEMP\SecurityOff.reg"
'@
RunAsTI powershell "-nologo -windowstyle hidden -command $SecurityOff"
Timeout /T 5 | Out-Null
# Stop smartscreen running
Stop-Process -Force -Name smartscreen -ErrorAction SilentlyContinue | Out-Null
# Move smartscreen
$SmartScreen = @'
cmd.exe /c move /y "C:\Windows\System32\smartscreen.exe" "C:\Windows\smartscreen.exe"
'@
RunAsTI powershell "-nologo -windowstyle hidden -command $SmartScreen"
Timeout /T 5 | Out-Null
# Disable windows-defender-default-definitions
Dism /Online /NoRestart /Disable-Feature /FeatureName:Windows-Defender-Default-Definitions | Out-Null
# Disable windows-defender-applicationguard
Dism /Online /NoRestart /Disable-Feature /FeatureName:Windows-Defender-ApplicationGuard | Out-Null
# Disable data execution prevention
cmd /c "bcdedit /set nx AlwaysOff >nul 2>&1"
Clear-Host
Write-Host "Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Toggle normal boot
cmd /c "bcdedit /deletevalue safeboot >nul 2>&1"
# Restart
shutdown -r -t 00
exit

    }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
    exit
    }
    2 {
    Clear-Host
    Write-Host "1. Step: One"
    Write-Host "2. Step: Two (Im In Safe Mode)"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "Step: One. Please wait . . ."
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; ENABLE WINDOWS SECURITY SETTINGS
; Real time protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection]
"DisableRealtimeMonitoring"=dword:00000000

; Dev drive protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection]
"DisableAsyncScanOnOpen"=dword:00000000

; Cloud delivered protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Spynet]
"SpyNetReporting"=dword:00000002

; Automatic sample submission
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Spynet]
"SubmitSamplesConsent"=dword:00000001

; Tamper protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features]
"TamperProtection"=dword:00000005

; Controlled folder access 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access]
"EnableControlledFolderAccess"=dword:00000001

; Firewall notifications
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications]
"DisableEnhancedNotifications"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection]
"NoActionNotificationDisabled"=dword:00000000
"SummaryNotificationDisabled"=dword:00000000
"FilesBlockedNotificationDisabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows Defender Security Center\Account protection]
"DisableNotifications"=dword:00000000
"DisableDynamiclockNotifications"=dword:00000000
"DisableWindowsHelloNotifications"=dword:00000000

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Epoch]
"Epoch"=dword:000004cc

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile]
"DisableNotifications"=dword:00000000

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile]
"DisableNotifications"=dword:00000000

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile]
"DisableNotifications"=dword:00000000

; Smart app control (can't turn back on)
; [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender]
; "VerifiedAndReputableTrustModeEnabled"=dword:00000001
; "SmartLockerMode"=dword:00000001
; "PUAProtection"=dword:00000002

; [HKEY_LOCAL_MACHINE\System\ControlSet001\Control\AppID\Configuration\SMARTLOCKER]
; "START_PENDING"=dword:00000004
; "ENABLED"=hex(b):04,00,00,00,00,00,00,00

; [HKEY_LOCAL_MACHINE\System\ControlSet001\Control\CI\Policy]
; "VerifiedAndReputablePolicyState"=dword:00000001

; Check apps and files
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
"SmartScreenEnabled"="Warn"

; Smartscreen for Microsoft Edge
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge\SmartScreenEnabled]
@=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge\SmartScreenPuaEnabled]
@=dword:00000001

; Phishing protection
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WTDS\Components]
"CaptureThreatWindow"=dword:00000001
"NotifyMalicious"=dword:00000001
"NotifyPasswordReuse"=dword:00000001
"NotifyUnsafeApp"=dword:00000001
"ServiceEnabled"=dword:00000001

; Potentially unwanted app blocking
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender]
"PUAProtection"=dword:00000001

; Smartscreen for microsoft store apps
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost]
"EnableWebContentEvaluation"=dword:00000001

; Exploit protection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Session Manager\kernel]
"MitigationOptions"=hex(3):11,11,11,00,00,01,00,00,00,00,00,00,00,00,00,00,\
00,00,00,00,00,00,00,00

; Core isolation 
; Memory integrity 
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity]
"ChangedInBootCycle"=-
"Enabled"=dword:00000001
"WasEnabledBy"=dword:00000002

; Kernel-mode hardware-enforced stack protection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\DeviceGuard\Scenarios\KernelShadowStacks]
"ChangedInBootCycle"=-
"Enabled"=dword:00000001
"WasEnabledBy"=dword:00000002

; Microsoft vulnerable driver blocklist
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\CI\Config]
"VulnerableDriverBlocklistEnable"=dword:00000001

; ENABLE DEFENDER SERVICES
; Microsoft Defender Antivirus network inspection service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisSvc]
"Start"=dword:00000003

; Microsoft Defender Antivirus service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinDefend]
"Start"=dword:00000002

; Microsoft Defender core service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MDCoreSvc]
"Start"=dword:00000002

; Security center
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wscsvc]
"Start"=dword:00000002

; Web threat defense service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\webthreatdefsvc]
"Start"=dword:00000003

; Web threat defense user service_XXXXX
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\webthreatdefusersvc]
"Start"=dword:00000002

; Windows Defender advanced threat protection service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sense]
"Start"=dword:00000003

; Windows Security service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SecurityHealthService]
"Start"=dword:00000002

; ENABLE DEFENDER DRIVERS
; Microsoft Defender Antivirus boot driver
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdBoot]
"Start"=dword:00000000

; Microsoft Defender Antivirus mini-filter driver
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdFilter]
"Start"=dword:00000000

; Microsoft Defender Antivirus network inspection system driver
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisDrv]
"Start"=dword:00000003

; ENABLE OTHER
; Windows Defender firewall
[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile]
"EnableFirewall"=dword:00000001

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile]
"EnableFirewall"=dword:00000001

; UAC
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"EnableLUA"=dword:00000001

; Spectre and Meltdown mitigations
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management]
"FeatureSettingsOverrideMask"=-
"FeatureSettingsOverride"=-

; Defender context menu handlers
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP]
@="{09A47860-11B0-4DA5-AFA5-26D86198A780}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\EPP]
@="{09A47860-11B0-4DA5-AFA5-26D86198A780}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP]
@="{09A47860-11B0-4DA5-AFA5-26D86198A780}"

; Enable open file - security warning prompt
; Launching applications and unsafe files (not secure) - prompt (recommended)
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1]
"2707"=-

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2]
"270B"=-
"2709"=-
"2708"=-
"2704"=-
"2703"=-
"2702"=-
"2701"=-
"2700"=-
"2600"=-
"2402"=-
"2401"=-
"2400"=-
"2302"=-
"2301"=-
"2300"=-
"2201"=-
"2200"=-
"2108"=-
"2107"=-
"2106"=-
"2105"=-
"2104"=-
"2103"=-
"2102"=-
"2101"=-
"2100"=-
"2007"=-
"2005"=-
"2004"=-
"2001"=-
"2000"=-
"1C00"=-
"1A10"=-
"1A06"=-
"1A05"=-
"2500"=-
"270C"=-
"1A02"=-
"1A00"=-
"1812"=-
"1809"=-
"1804"=-
"1803"=-
"1802"=-
"160B"=-
"160A"=-
"1609"=-
"1608"=-
"1607"=-
"1606"=-
"1605"=-
"1604"=-
"1601"=-
"140D"=-
"140C"=-
"140A"=-
"1409"=-
"1408"=-
"1407"=-
"1406"=-
"1405"=-
"1402"=-
"120C"=-
"120B"=-
"120A"=-
"1209"=-
"1208"=-
"1207"=-
"1206"=-
"1201"=-
"1004"=-
"1001"=-
"1A03"=-
"270D"=-
"2707"=-
"1A04"=-

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
"2000"=-
"2707"=-
"2500"=-
"1A00"=-
"1402"=-
"1409"=-
"2105"=-
"2103"=-
"1407"=-
"2101"=-
"1606"=-
"2301"=-
"1809"=-
"1601"=-
"270B"=-
"1607"=-
"1804"=-
"1806"=-
"160A"=-
"2100"=-
"1802"=-
"1A04"=-
"1609"=-
"2104"=-
"2300"=-
"120C"=-
"2102"=-
"1206"=-
"1608"=-
"2708"=-
"2709"=-
"1406"=-
"2600"=-
"1604"=-
"1803"=-
"1405"=-
"270C"=-
"120B"=-
"1201"=-
"1004"=-
"1001"=-
"120A"=-
"2201"=-
"1209"=-
"1208"=-
"2702"=-
"2001"=-
"2004"=-
"2007"=-
"2401"=-
"2400"=-
"2402"=-
"CurrentLevel"=dword:11500

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4]
"270C"=-
"1A05"=-
"1A04"=-
"1A03"=-
"1A02"=-
"1A00"=-
"1812"=-
"180B"=-
"1809"=-
"1804"=-
"1803"=-
"1802"=-
"160B"=-
"160A"=-
"1609"=-
"1608"=-
"1607"=-
"1606"=-
"1605"=-
"1604"=-
"1601"=-
"140D"=-
"140C"=-
"140A"=-
"1409"=-
"1408"=-
"1407"=-
"1406"=-
"1405"=-
"1402"=-
"120C"=-
"120B"=-
"120A"=-
"1209"=-
"1208"=-
"1207"=-
"1206"=-
"1201"=-
"1004"=-
"1001"=-
"1A10"=-
"1C00"=-
"2000"=-
"2001"=-
"2004"=-
"2005"=-
"2007"=-
"2100"=-
"2101"=-
"2102"=-
"2103"=-
"2104"=-
"2105"=-
"2106"=-
"2107"=-
"2200"=-
"2201"=-
"2300"=-
"2301"=-
"2302"=-
"2400"=-
"2401"=-
"2402"=-
"2600"=-
"2700"=-
"2701"=-
"2702"=-
"2703"=-
"2704"=-
"2708"=-
"2709"=-
"270B"=-
"1A06"=-
"270D"=-
"2707"=-
"2500"=-

; POWERSHELL
; Disallow powershell scripts
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell]
"ExecutionPolicy"="Restricted"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell]
"ExecutionPolicy"="Restricted"
"@
Set-Content -Path "$env:TEMP\SecurityOn.reg" -Value $MultilineComment -Force
# Enable scheduled tasks
schtasks /Change /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /Enable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Enable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Enable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable | Out-Null
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Enable | Out-Null
Clear-Host
Write-Host "Restarting To Safe Mode: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Toggle safe boot
cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
# Restart
shutdown -r -t 00
exit

    }
    2 {

Clear-Host
Write-Host "Step: Two. Please wait . . ."
# Import reg file
Regedit.exe /S "$env:TEMP\SecurityOn.reg"
Timeout /T 5 | Out-Null
# Import reg file RunAsTI
$SecurityOn = @'
Regedit.exe /S "$env:TEMP\SecurityOn.reg"
'@
RunAsTI powershell "-nologo -windowstyle hidden -command $SecurityOn"
Timeout /T 5 | Out-Null
# Move smartscreen
$SmartScreen = @'
cmd.exe /c move /y "C:\Windows\smartscreen.exe" "C:\Windows\System32\smartscreen.exe"
'@
RunAsTI powershell "-nologo -windowstyle hidden -command $SmartScreen"
Timeout /T 5 | Out-Null
# Enable windows-defender-default-definitions (can't turn back on)
# Dism /Online /NoRestart /Enable-Feature /FeatureName:Windows-Defender-Default-Definitions | Out-Null
# Enable windows-defender-applicationguard
# Dism /Online /NoRestart /Enable-Feature /FeatureName:Windows-Defender-ApplicationGuard | Out-Null
# Enable data execution prevention
cmd /c "bcdedit /deletevalue nx >nul 2>&1"
Clear-Host
Write-Host "Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Toggle normal boot
cmd /c "bcdedit /deletevalue safeboot >nul 2>&1"
# Restart
shutdown -r -t 00
exit

    }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
    exit
    }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
  
}

Get-Admin

function Start-Menu {
    do {
        Clear-Host

        Write-Host "============================" -ForegroundColor Cyan
        Write-Host "        WinFix Menu        " -ForegroundColor Cyan -BackgroundColor DarkBlue
        Write-Host "============================" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "--- Basic setup & activation ---" -ForegroundColor Cyan
        Write-Host "1.  Windows Activation" -ForegroundColor Yellow
        Write-Host "2.  Run CTT WinUtil" -ForegroundColor Yellow
        Write-Host "3.  Install DDU" -ForegroundColor Yellow
        Write-Host "4.  Install NVIDIA driver" -ForegroundColor Yellow
        Write-Host "5.  Install dependencies" -ForegroundColor Yellow
        Write-Host "6.  Run basic tweaks" -ForegroundColor Yellow
        Write-Host "7.  Optimize power plan" -ForegroundColor Yellow
        Write-Host ""

        Write-Host "--- Optimisation and removal ---" -ForegroundColor Cyan
        Write-Host "8.  Optimize registry" -ForegroundColor Yellow
        Write-Host "9.  Remove UWP apps" -ForegroundColor Yellow
        Write-Host "10.  Remove UWP features" -ForegroundColor Yellow
        Write-Host "11. Remove legacy features" -ForegroundColor Yellow
        Write-Host "12. Remove legacy apps" -ForegroundColor Yellow
        Write-Host "" 

        Write-Host "--- Network ---" -ForegroundColor Cyan
        Write-Host "13. Optimize network" -ForegroundColor Yellow
        Write-Host "14. Update hosts file" -ForegroundColor Yellow
        Write-Host ""

        Write-Host "--- Advanced & Cleanup ---" -ForegroundColor Cyan
        Write-Host "15. Remove scheduled tasks" -ForegroundColor Yellow
        Write-Host "16. Run advanced tweaks" -ForegroundColor Yellow
        Write-Host "17. Remove AI" -ForegroundColor Yellow
        Write-Host "18. Install context menus" -ForegroundColor Yellow
        Write-Host "19. Hardening - Virtualisation Security Features" -ForegroundColor Yellow
        Write-Host "20. Hardening - Defender configuration" -ForegroundColor Yellow
        Write-Host "21. Enable WSL" -ForegroundColor Yellow
        Write-Host "22  Disable Defender/Security" -ForegroundColor Yellow
        Write-Host "23. Disk cleanup" -ForegroundColor Yellow
        Write-Host ""

        Write-Host "0.  Exit" -ForegroundColor Red
        Write-Host "==================================" -ForegroundColor Red

        $choice = Read-Host "Select an option (0 to exit)"

        switch ($choice) {
            '1'  { Invoke-Activation }
            '2'  { Invoke-WinUtil }
            '3'  { Install-DDU }
            '4'  { Install-NvidiaDriver }
            '5'  { Install-Dependencies }
            '6'  { Optimize-BasicTweaks }
            '7'  { Optimize-PowerPlan }
            '8'  { Optimize-Registry }
            '9'  { Remove-UWPApps }
            '10' { Remove-UWPFeatures }
            '11' { Remove-LegacyFeatures }
            '12' { Remove-LegacyApps }
            '13' { Optimize-Network }
            '14' { Update-Hostsfile }
            '15' { Remove-ScheduledTasks }
            '16' { Optimize-AdvancedTweaks }
            '17' { Remove-AI }
            '18' { Install-ContextMenus }
            '19' { Enable-VirtualizationSecurityFeatures }
            '20' { Set-DefenderConfig }
            '21' { Enable-WSL }
            '22' { Remove-Defender }
            '23' { Initialize-DiskCleanup }
            '0'  { exit }
            default {
                Write-Host "`nInvalid selection. Press Enter to try again..." -ForegroundColor Red
                Read-Host
            }
        }

        if ($choice -ne '0') {
            Write-Host "`nPress Enter to return to menu..."
            Read-Host
        }

    } while ($choice -ne '0')
}

Start-Menu
