Write-Host "Disabling UAC..."
Start-Sleep -Seconds 2
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
$currentValue = Get-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin"

# If the value is 0, it was done correctly
if ($currentValue.ConsentPromptBehaviorAdmin -eq 0) {
    Write-Output "The registry value was set successfully."
    Start-Sleep -Seconds 2
} else {
    Write-Output "The registry value was not set correctly."
    Start-Sleep -Seconds 2
}
Clear-Host