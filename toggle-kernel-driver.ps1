# Toggle Any Kernel Driver On/Off
# Universal script for enabling/disabling kernel drivers

param(
    [string]$DriverName
)

Write-Host "=== KERNEL DRIVER TOGGLE ===" -ForegroundColor Cyan
Write-Host ""

# If no driver specified, show menu
if (-not $DriverName) {
    Write-Host "Available kernel drivers on your system:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[1] IOMap     - Korean software driver (KakaoTalk)"
    Write-Host "[2] vgk       - Riot Vanguard anti-cheat (Valorant/League)"
    Write-Host "[3] vgc       - Riot Vanguard client service"
    Write-Host "[4] Custom    - Enter driver name manually"
    Write-Host ""

    $choice = Read-Host "Select driver (1-4) or press Enter to exit"

    switch ($choice) {
        "1" { $DriverName = "IOMap" }
        "2" { $DriverName = "vgk" }
        "3" { $DriverName = "vgc" }
        "4" { $DriverName = Read-Host "Enter driver name" }
        default {
            Write-Host "Cancelled." -ForegroundColor Gray
            exit
        }
    }
}

# Check if driver exists
$driverExists = sc query $DriverName 2>$null
if (-not $driverExists) {
    Write-Host "ERROR: Driver '$DriverName' not found on system" -ForegroundColor Red
    Write-Host ""
    Write-Host "To list all drivers:" -ForegroundColor Yellow
    Write-Host "driverquery /v | findstr /i `"$DriverName`"" -ForegroundColor Gray
    pause
    exit
}

# Get current status
$driverStatus = sc query $DriverName 2>$null
$driverConfig = sc qc $DriverName 2>$null

Write-Host "=== DRIVER: $DriverName ===" -ForegroundColor Cyan
Write-Host ""

# Determine current state
$isEnabled = $false
$isRunning = $false

if ($driverStatus -match "RUNNING") {
    $isRunning = $true
}

if ($driverConfig -match "START_TYPE.*SYSTEM" -or $driverConfig -match "START_TYPE.*BOOT") {
    $isEnabled = $true
}

# Show current status
Write-Host "Current Status:" -ForegroundColor Yellow
if ($isEnabled) {
    Write-Host "  Start Type: ENABLED (will load on boot)" -ForegroundColor Green
} else {
    Write-Host "  Start Type: DISABLED (won't load on boot)" -ForegroundColor Red
}

if ($isRunning) {
    Write-Host "  Running: YES (currently loaded in kernel)" -ForegroundColor Yellow
} else {
    Write-Host "  Running: NO (not loaded)" -ForegroundColor Gray
}

Write-Host ""

# Driver-specific info
switch ($DriverName) {
    "IOMap" {
        Write-Host "About IOMap:" -ForegroundColor Cyan
        Write-Host "  - Korean software driver (KakaoTalk related)"
        Write-Host "  - Used for Korean keyboard/banking features"
        Write-Host "  - Safe to disable if only using KakaoTalk messaging"
    }
    "vgk" {
        Write-Host "About vgk (Riot Vanguard Kernel):" -ForegroundColor Cyan
        Write-Host "  - Riot Games anti-cheat (kernel-level)"
        Write-Host "  - Required for: Valorant, League of Legends"
        Write-Host "  - Disabling improves performance but games won't work"
    }
    "vgc" {
        Write-Host "About vgc (Riot Vanguard Client):" -ForegroundColor Cyan
        Write-Host "  - Riot Games anti-cheat (client service)"
        Write-Host "  - Works with vgk kernel driver"
        Write-Host "  - Usually disable both vgk and vgc together"
    }
}

Write-Host ""

# Offer toggle
if ($isEnabled) {
    Write-Host "Action: DISABLE $DriverName" -ForegroundColor Yellow
    Write-Host "This will prevent it from loading on next boot." -ForegroundColor Gray
    Write-Host ""

    $confirm = Read-Host "Disable $DriverName? (y/n)"
    if ($confirm -eq 'y') {
        sc config $DriverName start=disabled | Out-Null
        Write-Host ""
        Write-Host "✓ $DriverName DISABLED" -ForegroundColor Green
        Write-Host "REBOOT REQUIRED to apply changes" -ForegroundColor Red

        if ($isRunning) {
            Write-Host ""
            Write-Host "NOTE: Driver is still running NOW (loaded in kernel)" -ForegroundColor Yellow
            Write-Host "It will be unloaded after reboot" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No changes made." -ForegroundColor Gray
    }

} else {
    Write-Host "Action: ENABLE $DriverName" -ForegroundColor Yellow
    Write-Host "This will make it load on next boot." -ForegroundColor Gray
    Write-Host ""

    $confirm = Read-Host "Enable $DriverName? (y/n)"
    if ($confirm -eq 'y') {
        # Determine appropriate start type
        Write-Host ""
        Write-Host "Select start type:" -ForegroundColor Yellow
        Write-Host "[1] System   - Loads very early in boot (most kernel drivers)"
        Write-Host "[2] Demand   - Loads when needed (services)"
        Write-Host "[3] Boot     - Loads during boot (rare)"
        Write-Host ""

        $startChoice = Read-Host "Select (1-3, default: 1)"
        $startType = "system"

        switch ($startChoice) {
            "2" { $startType = "demand" }
            "3" { $startType = "boot" }
            default { $startType = "system" }
        }

        sc config $DriverName start=$startType | Out-Null
        Write-Host ""
        Write-Host "✓ $DriverName ENABLED (start=$startType)" -ForegroundColor Green
        Write-Host "REBOOT REQUIRED to apply changes" -ForegroundColor Red
    } else {
        Write-Host "No changes made." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "==========================" -ForegroundColor Cyan
pause
