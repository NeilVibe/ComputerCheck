# Diagnose System Slowness
Write-Host "=== SYSTEM SLOWNESS DIAGNOSTIC ===" -ForegroundColor Cyan

# Check disk I/O
Write-Host "`n[1] DISK I/O CHECK" -ForegroundColor Yellow
try {
    $diskPerf = Get-Counter '\PhysicalDisk(*)\% Disk Time' -ErrorAction Stop
    foreach ($sample in $diskPerf.CounterSamples) {
        if ($sample.CookedValue -gt 80) {
            Write-Host "WARNING: Disk $($sample.Path) at $([math]::Round($sample.CookedValue,2))% usage" -ForegroundColor Red
        } else {
            Write-Host "Disk $($sample.Path): $([math]::Round($sample.CookedValue,2))%" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Could not read disk performance counters" -ForegroundColor Red
}

# Check for not responding processes
Write-Host "`n[2] FROZEN PROCESSES" -ForegroundColor Yellow
$notResponding = Get-Process | Where-Object { $_.Responding -eq $false }
if ($notResponding.Count -gt 0) {
    $notResponding | Select-Object Name, Id | Format-Table
} else {
    Write-Host "No frozen processes found" -ForegroundColor Green
}

# Check Windows Defender activity
Write-Host "`n[3] WINDOWS DEFENDER SCAN STATUS" -ForegroundColor Yellow
$defender = Get-Process MsMpEng -ErrorAction SilentlyContinue
if ($defender) {
    Write-Host "Windows Defender CPU: $($defender.CPU)" -ForegroundColor Yellow
    Write-Host "Windows Defender RAM: $([math]::Round($defender.WS/1MB,0)) MB" -ForegroundColor Yellow

    $mpPref = Get-MpPreference -ErrorAction SilentlyContinue
    if ($mpPref) {
        Write-Host "Real-time protection: $($mpPref.DisableRealtimeMonitoring)" -ForegroundColor Yellow
    }
}

# Check for high CPU right NOW
Write-Host "`n[4] CURRENT HIGH CPU PROCESSES" -ForegroundColor Yellow
Get-Counter '\Process(*)\% Processor Time' | Select-Object -ExpandProperty CounterSamples |
    Where-Object { $_.CookedValue -gt 5 } |
    Sort-Object CookedValue -Descending |
    Select-Object -First 10 @{N='Process';E={$_.InstanceName}}, @{N='CPU %';E={[math]::Round($_.CookedValue,2)}} |
    Format-Table

# Check GPU usage
Write-Host "`n[5] GPU STATUS" -ForegroundColor Yellow
try {
    nvidia-smi --query-gpu=utilization.gpu,utilization.memory,temperature.gpu --format=csv,noheader,nounits 2>$null
} catch {
    Write-Host "Could not check GPU status (nvidia-smi not available)" -ForegroundColor Gray
}

Write-Host "`n=== END DIAGNOSTIC ===" -ForegroundColor Cyan
