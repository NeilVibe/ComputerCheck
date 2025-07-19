# Check Windows Event Levels (Danger Levels)
Write-Host "=== WINDOWS EVENT LEVELS (DANGER LEVELS) ===" -ForegroundColor Red
Write-Host "Checking for Critical, Error, and Warning events..." -ForegroundColor Yellow
Write-Host ""

$startTime = (Get-Date).AddDays(-7)

Write-Host "EVENT LEVEL MEANINGS:" -ForegroundColor Cyan
Write-Host "Level 1 = CRITICAL (System unstable/failing)" -ForegroundColor Red
Write-Host "Level 2 = ERROR (Something failed)" -ForegroundColor Red  
Write-Host "Level 3 = WARNING (Potential problems)" -ForegroundColor Yellow
Write-Host "Level 4 = INFORMATION (Normal operations)" -ForegroundColor Green
Write-Host "Level 5 = VERBOSE (Detailed info)" -ForegroundColor Gray
Write-Host ""

# Check for CRITICAL events (Level 1)
Write-Host "=== LEVEL 1: CRITICAL EVENTS ===" -ForegroundColor Red
$criticalEvents = Get-WinEvent -FilterHashtable @{
    Level=1
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($criticalEvents) {
    Write-Host "FOUND $($criticalEvents.Count) CRITICAL EVENTS!" -ForegroundColor Red
    $criticalEvents | Select-Object TimeCreated, LogName, Id, LevelDisplayName, Message | Format-Table -Wrap
} else {
    Write-Host "No Critical events found - GOOD!" -ForegroundColor Green
}

# Check for ERROR events (Level 2) 
Write-Host "`n=== LEVEL 2: ERROR EVENTS (Last 24 hours) ===" -ForegroundColor Red
$errorEvents = Get-WinEvent -FilterHashtable @{
    Level=2
    StartTime=(Get-Date).AddDays(-1)
} -ErrorAction SilentlyContinue | Select-Object -First 10

if ($errorEvents) {
    Write-Host "Found $($errorEvents.Count) Error events (showing first 10):" -ForegroundColor Yellow
    $errorEvents | Select-Object TimeCreated, LogName, Id, @{Name='Source';Expression={$_.ProviderName}} | Format-Table -AutoSize
} else {
    Write-Host "No Error events found" -ForegroundColor Green
}

# Check for WARNING events (Level 3)
Write-Host "`n=== LEVEL 3: WARNING EVENTS (Last 24 hours) ===" -ForegroundColor Yellow  
$warningEvents = Get-WinEvent -FilterHashtable @{
    Level=3
    StartTime=(Get-Date).AddDays(-1)
} -ErrorAction SilentlyContinue | Select-Object -First 10

if ($warningEvents) {
    Write-Host "Found Warning events (showing first 10):" -ForegroundColor Yellow
    $warningEvents | Select-Object TimeCreated, LogName, Id, @{Name='Source';Expression={$_.ProviderName}} | Format-Table -AutoSize
} else {
    Write-Host "No Warning events found" -ForegroundColor Green
}

# Check Security log for high-risk events
Write-Host "`n=== SECURITY LOG: HIGH-RISK EVENT IDs ===" -ForegroundColor Red
$securityRisk = Get-WinEvent -FilterHashtable @{
    LogName='Security'
    ID=4625,4648,4719,4720,4726,4728,4732,4756
    StartTime=$startTime
} -ErrorAction SilentlyContinue | Select-Object -First 10

if ($securityRisk) {
    Write-Host "High-risk Security events found:" -ForegroundColor Red
    $securityRisk | Select-Object TimeCreated, Id, @{Name='EventType';Expression={
        switch ($_.Id) {
            4625 { "Failed Logon" }
            4648 { "Explicit Credential Logon" }
            4719 { "System Audit Policy Changed" }
            4720 { "User Account Created" }
            4726 { "User Account Deleted" }
            4728 { "User Added to Global Group" }
            4732 { "User Added to Local Group" }
            4756 { "User Added to Universal Group" }
            default { "Other Security Event" }
        }
    }} | Format-Table -AutoSize
} else {
    Write-Host "No high-risk Security events found" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Event Levels checked for dangerous activity. Focus on Level 1 (Critical) and Level 2 (Error) events." -ForegroundColor White