If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
Exit}
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

function Show-ModernFilePicker {
param(
[ValidateSet('Folder', 'File')]
$Mode,
[string]$fileType
)
if ($Mode -eq 'Folder') {
$Title = 'Select Folder'
$modeOption = $false
$Filter = "Folders|`n"
}
else {
$Title = 'Select File'
$modeOption = $true
if ($fileType) {
$Filter = "$fileType Files (*.$fileType) | *.$fileType|All files (*.*)|*.*"
}
else {
$Filter = 'All Files (*.*)|*.*'
}
}
$AssemblyFullName = 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
$Assembly = [System.Reflection.Assembly]::Load($AssemblyFullName)
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.AddExtension = $modeOption
$OpenFileDialog.CheckFileExists = $modeOption
$OpenFileDialog.DereferenceLinks = $true
$OpenFileDialog.Filter = $Filter
$OpenFileDialog.Multiselect = $false
$OpenFileDialog.Title = $Title
$OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$OpenFileDialogType = $OpenFileDialog.GetType()
$FileDialogInterfaceType = $Assembly.GetType('System.Windows.Forms.FileDialogNative+IFileDialog')
$IFileDialog = $OpenFileDialogType.GetMethod('CreateVistaDialog', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $null)
$null = $OpenFileDialogType.GetMethod('OnBeforeVistaDialog', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $IFileDialog)
if ($Mode -eq 'Folder') {
[uint32]$PickFoldersOption = $Assembly.GetType('System.Windows.Forms.FileDialogNative+FOS').GetField('FOS_PICKFOLDERS').GetValue($null)
$FolderOptions = $OpenFileDialogType.GetMethod('get_Options', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $null) -bor $PickFoldersOption
$null = $FileDialogInterfaceType.GetMethod('SetOptions', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $FolderOptions)
}
$VistaDialogEvent = [System.Activator]::CreateInstance($AssemblyFullName, 'System.Windows.Forms.FileDialog+VistaDialogEvents', $false, 0, $null, $OpenFileDialog, $null, $null).Unwrap()
[uint32]$AdviceCookie = 0
$AdvisoryParameters = @($VistaDialogEvent, $AdviceCookie)
$AdviseResult = $FileDialogInterfaceType.GetMethod('Advise', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $AdvisoryParameters)
$AdviceCookie = $AdvisoryParameters[1]
$Result = $FileDialogInterfaceType.GetMethod('Show', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, [System.IntPtr]::Zero)
$null = $FileDialogInterfaceType.GetMethod('Unadvise', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $AdviceCookie)
if ($Result -eq [System.Windows.Forms.DialogResult]::OK) {
$FileDialogInterfaceType.GetMethod('GetResult', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $null)
}
return $OpenFileDialog.FileName
}

Write-Host "1. Priority: Already Running"
Write-Host "2. Priority: Launcher/Game Startup"
while ($true) {
$choice = Read-Host " "
if ($choice -match '^[1-2]$') {
switch ($choice) {
1 {

Clear-Host
# show priority options
Write-Host "1. Real Time"
Write-Host "2. High"
Write-Host "3. Above Normal"
Write-Host "4. Normal"
Write-Host "5. Below Normal"
Write-Host "6. Idle"
Write-Host ""
# select priority
$priochoice = Read-Host -Prompt "Priority"
Clear-Host
# map choice to priority
switch ($priochoice) {
"1" {$prio = "RealTime"}
"2" {$prio = "High"}
"3" {$prio = "AboveNormal"}
"4" {$prio = "Normal"}
"5" {$prio = "BelowNormal"}
"6" {$prio = "Idle"}
default {
Write-Host "Invalid input . . ." -ForegroundColor Red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit
}
}
# copy game exe id
(Get-Process | Where-Object {$_.WorkingSet64 -gt 500MB} | Select-Object Name, Id) | Format-Table -AutoSize
$exeid = Read-Host -Prompt "Enter Game Exe Id"
Clear-Host
# set game exe priority
$processid = Get-Process -Id $exeid -ErrorAction SilentlyContinue
$processid.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::$prio
Write-Host "Getting Value . . ."
Timeout /T 3 | Out-Null
Clear-Host
# show new value
$currentprio = $processid.PriorityClass
Write-Host "ID - $exeid = $currentprio"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

  }
2 {

Clear-Host
# stop game launchers running
$stop = "Battle.net", "BsgLauncher", "EADesktop", "EpicGamesLauncher", "GalaxyClient", "RobloxPlayerBeta", "RiotClientServices", "Launcher", "steam", "upc"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
Clear-Host
# show priority options
Write-Host "1. Real Time"
Write-Host "2. High"
Write-Host "3. Above Normal"
Write-Host "4. Normal"
Write-Host "5. Below Normal"
Write-Host "6. Low"
Write-Host ""
# select priority
$priochoice = Read-Host -Prompt "Priority"
Clear-Host
# map choice to priority
switch ($priochoice) {
"1" {$prio = "realtime"}
"2" {$prio = "high"}
"3" {$prio = "abovenormal"}
"4" {$prio = "normal"}
"5" {$prio = "belownormal"}
"6" {$prio = "low"}
default {
Write-Host "Invalid input . . ." -ForegroundColor Red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit
}
}
# select game launcher lnk or exe
Write-Host "Select Launcher/Game: Shortcut/Exe"
$gamelauncher = Show-ModernFilePicker -Mode File
Clear-Host
# set game exe priority
cmd /c "start `"`" /$prio `"$gamelauncher`""
# convert directory to file name without exe
$gamelauncher = [System.IO.Path]::GetFileNameWithoutExtension($gamelauncher)
# check value
$reloadgamelauncher = (Get-Process -Name "$gamelauncher").PriorityClass
Write-Host "Getting Value . . ."
Timeout /T 3 | Out-Null
Clear-Host
# show new value
Write-Host "EXE - $gamelauncher = $reloadgamelauncher"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

  }
} } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }