# Registry Startup Check - Malware Detection
Write-Host "=== REGISTRY STARTUP MALWARE SCANNER ===" -ForegroundColor Red
Write-Host "Scanning dangerous registry locations..." -ForegroundColor Yellow
Write-Host ""

$dangerousKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", 
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SYSTEM\CurrentControlSet\Services"
)

$suspiciousPatterns = @(
    "*temp*", "*tmp*", "*appdata*", "*programdata*", 
    "*system32*", "*syswow64*", "*.exe", "*.bat", 
    "*download*", "*users\public*", "*recycle*"
)

$knownGoodPrograms = @(
    "Windows Security", "Microsoft", "Intel", "NVIDIA", 
    "AMD", "Realtek", "Adobe", "Google", "Steam"
)

foreach ($key in $dangerousKeys) {
    Write-Host "Checking: $key" -ForegroundColor Cyan
    
    if (Test-Path $key) {
        $entries = Get-ItemProperty $key -ErrorAction SilentlyContinue
        
        if ($entries) {
            $entries.PSObject.Properties | Where-Object { 
                $_.Name -notlike "PS*" 
            } | ForEach-Object {
                $name = $_.Name
                $value = $_.Value
                
                $isKnownGood = $false
                foreach ($good in $knownGoodPrograms) {
                    if ($value -like "*$good*") {
                        $isKnownGood = $true
                        break
                    }
                }
                
                if (-not $isKnownGood) {
                    $isSuspicious = $false
                    foreach ($pattern in $suspiciousPatterns) {
                        if ($value -like $pattern) {
                            $isSuspicious = $true
                            break
                        }
                    }
                    
                    if ($isSuspicious) {
                        Write-Host "  [SUSPICIOUS] $name -> $value" -ForegroundColor Red
                    } else {
                        Write-Host "  [UNKNOWN] $name -> $value" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "  [SAFE] $name -> $value" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "  No entries found" -ForegroundColor Green
        }
    } else {
        Write-Host "  Key does not exist" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Registry startup scan complete." -ForegroundColor White
Write-Host "Review any RED (Suspicious) or YELLOW (Unknown) entries above." -ForegroundColor Yellow