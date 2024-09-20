# Check for Administrator privileges and relaunch as Administrator if not running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Set the URL for the raw file and destination path
$fileUrl = "https://raw.githubusercontent.com/fivance/WinOpt/main/WinFix.ps1"  # Corrected URL
$destinationFile = "C:\WinFix.ps1"

# Use Invoke-WebRequest (iwr) to download the specific file
Invoke-WebRequest -Uri $fileUrl -OutFile $destinationFile -ErrorAction Stop


# =======================
# Download a Specific Folder
# =======================

# Set the URL of the ZIP file for the entire repository
$repoUrl = "https://github.com/fivance/WinOpt/archive/refs/heads/main.zip"
$destinationZip = "C:\WinOpt.zip"
$extractPath = "C:\ExtractedRepo"  # Changed to avoid conflict with destination folder

# Download the ZIP file of the repository
Invoke-WebRequest -Uri $repoUrl -OutFile $destinationZip -ErrorAction Stop

# Extract the ZIP file
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($destinationZip, $extractPath)

# Define the folder inside the repository that you want to extract
$folderInRepo = "$extractPath\WinOpt-main\files"
$destinationFolder = "C:\files"

# Check if the destination folder exists, and create it if it doesn't
if (-not (Test-Path $destinationFolder)) {
    try {
        New-Item -ItemType Directory -Path $destinationFolder -ErrorAction Stop
        Write-Host "Created folder: $destinationFolder"
    } catch {
        Write-Host "Failed to create folder: $_"
    }
} else {
    Write-Host "Folder already exists: $destinationFolder"
}

# Copy the specific folder's contents to C:\
if (Test-Path $folderInRepo) {
    # Copy the contents of the folder to avoid nesting
    Copy-Item -Path "$folderInRepo\*" -Destination $destinationFolder -Recurse -ErrorAction Stop
    Write-Host "Copied contents from $folderInRepo to $destinationFolder"
} else {
    Write-Host "The folder $folderInRepo does not exist."
}

# Clean up: remove the ZIP file and the extracted repository
Remove-Item -Force $destinationZip
Remove-Item -Recurse -Force $extractPath

Write-Host "File and Folder downloaded successfully to C:\"
