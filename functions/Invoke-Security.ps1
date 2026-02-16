function Invoke-Security {
  [CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$PSScriptRoot\PolicyApplication_$(Get-Date -Format 'yyyyMMdd_HHmmss').log",
    [Parameter(Mandatory=$false)]
    [switch]$ValidationReport
)


Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows Security Hardening Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. Block Finger Protocol (Port 79)
# ============================================================================
Clear-Host
Write-Host "[1/6] Block Finger Protocol (Port 79)" -ForegroundColor Yellow
Write-Host "Protection: ClickFix malware attacks" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $ruleName = "Block Finger Protocol (Port 79)"
        
        if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue) {
            Write-Host "`nFinger Protocol Block: Already Protected" -ForegroundColor Green
        } else {
            New-NetFirewallRule -DisplayName $ruleName `
                -Description "Blocks outbound TCP port 79 (Finger protocol) to prevent ClickFix malware attacks using finger.exe" `
                -Direction Outbound -Action Block -Protocol TCP -RemotePort 79 -Profile Any -Enabled True | Out-Null
            
            if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue) {
                Write-Host "`nFirewall Rule Created: Outbound TCP port 79 blocked" -ForegroundColor Green
            }
        }
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create firewall rule: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 2. Disable Legacy TLS 1.0 and TLS 1.1
# ============================================================================
Clear-Host
Write-Host "[2/6] Disable Legacy TLS 1.0 and TLS 1.1" -ForegroundColor Yellow
Write-Host "Protection: BEAST, CRIME, and weak cipher attacks" -ForegroundColor Gray
Write-Host "WARNING: May break old web applications" -ForegroundColor Red
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $tlsVersions = @("TLS 1.0", "TLS 1.1")
        $components = @("Server", "Client")
        
        foreach ($version in $tlsVersions) {
            foreach ($component in $components) {
                $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$version\$component"
                
                if (-not (Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }
                
                Set-ItemProperty -Path $regPath -Name "Enabled" -Value 0 -Force
                Set-ItemProperty -Path $regPath -Name "DisabledByDefault" -Value 1 -Force
            }
        }
        
        Write-Host "`nLegacy TLS Disabled Successfully!" -ForegroundColor Green
        Write-Host "  TLS 1.0: Client + Server" -ForegroundColor Gray
        Write-Host "  TLS 1.1: Client + Server" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable legacy TLS: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 3. Disable LLMNR (Port 5355)
# ============================================================================
Clear-Host
Write-Host "[3/6] Disable LLMNR (Port 5355)" -ForegroundColor Yellow
Write-Host "Protection: Responder poisoning, credential theft" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $disabledRules = 0
        
        # Get all enabled inbound rules with ports
        $allRules = Get-NetFirewallRule -Direction Inbound -Enabled True -ErrorAction SilentlyContinue
        $portFilters = @{}
        Get-NetFirewallPortFilter -ErrorAction SilentlyContinue | ForEach-Object {
            $portFilters[$_.InstanceID] = $_
        }
        
        # Disable LLMNR firewall rules
        foreach ($rule in $allRules) {
            $portFilter = $portFilters[$rule.InstanceID]
            if ($portFilter -and $rule.Action -eq 'Allow') {
                if ($portFilter.LocalPort -eq 5355 -or $portFilter.RemotePort -eq 5355) {
                    Disable-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue
                    $disabledRules++
                }
            }
        }
        
        Write-Host "`nRisky Firewall Ports Disabled: $disabledRules rules" -ForegroundColor Green
        Write-Host "  - LLMNR (5355)" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable risky ports: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 4. Remove PowerShell v2
# ============================================================================
Clear-Host
Write-Host "[4/6] Remove PowerShell v2" -ForegroundColor Yellow
Write-Host "Protection: Downgrade attacks, AMSI bypass" -ForegroundColor Gray
Write-Host "WARNING: May require reboot" -ForegroundColor Red
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $psv2Feature = Get-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -ErrorAction SilentlyContinue
        
        if (-not $psv2Feature) {
            Write-Host "`nPowerShell v2 not available on this OS (nothing to remove)" -ForegroundColor Green
        }
        elseif ($psv2Feature.State -ne 'Enabled') {
            Write-Host "`nPowerShell v2 already disabled (State: $($psv2Feature.State))" -ForegroundColor Green
        }
        else {
            Write-Host "`nRemoving PowerShell v2..." -ForegroundColor Yellow
            Write-Host "This may take up to 60 seconds..." -ForegroundColor Gray
            
            $result = Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart -ErrorAction Stop
            
            Write-Host "`nPowerShell v2 Removed Successfully!" -ForegroundColor Green
            
            if ($result.RestartNeeded) {
                Write-Host "`nIMPORTANT: REBOOT REQUIRED" -ForegroundColor Yellow
                Write-Host "Changes will take effect after reboot." -ForegroundColor Gray
            }
        }
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to remove PowerShell v2: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 5. Disable WDigest Credential Caching
# ============================================================================
Clear-Host
Write-Host "[5/6] Disable WDigest Credential Caching" -ForegroundColor Yellow
Write-Host "Protection: Credential dumping (Mimikatz)" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        $wdigestRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest"
        
        $currentValue = $null
        if (Test-Path $wdigestRegPath) {
            $currentValue = (Get-ItemProperty -Path $wdigestRegPath -Name "UseLogonCredential" -ErrorAction SilentlyContinue).UseLogonCredential
        }
        
        if (-not (Test-Path $wdigestRegPath)) {
            New-Item -Path $wdigestRegPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $wdigestRegPath -Name "UseLogonCredential" -Value 0 -Type DWord -Force
        
        $newValue = (Get-ItemProperty -Path $wdigestRegPath -Name "UseLogonCredential").UseLogonCredential
        
        if ($newValue -eq 0) {
            if ($currentValue -eq 1) {
                Write-Host "`nSECURITY IMPROVEMENT: WDigest was storing plaintext credentials!" -ForegroundColor Yellow
                Write-Host "This has now been FIXED. Plaintext credential storage is disabled." -ForegroundColor Green
            } else {
                Write-Host "`nWDigest Credential Protection Enabled!" -ForegroundColor Green
                Write-Host "Plaintext credentials will not be stored in memory." -ForegroundColor Gray
            }
            Write-Host "Successfully installed!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Failed to configure WDigest protection: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# 6. Disable WPAD (Web Proxy Auto-Discovery)
# ============================================================================
Clear-Host
Write-Host "[6/6] Disable WPAD (Web Proxy Auto-Discovery)" -ForegroundColor Yellow
Write-Host "Protection: MITM attacks, proxy hijacking" -ForegroundColor Gray
$response = Read-Host "Do you want to install this feature? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    try {
        # Machine-wide settings
        $hklmKeys = @(
            @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"; Name = "DisableWpad"; Value = 1},
            @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad"; Name = "WpadOverride"; Value = 1},
            @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"; Name = "AutoDetect"; Value = 0}
        )
        
        foreach ($key in $hklmKeys) {
            if (-not (Test-Path $key.Path)) {
                New-Item -Path $key.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Value -Type DWord -Force
        }
        
        # User settings - apply to all user profiles
        if (-not (Test-Path "HKU:")) {
            New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
        }
        
        $userSIDs = Get-ChildItem -Path "HKU:\" -ErrorAction SilentlyContinue | 
                    Where-Object { $_.PSChildName -match '^S-1-5-21-' -and $_.PSChildName -notmatch '_Classes$' } |
                    Select-Object -ExpandProperty PSChildName
        
        foreach ($sid in $userSIDs) {
            $userKeyPath = "HKU:\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
            if (-not (Test-Path $userKeyPath)) {
                New-Item -Path $userKeyPath -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-ItemProperty -Path $userKeyPath -Name "AutoDetect" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        }
        
        # Apply to .DEFAULT for new users
        $defaultPath = "HKU:\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
        if (-not (Test-Path $defaultPath)) {
            New-Item -Path $defaultPath -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path $defaultPath -Name "AutoDetect" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        Write-Host "`nWPAD Disabled Successfully!" -ForegroundColor Green
        Write-Host "  Applied to all user profiles" -ForegroundColor Gray
        Write-Host "  Protection: MITM attacks, proxy hijacking" -ForegroundColor Gray
        Write-Host "Successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable WPAD: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipped." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3
Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Security Hardening Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "All selected security features have been applied." -ForegroundColor Green
Write-Host "Your system is now more secure against common attacks." -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: Some changes may require a system reboot to take effect." -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 3


if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrator privileges. Please run as Administrator."
    exit 1
}
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Windows 11 25H2 Group Policy Application Script" -ForegroundColor Cyan
Write-Host "  Total Policies: 199 (174 Registry + 23 Audit + 2 User)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

#region Embedded Data
$PoliciesDataCompressed = "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"
$AuditPoliciesDataCompressed = "H4sIANQ6h2kC/9WYXW/TMBSG7/crjnK9iDpJGeVu6lip1NJoZuMCceE4p60htSvHLlTT/vtO2o4PiWkuMCQrSi4S28lzPl6fk48nALd0AiSjcpa8hmTKL9/DB6Vr87UFxiDrv80ghaFZrb1Dm5zuR3NfSeFwYey2m3Xua+VgaLFG7ZRo4EY0qhZOGf2bGaPr8UU367YnJQ6yfJ6+HAhMGasHaYV1nvZ7dBT9Xk7H3cMCYy0b39KKHJ1TetGtwD2t0LYgdA2XQjXe4vf37UfRh3jshuYJ3b87/afAHKW3ym1hZI1fw1RoscAVmSAA+uxvoR8DZc8Aet2ihXMpjdfuOMx+rL4t35VE7NSG/Ps0Z/EqJneW1uxMSwkbmKNZFRPfQ6ROjPxifECYsj/PxidCM3sGvIPa4KpC2y7VOiA8BzG5b2IWITHJotWWmVuSnu4wX3TX+RzebEhP2wBoGe1muUbZlQah3o1KcS7QkUWRDEtX4Evxk20fz8oiJtU5hiwr4k7NWfUZ5W4f6T4lNDezs1ipr3BlNqLqHOyMpeouIHijVd9DDWQaJbcwXAodgpvNoyqAPIUxdWJyV94dy5r3YmKdlpzfDOHKN5hOcIPN0bhZ3GL1C26wWOVRbT4cdauoGUPqXagla5BIqSkNyNuoGrO9Q/m2dbgKLwmL6P+fcEfPghOWRaVPPyAPbv3mumAOqoFZVKB7vrGmBzborwn7j8p78ukeshz/me0UAAA="
$UserPoliciesDataCompressed = "H4sIANQ6h2kC/72PMU/DMBCF9/6KU+YypBILG2qgSNAkakI71AgdzrW1ML7IZ6uKEP8dA41ERxaGG07ve0/vbScA7+kAskVdZVeQLZvbFjbGdXwUyHOYXd7N4AIehXw2/SHvaSjxjb7obcO7cERPStVsjTYkSi2N9ixJUOoUpNTccuzm7AK5MOas0UYakwoj+GKpPRjf1ejD0MT9niQYdjIa2qH/Zlc3i+diU62KUSgwYBLy9H1M/21S9D6tWZOXVDLRUQ4lB7MzGs9qn+0suWWUcN339sT99lTugfVroz2R+9PqydMne1rryssBAAA="

function Expand-CompressedJson {
    param([string]$CompressedData)
    try {
        $bytes = [Convert]::FromBase64String($CompressedData)
        $ms = New-Object System.IO.MemoryStream
        $ms.Write($bytes, 0, $bytes.Length)
        $ms.Position = 0
        $gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
        $sr = New-Object System.IO.StreamReader($gzip)
        $json = $sr.ReadToEnd()
        $sr.Close()
        $gzip.Close()
        $ms.Close()
        return $json | ConvertFrom-Json
    } catch {
        Write-Host "ERROR decompressing data:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        throw
    }
}

Write-Host "[*] Decompressing embedded policy data..." -ForegroundColor Yellow
try {
    $policies = Expand-CompressedJson -CompressedData $PoliciesDataCompressed
    Write-Host "[+] Loaded $($policies.Count) registry policies" -ForegroundColor Green
    
    $auditPolicies = Expand-CompressedJson -CompressedData $AuditPoliciesDataCompressed
    Write-Host "[+] Loaded $($auditPolicies.Count) audit policies" -ForegroundColor Green
    
    $userPolicies = Expand-CompressedJson -CompressedData $UserPoliciesDataCompressed
    Write-Host "[+] Loaded $($userPolicies.Count) user policies" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "FATAL ERROR: Failed to load embedded policy data" -ForegroundColor Red
    exit 1
}
#endregion

#region Functions
function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    switch ($Level) {
        'Info'    { Write-Host $logMessage -ForegroundColor Cyan }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
    }
    Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
}

function Clean-KeyName {
    param([string]$KeyName)
    return $KeyName.TrimStart('[')
}

function Apply-RegistryPolicies {
    param([array]$Policies, [string]$RegistryHive = 'HKLM')
    Write-Log "Applying $($Policies.Count) registry policies to $RegistryHive..." -Level Info
    $successCount = 0
    $errorCount = 0
    $counter = 0
    foreach ($policy in $Policies) {
        $counter++
        if ($counter % 20 -eq 0) {
            Write-Progress -Activity "Applying Registry Policies" -Status "$counter of $($Policies.Count)" -PercentComplete (($counter / $Policies.Count) * 100)
        }
        try {
            $keyPath = Clean-KeyName $policy.KeyName
            $fullPath = "$RegistryHive`:\$keyPath"
            if (-not (Test-Path $fullPath)) {
                New-Item -Path $fullPath -Force | Out-Null
            }
            $regType = switch ($policy.Type) {
                'REG_DWORD' { 'DWord' }
                'REG_SZ' { 'String' }
                'REG_MULTI_SZ' { 'MultiString' }
                'REG_EXPAND_SZ' { 'ExpandString' }
                'REG_BINARY' { 'Binary' }
                'REG_QWORD' { 'QWord' }
                default { 'String' }
            }
            $data = $policy.Data
            if ($regType -eq 'DWord' -or $regType -eq 'QWord') {
                $data = [int]$data
            }
            Set-ItemProperty -Path $fullPath -Name $policy.ValueName -Value $data -Type $regType -Force
            $successCount++
        } catch {
            Write-Log "Failed: $($policy.ValueName) - $($_.Exception.Message)" -Level Error
            $errorCount++
        }
    }
    Write-Progress -Activity "Applying Registry Policies" -Completed
    Write-Log "Registry: $successCount succeeded, $errorCount failed" -Level Info
    return @{Success = $successCount; Failed = $errorCount}
}

function Apply-AuditPolicies {
    param([array]$AuditPolicies)

    Write-Log "Applying $($AuditPolicies.Count) audit policies..." -Level Info
    $successCount = 0
    $errorCount = 0

    # Get list of valid subcategories for this system
    $validSubcategories = (auditpol /list /subcategory:* | ForEach-Object { $_.Trim() })

    foreach ($policy in $AuditPolicies) {
        try {
            # Remove "Audit " prefix if present
            $subcategory = $policy.Subcategory -replace '^Audit\s+', ''

            if (-not $validSubcategories -contains $subcategory) {
                Write-Log "Skipped (invalid subcategory): $($policy.Subcategory)" -Level Warning
                $errorCount++
                continue
            }

            $setting = $policy.InclusionSetting
            $auditSetting = switch ($setting) {
                'Success' { '/success:enable /failure:disable' }
                'Failure' { '/success:disable /failure:enable' }
                'Success and Failure' { '/success:enable /failure:enable' }
                'No Auditing' { '/success:disable /failure:disable' }
                default { '/success:disable /failure:disable' }
            }

            $command = "auditpol /set /subcategory:`"$subcategory`" $auditSetting"
            $result = Invoke-Expression $command 2>&1

            if ($LASTEXITCODE -eq 0) {
                $successCount++
            } else {
                Write-Log "Failed: $subcategory" -Level Error
                $errorCount++
            }

        } catch {
            Write-Log "Failed: $($policy.Subcategory) - $($_.Exception.Message)" -Level Error
            $errorCount++
        }
    }

    Write-Log "Audit: $successCount succeeded, $errorCount failed" -Level Info
    return @{Success = $successCount; Failed = $errorCount}
}


function Apply-UserRegistryPolicies {
    param([array]$Policies)
    Write-Log "Applying $($Policies.Count) user registry policies..." -Level Info
    $successCount = 0
    $errorCount = 0
    foreach ($policy in $Policies) {
        try {
            $keyPath = Clean-KeyName $policy.KeyName
            $fullPath = "HKCU:\$keyPath"
            if (-not (Test-Path $fullPath)) {
                New-Item -Path $fullPath -Force | Out-Null
            }
            $regType = switch ($policy.Type) {
                'REG_DWORD' { 'DWord' }
                'REG_SZ' { 'String' }
                'REG_MULTI_SZ' { 'MultiString' }
                'REG_EXPAND_SZ' { 'ExpandString' }
                'REG_BINARY' { 'Binary' }
                'REG_QWORD' { 'QWord' }
                default { 'String' }
            }
            $data = $policy.Data
            if ($regType -eq 'DWord' -or $regType -eq 'QWord') {
                $data = [int]$data
            }
            Set-ItemProperty -Path $fullPath -Name $policy.ValueName -Value $data -Type $regType -Force
            $successCount++
        } catch {
            Write-Log "Failed: $($policy.ValueName)" -Level Error
            $errorCount++
        }
    }
    Write-Log "User: $successCount succeeded, $errorCount failed" -Level Info
    return @{Success = $successCount; Failed = $errorCount}
}
#endregion

#region Main Execution
try {
    Write-Log "========================================" -Level Info
    Write-Log "Group Policy Application Started" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log "Log: $LogPath" -Level Info
    
    Write-Log "Creating system restore point..." -Level Info
    try {
        Checkpoint-Computer -Description "Before GPO" -RestorePointType "MODIFY_SETTINGS"
        Write-Log "Restore point created" -Level Success
    } catch {
        Write-Log "WARNING: Could not create restore point" -Level Warning
    }
    
    Write-Log "`nApplying Computer Registry Policies..." -Level Info
    $registryResults = Apply-RegistryPolicies -Policies $policies -RegistryHive 'HKLM'
    
    Write-Log "`nApplying Audit Policies..." -Level Info
    $auditResults = Apply-AuditPolicies -AuditPolicies $auditPolicies
    
    Write-Log "`nApplying User Registry Policies..." -Level Info
    $userResults = Apply-UserRegistryPolicies -Policies $userPolicies
    
    $totalSuccess = $registryResults.Success + $auditResults.Success + $userResults.Success
    $totalFailed = $registryResults.Failed + $auditResults.Failed + $userResults.Failed
    
    Write-Log "`n========================================" -Level Info
    Write-Log "SUMMARY" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log "Registry: $($registryResults.Success)/$($policies.Count)" -Level Info
    Write-Log "Audit: $($auditResults.Success)/$($auditPolicies.Count)" -Level Info
    Write-Log "User: $($userResults.Success)/$($userPolicies.Count)" -Level Info
    Write-Log "TOTAL: $totalSuccess policies applied successfully" -Level $(if ($totalFailed -eq 0) { 'Success' } else { 'Warning' })
    
    Write-Log "`n========================================" -Level Info
    Write-Log "NEXT STEPS" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log "1. Review log: $LogPath" -Level Info
    Write-Log "2. Run: gpupdate /force" -Level Info
    Write-Log "3. Restart computer" -Level Info
    
    Write-Host ""
    $response = Read-Host "Run gpupdate /force now? [Y/N]"
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Log "Running gpupdate..." -Level Info
        gpupdate /force
        Write-Log "Completed" -Level Success
    }
    
} catch {
    Write-Log "CRITICAL ERROR: $($_.Exception.Message)" -Level Error
    exit 1
} finally {
    Write-Log "`nScript completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level Info
}
#endregion

Write-Host "Applied Privacy, AI and Security Policies successfully!" -ForegroundColor Green
Write-Host "Please restart your computer to ensure all changes take effect." -ForegroundColor Yellow
  
}