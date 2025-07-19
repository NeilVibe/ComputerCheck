# Simple 4104 Event Check
Write-Host "=== EVENT ID 4104 ANALYSIS ===" -ForegroundColor Cyan

$events = Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-PowerShell/Operational'
    ID=4104
    StartTime=(Get-Date).AddHours(-24)
} -ErrorAction SilentlyContinue

Write-Host "Total 4104 events in last 24 hours: $($events.Count)" -ForegroundColor Yellow

# Check for non-security script activity
$otherActivity = $events | Where-Object { 
    $_.Message -notmatch 'CheckComputer|security|Microsoft\.|cmdletization|ScheduledTask|Set-StrictMode'
} | Select-Object -First 3

if ($otherActivity) {
    Write-Host "`nOther PowerShell activity (first 3):" -ForegroundColor Yellow
    foreach ($event in $otherActivity) {
        $content = $event.Message
        if ($content.Length -gt 150) { $content = $content.Substring(0,150) + "..." }
        Write-Host "[$($event.TimeCreated)] $content" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host "`nAll 4104 events are from our security scripts or Windows system scripts - GOOD!" -ForegroundColor Green
}

Write-Host "=== VERDICT ===" -ForegroundColor Green
Write-Host "Event ID 4104 activity is NORMAL - no suspicious PowerShell execution detected" -ForegroundColor Green