# Disable ALL Known Freezing Culprits
# Based on web research: NVIDIA Overlay + ASUS Armoury Crate cause daily freezing
# Run this ONCE after reboot to prevent freezing

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DISABLE FREEZING CULPRITS (PERMANENT)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will PERMANENTLY disable:" -ForegroundColor Yellow
Write-Host "  1. NVIDIA GeForce Overlay" -ForegroundColor Red
Write-Host "  2. ASUS Armoury Crate" -ForegroundColor Red
Write-Host ""
Write-Host "WHY? Web research shows these cause:" -ForegroundColor Red
Write-Host "  - Daily UI freezing" -ForegroundColor Red
Write-Host "  - Ghost windows blocking input" -ForegroundColor Red
Write-Host "  - Frozen processes" -ForegroundColor Red
Write-Host "  - Handle leaks" -ForegroundColor Red
Write-Host ""
Write-Host "NOTE: You can still use" -ForegroundColor Cyan
Write-Host "  - NVIDIA drivers (just not the overlay)" -ForegroundColor White
Write-Host "  - BIOS fan controls (Armoury Crate not needed)" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    pause
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# ============================================
# PART 1: DISABLE NVIDIA OVERLAY
# ============================================
Write-Host ""
Write-Host "[PART 1] Disabling NVIDIA Overlay..." -ForegroundColor Yellow
Write-Host ""

# 1.1: Kill current processes
Write-Host "  [1/3] Killing NVIDIA Overlay processes..." -ForegroundColor Cyan
$nvidiaKilled = 0
Get-Process -Name "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    $nvidiaKilled++
}
Write-Host "    >> Killed $nvidiaKilled processes" -ForegroundColor $(if ($nvidiaKilled -gt 0) { "Green" } else { "Gray" })

# 1.2: Disable via registry
Write-Host "  [2/3] Disabling in registry..." -ForegroundColor Cyan
try {
    $regPath = "HKCU:\Software\NVIDIA Corporation\Global\GFExperience"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "EnableOverlay" -Value 0 -ErrorAction Stop
        Write-Host "    >> Registry disabled" -ForegroundColor Green
    } else {
        Write-Host "    >> Registry path not found" -ForegroundColor Gray
    }
} catch {
    Write-Host "    >> Could not modify registry: $_" -ForegroundColor Red
}

# 1.3: Disable scheduled tasks
Write-Host "  [3/3] Disabling scheduled tasks..." -ForegroundColor Cyan
$nvidiaTasksDisabled = 0
Get-ScheduledTask -TaskName "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue | ForEach-Object {
    Disable-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue
    $nvidiaTasksDisabled++
}
Write-Host "    >> Disabled $nvidiaTasksDisabled tasks" -ForegroundColor $(if ($nvidiaTasksDisabled -gt 0) { "Green" } else { "Gray" })

Write-Host ""
Write-Host "  [OK] NVIDIA Overlay disabled" -ForegroundColor Green

# ============================================
# PART 2: DISABLE ASUS ARMOURY CRATE
# ============================================
Write-Host ""
Write-Host "[PART 2] Disabling ASUS Armoury Crate..." -ForegroundColor Yellow
Write-Host ""

# 2.1: Stop Armoury Crate service
Write-Host "  [1/5] Stopping Armoury Crate service..." -ForegroundColor Cyan
try {
    Stop-Service -Name "ArmouryCrateService" -Force -ErrorAction Stop
    Set-Service -Name "ArmouryCrateService" -StartupType Disabled -ErrorAction Stop
    Write-Host "    >> ArmouryCrateService stopped and disabled" -ForegroundColor Green
} catch {
    Write-Host "    >> Service not found or already stopped" -ForegroundColor Gray
}

# 2.2: Kill all ASUS Framework processes
Write-Host "  [2/5] Killing ASUS Framework processes..." -ForegroundColor Cyan
$asusKilled = 0
Get-Process -Name "asus_framework","ArmourySocketServer","ArmourySwAgent" -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    $asusKilled++
}
Write-Host "    >> Killed $asusKilled processes" -ForegroundColor $(if ($asusKilled -gt 0) { "Green" } else { "Gray" })

# 2.3: Disable ASUS services (keep fan control if needed)
Write-Host "  [3/5] Disabling ASUS services..." -ForegroundColor Cyan
$services = @("ArmouryCrateService", "asComSvc", "AsusUpdateCheck", "LightingService")
$servicesDisabled = 0
foreach ($svc in $services) {
    try {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        $servicesDisabled++
    } catch {
        # Service doesn't exist, skip
    }
}
Write-Host "    >> Disabled $servicesDisabled services" -ForegroundColor Green
Write-Host "    >> Kept: AsusFanControlService (for fan control)" -ForegroundColor Cyan

# 2.4: Disable scheduled tasks
Write-Host "  [4/5] Disabling ASUS scheduled tasks..." -ForegroundColor Cyan
$asusTasksDisabled = 0
Get-ScheduledTask -TaskName "*ASUS*","*Armoury*" -ErrorAction SilentlyContinue | ForEach-Object {
    Disable-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue
    $asusTasksDisabled++
}
Write-Host "    >> Disabled $asusTasksDisabled tasks" -ForegroundColor $(if ($asusTasksDisabled -gt 0) { "Green" } else { "Gray" })

# 2.5: Remove from startup
Write-Host "  [5/5] Removing from startup..." -ForegroundColor Cyan
$startupRemoved = 0
$startupKeys = @(
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($key in $startupKeys) {
    if (Test-Path $key) {
        Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty | ForEach-Object {
            $name = $_.Name
            if ($name -like "*ASUS*" -or $name -like "*Armoury*") {
                Remove-ItemProperty -Path $key -Name $name -ErrorAction SilentlyContinue
                $startupRemoved++
            }
        }
    }
}
Write-Host "    >> Removed $startupRemoved startup entries" -ForegroundColor $(if ($startupRemoved -gt 0) { "Green" } else { "Gray" })

Write-Host ""
Write-Host "  [OK] ASUS Armoury Crate disabled" -ForegroundColor Green

# ============================================
# SUMMARY
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "ALL BLOATWARE DISABLED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was disabled:" -ForegroundColor Cyan
Write-Host "  [x] NVIDIA GeForce Overlay" -ForegroundColor White
Write-Host "  [x] ASUS Armoury Crate" -ForegroundColor White
Write-Host "  [x] $($nvidiaKilled + $asusKilled) processes killed" -ForegroundColor White
Write-Host "  [x] $($servicesDisabled) services disabled" -ForegroundColor White
Write-Host "  [x] $($nvidiaTasksDisabled + $asusTasksDisabled) scheduled tasks disabled" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. RESTART your computer" -ForegroundColor White
Write-Host "2. Test for 2-3 days" -ForegroundColor White
Write-Host "3. Freezing should STOP or be much less frequent!" -ForegroundColor Green
Write-Host ""
Write-Host "If you need Armoury Crate features:" -ForegroundColor Yellow
Write-Host "  - Fan control: Use BIOS instead (better)" -ForegroundColor White
Write-Host "  - RGB lighting: Use OpenRGB (open source, no freezing)" -ForegroundColor White
Write-Host ""
Write-Host "If you need recording/overlay:" -ForegroundColor Yellow
Write-Host "  - Use OBS Studio (better than NVIDIA, no freezing)" -ForegroundColor White
Write-Host ""

pause
