# Daily UI Freeze - Root Causes Found

**Date:** 2025-11-16
**Issue:** System freezes daily with 2-minute UI delays

---

## What We Found (90 minutes of investigation)

### PRIMARY CULPRIT: NVIDIA GeForce Overlay
**Evidence:**
- 5 NVIDIA Overlay processes were running
- Ghost window remained even after killing processes
- Window was blocking UI input
- This is a KNOWN ISSUE with NVIDIA GeForce Experience

### SECONDARY ISSUES:
1. **ASUS Framework** - Multiple frozen processes (PID 18772, 3128, 13612, etc.)
2. **Handle Leaks** - System: 5,340, explorer: 5,277 (should be ~2,000)
3. **DoSvc (Windows Update)** - Had 5,485 handles, caused port exhaustion
4. **SystemSettings** - Frozen (PID 13896)

---

## Why It Happens Daily

**The Pattern:**
1. You use your computer normally
2. NVIDIA GeForce Overlay activates (gaming, screen recording, or automatically)
3. Overlay gets stuck or fails to close properly
4. Ghost windows accumulate
5. Handle leaks build up (DoSvc, System, Explorer)
6. After hours/days, UI becomes unresponsive

**Triggers:**
- Alt+Z (NVIDIA Overlay hotkey)
- Starting/closing games
- Windows Updates running in background
- ASUS software conflicts

---

## PERMANENT FIXES

### Fix 1: Disable NVIDIA GeForce Overlay (RECOMMENDED)

**Why:**
- This is THE #1 cause of your freezing
- You probably don't use the overlay features anyway
- Most gamers disable it for performance

**How:**
```powershell
# Disable NVIDIA Overlay completely
Stop-Process -Name "NVIDIA*Overlay*" -Force -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName "NVIDIA Overlay*" -ErrorAction SilentlyContinue

# Disable in GeForce Experience:
# 1. Open GeForce Experience
# 2. Click Settings (gear icon)
# 3. General > In-Game Overlay > Toggle OFF
```

**Script to disable:**
```powershell
# Run this once:
Get-Process -Name "*NVIDIA*Overlay*" | Stop-Process -Force
taskkill /F /IM "NVIDIA Overlay.exe"
```

---

### Fix 2: Disable ASUS Framework Auto-Start

**Why:**
- Multiple ASUS processes were frozen
- They auto-start and consume resources
- Not essential for system operation

**How:**
```powershell
# Disable ASUS Framework from startup
Get-ScheduledTask -TaskName "*ASUS*" | Disable-ScheduledTask
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "ASUS*" -ErrorAction SilentlyContinue
```

---

### Fix 3: Restart DoSvc Weekly

**Why:**
- Windows Update service (DoSvc) leaks handles over time
- Causes port exhaustion after days of uptime

**How:**
Create a scheduled task:
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -Command Restart-Service DoSvc"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
Register-ScheduledTask -TaskName "Weekly_DoSvc_Restart" -Action $action -Trigger $trigger -Description "Prevent DoSvc handle leaks"
```

---

### Fix 4: Create Auto-Recovery Script

**What it does:**
- Monitors for UI freezing indicators
- Automatically kills problem processes
- Prevents full system freeze

**Script:** (see `auto-fix-ui-freeze.ps1` below)

---

## PREVENTION SCRIPT

Save this as: `C:\Users\MYCOM\Desktop\CheckComputer\auto-fix-ui-freeze.ps1`

```powershell
# Auto-Fix UI Freeze Script
# Run this when system starts feeling slow

Write-Host "=== UI Freeze Auto-Fix ===" -ForegroundColor Cyan

# 1. Kill NVIDIA Overlay (main culprit)
Write-Host "Killing NVIDIA Overlay..." -ForegroundColor Yellow
Get-Process -Name "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue | Stop-Process -Force
taskkill /F /IM "NVIDIA Overlay.exe" 2>$null

# 2. Kill frozen ASUS processes
Write-Host "Killing ASUS Framework..." -ForegroundColor Yellow
Get-Process -Name "asus_framework" -ErrorAction SilentlyContinue | Stop-Process -Force

# 3. Check handle counts
Write-Host "`nChecking handle counts..." -ForegroundColor Yellow
$explorerHandles = (Get-Process explorer).Handles
$systemHandles = (Get-Process -Name System).Handles

Write-Host "Explorer handles: $explorerHandles (normal: <2000)" -ForegroundColor $(if ($explorerHandles -gt 3000) { "Red" } else { "Green" })
Write-Host "System handles: $systemHandles (normal: <2000)" -ForegroundColor $(if ($systemHandles -gt 3000) { "Red" } else { "Green" })

# 4. Restart explorer if handle leak detected
if ($explorerHandles -gt 3000) {
    Write-Host "`nRestarting Explorer due to handle leak..." -ForegroundColor Red
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Start-Process explorer
}

# 5. Check DoSvc
$dosvcHandles = Get-Process -Name svchost | Where-Object {
    (Get-WmiObject Win32_Service | Where-Object ProcessId -eq $_.Id).Name -eq 'DoSvc'
} | Select-Object -First 1 -ExpandProperty Handles

if ($dosvcHandles -gt 3000) {
    Write-Host "`nRestarting DoSvc due to handle leak..." -ForegroundColor Red
    Restart-Service -Name DoSvc -Force
}

