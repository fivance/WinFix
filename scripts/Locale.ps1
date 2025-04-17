# Prompt user for language input
$language = Read-Host "Enter the language code (e.g., en-US for English, hr-HR for Croatian)"

# Set keyboard layout
Set-WinUILanguageOverride -Language $language
Set-WinUserLanguageList -Language $language -Force

# Set region format
Set-Culture -CultureInfo $language

# Set system locale
Set-WinSystemLocale -SystemLocale $language

# Update Windows region settings using registry
$languageRegion = $language -replace '-', '_'
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "LocaleName" -Value $languageRegion

# Restart system to apply changes
Write-Host "System needs to restart to apply changes..."
Start-Sleep -Seconds 3