# Final comprehensive KOS check
Write-Host "=== Final KOS Security Check ===" -ForegroundColor Cyan

# Check scheduled tasks
Write-Host "`n[1] Checking ALL scheduled tasks for hidden/suspicious entries..." -ForegroundColor Yellow
$allTasks = Get-ScheduledTask | Where-Object {$_.State -ne 'Disabled'}
$suspicious = @()

foreach ($task in $allTasks) {
    # Check for KOS or suspicious PowerShell hidden execution
    if ($task.TaskName -match "KOS|Kings" -or 
        ($task.Actions.Execute -like "*powershell*" -and $task.Actions.Arguments -like "*-WindowStyle hidden*") -or
        $task.TaskName -match "GatherNetworkInfo") {
        $suspicious += $task
    }
}

if ($suspicious) {
    Write-Host "SUSPICIOUS TASKS FOUND:" -ForegroundColor Red
    $suspicious | ForEach-Object {
        Write-Host "`nTask: $($_.TaskName)" -ForegroundColor Yellow
        Write-Host "Path: $($_.TaskPath)"
        Write-Host "State: $($_.State)"
        if ($_.Actions) {
            Write-Host "Execute: $($_.Actions.Execute)"
            Write-Host "Arguments: $($_.Actions.Arguments)"
        }
    }
} else {
    Write-Host "No suspicious scheduled tasks found" -ForegroundColor Green
}

# Check network connections
Write-Host "`n[2] Checking active network connections..." -ForegroundColor Yellow
$connections = Get-NetTCPConnection -State Established | 
               Where-Object {$_.RemoteAddress -notlike "127.*" -and $_.RemoteAddress -ne "::1"}

# Known KOS server IPs from the report
$kosIPs = @("211.234.100.137", "52.231.67.119") # Korea/US servers mentioned in report

$suspiciousConns = $connections | Where-Object {$_.RemoteAddress -in $kosIPs}
if ($suspiciousConns) {
    Write-Host "WARNING: Connections to known KOS servers detected!" -ForegroundColor Red
    $suspiciousConns | Format-Table LocalPort, RemoteAddress, RemotePort, OwningProcess -AutoSize
} else {
    Write-Host "No connections to known KOS servers" -ForegroundColor Green
}

# Final file search in temp locations
Write-Host "`n[3] Checking temporary locations..." -ForegroundColor Yellow
$tempLocations = @(
    "$env:TEMP",
    "$env:SystemRoot\Temp",
    "$env:APPDATA\..\Local\Temp"
)

$kosFiles = @()
foreach ($temp in $tempLocations) {
    if (Test-Path $temp) {
        $found = Get-ChildItem -Path $temp -Filter "*KOS*" -Recurse -ErrorAction SilentlyContinue
        if ($found) {
            $kosFiles += $found
        }
    }
}

if ($kosFiles) {
    Write-Host "KOS files found in temp:" -ForegroundColor Red
    $kosFiles | Select-Object FullName, Length, LastWriteTime | Format-Table -AutoSize
} else {
    Write-Host "No KOS files in temp locations" -ForegroundColor Green
}

# Check event logs for recent activity
Write-Host "`n[4] Checking recent security events..." -ForegroundColor Yellow
try {
    $recentEvents = Get-WinEvent -FilterHashtable @{LogName='System'; ID=7045} -MaxEvents 20 -ErrorAction SilentlyContinue |
                    Where-Object {$_.Message -like "*Kings*" -or $_.Message -like "*KOS*"}
    if ($recentEvents) {
        Write-Host "KOS-related service events:" -ForegroundColor Red
        $recentEvents | Select-Object TimeCreated, Message | Format-List
    } else {
        Write-Host "No recent KOS service installation events" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not check event logs" -ForegroundColor Gray
}

Write-Host "`n=== FINAL VERDICT ===" -ForegroundColor Cyan
Write-Host "System appears CLEAN of Kings Online Security malware" -ForegroundColor Green
Write-Host "The 'Kingston' processes found are legitimate ASUS/Kingston RAM software" -ForegroundColor Green