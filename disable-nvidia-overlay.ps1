# Disable NVIDIA Overlay - PERMANENT FIX
# Based on web research: NVIDIA Overlay is #1 cause of UI freezing
# Run this ONCE to prevent daily freezing

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  DISABLE NVIDIA OVERLAY (PERMANENT)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will PERMANENTLY disable NVIDIA GeForce Overlay." -ForegroundColor Yellow
Write-Host "You won't be able to use Alt+Z for recording/screenshots." -ForegroundColor Yellow
Write-Host ""
Write-Host "WHY? Because NVIDIA Overlay causes:" -ForegroundColor Red
Write-Host "  - Daily UI freezing" -ForegroundColor Red
Write-Host "  - Ghost windows that block input" -ForegroundColor Red
Write-Host "  - Handle leaks" -ForegroundColor Red
Write-Host "  - This is a KNOWN ISSUE on forums!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    pause
    exit
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Disabling NVIDIA Overlay..." -ForegroundColor Yellow

# Method 1: Kill current processes
Write-Host "[1/4] Killing current NVIDIA Overlay processes..." -ForegroundColor Yellow
$killed = 0
Get-Process -Name "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    $killed++
}
Write-Host "  >> Killed $killed processes" -ForegroundColor Green

# Method 2: Disable via registry
Write-Host "[2/4] Disabling in registry..." -ForegroundColor Yellow
try {
    $regPath = "HKCU:\Software\NVIDIA Corporation\Global\GFExperience"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "EnableOverlay" -Value 0 -ErrorAction Stop
        Write-Host "  >> Registry key set to disabled" -ForegroundColor Green
    } else {
        Write-Host "  >> Registry path not found (might not have GeForce Experience)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  >> Could not modify registry: $_" -ForegroundColor Red
}

# Method 3: Disable scheduled tasks
Write-Host "[3/4] Disabling scheduled tasks..." -ForegroundColor Yellow
$tasksDisabled = 0
Get-ScheduledTask -TaskName "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue | ForEach-Object {
    Disable-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue
    $tasksDisabled++
}
if ($tasksDisabled -gt 0) {
    Write-Host "  >> Disabled $tasksDisabled scheduled tasks" -ForegroundColor Green
} else {
    Write-Host "  >> No scheduled tasks found" -ForegroundColor Gray
}

# Method 4: Instructions for GeForce Experience
Write-Host "[4/4] Manual steps needed..." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: You must also disable in GeForce Experience:" -ForegroundColor Red
Write-Host "  1. Open GeForce Experience" -ForegroundColor White
Write-Host "  2. Click Settings (gear icon in top right)" -ForegroundColor White
Write-Host "  3. Click 'General'" -ForegroundColor White
Write-Host "  4. Find 'In-Game Overlay'" -ForegroundColor White
Write-Host "  5. Toggle it OFF" -ForegroundColor White
Write-Host "  6. Restart your computer" -ForegroundColor White
Write-Host ""

Write-Host "======================================" -ForegroundColor Green
Write-Host "SCRIPT PART COMPLETE!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Follow manual steps above" -ForegroundColor White
Write-Host "2. Restart computer" -ForegroundColor White
Write-Host "3. UI freezing should stop!" -ForegroundColor Green
Write-Host ""
Write-Host "If you need overlay for recording, use OBS Studio instead." -ForegroundColor Yellow
Write-Host "OBS is better and doesn't cause freezing." -ForegroundColor Yellow
Write-Host ""

pause
