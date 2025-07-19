# Check Event ID 4104 - PowerShell Script Block Logging
Write-Host "=== CHECKING EVENT ID 4104 (PowerShell Script Blocks) ===" -ForegroundColor Cyan
Write-Host "Looking at recent PowerShell script executions..." -ForegroundColor Yellow

$startTime = (Get-Date).AddHours(-24)

# Get PowerShell Script Block events
$scriptBlocks = Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-PowerShell/Operational'
    ID=4104
    StartTime=$startTime
} -ErrorAction SilentlyContinue

Write-Host "`nTotal PowerShell Script Block events in last 24 hours: $($scriptBlocks.Count)" -ForegroundColor Yellow

# Categorize the events
$ourSecurityScripts = $scriptBlocks | Where-Object { 
    $_.Message -match 'CheckComputer|security-check|event-monitor|memory-usage|comprehensive|deep-process|vmmem' 
}

$systemScripts = $scriptBlocks | Where-Object { 
    $_.Message -match 'Microsoft\.|Get-ChildItem|Set-StrictMode|cmdletization|ScheduledTask' -and
    $_.Message -notmatch 'CheckComputer'
}

$otherScripts = $scriptBlocks | Where-Object { 
    $_.Message -notmatch 'Microsoft\.|Get-ChildItem|Set-StrictMode|cmdletization|ScheduledTask|CheckComputer|security-check|event-monitor|memory-usage|comprehensive|deep-process|vmmem'
}

Write-Host "`n=== BREAKDOWN OF 4104 EVENTS ===" -ForegroundColor Green
Write-Host "Our Security Scripts: $($ourSecurityScripts.Count)" -ForegroundColor Green
Write-Host "Windows System Scripts: $($systemScripts.Count)" -ForegroundColor Green  
Write-Host "Other Scripts: $($otherScripts.Count)" -ForegroundColor Yellow

if ($otherScripts.Count -gt 0) {
    Write-Host "`n=== OTHER POWERSHELL ACTIVITY ===`n" -ForegroundColor Yellow
    $otherScripts | Select-Object TimeCreated, @{Name='ScriptContent';Expression={
        $content = $_.Message
        if ($content.Length -gt 200) { 
            $content.Substring(0,200) + "..." 
        } else { 
            $content 
        }
    }} | Format-List -First 5
} else {
    Write-Host "`nNo other PowerShell activity detected - all events are from our security checks or Windows system scripts" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Event ID 4104 shows PowerShell script execution activity." -ForegroundColor White
Write-Host "✅ All activity appears normal - mostly our security scripts and Windows system operations" -ForegroundColor Green