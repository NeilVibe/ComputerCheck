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

### Black Screen at Startup
- Check for **ArmouryCrateService** timeouts
- Look for multiple Event 7011 entries
- Banking/security software can cause delays
- **NEW: Run registry-audit** to find startup conflicts

### Slow Performance
- Run: `MegaManager.ps1 performance memory`
- Check for processes over 1GB RAM
- Look for vmmem.exe (WSL memory issue)
- **NEW: Check registry** for startup bloatware

### Suspicious Activity
- Run: `MegaManager.ps1 security comprehensive`
- **NEW: Run registry-audit** for comprehensive analysis
- Check Event IDs: 4625, 4720, 7045, 4698
- Review startup registry entries

### Registry Issues (NEW)
- **Startup delays**: Use `registry-audit` to find bloatware
- **Unknown programs**: Check startup entries analysis
- **System instability**: Look for orphaned registry keys
- **Security concerns**: Analyze shell/winlogon modifications

## Important Notes
- **Always use absolute paths** (C:\Users\MYCOM\Desktop\CheckComputer\)
- **French system** - logs may be in French
- **Run as Administrator** when needed
- **Check project README.md** for full documentation

## Success Patterns
- When user says "computer stayed black" → Check Event 7011 + registry-audit
- When user says "something at startup" → Check registry startup + registry-audit
- When user says "acting strange" → Run dangerous-events scan + registry-audit
- When user mentions specific time → Filter events to that timeframe
- **NEW: Registry issues** → Always run registry-audit for comprehensive analysis

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