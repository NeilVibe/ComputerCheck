# Security Manager Usage Guide

## Quick Start

### From WSL/Linux Terminal:
```bash
# Basic commands
./secman help                    # Show help
./secman scan-malware KOS        # Search for specific malware
./secman monitor                 # Monitor system resources
./secman health                  # Quick health check

# Admin commands (will prompt for UAC)
./secman admin scan-network      # Network scan with admin rights
./secman admin scan-process      # Deep process scan
```

### From PowerShell:
```powershell
# Direct usage
.\SecurityManager.ps1 scan-malware KOS
.\SecurityManager.ps1 monitor-memory
.\SecurityManager.ps1 quick-health -Export

# With options
.\SecurityManager.ps1 scan-process -Deep
.\SecurityManager.ps1 scan-malware Kings -Export -ExportPath ".\report.txt"
```

## Available Actions

### 1. Malware Scanning
```bash
# Search for specific malware by name
./secman scan-malware KOS
./secman scan-malware Kings
./secman scan-malware ransomware
```

### 2. Process Monitoring
```bash
# Find suspicious processes
./secman scan-process

# From PowerShell with deep scan
.\SecurityManager.ps1 scan-process -Deep
```

### 3. Network Analysis
```bash
# Check current connections
./secman scan-network

# With admin rights for more details
./secman admin scan-network
```

### 4. System Health
```bash
# Quick health check
./secman health

# Memory monitoring
./secman monitor
```

## Advanced Usage

### Custom Searches
```powershell
# Search for files
.\SecurityManager.ps1 search-file "*.exe" -Deep

# Monitor specific event IDs
.\SecurityManager.ps1 monitor-events 4625  # Failed logons
```

### Exporting Results
```powershell
# Export any scan to file
.\SecurityManager.ps1 scan-malware KOS -Export
.\SecurityManager.ps1 quick-health -Export -ExportPath "C:\Reports\health.txt"
```

### Scheduled Scans
Create a scheduled task to run regular scans:
```powershell
# Weekly security scan
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\SecurityManager.ps1 quick-health -Export"
$trigger = New-ScheduledTaskTrigger -Weekly -At 9am -DaysOfWeek Monday
Register-ScheduledTask -TaskName "WeeklySecurityScan" -Action $action -Trigger $trigger
```

## Key Features

1. **Error-Free Execution**: All syntax issues from WSL are handled
2. **Modular Design**: Each function can be used independently
3. **Performance Optimized**: Targeted searches instead of full C:\ scans
4. **Admin-Aware**: Automatically detects when admin rights are needed
5. **Export Options**: Save results for documentation

## Troubleshooting

### "Redirection operator" errors
- Use the secman wrapper script instead of direct PowerShell calls from WSL

### "Access Denied" errors
- Use `./secman admin <command>` for operations requiring elevation

### Slow performance
- Avoid using -Deep flag unless necessary
- Target specific directories instead of full system scans

## What We Learned & Implemented

1. **Proper escaping**: All $ signs in PowerShell commands are escaped when called from bash
2. **Script files**: Complex operations use temporary script files instead of inline commands
3. **Error handling**: All commands include proper error suppression
4. **Performance**: Targeted searches with early filtering
5. **Modularity**: Each scan type is independent and reusable