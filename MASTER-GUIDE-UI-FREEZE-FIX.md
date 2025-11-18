# Master Guide: UI Freeze Fix & Monitoring

**Created:** 2025-11-16
**Status:** ✅ FIXED - Bloatware permanently disabled
**Purpose:** Complete reference for what was done, how to monitor, and how to maintain

---

## Quick Summary: What We Fixed

**Problem:** Computer UI freezing for 30+ seconds randomly
**Root Cause:** Windows 11 bloatware leaking handles in Explorer.exe
**Solution:** Permanently disabled Widgets, Phone Link, and taskbar clutter
**Result:** Handle leak stopped, freezing eliminated

---

## Table of Contents

1. [What Was Done](#what-was-done)
2. [Regular Monitoring (Quick Checks)](#regular-monitoring)
3. [All Scripts & How to Use Them](#all-scripts--how-to-use-them)
4. [All Documentation Files](#all-documentation-files)
5. [Maintenance Schedule](#maintenance-schedule)
6. [Troubleshooting](#troubleshooting)
7. [If Freeze Returns](#if-freeze-returns)

---

## What Was Done

### Permanently Disabled:

| Item | What It Was | Why Removed | Status |
|------|-------------|-------------|--------|
| **Windows Widgets** | Weather/news panel | Handle leak (954 handles) | ✅ Removed |
| **Phone Link** | Phone notifications | Handle leak (1,470 handles) | ✅ Removed |
| **Taskbar Search Box** | Visible search box | Handle leak (1,866 handles) | ✅ Hidden |
| **Windows Chat/Teams** | Consumer Teams | Bloatware | ✅ Removed |
| **Cortana Button** | Voice assistant | Bloatware | ✅ Hidden |
| **Task View Button** | Virtual desktops | Duplicate of Win+Tab | ✅ Hidden |

### Result:
- **Before:** Explorer.exe at 4,978 handles (critical, about to freeze)
- **After:** Explorer.exe at 3,146 handles (healthy, stable)
- **Savings:** -1,832 handles (-37%), -150 MB RAM (-47%)

### What Still Works:
- ✅ Search: Press **Win + S**
- ✅ Task View: Press **Win + Tab**
- ✅ All Windows features functional
- ✅ Just cleaner, faster, no bloatware!

---

## Regular Monitoring

### Quick Health Check (Do This Weekly)

**From WSL/Linux:**
```bash
# Check Explorer.exe handles (30 seconds)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"
```

**From PowerShell/Windows:**
```powershell
# Check Explorer.exe handles
Get-Process explorer | Select-Object Name, Handles
```

**What to Look For:**
- ✅ **3,000 - 3,500 handles:** HEALTHY (normal range)
- ⚠️ **3,500 - 4,000 handles:** WATCH (slight increase, monitor)
- 🚨 **4,000 - 4,500 handles:** WARNING (leak starting)
- 💀 **5,000+ handles:** CRITICAL (freeze imminent, fix needed)

**Recommended:** Check once a week, or when computer feels slow

---

### Full System Check (Do This Monthly)

**From WSL:**
```bash
# Run comprehensive check
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\capture-freeze-state.ps1"
```

**This captures:**
- Explorer.exe status (handles, memory, CPU)
- Top processes by handles
- Recent event logs
- Network connections
- Services status

**Output:** Creates timestamped report file for comparison

---

### Check for Bloatware Respawn (After Windows Updates)

**From WSL:**
```bash
# Check if bloatware came back
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Where-Object {\$_.Name -like '*Widget*' -or \$_.Name -like '*Phone*' -or \$_.Name -like '*SearchHost*'} | Select-Object Name, Handles, @{N='MemoryMB';E={[math]::Round(\$_.WorkingSet64/1MB,2)}}"
```

**Expected Results:**
- ✅ **No results or only SearchHost:** Good (bloatware still disabled)
- ⚠️ **Widgets or PhoneExperienceHost found:** Bloatware respawned (re-run removal script)

---

## All Scripts & How to Use Them

### 1. **disable-windows11-bloatware.ps1** - Main Removal Script

**What it does:** Permanently disables all Windows 11 bloatware
**When to use:** First time setup, or if bloatware respawns after Windows updates
**How to run:**

```bash
# From WSL (with UAC prompt):
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\disable-windows11-bloatware.ps1' -Wait"
```

```powershell
# From PowerShell as Administrator:
cd C:\Users\MYCOM\Desktop\CheckComputer
.\disable-windows11-bloatware.ps1
```

**What it removes:**
- Windows Widgets (app + taskbar icon)
- Phone Link (app)
- SearchHost UI (hides taskbar search box)
- Chat/Teams consumer version
- Cortana button
- Task View button

**Safe?** ✅ YES - Changes are reversible (see bottom of script for undo commands)

**Reusable?** ✅ YES - Run anytime bloatware respawns

---

### 2. **capture-freeze-state.ps1** - Freeze Diagnostic Tool

**What it does:** Captures complete system state for analysis
**When to use:**
- Monthly health check
- When computer feels slow
- To compare with baseline
- To document freeze if it happens again

**How to run:**

```bash
# From WSL:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\capture-freeze-state.ps1"
```

```powershell
# From PowerShell:
cd C:\Users\MYCOM\Desktop\CheckComputer
.\capture-freeze-state.ps1
```

**Output:** Creates `freeze-state-YYYY-MM-DD-HHMMSS.txt` with:
- Explorer.exe status (handles, memory, CPU, threads)
- Top 10 processes by handles
- Top 10 processes by CPU
- Kernel driver status (vgk, IOMap, etc.)
- Recent event logs (last 5 minutes)
- Network connections count
- Critical services status
- System information

**Use case:** Compare with BASELINE-HEALTHY-STATE.md to spot differences

---

### 3. **MegaManager.ps1** - Multi-Purpose System Tool

**What it does:** Security scans, performance checks, system monitoring
**When to use:**
- Check for malware
- Monitor dangerous events
- Check memory usage
- Registry audits

**How to run:**

```bash
# From WSL:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\MegaManager.ps1" [command]

# Available commands:
# security comprehensive    - Full security scan
# security registry-audit   - Registry health check
# performance memory        - Memory analysis
# monitoring dangerous-events - Check suspicious events
# list                      - Show all available tools
```

**Common uses:**
- Monthly security check: `security comprehensive`
- Registry cleanup: `security registry-audit`
- Memory issues: `performance memory`

---

### 4. **toggle-kernel-driver.ps1** - Driver Management

**What it does:** Enable/disable problematic kernel drivers (vgk, IOMap, etc.)
**When to use:**
- DPC latency issues (micro-stutters, audio glitches)
- Gaming (enable vgk for Valorant/League, disable after)

**How to run:**

```bash
# From WSL (interactive menu):
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1"

# Specific driver:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName vgk
```

**Note:** Requires reboot to take effect

---

### 5. **toggle-vanguard.ps1** - Quick Riot Vanguard Toggle

**What it does:** Enable/disable Riot Vanguard (vgk driver)
**When to use:**
- Before playing Valorant/League (enable)
- After gaming (disable for better performance)

**How to run:**

```bash
# From WSL:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-vanguard.ps1"
```

**Note:** Requires reboot

---

### 6. **restore-windows10-context-menu.ps1** - Context Menu Fix

**What it does:** Restores Windows 10 right-click menu (removes Windows 11 "Show more options" annoyance)
**When to use:** One-time setup (already done if you hate Windows 11 menus)

**How to run:**

```bash
# From WSL:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\restore-windows10-context-menu.ps1" Restore
```

---

## All Documentation Files

### Investigation & Analysis:

| File | Purpose | When to Read |
|------|---------|--------------|
| **BASELINE-HEALTHY-STATE.md** | Original healthy state (09:44 boot) | Compare with current state |
| **HANDLE-LEAK-EXPLAINED.md** | Technical explanation of handle leaks | Understand WHY freezing happens |
| **WHAT-ARE-WIDGETS-AND-SEARCH.md** | What bloatware is and why you don't need it | Understand what was removed |
| **RTKAUDIOSERVICE-EXPLAINED.md** | Why Realtek audio is safe to keep | Identify safe vs bloatware processes |
| **FREEZE-INVESTIGATION-PROTOCOL.md** | How to investigate freezes | If freeze returns |
| **BLOATWARE-REMOVAL-SUCCESS.md** | Complete record of what was done | Review what changed |

### Troubleshooting Guides:

| File | Purpose | When to Read |
|------|---------|--------------|
| **UI-FREEZE-DIAGNOSTIC-2025-11-16.md** | Why freeze is hard to detect | Understand investigation challenges |
| **UI-FREEZE-ROOT-CAUSES.md** | All possible freeze causes | Differential diagnosis |
| **WHY-FREEZE-IS-INVISIBLE.md** | Why event logs don't show freeze | Understand monitoring limitations |
| **WHY-NO-FREEZE-LOGS.md** | Why we needed baseline comparison | Methodology explanation |

### System Documentation:

| File | Purpose | When to Read |
|------|---------|--------------|
| **docs/UI-LAG-FIX.md** | Kernel driver DPC latency fix | Different issue (IOMap/vgk) |
| **docs/POWERSHELL-ADMIN-GUIDE.md** | How to use PowerShell with admin rights | Learn PowerShell techniques |
| **docs/WSL-WINDOWS-INTEGRATION.md** | Run Windows commands from WSL | Cross-platform workflows |
| **docs/SSH-WSL-TROUBLESHOOTING.md** | SSH to WSL setup | Remote access issues |
| **docs/WINDOWS11-CONTEXT-MENU-FIX.md** | Windows 10 right-click menu restore | Context menu annoyance |

### Project Documentation:

| File | Purpose | When to Read |
|------|---------|--------------|
| **CLAUDE.md** | Quick reference for all tools | Starting point for everything |
| **README.md** | Project overview | Understand toolkit structure |
| **ROADMAP.md** | Development history | See what's been built |
| **FINAL_PROJECT_STATUS.md** | Current project status | Check latest additions |

---

## Maintenance Schedule

### Daily: (Optional, only if feeling paranoid)
```bash
# Quick handle check (10 seconds)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"
```

### Weekly: (Recommended)
```bash
# 1. Check Explorer handles
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"

# 2. Check for bloatware respawn
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Where-Object {\$_.Name -like '*Widget*' -or \$_.Name -like '*Phone*'} | Select-Object Name"
```

### Monthly: (Good practice)
```bash
# Full system health capture
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\capture-freeze-state.ps1"

# Security scan
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\MegaManager.ps1" security comprehensive
```

### After Windows Updates: (Critical!)
```bash
# 1. Check if bloatware was reinstalled
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-AppxPackage | Where-Object {\$_.Name -like '*WebExperience*' -or \$_.Name -like '*YourPhone*'} | Select-Object Name"

# 2. If bloatware found, re-run removal script
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\disable-windows11-bloatware.ps1' -Wait"

# 3. Restart Explorer
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "taskkill /f /im explorer.exe; Start-Process explorer.exe"
```

---

## Troubleshooting

### "Handles are climbing again!"

**Diagnostic:**
```bash
# 1. Check current handle count
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"

# 2. Find top handle users
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Sort-Object -Property Handles -Descending | Select-Object -First 10 Name, Handles"

# 3. Check if bloatware respawned
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Where-Object {\$_.Name -like '*Widget*' -or \$_.Name -like '*Phone*' -or \$_.Name -like '*SearchHost*'}"
```

**Solutions:**
1. If bloatware found → Re-run removal script
2. If new program has high handles → Investigate that program
3. If SearchHost has 2,000+ handles → Kill and restart it
4. If handles > 4,500 → Restart Explorer.exe immediately

---

### "Bloatware came back after Windows update!"

**This is normal!** Windows updates sometimes reinstall bloatware.

**Fix:**
```bash
# Re-run removal script (safe to run multiple times)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\disable-windows11-bloatware.ps1' -Wait"

# Restart Explorer
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "taskkill /f /im explorer.exe; Start-Process explorer.exe"
```

---

### "SearchHost has high handles!"

**SearchHost can't be fully removed** (Windows needs it for search indexing), but you can restart it:

```bash
# Kill SearchHost (it will restart automatically with fresh handles)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Stop-Process -Name SearchHost -Force"

# Wait 10 seconds, check new handle count
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Sleep -Seconds 10; Get-Process SearchHost | Select-Object Name, Handles"
```

**Expected:** Handles should drop to ~800-1,200 after restart

---

### "I want to undo everything!"

**To restore bloatware:**

```powershell
# Run as Administrator

# 1. Show search box
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 2

# 2. Show Task View button
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 1

# 3. Show Widgets icon
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 1

# 4. Reinstall Widgets (Microsoft Store)
# Open Microsoft Store → Search "Widgets" → Install

# 5. Reinstall Phone Link (Microsoft Store)
# Open Microsoft Store → Search "Phone Link" → Install

# 6. Restart Explorer
taskkill /f /im explorer.exe
Start-Process explorer.exe
```

---

## If Freeze Returns

### Step 1: Capture Current State
```bash
# Run diagnostic immediately
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\capture-freeze-state.ps1"
```

### Step 2: Compare with Baseline
- Open generated `freeze-state-YYYY-MM-DD-HHMMSS.txt`
- Compare with `BASELINE-HEALTHY-STATE.md`
- Look for differences:
  - Explorer handles > 5,000?
  - New process with high handles?
  - New bloatware running?
  - Recent event log errors?

### Step 3: Identify Culprit

**If bloatware respawned:**
→ Re-run `disable-windows11-bloatware.ps1`

**If new program has high handles:**
→ Investigate that program (malware? buggy software?)

**If SearchHost > 2,000 handles:**
→ Kill and restart SearchHost

**If Explorer handles > 5,000:**
→ Restart Explorer.exe immediately:
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "taskkill /f /im explorer.exe; Start-Process explorer.exe"
```

### Step 4: Document
- Save diagnostic output
- Note what changed since last check
- Update this guide if new pattern found

---

## File Organization

### Scripts (Executable):
```
CheckComputer/
├── disable-windows11-bloatware.ps1    ← Main removal tool
├── capture-freeze-state.ps1           ← Diagnostic tool
├── MegaManager.ps1                    ← Security/performance suite
├── toggle-kernel-driver.ps1           ← Driver management
├── toggle-vanguard.ps1                ← Quick vgk toggle
└── restore-windows10-context-menu.ps1 ← Context menu fix
```

### Documentation:
```
CheckComputer/
├── MASTER-GUIDE-UI-FREEZE-FIX.md      ← THIS FILE (start here!)
├── BASELINE-HEALTHY-STATE.md          ← Healthy state reference
├── BLOATWARE-REMOVAL-SUCCESS.md       ← What was done
├── HANDLE-LEAK-EXPLAINED.md           ← Technical deep dive
├── WHAT-ARE-WIDGETS-AND-SEARCH.md     ← Bloatware explanation
├── RTKAUDIOSERVICE-EXPLAINED.md       ← Realtek audio info
├── FREEZE-INVESTIGATION-PROTOCOL.md   ← Investigation workflow
└── CLAUDE.md                          ← Quick reference
```

### Detailed Docs:
```
CheckComputer/docs/
├── UI-LAG-FIX.md                      ← Kernel driver DPC fix
├── POWERSHELL-ADMIN-GUIDE.md          ← PowerShell reference
├── WSL-WINDOWS-INTEGRATION.md         ← WSL/Windows workflows
├── SSH-WSL-TROUBLESHOOTING.md         ← SSH setup
└── WINDOWS11-CONTEXT-MENU-FIX.md      ← Context menu restore
```

---

## Quick Command Reference

### Daily Check (10 seconds):
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"
```

### Emergency Fix (If freezing):
```bash
# Restart Explorer immediately
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "taskkill /f /im explorer.exe; Start-Process explorer.exe"
```

### Remove Bloatware Again:
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\disable-windows11-bloatware.ps1' -Wait"
```

### Full Diagnostic:
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\capture-freeze-state.ps1"
```

---

## Summary: You're All Set! ✅

### What You Have:

1. **✅ Fixed computer** - Bloatware permanently disabled
2. **✅ Monitoring tools** - Scripts to check health regularly
3. **✅ Complete documentation** - Understand everything that was done
4. **✅ Reusable scripts** - Fix it again if bloatware returns
5. **✅ Maintenance schedule** - Know when and what to check
6. **✅ Troubleshooting guide** - Fix issues if they come back

### Expected Behavior Going Forward:

- **Explorer handles:** Stay around 3,000-3,500 (healthy range)
- **UI responsiveness:** Instant, no delays
- **No freezing:** Issue eliminated
- **After Windows updates:** Bloatware might respawn (just re-run script)

### If You Forget Everything, Remember This:

**Weekly check:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"
```

**If handles > 4,000 or freezing returns:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\disable-windows11-bloatware.ps1' -Wait"
```

---

**Everything is documented, organized, reusable, and clean!** 🎉

**Last Updated:** 2025-11-16
**Status:** COMPLETE - Computer healthy, bloatware nuked, monitoring in place!
