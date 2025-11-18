# Project Structure

## Main Components

```
CheckComputer/
│
├── 🎛️  MEGA MANAGER (Master Controller)
│   ├── MegaManager.ps1           # Central command center for all tools
│   └── Usage: .\MegaManager.ps1 <class> <tool>
│       ├── security              # Security tools
│       ├── performance           # Performance monitoring
│       ├── monitoring            # Event monitoring
│       └── utilities             # Helper tools (NEW: D drive management!)
│
├── 🚀 MODULAR TOOLS
│   ├── SecurityManager.ps1       # Main security manager with all functions
│   ├── secman                    # WSL-friendly wrapper script
│   ├── check-d-drive.ps1         # NEW: Check drive usage
│   ├── check-d-drive-hidden-ties.ps1  # NEW: Find hidden drive locks
│   ├── release-d-drive.ps1       # NEW: Release drive locks
│   └── lib/
│       └── PSRunner.ps1          # PowerShell execution module
│
├── 📂 CATEGORIES/ (Organized Tools)
│   ├── security/                 # Security scanning tools
│   │   ├── comprehensive-security-check.ps1
│   │   ├── deep-process-check.ps1
│   │   ├── registry-startup-analysis.ps1
│   │   └── registry-comprehensive-audit.ps1
│   ├── performance/              # Performance monitoring
│   │   ├── memory-usage-check.ps1
│   │   └── check-vmmem.ps1
│   ├── monitoring/               # Event log monitoring
│   │   ├── dangerous-event-ids.ps1
│   │   ├── check-4104-events.ps1
│   │   └── usb-device-monitor.ps1
│   └── utilities/                # Helper tools
│       ├── test-admin.ps1
│       └── check-wsl-service.ps1
│
├── 📚 DOCUMENTATION
│   ├── README.md                 # Project overview and quick start
│   ├── CLAUDE.md                 # AI Assistant quick reference
│   ├── USAGE_GUIDE.md            # Detailed usage instructions
│   ├── INSTALL.md                # Installation guide
│   ├── docs/
│   │   ├── WSL-WINDOWS-INTEGRATION.md  # NEW: Complete WSL-Windows guide
│   │   ├── LESSONS_LEARNED.md    # What we learned
│   │   ├── PROJECT_STRUCTURE.md  # This file
│   │   ├── troubleshooting-protocols.md
│   │   └── WHAT_WORKS.md
│   └── computer_security_report.md  # Historical malware analysis
│
├── 🔧 LEGACY SCRIPTS (Still Working)
│   ├── check_security.ps1        # Original comprehensive checker
│   ├── comprehensive-security-check.ps1
│   ├── deep-process-check.ps1
│   ├── memory-usage-check.ps1
│   ├── safe-event-monitor.ps1
│   ├── check-vmmem.ps1
│   ├── check-4104-simple.ps1
│   └── test-admin.ps1
│
└── 📦 ARCHIVE/
    ├── hunt-kos.ps1              # KOS-specific hunters
    ├── quick-kos-hunt.ps1
    ├── final-kos-check.ps1
    └── check-suspicious-task.ps1

```

## Key Improvements in v2.1 (Latest)

1. **D Drive Management Tools**: Complete disk usage and lock analysis
2. **WSL-Windows Integration Guide**: Full documentation for MEGA POWER commands
3. **MegaManager Integration**: All tools accessible from single controller
4. **Comprehensive Documentation**: Step-by-step guides for all scenarios

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

### NEW: D Drive Management (v2.1)
```bash
# From WSL - Check what's using D drive
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\check-d-drive.ps1"

# Check hidden Windows locks
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\check-d-drive-hidden-ties.ps1"

# Release all locks before formatting
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\release-d-drive.ps1"

# Via MegaManager (shorter!)
.\MegaManager.ps1 utilities check-drive
.\MegaManager.ps1 utilities check-drive-ties
.\MegaManager.ps1 utilities release-drive
```

### WSL-Windows Integration
```bash
# The MEGA POWER command pattern
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass \
  -File "C:\Path\To\Script.ps1"

# For complete guide, see:
# docs/WSL-WINDOWS-INTEGRATION.md
```

## Adding New Functions

To add a new security check:

1. Add a new case in `SecurityManager.ps1`
2. Use the established patterns for error handling
3. Test from both PowerShell and WSL
4. Update help text in both scripts

To add a new tool to MegaManager:

1. Create the PowerShell script in appropriate category folder
2. Add the tool to the relevant class section in `MegaManager.ps1`
3. Update the help text and list output
4. Test via `.\MegaManager.ps1 <class> <tool>`
5. **CRITICAL**: Run `sudo chmod +x /path/to/script.ps1` for WSL compatibility

## Navigation Guide

| Need to... | Check this file... |
|------------|-------------------|
| Quick command reference | `CLAUDE.md` |
| Learn WSL-Windows integration | `docs/WSL-WINDOWS-INTEGRATION.md` |
| Understand project layout | `docs/PROJECT_STRUCTURE.md` (this file) |
| Get usage instructions | `USAGE_GUIDE.md` |
| Troubleshoot issues | `docs/troubleshooting-protocols.md` |
| See what works | `docs/WHAT_WORKS.md` |