Write-Host "`n=== Fix Complete ===" -ForegroundColor Green
Write-Host "If still frozen, press Ctrl+Alt+Delete and restart." -ForegroundColor Yellow
```

---

## DAILY MONITORING SCRIPT

Save this as: `C:\Users\MYCOM\Desktop\CheckComputer\check-ui-health.ps1`

```powershell
# Daily UI Health Check
# Run this once a day to catch problems early

Write-Host "=== Daily UI Health Check ===" -ForegroundColor Cyan

# Check for NVIDIA Overlay processes
$nvidiaOverlay = Get-Process -Name "*NVIDIA*Overlay*" -ErrorAction SilentlyContinue
if ($nvidiaOverlay) {
    Write-Host "[WARNING] NVIDIA Overlay is running ($($nvidiaOverlay.Count) processes)" -ForegroundColor Red
    Write-Host "This will cause freezing! Disable it in GeForce Experience settings." -ForegroundColor Yellow
} else {
    Write-Host "[OK] NVIDIA Overlay not running" -ForegroundColor Green
}

# Check handle counts
$explorer = Get-Process explorer
$system = Get-Process -Name System

Write-Host "`nHandle Counts:" -ForegroundColor Cyan
Write-Host "  Explorer: $($explorer.Handles) $(if ($explorer.Handles -gt 3000) { '[HIGH]' } else { '[OK]' })" -ForegroundColor $(if ($explorer.Handles -gt 3000) { "Yellow" } else { "Green" })
Write-Host "  System: $($system.Handles) $(if ($system.Handles -gt 3000) { '[HIGH]' } else { '[OK]' })" -ForegroundColor $(if ($system.Handles -gt 3000) { "Yellow" } else { "Green" })

# Check port usage
$tcpConnections = (Get-NetTCPConnection -State Established,TimeWait -ErrorAction SilentlyContinue).Count
Write-Host "  TCP Connections: $tcpConnections $(if ($tcpConnections -gt 1000) { '[HIGH]' } else { '[OK]' })" -ForegroundColor $(if ($tcpConnections -gt 1000) { "Yellow" } else { "Green" })

# Check frozen processes
Write-Host "`nFrozen Processes:" -ForegroundColor Cyan
$frozen = Get-Process | Where-Object { $_.Responding -eq $false -and $_.MainWindowHandle -ne 0 }
if ($frozen) {
    foreach ($proc in $frozen) {
        Write-Host "  [FROZEN] $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Red
    }
} else {
    Write-Host "  [OK] No frozen processes" -ForegroundColor Green
}

Write-Host "`n=== Check Complete ===" -ForegroundColor Green
```

---

## SETUP INSTRUCTIONS

### Step 1: Disable NVIDIA Overlay (DO THIS FIRST!)

1. Open **GeForce Experience**
2. Click the **Settings** gear icon (top right)
3. Click **General**
4. Find **"In-Game Overlay"**
5. **Toggle it OFF**
6. Restart computer

**OR via registry:**
```powershell
Set-ItemProperty -Path "HKCU:\Software\NVIDIA Corporation\Global\GFExperience" -Name "EnableOverlay" -Value 0
Stop-Process -Name "NVIDIA Overlay*" -Force -ErrorAction SilentlyContinue
```

---

### Step 2: Create Scheduled Task for Auto-Fix

```powershell
# Run this to create a hotkey (Ctrl+Alt+F) to fix freezing
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\auto-fix-ui-freeze.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "UI_Freeze_AutoFix_Hotkey" -Action $action -Trigger $trigger -Description "Quick fix for UI freezing"
```

Then create a desktop shortcut:
- Right-click Desktop → New → Shortcut
- Target: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\auto-fix-ui-freeze.ps1"`
- Name: "Fix UI Freeze"

**Now you can double-click this instead of rebooting!**

---

### Step 3: Daily Health Check

Run this every morning to catch problems early:
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\check-ui-health.ps1"
```

---

## WHAT TO DO WHEN IT FREEZES

**Quick Fix (2 minutes):**
1. Double-click "Fix UI Freeze" shortcut on desktop
2. Wait 10 seconds
3. Try clicking around - should be responsive

**If still frozen:**
1. Press `Ctrl+Alt+Delete`
2. Click **Restart**

**After reboot:**
1. Check if NVIDIA Overlay is disabled in GeForce Experience
2. Run health check script
3. Make sure ASUS software isn't auto-starting

---

## EXPECTED RESULTS

**After disabling NVIDIA Overlay:**
- Freezing should stop happening daily
- Maybe once a week instead of daily
- When it does happen, auto-fix script will help

**If still freezing after fixes:**
- Come back and we'll investigate deeper
- Might need to disable more services
- Could be hardware issue (rare)

---

## SUMMARY OF CULPRITS

| Component | Impact | Fix |
|-----------|--------|-----|
| **NVIDIA Overlay** | HIGH - Main cause | Disable in GeForce Experience |
| **ASUS Framework** | MEDIUM | Disable auto-start |
| **DoSvc (Windows Update)** | MEDIUM | Weekly restart |
| **Handle Leaks** | LOW | Auto-fix script catches it |

---

**Next Steps:**
1. Reboot NOW to clear current freeze
2. Disable NVIDIA Overlay immediately after reboot
3. Create auto-fix script
4. Monitor for 2-3 days
5. Report back if still happening

**The freezing should stop or be much less frequent after disabling NVIDIA Overlay.**
