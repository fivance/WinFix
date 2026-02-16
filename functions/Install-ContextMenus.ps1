function Install-ContextMenus {
  Clear-Host
  Write-Host "Installing ContextMenu entries..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

$repoBase = "https://raw.githubusercontent.com/fivance/contextmenu/main"

$regFiles = @(
    "CommandStore.reg",
    "SystemShortcutsContextMenu.reg",
    "SystemToolsContextMenu.reg"
)

foreach ($file in $regFiles) {
    try {
        $url  = "$repoBase/$file"
        $dest = Join-Path $env:TEMP $file

        Write-Host "Downloading $file ..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop

        Write-Host "Applying $file ..." -ForegroundColor Yellow
        Start-Process regedit.exe -ArgumentList "/s `"$dest`"" -Wait -NoNewWindow

        Write-Host "Cleaning up $file ..." -ForegroundColor DarkGray
        Remove-Item -Path $dest -Force -ErrorAction SilentlyContinue
        Write-Host "$file applied and removed from TEMP." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to process $file : $_" -ForegroundColor Red
    }
}
  
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

Reg.exe add 'HKCR\*\shell\runas' /ve /t REG_SZ /d 'Take Ownership' /f
Reg.exe add 'HKCR\*\shell\runas\command' /ve /t REG_SZ /d 'cmd.exe /c takeown /f \"%1\" && icacls \"%1\" /grant administrators:F' /f
Reg.exe add 'HKCR\*\shell\runas\command' /v 'IsolatedCommand' /t REG_SZ /d 'cmd.exe /c takeown /f \"%1\" && icacls \"%1\" /grant administrators:F' /f
Reg.exe add 'HKCR\Directory\shell\runas' /ve /t REG_SZ /d 'Take Ownership' /f
Reg.exe add 'HKCR\Directory\shell\runas\command' /ve /t REG_SZ /d 'cmd.exe /c takeown /f \"%1\" /r /d y && icacls \"%1\" /grant administrators:F /t' /f
Reg.exe add 'HKCR\Directory\shell\runas\command' /v 'IsolatedCommand' /t REG_SZ /d 'cmd.exe /c takeown /f \"%1\" /r /d y && icacls \"%1\" /grant administrators:F /t' /f
Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' /v '{9F156763-7844-4DC4-B2B1-901F640F5155}' /t REG_SZ /d `"`" /f
}