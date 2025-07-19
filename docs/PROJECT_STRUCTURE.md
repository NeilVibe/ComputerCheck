# Project Structure

## Main Components

```
CheckComputer/
│
├── 🚀 NEW MODULAR SYSTEM
│   ├── SecurityManager.ps1      # Main security manager with all functions
│   ├── secman                   # WSL-friendly wrapper script
│   └── lib/
│       └── PSRunner.ps1         # PowerShell execution module
│
├── 📚 DOCUMENTATION
│   ├── README.md                # Project overview and quick start
│   ├── USAGE_GUIDE.md          # Detailed usage instructions
│   ├── LESSONS_LEARNED.md      # What we learned about PS/WSL integration
│   ├── PROJECT_STRUCTURE.md    # This file
│   └── computer_security_report.md  # Historical malware analysis
│
├── 🔧 LEGACY SCRIPTS (Still Working)
│   ├── check_security.ps1       # Original comprehensive checker
│   ├── comprehensive-security-check.ps1
│   ├── deep-process-check.ps1
│   ├── memory-usage-check.ps1
│   ├── safe-event-monitor.ps1
│   ├── check-vmmem.ps1
│   ├── check-4104-simple.ps1
│   └── test-admin.ps1
│
└── 📦 ARCHIVE/
    ├── hunt-kos.ps1            # KOS-specific hunters
    ├── quick-kos-hunt.ps1
    ├── final-kos-check.ps1
    └── check-suspicious-task.ps1

```

## Key Improvements in v2.0

1. **Modular Design**: Each security function is independent
2. **Error-Free WSL Integration**: No more syntax errors
3. **Performance Optimized**: Targeted searches, no full C:\ scans
4. **Flexible Options**: Export, deep scan, quick scan modes
5. **Admin-Aware**: Automatic elevation when needed

## Usage Examples

### Quick Tasks
```bash
# From WSL
./secman health              # Quick health check
./secman scan-malware virus  # Search for "virus"

# From PowerShell
.\SecurityManager.ps1 monitor-memory
```

### Advanced Tasks
```powershell
# Deep scan with export
.\SecurityManager.ps1 scan-process -Deep -Export

# Custom export path
.\SecurityManager.ps1 scan-malware ransomware -Export -ExportPath "C:\Reports\scan.txt"
```

## Adding New Functions

To add a new security check:

1. Add a new case in `SecurityManager.ps1`
2. Use the established patterns for error handling
3. Test from both PowerShell and WSL
4. Update help text in both scripts