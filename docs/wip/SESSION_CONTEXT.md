# Session Context - Claude Handoff Document

**Updated:** 2025-12-20 | **Status:** FIXED | **Systemd:** running

---

## TL;DR FOR NEXT SESSION

**CRITICAL WSL FIXES APPLIED THIS SESSION:**

1. **Enabled linger** for neil1988 - user session now persists
2. **Rewrote startup scripts** - no more `--exec` (was killing WSL immediately)
3. **Created watchdog task** - auto-restarts WSL every 5 minutes if down
4. **Deleted broken old task** - WSL-SSH-Startup removed

**System Status:**
```
Systemd:          running (all services OK)
Linger:           ENABLED (critical fix)
WSL-Startup:      NEW (hidden VBS approach)
WSL-Watchdog:     NEW (5-min keepalive check)
SSH Service:      Running
```

---

## WHAT WAS FIXED THIS SESSION

### Root Causes Found

| Problem | Root Cause | Fix Applied |
|---------|------------|-------------|
| Slow neil1988 startup | Systemd user session init | Linger enabled |
| SSH cuts off after 5 sec | `Linger=no` killed session | `loginctl enable-linger neil1988` |
| Startup task fails | Used `--exec` flag | Rewrote with persistent sleep loop |
| No auto-reconnect | Nothing existed | Created WSL-Watchdog task |

### 1. Linger Enabled
```bash
# CRITICAL FIX - keeps user session alive even without login
sudo loginctl enable-linger neil1988
```
**Result:** `/var/lib/systemd/linger/neil1988` file created

### 2. Startup Task (Simple)
Opens Windows Terminal with Ubuntu2 at login:
```
wt.exe -p Ubuntu2
```

### 3. Watchdog Script
**File:** `C:\Users\MYCOM\wsl-watchdog.ps1`
- Runs every 5 minutes via scheduled task
- If WSL is down → opens a terminal

### 4. Scheduled Tasks
| Task | Action | Trigger |
|------|--------|---------|
| WSL-Startup | `wt.exe -p Ubuntu2` | At login |
| WSL-Watchdog | Opens terminal if WSL down | Every 5 minutes |

---

## FILES CREATED/MODIFIED

| File | Location | Purpose |
|------|----------|---------|
| `wsl-startup-hidden.vbs` | `C:\Users\MYCOM\` | Hidden startup (NEW) |
| `wsl-startup-fixed.cmd` | `C:\Users\MYCOM\` | Alternative visible startup |
| `wsl-watchdog.ps1` | `C:\Users\MYCOM\` | Auto-reconnect (NEW) |
| `linger/neil1988` | `/var/lib/systemd/linger/` | Linger enabled (NEW) |

---

## WHY THE OLD APPROACH FAILED

The old `wsl-startup.cmd` used:
```cmd
wsl.exe -d Ubuntu2 --exec /usr/bin/systemctl is-system-running --wait
```

**Problems:**
1. `--exec` = run command then EXIT immediately
2. No persistent session = WSL shuts down
3. No linger = user session dies
4. SSH worked for 5 seconds then cut off

---

## VERIFICATION COMMANDS

```bash
# Check linger status
loginctl show-user neil1988 | grep Linger
# Expected: Linger=yes

# Check SSH is running
systemctl status ssh

# Check scheduled tasks (from PowerShell)
Get-ScheduledTask | Where-Object {$_.TaskName -like '*WSL*'}

# Test SSH from Windows
ssh neil1988@localhost -p 22
```

---

## REMAINING ISSUES

1. **Slow first login** - Still ~2-3 seconds for systemd user session init (acceptable)
2. **Explorer handles** - Still accumulating (unrelated to WSL)

---

## QUICK COMMANDS

```bash
# Kill and restart WSL cleanly
wsl.exe --shutdown
wsl.exe -d Ubuntu2 -u neil1988

# Manual keepalive start
wsl.exe -d Ubuntu2 -u neil1988 -- bash -c "while true; do sleep 3600; done" &

# Check if keepalive is running
pgrep -af "sleep 3600"
```

---

*Last updated: 2025-12-20 - WSL startup/reconnect fully fixed*
