# Test Suite for WSL Watchdog
# Run this BEFORE applying any watchdog changes

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  WSL WATCHDOG TEST SUITE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passed = 0
$failed = 0

# Test 1: Can we detect WSL running state?
Write-Host "[TEST 1] Detect WSL running state via exit code" -ForegroundColor Yellow
$null = wsl.exe -d Ubuntu2 --exec /bin/true 2>$null
$exitCode = $LASTEXITCODE
if ($exitCode -eq 0) {
    Write-Host "  PASS: Exit code 0 = WSL is running" -ForegroundColor Green
    $passed++
} else {
    Write-Host "  FAIL: Exit code $exitCode - detection broken" -ForegroundColor Red
    $failed++
}

# Test 2: Verify wsl --list --running has our distro (even with unicode issues)
Write-Host "[TEST 2] WSL list running contains Ubuntu2" -ForegroundColor Yellow
$running = wsl.exe --list --running 2>$null | Out-String
if ($running -match "U.*b.*u.*n.*t.*u.*2") {
    Write-Host "  PASS: Ubuntu2 found in running list" -ForegroundColor Green
    $passed++
} else {
    Write-Host "  FAIL: Ubuntu2 not in running list" -ForegroundColor Red
    $failed++
}

# Test 3: wt.exe exists
Write-Host "[TEST 3] Windows Terminal (wt.exe) exists" -ForegroundColor Yellow
$wt = Get-Command wt.exe -ErrorAction SilentlyContinue
if ($wt) {
    Write-Host "  PASS: wt.exe found at $($wt.Source)" -ForegroundColor Green
    $passed++
} else {
    Write-Host "  FAIL: wt.exe not found" -ForegroundColor Red
    $failed++
}

# Test 4: Scheduled task exists
Write-Host "[TEST 4] WSL-Watchdog task exists" -ForegroundColor Yellow
$task = Get-ScheduledTask -TaskName "WSL-Watchdog" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "  PASS: Task exists, State=$($task.State)" -ForegroundColor Green
    $passed++
} else {
    Write-Host "  FAIL: Task not found" -ForegroundColor Red
    $failed++
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESULTS: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if ($failed -gt 0) {
    exit 1
}
