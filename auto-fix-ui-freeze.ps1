# Auto-Fix UI Freeze Script
# Quick fix for daily freezing issues
# Double-click this when system freezes

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "    UI FREEZE AUTO-FIX SCRIPT" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 1. Kill NVIDIA Overlay (MAIN CULPRIT according to forums)
Write-Host "[1/5] Killing NVIDIA Overlay processes..." -ForegroundColor Yellow
$nvidiaKilled = 0
Get-Process -Name "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    $nvidiaKilled++
}
if ($nvidiaKilled -gt 0) {
    Write-Host "  >> Killed $nvidiaKilled NVIDIA Overlay processes" -ForegroundColor Green
} else {
    Write-Host "  >> No NVIDIA Overlay processes found" -ForegroundColor Gray
}

# 2. Kill frozen ASUS processes
Write-Host "[2/5] Killing ASUS Framework..." -ForegroundColor Yellow
$asusKilled = 0
Get-Process -Name "asus_framework" -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    $asusKilled++
}
if ($asusKilled -gt 0) {
    Write-Host "  >> Killed $asusKilled ASUS processes" -ForegroundColor Green
} else {
    Write-Host "  >> No frozen ASUS processes" -ForegroundColor Gray
}

# 3. Kill any frozen processes
Write-Host "[3/5] Killing frozen processes..." -ForegroundColor Yellow
$frozenKilled = 0
Get-Process | Where-Object { $_.Responding -eq $false -and $_.MainWindowHandle -ne 0 } | ForEach-Object {
    Write-Host "  >> Killing frozen: $($_.Name) (PID: $($_.Id))" -ForegroundColor Red
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    $frozenKilled++
}
if ($frozenKilled -eq 0) {
    Write-Host "  >> No frozen processes found" -ForegroundColor Gray
}

# 4. Check handle counts and restart if needed
Write-Host "[4/5] Checking handle leaks..." -ForegroundColor Yellow
$explorer = Get-Process explorer -ErrorAction SilentlyContinue
if ($explorer) {
    $explorerHandles = $explorer.Handles
    Write-Host "  >> Explorer handles: $explorerHandles" -ForegroundColor $(if ($explorerHandles -gt 3000) { "Red" } else { "Green" })

    if ($explorerHandles -gt 3000) {
        Write-Host "  >> Handle leak detected! Restarting Explorer..." -ForegroundColor Red
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 2
        Start-Process explorer
        Write-Host "  >> Explorer restarted" -ForegroundColor Green
    }
}

# 5. Check and restart DoSvc if leaking
Write-Host "[5/5] Checking Windows Update service..." -ForegroundColor Yellow
$dosvc = Get-Process -Name svchost | Where-Object {
    $svcName = (Get-WmiObject Win32_Service | Where-Object ProcessId -eq $_.Id | Select-Object -First 1).Name
    $svcName -eq 'DoSvc'
} | Select-Object -First 1

if ($dosvc -and $dosvc.Handles -gt 3000) {
    Write-Host "  >> DoSvc handle leak detected ($($dosvc.Handles) handles)" -ForegroundColor Red
    Write-Host "  >> Restarting DoSvc..." -ForegroundColor Yellow
    Restart-Service -Name DoSvc -Force -ErrorAction SilentlyContinue
    Write-Host "  >> DoSvc restarted" -ForegroundColor Green
} else {
    Write-Host "  >> DoSvc is healthy" -ForegroundColor Gray
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "    FIX COMPLETE!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Try clicking around now. If still frozen:" -ForegroundColor Yellow
Write-Host "  1. Press Ctrl+Alt+Delete" -ForegroundColor White
Write-Host "  2. Click 'Restart'" -ForegroundColor White
Write-Host ""
Write-Host "To PREVENT this from happening again:" -ForegroundColor Cyan
Write-Host "  Run: disable-nvidia-overlay.ps1" -ForegroundColor White
Write-Host ""

pause
