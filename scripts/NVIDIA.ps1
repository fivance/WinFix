# Clean old files
Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver.exe" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:TEMP\7-Zip.exe" -ErrorAction SilentlyContinue | Out-Null
# find latest nvidia driver
$uri = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=120&pfid=929&osID=57&languageCode=1033&isWHQL=1&dch=1&sort1=0&numberOfResults=1'
$response = Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing
$payload = $response.Content | ConvertFrom-Json
$version =  $payload.IDS[0].downloadInfo.Version
# Check windows version & bits
$windowsVersion = if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {"win10-win11"} else {"win8-win7"}
$windowsArchitecture = if ([Environment]::Is64BitOperatingSystem) {"64bit"} else {"32bit"}
# Create download link
$url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-dch-whql.exe"
Write-Output "Downloading: Nvidia Driver $version..."
# Download NVIDIA driver
Get-FileFromWeb -URL $url -File "$env:TEMP\NvidiaDriver.exe"
Clear-Host
Write-Host "Installing: Nvidia Driver..."
# Download 7zip
Get-FileFromWeb -URL "https://github.com/fivance/files/raw/main/7-Zip.exe" -File "$env:TEMP\7-Zip.exe"
# Install 7zip
Start-Process -wait "$env:TEMP\7-Zip.exe" /S
# Extract files with 7zip
cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\NvidiaDriver.exe" -o"$env:TEMP\NvidiaDriver" -y | Out-Null
# Install nvidia driver
Start-Process "$env:TEMP\NvidiaDriver\setup.exe"

  Clear-Host
Write-Host "Installing: NvidiaProfileInspector..."
# Download inspector
Get-FileFromWeb -URL "https://github.com/fivance/files/raw/main/Inspector.zip" -File "$env:TEMP\Inspector.zip"
# Extract files
Expand-Archive "$env:TEMP\Inspector.zip" -DestinationPath "$env:TEMP\Inspector" -ErrorAction SilentlyContinue
# create config for inspector
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
# import config
Start-Process -wait "$env:TEMP\Inspector\nvidiaProfileInspector.exe" -ArgumentList "$env:TEMP\Inspector\Inspector.nip"
# open nvidiacontrolpanel
Start-Process "shell:appsFolder\NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj!NVIDIACorp.NVIDIAControlPanel"
