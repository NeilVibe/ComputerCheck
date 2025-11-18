# CLAUDE.md - AI Assistant Quick Reference

## 🚀 PROJECT LOCATION (Updated 2025-11-18)

**IMPORTANT: Project has been migrated to Linux filesystem!**

### Current Location:
```
/home/neil1988/CheckComputer
```

**Previous Location:** `/mnt/c/Users/MYCOM/Desktop/CheckComputer` (Windows Desktop - now obsolete)

### Why Migrated:
- ✅ **Faster performance** - Native Linux filesystem (vs Windows mount)
- ✅ **Better git operations** - No Windows permission conflicts
- ✅ **Cleaner workflow** - All projects in Linux home directory
- ✅ **Easier permissions** - chmod works perfectly

### What Changed:
- **PROJECT_ROOT in scripts:** Updated to `/home/neil1988/CheckComputer`
- **Git remote:** Changed from HTTPS to SSH (git@github.com:NeilVibe/ComputerCheck.git)
- **All commits pushed:** 6 commits including migration changes

### What DIDN'T Change:
- ✅ All PowerShell scripts work identically (same commands!)
- ✅ MegaManager.ps1, SecurityManager.ps1 - Same usage
- ✅ All diagnostic tools - Same functionality
- ✅ Infrastructure tools (tools.sh, run.sh, check.sh) - Work better!

### Working from New Location:
```bash
# Your working directory:
cd ~/CheckComputer

# Access from Windows Explorer:
\\wsl$\Ubuntu\home\neil1988\CheckComputer

# PowerShell scripts still work (use \\wsl$ path):
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\MegaManager.ps1" [command]
```

**Migration Documentation:** See `GIT-PUSH-ISSUE-AND-MIGRATION.md` for complete details.

---

## Project Overview
This is a Windows security and troubleshooting toolkit designed to diagnose and fix computer issues systematically.

### 🎉 MAJOR UPDATES (2025-11-16)

#### UI Freeze Fixed!
**Windows 11 bloatware handle leak permanently eliminated!**
- **Problem:** UI freezing for 30+ seconds randomly
- **Root Cause:** Widgets, Phone Link, SearchHost leaking handles in Explorer.exe
- **Solution:** Bloatware permanently disabled (handles dropped from 4,978 → 3,146)
- **Status:** ✅ FIXED - Computer stable, monitoring in place

**📖 Complete Guide:** See **MASTER-GUIDE-UI-FREEZE-FIX.md** for:
- What was done and why
- How to monitor regularly (weekly/monthly checks)
- All scripts and how to use them
- Maintenance schedule
- Troubleshooting if freeze returns

**Quick Check (Do Weekly):**
```bash
# From WSL - Check Explorer.exe handles (should be 3,000-3,500)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Handles"
```

#### SSH Security Hardened!
**SSH brute force attacks blocked - 32,783+ attack attempts detected and stopped!**
- **Problem:** Password authentication enabled, under active brute force attack
- **Root Cause:** SSH exposed to internet with password auth allowing unlimited guessing
- **Solution:** Password auth disabled, key-only authentication enforced
- **Status:** ✅ SECURED - All password attempts rejected instantly, only SSH keys accepted

**📖 Complete Guide:** See **SSH-FULLY-SECURED-2025-11-16.md** for full details

**Quick Check (Do Weekly):**
```bash
# Check SSH security status
sudo ./check-ssh-security.sh
```

**About fail2ban:** ⚠️ DISABLED - Doesn't work with WSL SSH (sees wrong IPs)
- See **FAIL2BAN-WSL-LIMITATION.md** for complete explanation
- WSL port forwarding makes fail2ban see internal IPs (172.28.x.x), not real attackers
- NOT NEEDED: Password auth is OFF = no brute force possible!
- **Current security: MAXIMUM** (key-only authentication)

### 🚨 CRITICAL FINDING - WSL Ubuntu Space Usage
**Your WSL Ubuntu installation on E: drive is consuming 405GB (43% of drive capacity)**
- Location: `E:\Ubuntu\UbuntuWSL\ext4.vhdx`
- This contains your entire Linux filesystem - ALL your data, projects, code
- Analysis tools available: `analyze-wsl-contents.sh`, `space-sniffer.sh`
- **IMPORTANT:** All tools are READ-ONLY. No modifications without explicit permission!

## Primary Tools (Use These First!)

