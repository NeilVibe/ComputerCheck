# Kernel Drivers Reference Guide

**Quick reference for managing kernel drivers on your system**

---

## Quick Commands

### Universal Toggle Script (Recommended)
```bash
# Interactive menu (easiest)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1"

# Toggle specific driver
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName IOMap
```

### Manual Commands
```powershell
# Check driver status
sc query DriverName

# Check driver config
sc qc DriverName

# Disable driver
sc config DriverName start=disabled

# Enable driver (system start)
sc config DriverName start=system

# Enable driver (on-demand)
sc config DriverName start=demand
```

---

## Kernel Drivers on Your System

### Problematic Drivers (Cause UI Lag)

#### 1. IOMap
**What:** Korean software kernel driver
**Source:** KakaoTalk (Korean messaging app)
**Purpose:** Korean keyboard input, banking software integration
**Status:** ✅ SAFE TO DISABLE

**Impact if Disabled:**
- ✅ KakaoTalk messaging still works
- ❌ Korean banking apps may not work
- ❌ Korean keyboard features disabled

**Commands:**
```bash
# Disable
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config IOMap start=disabled"

# Enable
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config IOMap start=demand"
```

---

#### 2. vgk (Riot Vanguard Kernel)
**What:** Riot Games anti-cheat kernel driver
**Source:** Valorant, League of Legends
**Purpose:** Kernel-level anti-cheat protection
**Status:** ⚠️ CONDITIONAL (disable for performance, enable for gaming)

**Impact if Disabled:**
- ✅ Better system performance
- ✅ No kernel-level monitoring
- ❌ Valorant won't work
- ❌ League of Legends won't work

**Commands:**
```bash
# Disable (better performance)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config vgk start=disabled"

# Enable (for gaming)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config vgk start=system"
```

**Recommendation:** Use `toggle-vanguard.ps1` or `toggle-kernel-driver.ps1` for easy switching

---

#### 3. vgc (Riot Vanguard Client)
**What:** Riot Vanguard client service
**Source:** Riot Games (companion to vgk)
**Purpose:** User-mode component of Vanguard
**Status:** ⚠️ CONDITIONAL (disable with vgk)

**Impact if Disabled:**
- Same as vgk (disable both together)

**Commands:**
```bash
# Disable
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config vgc start=disabled"

# Enable
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config vgc start=demand"
```

---

### Critical Drivers (NEVER Disable!)

#### nvlddmkm (NVIDIA Display Driver)
**What:** NVIDIA graphics kernel driver
**Source:** NVIDIA GPU drivers
**Purpose:** GPU/display functionality
**Status:** ❌ CRITICAL - NEVER DISABLE

**Impact if Disabled:**
- ❌ Display will not work
- ❌ Windows will likely crash
- ❌ System unbootable

---

#### disk, volmgr, partmgr
**What:** Storage and volume management drivers
**Status:** ❌ CRITICAL - NEVER DISABLE

**Impact if Disabled:**
- ❌ Cannot access hard drives
- ❌ System unbootable
- ❌ Data inaccessible

---

### Optional Drivers (Safe to Manage)

#### ReadyBoost (rdyboost)
**What:** ReadyBoost cache driver
**Purpose:** Uses USB drives to speed up system
**Status:** ✅ Safe to disable if not using ReadyBoost

**Impact if Disabled:**
- ReadyBoost feature unavailable (not critical)

---

#### vmmemWSL
**What:** WSL (Windows Subsystem for Linux) memory driver
**Purpose:** WSL virtual machine memory management
**Status:** ⚠️ Only disable if you don't use WSL

**Impact if Disabled:**
- ❌ WSL won't work
- ❌ Linux distributions won't start

---

## How to Identify Driver Issues

### Check if Driver is Causing Problems

**1. Check DPC Latency (Advanced)**
```powershell
# List all running kernel drivers
driverquery /v

# Check specific driver
driverquery /v | findstr /i "DriverName"
```

**2. Check Driver Resource Usage**
```powershell
# Get loaded driver info
Get-WindowsDriver -Online -All | Where-Object {$_.ProviderName -like "*keyword*"}
```

**3. Check Event Logs for Driver Errors**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 50 | Where-Object {$_.Message -like '*driver*'} | Format-List"
```

---

## Driver Start Types Explained

| Start Type | When Loads | Use Case |
|-----------|-----------|----------|
| **Boot** | During boot process | Critical boot drivers |
| **System** | After boot, before user login | Most kernel drivers |
| **Automatic** | After user login | Services and non-critical drivers |
| **Manual/Demand** | When explicitly started | On-demand services |
| **Disabled** | Never loads | Permanently disabled |

---

## Common Scenarios

### Scenario 1: Gaming Performance vs Anti-Cheat
**Problem:** vgk causes performance issues but needed for Valorant/League

**Solution:**
```bash
# Before gaming session
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName vgk
# (Enable vgk, reboot)

# After gaming session
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName vgk
# (Disable vgk, reboot)
```

---

### Scenario 2: Korean Software Conflicts
**Problem:** IOMap causing system slowdowns, but need KakaoTalk

**Solution:**
```bash
# Disable IOMap (KakaoTalk messaging will still work)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config IOMap start=disabled"
# Reboot

# If banking apps don't work, re-enable:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc config IOMap start=demand"
# Reboot
```

---

### Scenario 3: Diagnosing Unknown Driver Issues
```bash
# 1. List all running kernel drivers
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "driverquery /v | Sort-Object"

# 2. Check for errors in event logs
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\MegaManager.ps1" monitoring dangerous-events

# 3. Check driver-specific events
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='*driver*'; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 20"

# 4. Monitor handles/resources
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\diagnose-slowness.ps1"
```

---

## Safety Guidelines

### ✅ Safe to Disable:
- IOMap (if not using Korean banking)
- vgk/vgc (if not gaming)
- ReadyBoost
- Optional manufacturer bloatware drivers

### ⚠️ Disable with Caution:
- Audio drivers (system will have no sound)
- Network drivers (will lose internet)
- Bluetooth drivers (Bluetooth won't work)
- Touchpad drivers (touchpad won't work)

### ❌ NEVER Disable:
- nvlddmkm (NVIDIA display)
- disk, volmgr, partmgr (storage)
- ACPI, PCI drivers (system management)
- Security drivers (BitLocker, TPM)
- Any driver you don't recognize (research first!)

---

## Troubleshooting

### Driver Won't Disable
```bash
# Check if driver is currently in use
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc query DriverName"

# Some drivers require admin rights - run PowerShell as admin
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -Command \"sc config DriverName start=disabled\"'"
```

### System Won't Boot After Disabling Driver
1. Boot into Safe Mode (F8 during startup)
2. Re-enable the driver:
   ```powershell
   sc config DriverName start=system
   ```
3. Reboot normally

### Driver Re-enables Itself
- Check for software that automatically re-enables it (e.g., Riot Vanguard reinstalls itself)
- Use Task Scheduler to check for automated tasks
- Some security software will re-enable drivers

---

## Reference Commands Cheat Sheet

```bash
# === UNIVERSAL TOGGLE (EASIEST) ===
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1"

# === SPECIFIC DRIVERS ===
# Toggle IOMap
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName IOMap

# Toggle vgk (Riot Vanguard)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-vanguard.ps1"

# === DIAGNOSTICS ===
# Check all drivers
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "driverquery /v"

# Check specific driver status
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "sc query DriverName"

# Full system diagnostic
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\diagnose-slowness.ps1"
```

---

**Last Updated:** 2025-01-16
**Related Docs:** UI-LAG-FIX.md, CLAUDE.md
