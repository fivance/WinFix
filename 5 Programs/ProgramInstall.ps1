# Define URLs for the installers that always point to the latest version
$urls = @{
    "EverythingSearch" = "https://www.voidtools.com/Everything-1.4.1.1009.x64-Setup.exe"
    "Ditto" = "https://sourceforge.net/projects/ditto-cp/files/latest/download"
    "Lightshot" = "https://app.prntscr.com/build/setup-lightshot.exe"
    "HLSW" = "https://www.hlsw.org/download/HLSW_Setup.exe"
    "Notepad++" = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.Installer.x64.exe"
    "Putty" = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-installer.msi"
    "FileZilla" = "https://download.filezilla-project.org/client/FileZilla_latest_win64-setup.exe"
    "SublimeText" = "https://download.sublimetext.com/latest/stable/windows64"
    "TeamSpeak3Client" = "https://files.teamspeak-services.com/releases/client/3.5.6/TeamSpeak3-Client-win64-3.5.6.exe" # Needs manual check for latest
    "VLCMediaPlayer" = "https://get.videolan.org/vlc/last/win64/vlc-win64.exe"
}

# Define installation arguments for silent installs
$installArgs = @{
    "EverythingSearch" = "/S"
    "Ditto" = "/S"
    "Lightshot" = "/S"
    "HLSW" = "/S"
    "Notepad++" = "/S"
    "Putty" = "/quiet"
    "FileZilla" = "/S"
    "SublimeText" = "/verysilent"
    "TeamSpeak3Client" = "/S"
    "VLCMediaPlayer" = "/S"
}

# Create a temporary directory for the downloads
$tempDir = "$env:TEMP\ProgramDownloads"
New-Item -Path $tempDir -ItemType Directory -Force

# Function to download and install each program
function DownloadAndInstall {
    param (
        [string]$name,
        [string]$url,
        [string]$installArg
    )

    $filePath = "$tempDir\$name.exe"
    
    # Download the installer
    Write-Output "Downloading $name..."
    Invoke-WebRequest -Uri $url -OutFile $filePath

    # Install the program silently
    Write-Output "Installing $name..."
    Start-Process -FilePath $filePath -ArgumentList $installArg -Wait

    # Clean up the installer
    Remove-Item -Path $filePath -Force
}

# Ask user which programs to install
Write-Output "Select which programs to install (comma-separated list):"
$programsList = $urls.Keys -join ", "
Write-Output $programsList
$userInput = Read-Host "Enter your choices"

# Convert user input to array
$selectedPrograms = $userInput -split ",\s*" | ForEach-Object { $_.Trim() }

# Loop through selected programs and install them
foreach ($program in $selectedPrograms) {
    if ($urls.ContainsKey($program)) {
        DownloadAndInstall -name $program -url $urls[$program] -installArg $installArgs[$program]
    } else {
        Write-Output "Invalid selection: $program"
    }
}

# Remove the temporary directory
Remove-Item -Path $tempDir -Recurse -Force

Write-Output "Selected programs installed successfully."