### MegaManager.ps1 - Master Controller
```bash
# From WSL/Linux (new location):
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\MegaManager.ps1" [command]

# Or use the infrastructure wrapper:
cd ~/CheckComputer
./run.sh performance memory

# Available commands:
- security comprehensive    # Full security scan
- security registry-audit   # NEW: Comprehensive registry health audit
- performance memory        # Memory analysis
- monitoring dangerous-events # Check for suspicious events
- security registry-startup # Check startup programs
- utilities check-drive     # Check drive usage and locks (NEW!)
- test                     # Test all tools
- list                     # List available tools
```

### SecurityManager.ps1 - Targeted Security Scans
```bash
# Search for specific malware/process:
.\SecurityManager.ps1 malware [ProcessName]
.\SecurityManager.ps1 scan-malware [Name] -Deep
```

### D Drive Tools - Disk Management & Formatting (NEW!)
```bash
# Check what's using D drive (or any drive)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\check-d-drive.ps1"

# Check hidden Windows ties (indexing, restore points, etc.)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\check-d-drive-hidden-ties.ps1"

# Release all Windows locks on D drive (before formatting)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl$\Ubuntu\home\neil1988\CheckComputer\release-d-drive.ps1"
```

## Troubleshooting Protocol

### For "Computer Acting Strange" Issues:
1. **Check recent events** (last 10-15 minutes)
2. **Look for Event ID 7011** (service timeouts) 
3. **Run MegaManager monitoring dangerous-events**
4. **NEW: Run registry audit** for comprehensive analysis
5. **Check startup items** if boot is slow
6. **Verify memory usage** if system is sluggish

### Key Event IDs to Check:
- **7011**: Service timeout (startup delays)
- **7045**: New service installed (security)
- **4625**: Failed logon (brute force)
- **6008**: Unexpected shutdown
- **1116**: Malware detected

### Quick PowerShell Commands:
```powershell
# Check recent errors (use exactly as shown):
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddMinutes(-15)} | Format-List

# Check service status:
Get-Service -Name "ServiceName" | Select-Object Name, Status, StartType

# Disable problematic service:
Stop-Service -Name "ServiceName" -Force; Set-Service -Name "ServiceName" -StartupType Disabled
```

## Common Issues & Solutions

### Boot/Startup Issues
- **Event 7011 Pattern**: Service timeout issues causing delays
- **Registry conflicts**: Multiple security/banking software conflicts
- **Service analysis**: Check which services are hanging during boot
- **Combined approach**: Event logs + registry startup audit

### Performance Problems
- **Memory analysis**: Check for resource-heavy processes
- **Startup bloatware**: Registry audit reveals auto-starting programs
- **WSL memory issues**: Look for vmmem.exe consuming resources
- **Process correlation**: Match high memory usage to startup entries

### Security/Malware Concerns
- **Multi-layer approach**: Comprehensive scan + registry audit + event monitoring
- **Persistence detection**: Registry startup locations + scheduled tasks
- **Event correlation**: Match suspicious activities with Event IDs (4625, 4720, 7045, 4698)
- **System modifications**: Check for shell/winlogon changes

### Registry-Specific Issues
- **Startup conflicts**: Banking/security software causing delays
- **Orphaned entries**: Software leaving traces after uninstall
- **System modifications**: Unauthorized changes to critical settings
- **Performance impact**: Too many startup programs degrading boot time

## Important Notes
- **Project location:** `/home/neil1988/CheckComputer` (migrated from Windows Desktop 2025-11-18)
- **Use Linux paths:** `~/CheckComputer/...` for bash scripts
- **PowerShell scripts:** Use `\\wsl$\Ubuntu\home\neil1988\CheckComputer\...` path
- **French system** - logs may be in French
- **Run as Administrator** when needed (for PowerShell operations)
- **Check project README.md** for full documentation

## CRITICAL: CHMOD Requirements
**⚠️ CHMOD IS ESSENTIAL FOR WSL/Linux COMPATIBILITY ⚠️**

### When CHMOD is Required:
- **After any file creation/modification**
- **When git push fails with permission errors**
- **When PowerShell scripts won't execute from WSL**
- **After cloning/downloading the project**

### Required CHMOD Commands:
```bash
# Fix all project permissions (ALWAYS RUN THIS FIRST)
sudo chmod -R 755 ~/CheckComputer

# Make all scripts executable
sudo chmod +x ~/CheckComputer/*.ps1
sudo chmod +x ~/CheckComputer/categories/*/*.ps1
sudo chmod +x ~/CheckComputer/*.sh

# Fix git config if push fails (rarely needed on Linux filesystem)
sudo chmod 644 ~/CheckComputer/.git/config
```

### Signs You Need CHMOD:
- **"Operation not permitted"** errors
- **"Permission denied"** when running scripts
- **Git push fails** with chmod errors on config.lock
- **Scripts exist but won't execute** from WSL terminal

