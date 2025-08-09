# Computer Health Checkup

This project provides comprehensive tools for checking your computer's overall health, performance, and security. Regular checkups help maintain optimal system performance and catch potential issues early.

## What This Tool Can Check

### 1. Security Health
- **Suspicious Processes**: Identifies processes with hidden paths or unusual behavior
- **Network Connections**: Monitors for unexpected outbound connections
- **Scheduled Tasks**: Checks for potentially malicious automated tasks
- **Startup Items**: Reviews programs that launch at system startup
- **System Services**: Analyzes running services for anomalies
- **Script Locations**: Scans for suspicious scripts in system directories

### 2. Performance Issues
- **Resource Usage**: Identifies processes consuming excessive CPU/memory
- **Disk Space**: Checks available storage and large files
- **System Errors**: Reviews event logs for critical errors
- **Driver Issues**: Identifies outdated or problematic drivers

### 3. System Integrity
- **Windows Updates**: Verifies system is up-to-date
- **File System**: Checks for corruption or errors
- **Registry Health**: Identifies potential registry issues
- **Software Conflicts**: Detects conflicting applications

## How to Use

### 🚀 NEW: Comprehensive Registry Analyzer (Latest Addition)

**Full registry health audit and analysis tool** - detect startup bloatware, security issues, and system problems!

#### Quick Registry Analysis:
```bash
# From WSL/Linux Terminal:
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\MegaManager.ps1" security registry-audit

# Or from PowerShell:
.\MegaManager.ps1 security registry-audit
.\MegaManager.ps1 security registry-audit -Export  # Save detailed report
```

### 🚀 Security Manager v2.0 (Also Recommended)

Built with lessons learned - no more syntax errors or slow scans!

#### From WSL/Linux Terminal:
```bash
./secman help                 # Show all available commands
./secman scan-malware KOS     # Search for specific malware
./secman health               # Quick system health check
./secman monitor              # Monitor memory usage
./secman admin scan-network   # Network scan with admin rights
```

#### From PowerShell:
```powershell
.\SecurityManager.ps1 help
.\SecurityManager.ps1 scan-malware KOS -Deep
.\SecurityManager.ps1 monitor-memory
.\SecurityManager.ps1 quick-health -Export
```

### Legacy Scripts (Still Available)

1. **Option 1 - GUI Method**:
   - Right-click on **check_security.ps1**
   - Select "Run with PowerShell"
   - Choose "Run as administrator" when prompted

2. **Option 2 - Command Line**:
   ```powershell
   cd C:\Users\MYCOM\Desktop\CheckComputer
   .\check_security.ps1
   ```

### Recommended Checkup Schedule

- **Weekly**: Quick security scan + registry audit
- **Monthly**: Full system checkup + comprehensive registry analysis
- **After Issues**: When experiencing slowdowns or crashes
- **Post-Installation**: After installing major software (check startup changes)
- **Quarterly**: Deep system analysis + registry cleanup

## Understanding Results

The checkup will provide:
- **Green/OK**: System component is healthy
- **Yellow/Warning**: Minor issues that should be monitored
- **Red/Critical**: Immediate attention required

### Registry Analysis Results:
- **[SAFE]**: Known good software (Microsoft, NVIDIA, etc.)
- **[UNKNOWN]**: Needs review (could be legitimate software)
- **[SUSPICIOUS]**: High risk entries requiring investigation
- **Orphaned Keys**: >20 suggests cleanup needed
- **Critical Issues**: >0 requires immediate security investigation

## What to Do After Checkup

1. **Review all findings** in the generated report
2. **Address critical issues** immediately
3. **Schedule follow-up** for warnings
4. **Document changes** made to the system
5. **Run verification** after fixes

## Additional Resources

- **INSTALL.md**: Quick installation guide
- **USAGE_GUIDE.md**: Detailed usage instructions  
- **FINAL_PROJECT_STATUS.md**: Complete project overview
- **computer_security_report.md**: Historical security incident documentation
- **docs/**: Detailed documentation and lessons learned
- **archive/**: Old scripts and specialized tools

## Best Practices

1. **Run as Administrator** for complete system access
2. **Close unnecessary programs** before running checkup
3. **Save your work** before starting
4. **Keep logs** of all checkups for trend analysis
5. **Act on findings** promptly to prevent issues

---

*Computer Health Checkup Tool - Last updated: January 2025*  
**🆕 Latest Addition: Comprehensive Registry Analyzer - Full system registry health audit** 