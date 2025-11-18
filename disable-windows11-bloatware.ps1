# Permanent Windows 11 Bloatware Removal
# Disables handle-leaking processes that cause UI freezing
# Safe and reversible!

param(
    [switch]$DryRun = $false  # Set to $true to see what would be changed without actually changing
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "WINDOWS 11 BLOATWARE REMOVAL" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made!" -ForegroundColor Yellow
    Write-Host ""
}

$changes = @()
$errors = @()

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Running as Administrator: OK" -ForegroundColor Green
Write-Host ""

# ============================================
# 1. DISABLE WINDOWS WIDGETS (BIGGEST OFFENDER)
# ============================================
Write-Host "[1/7] Disabling Windows Widgets..." -ForegroundColor Yellow

try {
    # Method 1: Remove Widgets app package
    $widgetsPackage = Get-AppxPackage -Name "*WebExperience*" -ErrorAction SilentlyContinue
    if ($widgetsPackage) {
        if (-not $DryRun) {
            Remove-AppxPackage -Package $widgetsPackage.PackageFullName -ErrorAction Stop
            $changes += "✅ Removed Windows Widgets app package"
            Write-Host "  ✅ Widgets app package removed" -ForegroundColor Green
        } else {
            Write-Host "  [DRY RUN] Would remove: $($widgetsPackage.Name)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ℹ️ Widgets app already removed or not found" -ForegroundColor Gray
    }

    # Method 2: Hide Widgets icon from taskbar (registry)
    $taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (-not $DryRun) {
        Set-ItemProperty -Path $taskbarPath -Name "TaskbarDa" -Value 0 -Type DWord -Force
        $changes += "✅ Hidden Widgets icon from taskbar"
        Write-Host "  ✅ Widgets icon hidden from taskbar" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would hide Widgets from taskbar" -ForegroundColor Cyan
    }
} catch {
    $errors += "❌ Widgets: $_"
    Write-Host "  ❌ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 2. DISABLE SEARCHHOST (TASKBAR SEARCH)
# ============================================
Write-Host "[2/7] Disabling SearchHost (Taskbar Search)..." -ForegroundColor Yellow

try {
    # Hide search box from taskbar (you can still use Win+S!)
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (-not $DryRun) {
        # 0 = Hidden, 1 = Show search icon, 2 = Show search box
        Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force
        $changes += "✅ Hidden taskbar search box (Win+S still works!)"
        Write-Host "  ✅ Search box hidden from taskbar" -ForegroundColor Green
        Write-Host "  ℹ️ You can still search with Win+S keyboard shortcut!" -ForegroundColor Cyan
    } else {
        Write-Host "  [DRY RUN] Would hide search from taskbar" -ForegroundColor Cyan
    }
} catch {
    $errors += "❌ SearchHost: $_"
    Write-Host "  ❌ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 3. DISABLE PHONE LINK (PHONEEXPERIENCEHOST)
# ============================================
Write-Host "[3/7] Disabling Phone Link (PhoneExperienceHost)..." -ForegroundColor Yellow

try {
    # Remove Phone Link app
    $phonePackage = Get-AppxPackage -Name "*YourPhone*" -ErrorAction SilentlyContinue
    if ($phonePackage) {
        if (-not $DryRun) {
            Remove-AppxPackage -Package $phonePackage.PackageFullName -ErrorAction Stop
            $changes += "✅ Removed Phone Link app"
            Write-Host "  ✅ Phone Link app removed" -ForegroundColor Green
        } else {
            Write-Host "  [DRY RUN] Would remove: $($phonePackage.Name)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ℹ️ Phone Link app already removed or not found" -ForegroundColor Gray
    }

    # Kill any running instances
    if (-not $DryRun) {
        Stop-Process -Name "PhoneExperienceHost" -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ Stopped PhoneExperienceHost process" -ForegroundColor Green
    }
} catch {
    $errors += "❌ Phone Link: $_"
    Write-Host "  ❌ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 4. DISABLE WINDOWS CHAT (TEAMS)
# ============================================
Write-Host "[4/7] Disabling Windows Chat/Teams..." -ForegroundColor Yellow

try {
    # Hide Chat icon from taskbar
    $chatPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (-not $DryRun) {
        Set-ItemProperty -Path $chatPath -Name "TaskbarMn" -Value 0 -Type DWord -Force
        $changes += "✅ Hidden Chat/Teams icon from taskbar"
        Write-Host "  ✅ Chat/Teams icon hidden" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would hide Chat from taskbar" -ForegroundColor Cyan
    }

    # Remove Teams consumer app (not business Teams)
    $teamsPackage = Get-AppxPackage -Name "*MicrosoftTeams*" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*MSTeams*" }
    if ($teamsPackage) {
        if (-not $DryRun) {
            Remove-AppxPackage -Package $teamsPackage.PackageFullName -ErrorAction Stop
            Write-Host "  ✅ Removed Teams consumer app" -ForegroundColor Green
        } else {
            Write-Host "  [DRY RUN] Would remove: $($teamsPackage.Name)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ℹ️ Teams consumer app not found" -ForegroundColor Gray
    }
} catch {
    $errors += "❌ Chat/Teams: $_"
    Write-Host "  ❌ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 5. DISABLE CORTANA
# ============================================
Write-Host "[5/7] Disabling Cortana..." -ForegroundColor Yellow

try {
    # Disable Cortana
    $cortanaPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (-not $DryRun) {
        Set-ItemProperty -Path $cortanaPath -Name "ShowCortanaButton" -Value 0 -Type DWord -Force
        $changes += "✅ Disabled Cortana taskbar button"
        Write-Host "  ✅ Cortana button hidden" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would hide Cortana button" -ForegroundColor Cyan
    }
} catch {
    $errors += "❌ Cortana: $_"
    Write-Host "  ❌ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 6. DISABLE TASK VIEW BUTTON
# ============================================
Write-Host "[6/7] Disabling Task View button (Optional)..." -ForegroundColor Yellow

try {
    # Hide Task View button (you can still use Win+Tab)
    $taskViewPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (-not $DryRun) {
        Set-ItemProperty -Path $taskViewPath -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force
        $changes += "✅ Hidden Task View button (Win+Tab still works!)"
        Write-Host "  ✅ Task View button hidden" -ForegroundColor Green
        Write-Host "  ℹ️ You can still use Win+Tab keyboard shortcut!" -ForegroundColor Cyan
    } else {
        Write-Host "  [DRY RUN] Would hide Task View button" -ForegroundColor Cyan
    }
} catch {
    $errors += "❌ Task View: $_"
    Write-Host "  ❌ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 7. KILL BACKGROUND BLOATWARE PROCESSES
# ============================================
Write-Host "[7/7] Stopping bloatware background processes..." -ForegroundColor Yellow

$bloatwareProcesses = @(
    "Widgets",
    "WidgetService",
    "SearchHost",
    "PhoneExperienceHost",
    "MicrosoftEdgeUpdate"
)

foreach ($proc in $bloatwareProcesses) {
    try {
        if (-not $DryRun) {
            $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
            if ($running) {
                Stop-Process -Name $proc -Force -ErrorAction Stop
                Write-Host "  ✅ Stopped: $proc" -ForegroundColor Green
            }
        } else {
            $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
            if ($running) {
                Write-Host "  [DRY RUN] Would stop: $proc" -ForegroundColor Cyan
            }
        }
    } catch {
        # Ignore errors for processes not running
    }
}

Write-Host ""

# ============================================
# SUMMARY
# ============================================
Write-Host "================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

if ($changes.Count -gt 0) {
    Write-Host "Changes made:" -ForegroundColor Green
    foreach ($change in $changes) {
        Write-Host "  $change" -ForegroundColor White
    }
    Write-Host ""
}

if ($errors.Count -gt 0) {
    Write-Host "Errors encountered:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  $error" -ForegroundColor Yellow
    }
    Write-Host ""
}

if (-not $DryRun) {
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Restart Explorer.exe to apply changes:" -ForegroundColor White
    Write-Host "   taskkill /f /im explorer.exe; Start-Process explorer.exe" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Or reboot computer for full effect" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Monitor Explorer.exe handles to verify leak stopped:" -ForegroundColor White
    Write-Host "   Get-Process explorer | Select-Object Name, Handles" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "WHAT YOU CAN STILL DO:" -ForegroundColor Green
    Write-Host "  ✅ Search: Press Win+S (same search, no taskbar box)" -ForegroundColor White
    Write-Host "  ✅ Task View: Press Win+Tab (same feature, no button)" -ForegroundColor White
    Write-Host "  ✅ All other Windows features work normally!" -ForegroundColor White
    Write-Host ""
    Write-Host "WHAT'S GONE:" -ForegroundColor Yellow
    Write-Host "  ❌ Widgets panel (weather/news in taskbar)" -ForegroundColor White
    Write-Host "  ❌ Phone Link (phone notifications on PC)" -ForegroundColor White
    Write-Host "  ❌ Chat/Teams icon (consumer version)" -ForegroundColor White
    Write-Host "  ❌ Taskbar clutter (search box, buttons you don't use)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "DRY RUN COMPLETE - No actual changes made" -ForegroundColor Cyan
    Write-Host "Run again without -DryRun to apply changes" -ForegroundColor Yellow
}

Write-Host "================================" -ForegroundColor Green
Write-Host "BLOATWARE REMOVAL COMPLETE!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# ============================================
# REVERSAL INSTRUCTIONS
# ============================================
Write-Host "TO REVERSE THESE CHANGES:" -ForegroundColor Cyan
Write-Host "1. Show Widgets: Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 1" -ForegroundColor Gray
Write-Host "2. Show Search: Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 2" -ForegroundColor Gray
Write-Host "3. Reinstall apps: Open Microsoft Store and search for 'Widgets' or 'Phone Link'" -ForegroundColor Gray
Write-Host ""