### CHMOD in Anti-ClaudeBloat Protocol:
- **ALWAYS chmod new files** before committing
- **Fix permissions** as part of cleanup process
- **Test execution** after chmod to verify fixes

## General Troubleshooting Patterns
- **Boot/Startup Issues** → Check Event 7011 (service timeouts) + registry-audit for startup conflicts
- **Startup Delays/Programs** → Always run registry startup analysis + registry-audit
- **System Instability/Strange Behavior** → Run dangerous-events scan + comprehensive registry audit
- **Time-Specific Issues** → Filter events to exact timeframe when problem occurred
- **Unknown Programs/Performance** → Registry audit reveals startup bloatware and system modifications
- **Security Concerns** → Combined approach: event logs + registry analysis + process scanning

## Project Philosophy
This toolkit is designed to:
1. Find issues systematically (not randomly)
2. Provide evidence (show the logs)
3. Explain in simple terms
4. Fix safely (with user permission)
5. Document solutions for future use

## WSL-Windows Integration Guide
**🚀 MEGA POWER: Full WSL-to-Windows Freedom**

### The Magic Command Pattern
This is the key to running ANY PowerShell script from WSL with FULL Windows rights:

```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Path\To\Script.ps1"
```

**Why this works:**
- `/mnt/c/` - WSL mount point for Windows C: drive
- `-NoProfile` - Skip loading PowerShell profiles (faster, cleaner)
- `-ExecutionPolicy Bypass` - Ignore script execution restrictions
- `-File "C:\..."` - Windows-style path (not WSL path!)

### Path Translation Rules

| WSL Path | Windows Path | When to Use |
|----------|--------------|-------------|
| `/mnt/c/Users/MYCOM/Desktop` | `C:\Users\MYCOM\Desktop` | Inside PowerShell commands |
| `//c/Users/MYCOM/Desktop` | `C:\Users\MYCOM\Desktop` | Alternative WSL notation |
| `$HOME` in WSL | `/home/username` | WSL-only operations |
| `%USERPROFILE%` in Windows | `C:\Users\MYCOM` | Windows environment |

**Critical Rule:** When calling PowerShell from WSL, ALWAYS use Windows-style paths (`C:\...`) inside the PowerShell command!

### Common Patterns

#### 1. Run PowerShell Script from WSL
```bash
# Basic execution
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\script.ps1"

# With parameters
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\script.ps1" -Param1 Value1 -Param2 Value2

# With admin rights (will prompt UAC)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Path\To\Script.ps1'"
```

#### 2. Run PowerShell Commands Directly
```bash
# Single command
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Select-Object -First 10"

# Multiple commands (use semicolons)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Service -Name WSearch; Stop-Service -Name WSearch -Force"

# Complex commands with variables (escape $ with \$)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process | Where-Object {\$_.CPU -gt 100}"
```

#### 3. Create Wrapper Scripts (Recommended!)
Instead of typing long commands, create bash wrappers:

```bash
# Example: secman wrapper
#!/bin/bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\SecurityManager.ps1" "$@"
```

Then just use: `./secman scan-malware KOS`

### File Access from Both Sides

#### WSL Accessing Windows Files
```bash
# Read Windows file from WSL
cat /mnt/c/Users/MYCOM/Desktop/file.txt

# Edit Windows file from WSL
nano /mnt/c/Users/MYCOM/Desktop/file.txt

# List Windows directory from WSL
ls /mnt/c/Users/MYCOM/Desktop/
```

#### Windows Accessing WSL Files
```powershell
# From PowerShell or File Explorer
\\wsl$\Ubuntu\home\username\file.txt

# Or using wsl command
wsl cat /home/username/file.txt
```

### Permission Management

#### Always Set Permissions After Creating Files
```bash
# Make script executable
sudo chmod +x /mnt/c/Users/MYCOM/Desktop/CheckComputer/script.ps1

# Fix all project permissions
sudo chmod -R 755 /mnt/c/Users/MYCOM/Desktop/CheckComputer

# Fix specific file permissions
sudo chmod 644 /mnt/c/Users/MYCOM/Desktop/CheckComputer/file.txt
```

### Troubleshooting WSL-Windows Issues

**Problem:** "Permission denied" when running PowerShell script
**Solution:** Run `sudo chmod +x /path/to/script.ps1`

**Problem:** PowerShell can't find file
**Solution:** Check you're using Windows paths (`C:\...`) not WSL paths (`/mnt/c/...`)

**Problem:** "Redirection operator" errors from bash
**Solution:** Use `-File` parameter instead of inline commands, or escape properly

