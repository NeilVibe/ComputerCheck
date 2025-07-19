# Safe Windows Event Monitor
Write-Host "=== SAFE WINDOWS EVENT MONITOR ===" -ForegroundColor Green
Write-Host "Checking important Windows Event IDs..." -ForegroundColor Yellow
Write-Host ""

$startTime = (Get-Date).AddDays(-7)

# Event ID 1116: Windows Defender detected malware
Write-Host "=== CHECKING EVENT ID 1116 (Windows Defender Detections) ===" -ForegroundColor Cyan
$defenderDetections = Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Windows Defender/Operational'
    ID=1116
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($defenderDetections) {
    Write-Host "Windows Defender detected $($defenderDetections.Count) threats in the last 7 days" -ForegroundColor Red
    $defenderDetections | Select-Object TimeCreated, Message | Format-List
} else {
    Write-Host "No malware detections by Windows Defender" -ForegroundColor Green
}

# Event ID 4625: Failed logon attempts
Write-Host "`n=== CHECKING EVENT ID 4625 (Failed Logons) ===" -ForegroundColor Cyan
$failedLogons = Get-WinEvent -FilterHashtable @{
    LogName='Security'
    ID=4625
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($failedLogons) {
    Write-Host "Found $($failedLogons.Count) failed logon attempts" -ForegroundColor Yellow
    $failedLogons | Select-Object TimeCreated -First 5 | Format-Table
} else {
    Write-Host "No failed logon attempts found" -ForegroundColor Green
}

# Event ID 7045: New service installed
Write-Host "`n=== CHECKING EVENT ID 7045 (New Services) ===" -ForegroundColor Cyan
$newServices = Get-WinEvent -FilterHashtable @{
    LogName='System'
    ID=7045
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($newServices) {
    Write-Host "New services installed in the last 7 days:" -ForegroundColor Yellow
    $newServices | Select-Object TimeCreated, Message | Format-List
} else {
    Write-Host "No new services installed" -ForegroundColor Green
}

# Event ID 4698: Scheduled task created
Write-Host "`n=== CHECKING EVENT ID 4698 (New Scheduled Tasks) ===" -ForegroundColor Cyan
$newTasks = Get-WinEvent -FilterHashtable @{
    LogName='Security'
    ID=4698
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($newTasks) {
    Write-Host "New scheduled tasks created:" -ForegroundColor Yellow
    $newTasks | Select-Object TimeCreated -First 5 | Format-Table
} else {
    Write-Host "No new scheduled tasks created" -ForegroundColor Green
}

# Event ID 4648: Logon with explicit credentials
Write-Host "`n=== CHECKING EVENT ID 4648 (Explicit Credential Logons) ===" -ForegroundColor Cyan
$explicitLogons = Get-WinEvent -FilterHashtable @{
    LogName='Security'
    ID=4648
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($explicitLogons) {
    Write-Host "Found $($explicitLogons.Count) explicit credential logons" -ForegroundColor Yellow
} else {
    Write-Host "No explicit credential logons found" -ForegroundColor Green
}

# Event ID 4657: Registry value modified
Write-Host "`n=== CHECKING EVENT ID 4657 (Registry Changes) ===" -ForegroundColor Cyan
$registryChanges = Get-WinEvent -FilterHashtable @{
    LogName='Security'
    ID=4657
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($registryChanges) {
    Write-Host "Found $($registryChanges.Count) registry modifications" -ForegroundColor Yellow
} else {
    Write-Host "No registry audit events (auditing may not be enabled)" -ForegroundColor Yellow
}

# Event ID 1001: Windows Error Reporting crashes
Write-Host "`n=== CHECKING EVENT ID 1001 (Application Crashes) ===" -ForegroundColor Cyan
$crashes = Get-WinEvent -FilterHashtable @{
    LogName='Application'
    ID=1001
    StartTime=$startTime
} -ErrorAction SilentlyContinue

if ($crashes) {
    Write-Host "Found $($crashes.Count) application crashes" -ForegroundColor Yellow
    $crashes | Select-Object TimeCreated, Message | Select-Object -First 3 | Format-List
} else {
    Write-Host "No application crashes found" -ForegroundColor Green
}

# Simple PowerShell activity check (safe version)
Write-Host "`n=== CHECKING POWERSHELL ACTIVITY (Safe Check) ===" -ForegroundColor Cyan
$psActivity = Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-PowerShell/Operational'
    ID=4103,4104
    StartTime=$startTime
} -ErrorAction SilentlyContinue | Where-Object {
    $_.Message -notmatch 'CheckComputer|security|event-monitor'
}

if ($psActivity) {
    Write-Host "PowerShell activity detected: $($psActivity.Count) events" -ForegroundColor Yellow
    Write-Host "This is normal if you use PowerShell regularly" -ForegroundColor Green
} else {
    Write-Host "No recent PowerShell activity" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Green
Write-Host "Event monitoring complete. Check any YELLOW or RED items above." -ForegroundColor Yellow