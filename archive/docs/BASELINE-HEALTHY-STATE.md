# Baseline: System Healthy State (No Freezing)
**Date/Time:** 2025-11-16 09:44 (After Restart)
**Status:** System running normally, NO UI freezing

## Purpose
This document captures the "healthy" state of the computer when it's NOT freezing, to compare against future freeze events.

---

## 1. EXPLORER.EXE STATUS (CRITICAL METRIC)
**This is the #1 indicator of UI health!**

| Metric | Value | Status |
|--------|-------|--------|
| **Handles** | **3,246** | ✅ HEALTHY (Critical threshold: 5,000+) |
| **Memory (MB)** | 193.73 | ✅ Normal |
| **CPU** | 5.75 | ✅ Low |
| **Threads** | 108 | ✅ Normal |
| **Process ID** | 6660 | - |

**Conclusion:** Explorer.exe is in excellent health. Handles are well below critical threshold.

---

## 2. KERNEL DRIVERS STATUS
**Known problematic drivers that can cause DPC latency:**

| Driver | State | Status | StartMode | Notes |
|--------|-------|--------|-----------|-------|
| **vgk** | **Running** | OK | System | Riot Vanguard - Can cause DPC latency |
| **IOMap** | **Running** | OK | Disabled | Korean banking driver - Known DPC latency cause |
| vgc | Not found | - | - | Riot Vanguard component |
| GLCKIO2 | Not found | - | - | ASUS RGB driver |
| WinRing0x64 | Not found | - | - | Hardware monitoring driver |

**⚠️ CRITICAL:** Both vgk and IOMap are RUNNING during healthy state!

---

## 3. TOP PROCESSES (CPU Usage)

| Process | PID | CPU | Memory (MB) | Handles | Notes |
|---------|-----|-----|-------------|---------|-------|
| chrome | 19072 | 78.98 | 198.22 | 950 | Browser |
| chrome | 19988 | 44.86 | 808.08 | 575 | Browser |
| SearchIndexer | 10164 | 41.98 | 50.03 | 675 | Windows Search |
| System | 4 | 28.81 | 2.29 | 5013 | Kernel |
| **vmmemWSL** | 1820 | 26.05 | **6,894.77** | 0 | **WSL Memory** |
| MsMpEng | 7716 | 14.31 | 317.37 | 1141 | Windows Defender |
| nvcontainer | 11660 | 5.75 | 63.93 | 735 | NVIDIA |
| **explorer** | 6660 | 5.75 | 193.73 | 3246 | **Windows Shell** |
| KakaoTalk | 12108 | 4.72 | 88.55 | 905 | Chat app |
| dwm | 2168 | 3.09 | 96.14 | 1291 | Desktop Window Manager |
| ROGLiveService | 7620 | 1.83 | 27.53 | 530 | ASUS service |

**Key Observations:**
- Chrome is the highest CPU user
- vmmemWSL using 6.8 GB memory (WSL Ubuntu on E: drive)
- Explorer.exe CPU is LOW (healthy)
- No runaway processes

---

## 4. SERVICES STATUS

### Running Services
| Service | Status | StartType | Notes |
|---------|--------|-----------|-------|
| AsusCertService | Running | Automatic | ASUS certificate |
| AsusFanControlService | Running | Automatic | Fan control |
| ROG Live Service | Running | Automatic | ASUS bloatware (running) |
| WSLService | Running | Automatic | WSL |

### Stopped Services (Good!)
| Service | Status | StartType | Notes |
|---------|--------|-----------|-------|
| ArmouryCrateService | Stopped | Disabled | ✅ Successfully disabled |
| AsusUpdateCheck | Stopped | Disabled | ✅ Successfully disabled |
| asus | Stopped | Automatic | ASUS update |
| asusm | Stopped | Manual | ASUS update manual |
| GoogleChromeElevationService | Stopped | Manual | Chrome |
| GoogleUpdaterInternalService | Stopped | Automatic | Google |
| GoogleUpdaterService | Stopped | Automatic | Google |
| WslInstaller | Stopped | Automatic | WSL installer |

---

## 5. NETWORK STATUS

### Listening Ports (Key Services)
| Port | Process | Notes |
|------|---------|-------|
| 22 | svchost | SSH |
| 80, 443 | wslrelay | WSL forwarding |
| 631, 4002, 4003, 5002, 5050, 5433, 5555, 6380, 6432, 8000, 8001, 8081, 44625 | wslrelay | WSL multiple services |
| 13030, 22112 | ROGLiveService | ASUS service |
| 9012, 9013 | ArmourySocketServer | ASUS Armoury Crate |
| 9180 | lghub_updater | Logitech |

