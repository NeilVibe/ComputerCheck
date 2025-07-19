# Dangerous Windows Event IDs Reference
Write-Host "=== DANGEROUS WINDOWS EVENT IDs ===" -ForegroundColor Red
Write-Host "Checking for known dangerous Event IDs..." -ForegroundColor Yellow
Write-Host ""

$startTime = (Get-Date).AddDays(-7)

Write-Host "CRITICAL SECURITY EVENT IDs TO MONITOR:" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔴 CRITICAL THREATS:" -ForegroundColor Red
Write-Host "4625 - Failed Logon (Brute Force Attack)" -ForegroundColor Red
Write-Host "4648 - Explicit Credential Logon (Lateral Movement)" -ForegroundColor Red
Write-Host "4719 - System Audit Policy Changed (Covering Tracks)" -ForegroundColor Red
Write-Host "1116 - Windows Defender Malware Detection" -ForegroundColor Red
Write-Host ""
Write-Host "🟡 HIGH RISK:" -ForegroundColor Yellow
Write-Host "4720 - User Account Created" -ForegroundColor Yellow
Write-Host "4726 - User Account Deleted" -ForegroundColor Yellow
Write-Host "4728 - User Added to Security Group" -ForegroundColor Yellow
Write-Host "7045 - New Service Installed" -ForegroundColor Yellow
Write-Host "4698 - Scheduled Task Created" -ForegroundColor Yellow
Write-Host "4657 - Registry Value Modified" -ForegroundColor Yellow
Write-Host "4688 - Process Creation (if enabled)" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔵 MEDIUM RISK:" -ForegroundColor Cyan
Write-Host "4634 - Account Logged Off" -ForegroundColor Cyan
Write-Host "4624 - Successful Logon" -ForegroundColor Cyan
Write-Host "1001 - Application Error/Crash" -ForegroundColor Cyan
Write-Host "6008 - Unexpected System Shutdown" -ForegroundColor Cyan
Write-Host ""

# Check for the most dangerous ones
Write-Host "=== CHECKING YOUR SYSTEM FOR DANGEROUS EVENT IDs ===" -ForegroundColor Green

$dangerousEvents = @(
    @{ID=4625; Name="Failed Logon"; Risk="CRITICAL"},
    @{ID=4719; Name="Audit Policy Changed"; Risk="CRITICAL"},
    @{ID=1116; Name="Malware Detected"; Risk="CRITICAL"},
    @{ID=4720; Name="User Created"; Risk="HIGH"},
    @{ID=4726; Name="User Deleted"; Risk="HIGH"},
    @{ID=7045; Name="Service Installed"; Risk="HIGH"},
    @{ID=4698; Name="Task Created"; Risk="HIGH"},
    @{ID=6008; Name="Unexpected Shutdown"; Risk="MEDIUM"}
)

foreach ($event in $dangerousEvents) {
    $found = Get-WinEvent -FilterHashtable @{
        ID=$event.ID
        StartTime=$startTime
    } -ErrorAction SilentlyContinue
    
    $riskColor = switch ($event.Risk) {
        "CRITICAL" { "Red" }
        "HIGH" { "Yellow" }
        "MEDIUM" { "Cyan" }
        default { "White" }
    }
    
    if ($found) {
        Write-Host "[$($event.Risk)] Event $($event.ID) ($($event.Name)): $($found.Count) events" -ForegroundColor $riskColor
    } else {
        Write-Host "✅ Event $($event.ID) ($($event.Name)): No events" -ForegroundColor Green
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Event IDs checked for known dangerous activities." -ForegroundColor White
Write-Host "Focus on any RED (Critical) findings above." -ForegroundColor Red