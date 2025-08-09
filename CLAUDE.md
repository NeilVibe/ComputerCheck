# CLAUDE.md - AI Assistant Quick Reference

## Project Overview
This is a Windows security and troubleshooting toolkit designed to diagnose and fix computer issues systematically.

## Primary Tools (Use These First!)

### MegaManager.ps1 - Master Controller
```bash
# From WSL/Linux:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\MegaManager.ps1" [command]

# Available commands:
- security comprehensive    # Full security scan
- security registry-audit   # NEW: Comprehensive registry health audit
- performance memory        # Memory analysis  
- monitoring dangerous-events # Check for suspicious events
- security registry-startup # Check startup programs
- test                     # Test all tools
- list                     # List available tools
```

### SecurityManager.ps1 - Targeted Security Scans
```bash
# Search for specific malware/process:
.\SecurityManager.ps1 malware [ProcessName]
.\SecurityManager.ps1 scan-malware [Name] -Deep
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
- **Always use absolute paths** (C:\Users\MYCOM\Desktop\CheckComputer\)
- **French system** - logs may be in French
- **Run as Administrator** when needed
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
sudo chmod -R 755 /mnt/c/Users/MYCOM/Desktop/CheckComputer

# Make all scripts executable
sudo chmod +x /mnt/c/Users/MYCOM/Desktop/CheckComputer/*.ps1 
sudo chmod +x /mnt/c/Users/MYCOM/Desktop/CheckComputer/categories/*/*.ps1

# Fix git config if push fails
sudo chmod 644 /mnt/c/Users/MYCOM/Desktop/CheckComputer/.git/config
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

Last Updated: 2025-01-09
Last Success: Comprehensive Registry Analyzer added - full system registry audit capability
Previous Success: Diagnosed and fixed ArmouryCrateService causing 4-minute black screen delay