**Problem:** Script works in PowerShell but not from WSL
**Solution:** Check for special characters ($, >, <, |) - they need escaping in bash

**Problem:** Can't access WSL files from Windows
**Solution:** Use `\\wsl$\Ubuntu\home\...` path in Windows Explorer

### Advanced Techniques

#### Running Commands as Administrator from WSL
```bash
# Method 1: Prompt UAC
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Path\Script.ps1'"

# Method 2: Use gsudo (if installed)
gsudo powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Path\Script.ps1"
```

#### Passing Complex Data Between WSL and PowerShell
```bash
# Export from PowerShell to JSON, read in WSL
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-Process | ConvertTo-Json" > /tmp/processes.json
cat /tmp/processes.json | jq '.'

# Pass WSL data to PowerShell
cat data.txt | /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-Content -Path - | Process-Data"
```

#### Background Jobs
```bash
# Run PowerShell script in background
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Path\Script.ps1" &

# Check if still running
jobs
```

### Best Practices

1. **Use absolute paths** - Both in WSL and Windows contexts
2. **Always chmod new files** - Make them executable immediately
3. **Test in small steps** - Run commands incrementally, don't write huge scripts first
4. **Use wrapper scripts** - Hide complexity, make commands shorter
5. **Escape special characters** - When using `-Command` from bash
6. **Prefer `-File` over `-Command`** - More reliable for complex scripts
7. **Check permissions first** - If something fails, check chmod
8. **Use Windows paths in PowerShell** - Even when calling from WSL

## SSH to WSL Troubleshooting

### The SSH Connection Architecture
```
Internet/Router (172.30.1.54:22) → Windows Port Proxy → WSL (172.28.x.x:22)
```

### Quick SSH Diagnostic
```bash
# Check current WSL IP
ip addr show eth0 | grep "inet "

# Check SSH service
sudo systemctl status ssh

# Check port forwarding (the usual culprit!)
powershell.exe -c "netsh interface portproxy show all"
```

### The Most Common Issue: Missing Port Forwarding

**Problem:** SSH works yesterday, fails today (especially after Windows updates/reboots)

**Cause:** Windows port forwarding configuration was wiped or WSL IP changed

**Fix (Run as Administrator):**
```powershell
# First, get current WSL IP from: ip addr show eth0
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=[WSL_IP]

# Example with actual IP:
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.150.120
```

**From WSL with UAC elevation:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -Command \"netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.150.120\"' -Wait"
```

### Why This Happens
- **WSL IP is dynamic** - Changes on reboot
- **Windows upgrades reset port proxy** - Especially major updates (Win10→Win11)
- **Port forwarding lives in Windows registry** - Can be wiped

### Complete SSH Troubleshooting
See **docs/SSH-WSL-TROUBLESHOOTING.md** for comprehensive guide including:
- Complete diagnostic checklist
- Network architecture explanation
- All common issues and solutions
- Windows 10 vs Windows 11 differences
- Historical context and IP changes

## Terminal Commands Best Practices

**📘 NEW: Complete guide to running Linux/WSL terminal commands properly**

See **docs/TERMINAL-COMMANDS-GUIDE.md** for comprehensive documentation covering:
- Understanding exit codes (is it really an error?)
- When to use `sudo` (admin rights explained)
- File permissions and `chmod`/`chown` usage
- Common errors and how to fix them
- Best practices and safety tips
- Quick reference card for daily commands

**Quick Topics Covered:**
- ✅ Exit codes explained (0=success, 3=service stopped, etc.)
- ✅ sudo usage (when you need it, when you don't)
- ✅ Permission denied fixes (chmod, chown)
- ✅ Service management (systemctl patterns)
- ✅ Common errors and solutions
- ✅ Safe command practices

## PowerShell Admin Rights & Registry Mastery

**🔥 Complete guide to using PowerShell with FULL ADMIN POWER**

See **docs/POWERSHELL-ADMIN-GUIDE.md** for comprehensive documentation covering:
- How to get and use Administrator privileges
- Complete registry manipulation patterns (read/write with full rights)
- Service management and system-level operations
- WSL to Windows admin elevation techniques
- Real examples from this project (malware removal, drive cleanup, security checks)
- Safety guidelines and error handling
- Troubleshooting common admin/registry issues

**Quick Topics Covered:**
- ✅ UAC elevation from WSL (`Start-Process -Verb RunAs`)
- ✅ Registry HKLM write operations (requires admin)
- ✅ Service control (Stop-Service, Set-Service)
- ✅ Shadow copy management (vssadmin)
- ✅ Port forwarding configuration (netsh)
- ✅ System protection and recycle bin management
- ✅ Safe patterns with error handling

## Linux Monitoring Tools (Reference Guide)

**📚 Available Tools - Install Only When Needed!**

**IMPORTANT:** We do NOT bulk-install monitoring tools (that creates bloat!). Instead, we:
1. Use built-in Ubuntu tools FIRST (ps, grep, netstat, df, etc.)
2. Install additional tools ONE AT A TIME, only when specific need identified
3. User approves each tool individually
4. Try for 1 week, keep only if proven useful

**Currently Installed:**
- ✅ Built-in Ubuntu tools (ps, grep, awk, netstat, df, top, etc.) - Use these first!
- ❌ fail2ban - DISABLED (not needed, password auth is off)

**Available Tools (NOT Installed - Reference Only):**
See **LINUX-MONITORING-TOOLS.md** for complete reference guide

**Common Tools by Purpose:**
- **System monitoring:** htop (~200KB) - prettier than `top`
- **Network per-app:** nethogs (~50KB) - which app uses bandwidth
- **Disk usage:** ncdu (~100KB) - interactive disk browser
- **All-in-one:** glances (~2MB) - comprehensive monitor

**Installation Process (When Needed):**
```bash
# Example: Need to check network usage
# 1. Try built-in first
netstat -tulpn  # See what's using network

