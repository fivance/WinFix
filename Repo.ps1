
# Set the URL for the raw file and destination path
$fileUrl = "https://raw.githubusercontent.com/fivance/WinOpt/refs/heads/main/WinFix.ps1"
$destinationFile = "C:\WinFIX.ps1"

# Use Invoke-WebRequest (iwr) to download the specific file
Invoke-WebRequest -Uri $fileUrl -OutFile $destinationFile


# =======================
# Download a Specific Folder
# =======================

# Set the URL of the ZIP file for the entire repository
$repoUrl = "https://github.com/fivance/WinOpt/archive/refs/heads/main.zip"
$destinationZip = "C:\WinOpt.zip"
$extractPath = "C:\ExtractedRepo"

# Download the ZIP file of the repository
Invoke-WebRequest -Uri $repoUrl -OutFile $destinationZip

# Extract the ZIP file
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($destinationZip, $extractPath)

# Define the folder inside the repository that you want to extract
$folderInRepo = "$extractPath\WinOpt\files"
$destinationFolder = "C:\files"

# Copy the specific folder to C:\
Copy-Item -Path $folderInRepo -Destination $destinationFolder -Recurse

# Clean up: remove the ZIP file and the extracted repository
Remove-Item -Force $destinationZip
Remove-Item -Recurse -Force $extractPath

Write-Host "File and Folder downloaded successfully to C:\"
