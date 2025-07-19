# Quick Installation Guide

## Prerequisites
- Windows 10/11 with WSL2
- PowerShell (pre-installed on Windows)
- GitHub CLI (optional, for updates)

## Installation

### Option 1: Clone from GitHub
```bash
git clone https://github.com/NeilVibe/ComputerCheck.git
cd ComputerCheck
chmod -R 777 .
```

### Option 2: Download ZIP
1. Download from https://github.com/NeilVibe/ComputerCheck
2. Extract to desired location
3. Open terminal in the folder
4. Run: `chmod -R 777 .`

## Quick Start

### Main Tool (MegaManager)
```powershell
# Show all available tools
.\MegaManager.ps1 help

# Check memory usage
.\MegaManager.ps1 performance memory

# Security scan
.\MegaManager.ps1 security comprehensive

# Test admin rights
.\MegaManager.ps1 utilities test-admin
```

### Alternative Tool (SecurityManager)
```powershell
# Simple memory check
.\SecurityManager.ps1 memory

# Search for malware
.\SecurityManager.ps1 malware KOS

# Check network connections
.\SecurityManager.ps1 network
```

## From WSL/Linux
```bash
# Create alias for easy use
alias secman='/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(pwd)/MegaManager.ps1"'

# Then use
secman help
secman performance memory
```

## Troubleshooting

### Permission Issues
```bash
sudo chmod -R 777 /path/to/ComputerCheck
```

### PowerShell Execution Policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

### WSL Path Issues
Make sure you're using the correct Windows path format in WSL:
```bash
/mnt/c/Users/USERNAME/path/to/ComputerCheck
```

## That's It!
Your security toolkit is ready to use!