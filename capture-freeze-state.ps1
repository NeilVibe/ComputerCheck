# Freeze State Capture Tool
# Run this IMMEDIATELY when UI freeze occurs
# Usage: .\capture-freeze-state.ps1

param(
    [string]$OutputFile = "freeze-state-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "FREEZE STATE CAPTURE TOOL" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Capturing system state during UI freeze..." -ForegroundColor Yellow
Write-Host "Output file: $OutputFile" -ForegroundColor Green
Write-Host ""

$output = @()
$output += "FREEZE STATE CAPTURE"
$output += "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += "="*80
$output += ""

# 1. CRITICAL: Explorer.exe Status
Write-Host "[1/8] Checking Explorer.exe status..." -ForegroundColor Yellow
$output += "="*80
$output += "1. EXPLORER.EXE STATUS (CRITICAL METRIC)"
$output += "="*80
try {
    $explorer = Get-Process explorer -ErrorAction SilentlyContinue
    if ($explorer) {
        $output += "Name        : $($explorer.Name)"
        $output += "Process ID  : $($explorer.Id)"
        $output += "CPU         : $($explorer.CPU)"
        $output += "Memory (MB) : $([math]::Round($explorer.WorkingSet64/1MB, 2))"
        $output += "HANDLES     : $($explorer.Handles)  <-- CRITICAL! (Threshold: 5000+)"
        $output += "Threads     : $($explorer.Threads.Count)"
        $output += ""

        if ($explorer.Handles -gt 5000) {
            $output += ">>> ALERT: HANDLES CRITICAL! ($($explorer.Handles) > 5000)"
            Write-Host ">>> ALERT: Explorer.exe handles = $($explorer.Handles) (CRITICAL!)" -ForegroundColor Red
        } elseif ($explorer.Handles -gt 4000) {
            $output += ">>> WARNING: HANDLES HIGH ($($explorer.Handles) > 4000)"
            Write-Host ">>> WARNING: Explorer.exe handles = $($explorer.Handles) (High)" -ForegroundColor Yellow
        } else {
            $output += ">>> OK: Handles within normal range ($($explorer.Handles))"
            Write-Host ">>> OK: Explorer.exe handles = $($explorer.Handles)" -ForegroundColor Green
        }
    } else {
        $output += "ERROR: Explorer.exe not running!"
        Write-Host ">>> ERROR: Explorer.exe not running!" -ForegroundColor Red
    }
} catch {
    $output += "ERROR checking explorer: $_"
}
$output += ""

# 2. Top Processes by Handles
Write-Host "[2/8] Checking top processes by handle count..." -ForegroundColor Yellow
$output += "="*80
$output += "2. TOP 10 PROCESSES BY HANDLES"
$output += "="*80
try {
    $topHandles = Get-Process | Sort-Object -Property Handles -Descending | Select-Object -First 10
    $output += ($topHandles | Format-Table Name, Id, Handles, @{N='MemoryMB';E={[math]::Round($_.WorkingSet64/1MB,2)}}, CPU -AutoSize | Out-String)
} catch {
    $output += "ERROR: $_"
}
$output += ""

# 3. Top Processes by CPU
Write-Host "[3/8] Checking top processes by CPU..." -ForegroundColor Yellow
$output += "="*80
$output += "3. TOP 10 PROCESSES BY CPU"
$output += "="*80
try {
    $topCPU = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10
    $output += ($topCPU | Format-Table Name, Id, CPU, @{N='MemoryMB';E={[math]::Round($_.WorkingSet64/1MB,2)}}, Handles -AutoSize | Out-String)
} catch {
    $output += "ERROR: $_"
}
$output += ""

# 4. Kernel Drivers Status
Write-Host "[4/8] Checking kernel drivers..." -ForegroundColor Yellow
$output += "="*80
$output += "4. KERNEL DRIVERS STATUS"
$output += "="*80
try {
    $drivers = Get-CimInstance Win32_SystemDriver | Where-Object {$_.Name -in @('vgk', 'vgc', 'IOMap', 'GLCKIO2', 'WinRing0x64')}
    if ($drivers) {
        $output += ($drivers | Format-Table Name, State, Status, StartMode -AutoSize | Out-String)
    } else {
        $output += "No problematic drivers found running."
    }
} catch {
    $output += "ERROR: $_"
}
$output += ""

# 5. Recent Event Logs
Write-Host "[5/8] Checking recent event logs..." -ForegroundColor Yellow
$output += "="*80
$output += "5. RECENT EVENT LOGS (Last 5 Minutes)"
$output += "="*80
try {
    $events = Get-WinEvent -FilterHashtable @{LogName='System','Application'; Level=1,2,3; StartTime=(Get-Date).AddMinutes(-5)} -MaxEvents 15 -ErrorAction SilentlyContinue
    if ($events) {
        foreach ($event in $events) {
            $output += "Time: $($event.TimeCreated)"
            $output += "Source: $($event.ProviderName)"
            $output += "Event ID: $($event.Id)"
            $output += "Level: $($event.LevelDisplayName)"
            $output += "Message: $($event.Message.Substring(0, [Math]::Min(200, $event.Message.Length)))..."
            $output += "-"*40
        }
    } else {
        $output += "No recent errors/warnings found."
    }
} catch {
    $output += "ERROR: $_"
}
$output += ""

# 6. Network Connections
Write-Host "[6/8] Checking network connections..." -ForegroundColor Yellow
$output += "="*80
$output += "6. NETWORK CONNECTIONS"
$output += "="*80
try {
    $established = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue
    $listening = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
    $output += "Established connections: $($established.Count)"
    $output += "Listening ports: $($listening.Count)"
    $output += ""
    $output += "Top 5 processes by connection count:"
    $connGroups = $established | Group-Object -Property OwningProcess | Sort-Object Count -Descending | Select-Object -First 5
    foreach ($group in $connGroups) {
        $proc = Get-Process -Id $group.Name -ErrorAction SilentlyContinue
        $procName = if ($proc) { $proc.Name } else { "Unknown" }
        $output += "  PID $($group.Name) ($procName): $($group.Count) connections"
    }
} catch {
    $output += "ERROR: $_"
}
$output += ""

# 7. Services Status
Write-Host "[7/8] Checking critical services..." -ForegroundColor Yellow
$output += "="*80
$output += "7. CRITICAL SERVICES STATUS"
$output += "="*80
try {
    $services = Get-Service | Where-Object {$_.Name -like '*ROG*' -or $_.Name -like '*ASUS*' -or $_.Name -like '*Armoury*' -or $_.Name -like '*WSL*'}
    $output += ($services | Format-Table Name, Status, StartType -AutoSize | Out-String)
} catch {
    $output += "ERROR: $_"
}
$output += ""

# 8. System Info
Write-Host "[8/8] Capturing system info..." -ForegroundColor Yellow
$output += "="*80
$output += "8. SYSTEM INFORMATION"
$output += "="*80
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $output += "OS: $($os.Caption) $($os.Version)"
    $output += "Last Boot: $($os.LastBootUpTime)"
    $output += "Uptime: $((Get-Date) - $os.LastBootUpTime)"
    $output += "Total Memory: $([math]::Round($cs.TotalPhysicalMemory/1GB, 2)) GB"
    $output += "Free Memory: $([math]::Round($os.FreePhysicalMemory/1MB, 2)) MB"
} catch {
    $output += "ERROR: $_"
}
$output += ""

# Save to file
$output += "="*80
$output += "END OF CAPTURE"
$output += "="*80

$outputPath = Join-Path $PSScriptRoot $OutputFile
$output | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "CAPTURE COMPLETE!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "File saved: $outputPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Compare this file with BASELINE-HEALTHY-STATE.md" -ForegroundColor White
Write-Host "2. Look for differences in:" -ForegroundColor White
Write-Host "   - Explorer.exe handles (critical if > 5000)" -ForegroundColor White
Write-Host "   - New processes with high handles/CPU" -ForegroundColor White
Write-Host "   - Recent event log errors" -ForegroundColor White
Write-Host "   - Driver state changes" -ForegroundColor White
Write-Host ""

# Display summary
Write-Host "QUICK SUMMARY:" -ForegroundColor Cyan
if ($explorer) {
    Write-Host "  Explorer.exe Handles: $($explorer.Handles)" -ForegroundColor $(if ($explorer.Handles -gt 5000) { "Red" } elseif ($explorer.Handles -gt 4000) { "Yellow" } else { "Green" })
}
if ($established) {
    Write-Host "  Network Connections: $($established.Count)" -ForegroundColor White
}
Write-Host ""
