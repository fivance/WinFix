If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
Exit}
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

function Get-FileFromWeb {
param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
function Show-Progress {
param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
$percent = $CurrentValue / $TotalValue
$percentComplete = $percent * 100
if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
}
try {
$request = [System.Net.HttpWebRequest]::Create($URL)
$response = $request.GetResponse()
if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
[long]$fullSize = $response.ContentLength
[byte[]]$buffer = new-object byte[] 1048576
[long]$total = [long]$count = 0
$reader = $response.GetResponseStream()
$writer = new-object System.IO.FileStream $File, 'Create'
do {
$count = $reader.Read($buffer, 0, $buffer.Length)
$writer.Write($buffer, 0, $count)
$total += $count
if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
} while ($count -gt 0)
}
finally {
$reader.Close()
$writer.Close()
}
}

Write-Host "Installing: NvidiaProfileInspector . . ."
# check for file
if (-Not (Test-Path -Path "$env:TEMP\Inspector.exe")) {
# unblock drs files
$path = "C:\ProgramData\NVIDIA Corporation\Drs"
Get-ChildItem -Path $path -Recurse | Unblock-File
# download inspector
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Inspector.exe" -File "$env:TEMP\Inspector.exe"
# enable nvidia legacy sharpen
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableGR535" /t REG_DWORD /d "0" /f | Out-Null
reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters\FTS" /v "EnableGR535" /t REG_DWORD /d "0" /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters\FTS" /v "EnableGR535" /t REG_DWORD /d "0" /f | Out-Null
} else {
# skip
}
Clear-Host

Write-Host "1. Resizable BAR Force: On"
Write-Host "2. Resizable BAR Force: Off"
while ($true) {
$choice = Read-Host " "
if ($choice -match '^[1-2]$') {
switch ($choice) {
1 {

Clear-Host
Write-Host "Resizable BAR: On . . ."
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
    <SettingNameInfo />
    <SettingID>983226</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo />
    <SettingID>983227</SettingID>
    <SettingValue>1</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo />
    <SettingID>983295</SettingID>
    <SettingValue>AAAAQAAAAAA=</SettingValue>
    <ValueType>Binary</ValueType>
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
    <SettingValue>0</SettingValue>
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
Set-Content -Path "$env:TEMP\ReBarOn.nip" -Value $MultilineComment -Force
# import config
Start-Process -wait "$env:TEMP\Inspector.exe" -ArgumentList "$env:TEMP\ReBarOn.nip"
Clear-Host
Write-Host "Check Resizable BAR Is On: In Inspector . . ." -ForegroundColor Red
# open inspector
Start-Process -wait "$env:TEMP\Inspector.exe"
Clear-Host
Write-Host "Enable: Resizable BAR & Above 4G Decoding in BIOS" -ForegroundColor Red
Write-Host ""
Write-Host "Restarting To BIOS: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# restart to bios
cmd /c C:\Windows\System32\shutdown.exe /r /fw
exit

  }
2 {

Clear-Host
Write-Host "Resizable BAR: Off . . ."
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
    <SettingNameInfo />
    <SettingID>983226</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo />
    <SettingID>983227</SettingID>
    <SettingValue>0</SettingValue>
    <ValueType>Dword</ValueType>
  </ProfileSetting>
  <ProfileSetting>
    <SettingNameInfo />
    <SettingID>983295</SettingID>
    <SettingValue>AAAAAAAAAAA=</SettingValue>
    <ValueType>Binary</ValueType>
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
    <SettingValue>0</SettingValue>
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
Set-Content -Path "$env:TEMP\ReBarOff.nip" -Value $MultilineComment -Force
# import config
Start-Process -wait "$env:TEMP\Inspector.exe" -ArgumentList "$env:TEMP\ReBarOff.nip"
Clear-Host
Write-Host "Check Resizable BAR Is Off: In Inspector . . ." -ForegroundColor Red
# open inspector
Start-Process -wait "$env:TEMP\Inspector.exe"
Clear-Host
Write-Host "Disable: Resizable BAR & Above 4G Decoding in BIOS" -ForegroundColor Red
Write-Host ""
Write-Host "Restarting To BIOS: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# restart to bios
cmd /c C:\Windows\System32\shutdown.exe /r /fw
exit

  }
} } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }