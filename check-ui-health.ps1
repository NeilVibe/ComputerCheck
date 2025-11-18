# Daily UI Health Check
# Run this once a day to catch problems BEFORE they cause freezing

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "    DAILY UI HEALTH CHECK" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Checking for early warning signs of UI freezing..." -ForegroundColor Yellow
Write-Host ""

$warnings = 0
$critical = 0

# Check 1: NVIDIA Overlay (main culprit)
Write-Host "[1/6] NVIDIA Overlay Check..." -ForegroundColor Cyan
$nvidiaOverlay = Get-Process -Name "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue
if ($nvidiaOverlay) {
    Write-Host "  [CRITICAL] NVIDIA Overlay is running!" -ForegroundColor Red
    Write-Host "  >> Found $($nvidiaOverlay.Count) processes" -ForegroundColor Red
    Write-Host "  >> This WILL cause freezing eventually!" -ForegroundColor Red
    Write-Host "  >> Run disable-nvidia-overlay.ps1 to fix" -ForegroundColor Yellow
    $critical++
} else {
    Write-Host "  [OK] NVIDIA Overlay not running" -ForegroundColor Green
}

# Check 2: Handle counts
Write-Host "[2/6] Handle Leak Check..." -ForegroundColor Cyan
$explorer = Get-Process explorer -ErrorAction SilentlyContinue
$system = Get-Process -Name System -ErrorAction SilentlyContinue

if ($explorer) {
    $status = if ($explorer.Handles -gt 4000) { "CRITICAL"; $critical++ }
              elseif ($explorer.Handles -gt 3000) { "WARNING"; $warnings++ }
              else { "OK" }
    $color = if ($explorer.Handles -gt 4000) { "Red" }
             elseif ($explorer.Handles -gt 3000) { "Yellow" }
             else { "Green" }
    Write-Host "  [$status] Explorer: $($explorer.Handles) handles" -ForegroundColor $color
}

if ($system) {
    $status = if ($system.Handles -gt 4000) { "CRITICAL"; $critical++ }
              elseif ($system.Handles -gt 3000) { "WARNING"; $warnings++ }
              else { "OK" }
    $color = if ($system.Handles -gt 4000) { "Red" }
             elseif ($system.Handles -gt 3000) { "Yellow" }
             else { "Green" }
    Write-Host "  [$status] System: $($system.Handles) handles" -ForegroundColor $color
}

# Check 3: Network port usage
Write-Host "[3/6] Network Port Check..." -ForegroundColor Cyan
$tcpConnections = (Get-NetTCPConnection -State Established,TimeWait -ErrorAction SilentlyContinue | Measure-Object).Count
$status = if ($tcpConnections -gt 2000) { "CRITICAL"; $critical++ }
          elseif ($tcpConnections -gt 1000) { "WARNING"; $warnings++ }
          else { "OK" }
$color = if ($tcpConnections -gt 2000) { "Red" }
         elseif ($tcpConnections -gt 1000) { "Yellow" }
         else { "Green" }
Write-Host "  [$status] TCP Connections: $tcpConnections" -ForegroundColor $color

# Check 4: Frozen processes
Write-Host "[4/6] Frozen Process Check..." -ForegroundColor Cyan
$frozen = Get-Process | Where-Object { $_.Responding -eq $false -and $_.MainWindowHandle -ne 0 }
if ($frozen) {
    foreach ($proc in $frozen) {
        Write-Host "  [WARNING] Frozen: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host "  [OK] No frozen processes" -ForegroundColor Green
}

# Check 5: ASUS Framework
Write-Host "[5/6] ASUS Framework Check..." -ForegroundColor Cyan
$asus = Get-Process -Name "asus_framework" -ErrorAction SilentlyContinue
if ($asus) {
    $notResponding = $asus | Where-Object { $_.Responding -eq $false }
    if ($notResponding) {
        Write-Host "  [WARNING] ASUS Framework frozen ($($notResponding.Count) processes)" -ForegroundColor Yellow
        $warnings++
    } else {
        Write-Host "  [OK] ASUS Framework running ($($asus.Count) processes)" -ForegroundColor Green
    }
} else {
    Write-Host "  [OK] ASUS Framework not running" -ForegroundColor Green
}

# Check 6: DoSvc handle leak
Write-Host "[6/6] Windows Update (DoSvc) Check..." -ForegroundColor Cyan
$dosvc = Get-Process -Name svchost | Where-Object {
    $svcName = (Get-WmiObject Win32_Service | Where-Object ProcessId -eq $_.Id | Select-Object -First 1).Name
    $svcName -eq 'DoSvc'
} | Select-Object -First 1

if ($dosvc) {
    $status = if ($dosvc.Handles -gt 4000) { "CRITICAL"; $critical++ }
              elseif ($dosvc.Handles -gt 3000) { "WARNING"; $warnings++ }
              else { "OK" }
    $color = if ($dosvc.Handles -gt 4000) { "Red" }
             elseif ($dosvc.Handles -gt 3000) { "Yellow" }
             else { "Green" }
    Write-Host "  [$status] DoSvc: $($dosvc.Handles) handles" -ForegroundColor $color
} else {
    Write-Host "  [OK] DoSvc not running" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "HEALTH CHECK SUMMARY" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Critical Issues: $critical" -ForegroundColor $(if ($critical -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $warnings" -ForegroundColor $(if ($warnings -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($critical -gt 0) {
    Write-Host "ACTION REQUIRED:" -ForegroundColor Red
    Write-Host "  Run auto-fix-ui-freeze.ps1 NOW to prevent freezing!" -ForegroundColor Yellow
} elseif ($warnings -gt 0) {
    Write-Host "CAUTION:" -ForegroundColor Yellow
    Write-Host "  Some issues detected. Monitor closely." -ForegroundColor Yellow
} else {
    Write-Host "System is healthy! No freezing expected." -ForegroundColor Green
}

Write-Host ""
pause