# 2. If not enough, install ONE specific tool
sudo apt install nethogs  # Only this one!

# 3. Use it
sudo nethogs

# 4. Evaluate after 1 week: keep or remove
```

**What NOT To Do:**
- ❌ Don't install multiple tools at once
- ❌ Don't install "just in case"
- ❌ Don't keep tools you don't actually use
- ❌ Don't use bulk installer (ARCHIVED!)

**Why This Approach:**
We removed Windows bloatware (Widgets, SearchHost) - we don't add Linux bloat!

## Windows 11 Context Menu Fix

**🎯 NEW: Restore Windows 10 Classic Right-Click Menu!**

Windows 11's simplified context menu is annoying - all useful options are hidden behind "Show more options". Restore the full menu!

**Quick Fix:**
```powershell
# Run as Administrator
.\restore-windows10-context-menu.ps1 Restore
```

**From WSL:**
```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\restore-windows10-context-menu.ps1" Restore
```

**One-liner (manual):**
```cmd
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
taskkill /f /im explorer.exe & start explorer.exe
```

See **docs/WINDOWS11-CONTEXT-MENU-FIX.md** for:
- Detailed explanation of the problem
- Multiple fix methods
- Troubleshooting guide
- How to revert if needed
- Alternative methods (Shift+Right-Click, ExplorerPatcher)

## Windows UI Lag / Freezing Fix

**🚨 CRITICAL: Extreme UI lag (30+ second delays) despite normal resources**

**Issue Resolved:** 2025-01-16 - Kernel driver DPC latency + Explorer.exe handle leak

See **docs/UI-LAG-FIX.md** for complete documentation covering:
- Root cause analysis (IOMap, vgk, explorer.exe handle leak)
- Permanent fix (disable problematic kernel drivers)
- Quick toggle for Riot Vanguard (gaming vs performance)
- Diagnostic commands and monitoring
- Prevention strategies

**Quick Commands:**

```bash
# Toggle ANY kernel driver (IOMap, vgk, etc.) - Interactive menu
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1"

# Toggle specific driver directly
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-kernel-driver.ps1" -DriverName vgk

# Toggle Riot Vanguard only (quick shortcut)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\toggle-vanguard.ps1"

# Check explorer.exe handles (normal: 1000-2000, critical: 5000+)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Get-Process explorer | Select-Object Name, Id, Handles"

# Run full diagnostic
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\diagnose-slowness.ps1"
```

**What Was Fixed:**
- ✅ Disabled IOMap (Korean driver causing DPC latency)
- ✅ Disabled vgk (Riot Vanguard kernel driver)
- ✅ Disabled Windows Widgets (explorer.exe handle leak source)
- ✅ Created toggle script for easy vgk enable/disable

**Note:** If you play Valorant/League, use `toggle-vanguard.ps1` to enable vgk before gaming, then disable after for better performance.

---

Last Updated: 2025-11-18
Latest Achievement: Project Migrated to Linux Filesystem - Moved to /home/neil1988/CheckComputer for better performance, git works perfectly, 6 commits pushed!
Previous Addition: Terminal Commands Guide - Complete best practices for Linux/WSL commands, sudo, exit codes
Earlier Success: SSH Security 100% Locked Down - Key-only authentication, password auth disabled, impossible to brute force
Earlier Success: UI Freeze Fix - Windows 11 bloatware elimination (handles dropped 37%)