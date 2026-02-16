function Install-NvidiaDriver {
  Clear-Host
  Write-Host "Installing latest Nvidia Driver..." -ForegroundColor Cyan
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
  Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2501-x64.exe" -File "$env:TEMP\7-Zip.exe"
  Start-Process -wait "$env:TEMP\7-Zip.exe" /S
  cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\NvidiaDriver.exe" -o"$env:TEMP\NvidiaDriver" -y | Out-Null
  Start-Process "$env:TEMP\NvidiaDriver\setup.exe"
  Clear-Host
  Read-Host 'Press any key to continue (only press after driver is installed)'
  Write-Host "Installing: NvidiaProfileInspector..." -ForegroundColor Cyan
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
    Write-Host "Enabling P0 state for GPU..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    
  Clear-Host
  $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
  foreach($key in $subkeys){
  if ($key -notlike '*Configuration'){
  reg add "$key" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f | Out-Null
}
}
Clear-Host
Write-Host "P0 State: On ..."  -ForegroundColor Cyan
  $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
  foreach($key in $subkeys){
  if ($key -notlike '*Configuration'){
  Get-ItemProperty -Path "Registry::$key" -Name 'DisableDynamicPstate'
}
}

} else {
    Write-Host "Skipping GPU P0 state enable." -ForegroundColor Cyan
}   
  Start-Process "shell:appsFolder\NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj!NVIDIACorp.NVIDIAControlPanel"
}