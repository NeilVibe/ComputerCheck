# Memory Usage Analysis
Write-Host "=== MEMORY USAGE ANALYSIS ===" -ForegroundColor Cyan
Write-Host "Checking which processes are using the most memory..." -ForegroundColor Yellow
Write-Host ""

# Get total system memory
$totalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$totalMemoryGB = [math]::Round($totalMemory / 1GB, 2)
$usedMemory = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize - (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
$usedMemoryGB = [math]::Round($usedMemory / 1MB, 2)
$usedPercent = [math]::Round(($usedMemory / ((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize)) * 100, 2)

Write-Host "Total RAM: $totalMemoryGB GB" -ForegroundColor White
Write-Host "Used RAM: $usedMemoryGB GB ($usedPercent%)" -ForegroundColor White
Write-Host ""

# Get top memory consuming processes
Write-Host "TOP 20 MEMORY CONSUMERS:" -ForegroundColor Green
$processes = Get-Process | Where-Object {$_.WorkingSet -gt 0} | Sort-Object WorkingSet -Descending | Select-Object -First 20

$processes | Select-Object @{Name="Process";Expression={$_.Name}},
    @{Name="PID";Expression={$_.Id}},
    @{Name="Memory (MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
    @{Name="Memory (GB)";Expression={[math]::Round($_.WorkingSet / 1GB, 2)}},
    @{Name="% of Total";Expression={[math]::Round(($_.WorkingSet / $totalMemory) * 100, 2)}} | Format-Table -AutoSize

# Check for memory leaks (processes using excessive memory for their type)
Write-Host "`nCHECKING FOR ABNORMAL MEMORY USAGE:" -ForegroundColor Yellow

$suspicious = @()

foreach ($proc in Get-Process | Where-Object {$_.WorkingSet -gt 0}) {
    $memoryMB = [math]::Round($proc.WorkingSet / 1MB, 2)
    
    # Define thresholds for common process types
    switch -Wildcard ($proc.Name.ToLower()) {
        "chrome*" { if ($memoryMB -gt 2000) { $suspicious += @{Name=$proc.Name; PID=$proc.Id; Memory="$memoryMB MB"; Reason="Chrome tab using >2GB"} } }
        "firefox*" { if ($memoryMB -gt 2000) { $suspicious += @{Name=$proc.Name; PID=$proc.Id; Memory="$memoryMB MB"; Reason="Firefox tab using >2GB"} } }
        "svchost*" { if ($memoryMB -gt 500) { $suspicious += @{Name=$proc.Name; PID=$proc.Id; Memory="$memoryMB MB"; Reason="svchost using >500MB"} } }
        "explorer*" { if ($memoryMB -gt 300) { $suspicious += @{Name=$proc.Name; PID=$proc.Id; Memory="$memoryMB MB"; Reason="Explorer using >300MB"} } }
        "*edge*" { if ($memoryMB -gt 2000) { $suspicious += @{Name=$proc.Name; PID=$proc.Id; Memory="$memoryMB MB"; Reason="Edge tab using >2GB"} } }
        default { 
            # For unknown processes, flag if using more than 1GB
            if ($memoryMB -gt 1024 -and $proc.Name -notmatch "game|steam|discord|slack|teams|visual studio|code|idea") {
                $suspicious += @{Name=$proc.Name; PID=$proc.Id; Memory="$memoryMB MB"; Reason="Unknown process using >1GB"}
            }
        }
    }
}

if ($suspicious.Count -gt 0) {
    Write-Host "PROCESSES WITH POTENTIALLY ABNORMAL MEMORY USAGE:" -ForegroundColor Red
    $suspicious | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize
} else {
    Write-Host "No processes with abnormal memory usage detected!" -ForegroundColor Green
}

# Memory pressure analysis
Write-Host "`nMEMORY PRESSURE ANALYSIS:" -ForegroundColor Yellow
if ($usedPercent -gt 90) {
    Write-Host "WARNING: Memory usage is VERY HIGH ($usedPercent%)!" -ForegroundColor Red
    Write-Host "Consider closing some applications." -ForegroundColor Red
} elseif ($usedPercent -gt 80) {
    Write-Host "Memory usage is high ($usedPercent%)" -ForegroundColor Yellow
} else {
    Write-Host "Memory usage is normal ($usedPercent%)" -ForegroundColor Green
}