### Active Connections
- **12 established connections** (normal)

---

## 6. EVENT LOGS (Last 15 Minutes)

### Errors
| Time | Source | Event ID | Message |
|------|--------|----------|---------|
| 09:44:27 | TPM-WMI | 1796 | Secure Boot update failed (Secure Boot not enabled) |
| 09:41:31 | Service Control Manager | **7000** | Google Update service failed to start |
| 09:41:31 | Service Control Manager | **7009** | **Google Update service timeout (30 seconds)** |
| 09:39:27 | Service Control Manager | 7023 | FDResPub service stopped with error |

### Warnings
| Time | Source | Event ID | Message |
|------|--------|----------|---------|
| 09:41:32 | DistributedCOM | 10016 | COM permissions (multiple) |
| 09:39:26 | LsaSrv | 6155 | LSA package not signed (multiple packages) |
| 09:39:00 | Hyper-V-Hypervisor | 167 | HyperThreading warning |
| 09:38:30 | winsrvext | 100 | **Explorer.exe delayed shutdown by 5016ms** |

**Key Finding:** Google Update service timing out during startup (Event 7009) - This could be a startup delay contributor, but system is still healthy.

---

## 7. SYSTEM CHARACTERISTICS (HEALTHY STATE)

### What's NORMAL When NOT Freezing:
✅ Explorer.exe handles: ~3,200-3,300 (well below 5,000 threshold)
✅ Explorer.exe CPU: Low (~5%)
✅ vgk and IOMap drivers: RUNNING (but not causing issues)
✅ Chrome: High CPU is normal for browser
✅ vmmemWSL: High memory is normal (WSL Ubuntu)
✅ Network connections: ~12 active
✅ UI response: Immediate, no delays

### Potential Background Issues (Not Causing Freeze Yet):
⚠️ Google Update service timeout (30s) during startup
⚠️ ROG Live Service running (bloatware)
⚠️ Explorer.exe delayed shutdown by 5s (shutdown only)
⚠️ Multiple COM permission warnings
⚠️ IOMap and vgk drivers present and running

---

## 8. NEXT STEPS: WHEN FREEZE OCCURS

**Run these commands IMMEDIATELY when freezing happens:**

```bash
# 1. Check explorer.exe handles (CRITICAL!)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Id, CPU, @{N='MemoryMB';E={[math]::Round(\$_.WorkingSet64/1MB,2)}}, Handles, @{N='Threads';E={\$_.Threads.Count}}"

# 2. Check top processes
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Sort-Object -Property Handles -Descending | Select-Object -First 15 Name, Id, Handles, @{N='MemoryMB';E={[math]::Round(\$_.WorkingSet64/1MB,2)}}, CPU | Format-Table -AutoSize"

# 3. Check recent events
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddMinutes(-5)} -MaxEvents 20 -ErrorAction SilentlyContinue | Select-Object TimeCreated, ProviderName, Id, Message | Format-List"

# 4. Check network connections
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Measure-Object | Select-Object Count"

# 5. Check driver status
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-CimInstance Win32_SystemDriver | Where-Object {\$_.Name -in @('vgk', 'IOMap')} | Select-Object Name, State, Status"
```

**What to look for during freeze:**
1. **Explorer.exe handles > 5,000** (CRITICAL!)
2. Any process with extremely high handles
3. New Event IDs (especially 7011, 7045, 1116)
4. Spike in network connections
5. New driver loaded or driver state changed
6. High CPU processes that weren't there before

---

## 9. COMPARISON METRICS

**Create a table like this when freeze occurs:**

| Metric | Healthy (Now) | During Freeze | Difference |
|--------|---------------|---------------|------------|
| Explorer handles | 3,246 | [TBD] | [TBD] |
| Explorer CPU | 5.75 | [TBD] | [TBD] |
| vgk state | Running | [TBD] | [TBD] |
| IOMap state | Running | [TBD] | [TBD] |
| Network connections | 12 | [TBD] | [TBD] |
| Recent errors (5 min) | 4 | [TBD] | [TBD] |

---

**Last Updated:** 2025-11-16 09:44
**Computer State:** ✅ Healthy, No Freezing
**Next Action:** Monitor and capture freeze state when it occurs
