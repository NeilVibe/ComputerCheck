# Freeze Investigation Protocol
**Created:** 2025-11-16
**Purpose:** Compare healthy vs freeze states to identify root cause

---

## Current Status: ✅ BASELINE CAPTURED

We've successfully captured the **healthy state** of your computer when it's NOT freezing. Now we need to capture the **freeze state** when it happens again.

---

## How This Works

### The Strategy
1. **Baseline (Done!)** - We've documented the "good" state
2. **Freeze Capture (Next)** - Run script when freezing occurs
3. **Comparison** - Find the differences
4. **Root Cause** - Identify what changed
5. **Fix** - Address the specific issue

### Why This Approach?
Previous attempts to find the freeze cause failed because:
- Event logs showed nothing unusual (freeze doesn't log errors)
- UI is frozen but system resources look normal
- No obvious crashes or hangs to detect

**The key insight:** We need to compare TWO states to see what's different!

---

## What We Found (Healthy Baseline)

### ✅ HEALTHY METRICS (2025-11-16 09:44)

**Explorer.exe (The Key Indicator):**
- **Handles: 3,246** ← This is the MOST important number
- Memory: 193.73 MB
- CPU: 5.75% (low)
- Threads: 108

**Critical Threshold:** Explorer.exe handles > 5,000 = UI freeze likely

**Why Explorer.exe Handles Matter:**
- Explorer.exe is the Windows shell (taskbar, desktop, file explorer)
- Handle leaks cause UI freezing (buttons don't work, clicks ignored)
- Handle count directly correlates with UI responsiveness
- We've seen this before - when handles hit 5,000+, UI becomes unresponsive

**Other Healthy State Metrics:**
- vgk driver: RUNNING (Riot Vanguard)
- IOMap driver: RUNNING (Korean banking driver)
- Network connections: 12 active
- vmmemWSL: 6.8 GB (normal for WSL)
- Chrome: High CPU (normal)
- ROG Live Service: Running (bloatware but not causing issues now)

**Recent Events:**
- Google Update service timeout (30s) during boot
- Explorer.exe delayed shutdown by 5s (shutdown only)
- No critical errors affecting UI

---

## When Freeze Occurs: IMMEDIATE ACTIONS

### Step 1: Run Capture Script
**From WSL/Linux:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\capture-freeze-state.ps1"
```

**From PowerShell/Windows:**
```powershell
cd C:\Users\MYCOM\Desktop\CheckComputer
.\capture-freeze-state.ps1
```

**What This Does:**
- Captures Explorer.exe status (handles, memory, CPU)
- Lists top processes by handles and CPU
- Checks kernel driver status
- Grabs recent event logs (last 5 minutes)
- Counts network connections
- Checks critical services
- Saves everything to timestamped file

**Output:** Creates `freeze-state-YYYY-MM-DD-HHMMSS.txt`

---

### Step 2: Quick Manual Checks (If Script Fails)

**Priority 1: Explorer.exe Handles**
```powershell
Get-Process explorer | Select-Object Name, Id, Handles
```
**Expected:** 3,246 (baseline)
**If freezing:** Likely 5,000+ (CRITICAL!)

**Priority 2: Top Handles**
```powershell
Get-Process | Sort-Object -Property Handles -Descending | Select-Object -First 10 Name, Id, Handles
```
Look for any process with abnormally high handles.

**Priority 3: Recent Events**
```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddMinutes(-5)} -MaxEvents 10 | Format-List TimeCreated, ProviderName, Id, Message
```
Look for Event IDs: 7011 (service timeout), 7045 (new service), 1116 (malware)

---

## Step 3: Comparison Analysis

### Compare These Metrics

| Metric | Baseline (Healthy) | During Freeze | Difference | Action |
|--------|-------------------|---------------|------------|--------|
| **Explorer Handles** | 3,246 | **[CAPTURE]** | [CALCULATE] | If > 5000: Handle leak! |
| Explorer CPU | 5.75% | **[CAPTURE]** | [CALCULATE] | If > 50%: Busy processing |
| Explorer Memory | 193 MB | **[CAPTURE]** | [CALCULATE] | If > 500MB: Memory leak |
| vgk State | Running | **[CAPTURE]** | [CHECK] | If changed: Driver issue |
| IOMap State | Running | **[CAPTURE]** | [CHECK] | If changed: Driver issue |
| Network Connections | 12 | **[CAPTURE]** | [CALCULATE] | If > 50: Network flood |
| Recent Errors (5min) | 4 | **[CAPTURE]** | [CALCULATE] | New errors? |

### What to Look For

**Scenario 1: Explorer.exe Handle Leak** (Most Likely!)
- Explorer handles > 5,000
- **Cause:** Widgets, ASUS software, or Windows Search
- **Fix:** Disable bloatware, restart Explorer.exe
- **Long-term:** Identify leaking component and disable

**Scenario 2: Driver DPC Latency**
- vgk or IOMap suddenly active
- **Cause:** Kernel driver processing interrupts
- **Fix:** Disable driver temporarily
- **Tools:** Use `toggle-kernel-driver.ps1` or `toggle-vanguard.ps1`

**Scenario 3: Service Timeout**
- Event 7011 appears
- **Cause:** Service hanging
- **Fix:** Identify service and disable/fix

**Scenario 4: Process Runaway**
- New process with high handles/CPU not in baseline
- **Cause:** Malware, buggy update, or background task
- **Fix:** Kill process, investigate origin

**Scenario 5: Network Flood**
- Connections spike from 12 to 50+
- **Cause:** Network activity causing Explorer to wait
- **Fix:** Identify process causing connections

---

## Known Fixes Based on Previous Analysis

### Fix 1: Explorer.exe Handle Leak
```powershell
# Quick restart Explorer (loses window positions)
taskkill /f /im explorer.exe
start explorer.exe

# OR identify leak source first
Get-Process | Sort-Object Handles -Descending | Select-Object -First 10 Name, Handles
```

### Fix 2: Disable Windows Widgets
```powershell
# Widgets are known to cause Explorer handle leaks
Get-AppxPackage *WebExperience* | Remove-AppxPackage
```

### Fix 3: Disable Riot Vanguard (vgk)
```bash
# Toggle vgk driver off (requires restart)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-vanguard.ps1"
```

### Fix 4: Disable IOMap Driver
```bash
# Toggle IOMap driver off (requires restart)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName IOMap
```

### Fix 5: Disable ASUS ROG Live Service
```powershell
Stop-Service "ROG Live Service" -Force
Set-Service "ROG Live Service" -StartupType Disabled
```

---

## Investigation Workflow

```
1. Computer freezes
   ↓
2. Run capture-freeze-state.ps1
   ↓
3. Review generated file
   ↓
4. Compare with BASELINE-HEALTHY-STATE.md
   ↓
5. Identify differences
   ↓
6. Match to scenario above
   ↓
7. Apply appropriate fix
   ↓
8. Document findings
   ↓
9. Monitor for recurrence
```

---

## Files Created for This Investigation

1. **BASELINE-HEALTHY-STATE.md** - Healthy state documentation
2. **capture-freeze-state.ps1** - Freeze state capture tool
3. **FREEZE-INVESTIGATION-PROTOCOL.md** - This file (investigation guide)

---

## Next Steps

1. **Wait for freeze to occur** (don't try to force it)
2. **Run capture script immediately** when it happens
3. **Compare results** with baseline
4. **Identify root cause** from differences
5. **Apply targeted fix** (not random changes)
6. **Document findings** in new file

---

## Expected Outcome

Based on previous analysis (docs/UI-LAG-FIX.md), we expect:

**Most Likely Cause:** Explorer.exe handle leak from:
- Windows Widgets (WebExperience)
- ASUS ROG Live Service
- Windows Search Indexer
- ASUS Armoury Crate components

**Secondary Causes:**
- IOMap driver DPC latency
- vgk (Riot Vanguard) DPC latency
- Google Update service timeout affecting startup only

**Once we capture freeze state, we'll know for sure!**

---

**Status:** Ready for freeze capture. Script is armed and ready.

**Remember:** The goal is to UNDERSTAND the problem, not just restart the computer. Rebooting fixes symptoms but doesn't identify the root cause.
