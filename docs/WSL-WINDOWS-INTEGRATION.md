# WSL-Windows Integration Guide
**Complete guide to achieving MEGA POWER between WSL and Windows**

## Table of Contents
1. [The Foundation](#the-foundation)
2. [Command Patterns](#command-patterns)
3. [Path Management](#path-management)
4. [Permission Control](#permission-control)
5. [Advanced Techniques](#advanced-techniques)
6. [Troubleshooting](#troubleshooting)
7. [Real-World Examples](#real-world-examples)

---

## The Foundation

### Understanding the Bridge

WSL (Windows Subsystem for Linux) and Windows are two separate operating systems running on the same machine. The key to integration is understanding how they communicate:

```
┌─────────────────────────────────────────┐
│           Windows OS                    │
│  ┌────────────────────────────────┐    │
│  │  C:\Users\MYCOM\Desktop        │    │
│  │  C:\Windows\System32           │    │
│  └────────────────────────────────┘    │
│              ↕                          │
│         (Mount Point)                   │
│              ↕                          │
│  ┌────────────────────────────────┐    │
│  │  /mnt/c/Users/MYCOM/Desktop    │    │
│  │  /home/username                │    │
│  │         WSL Linux              │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### The Magic Command

This is the universal pattern for running PowerShell from WSL with full rights:

```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile \
  -ExecutionPolicy Bypass \
  -File "C:\Path\To\Script.ps1"
```

**Breakdown:**
- `/mnt/c/Windows/System32/...` - WSL path to PowerShell executable
- `-NoProfile` - Don't load user PowerShell profile (faster, cleaner)
- `-ExecutionPolicy Bypass` - Ignore script execution restrictions
- `-File "C:\..."` - Use Windows-style path for the script

---

## Command Patterns

### Pattern 1: Execute PowerShell Script

```bash
# Basic
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass \
  -File "C:\Users\MYCOM\Desktop\CheckComputer\script.ps1"

# With parameters
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass \
  -File "C:\path\script.ps1" -Param1 "Value1" -Param2 "Value2"

# With switch parameters
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass \
  -File "C:\path\script.ps1" -Export -Verbose
```

### Pattern 2: Execute PowerShell Command Directly

```bash
# Single command
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -Command "Get-Process | Select-Object -First 5"

# Multiple commands (separate with semicolon)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -Command "Get-Date; Get-Service -Name 'WSearch'"

# With variables (ESCAPE $ with \$)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -Command "Get-Process | Where-Object {\$_.CPU -gt 50}"
```

### Pattern 3: Chain Commands

```bash
# Sequential execution (both run, even if first fails)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "command1; command2; command3"

# Conditional execution (stop on error)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "command1 && command2 && command3"
```

### Pattern 4: Create Bash Wrapper Scripts

**Why?** Long commands are error-prone. Create shortcuts!

```bash
#!/bin/bash
# File: secman

# Pass all arguments to PowerShell script
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass \
  -File "C:\Users\MYCOM\Desktop\CheckComputer\SecurityManager.ps1" "$@"
```

Make executable and use:
```bash
chmod +x secman
./secman scan-malware KOS
./secman health -Export
```

---

## Path Management

### The Golden Rules

1. **In WSL context:** Use `/mnt/c/...` paths
2. **In PowerShell context:** Use `C:\...` paths
3. **NEVER mix** path styles in the same command

### Path Translation Table

| Description | WSL Path | Windows Path |
|-------------|----------|--------------|
| Desktop | `/mnt/c/Users/MYCOM/Desktop` | `C:\Users\MYCOM\Desktop` |
| Documents | `/mnt/c/Users/MYCOM/Documents` | `C:\Users\MYCOM\Documents` |
| Program Files | `/mnt/c/Program Files` | `C:\Program Files` |
| Windows System | `/mnt/c/Windows/System32` | `C:\Windows\System32` |
| WSL Home | `/home/username` | `\\wsl$\Ubuntu\home\username` |

### Accessing Files Cross-Platform

#### From WSL → Windows Files

```bash
# Read
cat /mnt/c/Users/MYCOM/Desktop/file.txt

# Edit
nano /mnt/c/Users/MYCOM/Desktop/script.ps1
vim /mnt/c/Users/MYCOM/Documents/data.csv

# List
ls -la /mnt/c/Users/MYCOM/Desktop/
find /mnt/c/Users/MYCOM -name "*.log"

# Copy
cp /mnt/c/Users/MYCOM/file.txt /home/username/
```

#### From Windows → WSL Files

```powershell
# From PowerShell
Get-Content \\wsl$\Ubuntu\home\username\file.txt
Copy-Item \\wsl$\Ubuntu\home\username\data.csv C:\Temp\

# From File Explorer
\\wsl$\Ubuntu\home\username\
```

#### From Windows Command Prompt

```cmd
wsl ls -la /home/username
wsl cat /home/username/file.txt
wsl --exec bash -c "command"
```

### Path Conversion Functions

Create helper functions in `~/.bashrc`:

```bash
# Convert WSL path to Windows path
wslpath2win() {
    echo "$1" | sed 's|/mnt/\([a-z]\)/|\U\1:/|'
}

# Convert Windows path to WSL path
winpath2wsl() {
    echo "$1" | sed 's|\([A-Z]\):|/mnt/\L\1|' | sed 's|\\|/|g'
}

# Usage:
# wslpath2win "/mnt/c/Users/MYCOM/Desktop" → "C:/Users/MYCOM/Desktop"
# winpath2wsl "C:\Users\MYCOM\Desktop" → "/mnt/c/Users/MYCOM/Desktop"
```

---

## Permission Control

### Why Permissions Matter

WSL uses Linux permissions. Windows files accessed through `/mnt/` can have permission issues. Always set permissions after creating/modifying files.

### Essential CHMOD Commands

```bash
# Make script executable
sudo chmod +x /mnt/c/path/to/script.ps1

# Make all scripts in directory executable
sudo chmod +x /mnt/c/path/to/directory/*.ps1

# Recursive permission fix (entire project)
sudo chmod -R 755 /mnt/c/Users/MYCOM/Desktop/CheckComputer

# Fix git config permissions
sudo chmod 644 /mnt/c/project/.git/config
```

### Permission Reference

| Code | Meaning | Use Case |
|------|---------|----------|
| 755 | rwxr-xr-x | Scripts, directories |
| 644 | rw-r--r-- | Config files, text files |
| 600 | rw------- | Private files (keys, passwords) |
| 777 | rwxrwxrwx | Everything (⚠️ use sparingly!) |

### Automatic Permission Fixing

Add to project scripts:

```powershell
# In PowerShell scripts, start with:
# Ensure script is executable
if (-not (Test-Path $PSCommandPath -PathType Leaf)) {
    Write-Error "Script not found or not accessible"
    exit 1
}
```

```bash
# In bash scripts, start with:
#!/bin/bash
# Auto-fix permissions on first run
if [ ! -x "$0" ]; then
    sudo chmod +x "$0"
fi
```

---

## Advanced Techniques

### 1. Running with Administrator Rights

#### Method A: UAC Prompt

```bash
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\path\script.ps1'"
```

#### Method B: Using gsudo (if installed)

```bash
# Install gsudo first (from PowerShell admin):
# winget install gsudo

# Then from WSL:
gsudo powershell -NoProfile -ExecutionPolicy Bypass -File "C:\path\script.ps1"
```

### 2. Capturing Output

```bash
# Store output in variable
output=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-Process | ConvertTo-Json")
echo "$output" | jq '.[] | select(.CPU > 100)'

# Save to file
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-Service" > /tmp/services.txt

# Pipe to WSL command
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue" | grep ".exe"
```

### 3. Environment Variables

```bash
# Access Windows environment variables from WSL
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "[Environment]::GetEnvironmentVariable('PATH', 'Machine')"

# Set Windows environment variable (requires admin)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "[Environment]::SetEnvironmentVariable('MY_VAR', 'value', 'User')"

# Pass WSL variable to PowerShell
MY_VAR="test"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Write-Host 'Value: $env:MY_VAR'"
```

### 4. Background Jobs

```bash
# Run PowerShell script in background
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass \
  -File "C:\path\long-running-script.ps1" &

# Get job ID
JOB_PID=$!
echo "Job running with PID: $JOB_PID"

# Check if still running
ps -p $JOB_PID

# Kill if needed
kill $JOB_PID
```

### 5. Data Exchange via Files

```bash
# WSL creates request file
echo "scan" > /mnt/c/Temp/request.txt

# PowerShell processes it
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -File "C:\processor.ps1" -InputFile "C:\Temp\request.txt" -OutputFile "C:\Temp\result.json"

# WSL reads result
cat /mnt/c/Temp/result.json | jq '.'
```

### 6. Interactive PowerShell from WSL

```bash
# Start interactive PowerShell session
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoExit

# Start PowerShell with custom prompt
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoExit -Command "function prompt { 'PS> ' }"
```

---

## Troubleshooting

### Common Issues & Solutions

#### Issue 1: "Permission denied"
```bash
# Problem:
./script.ps1
# bash: ./script.ps1: Permission denied

# Solution:
sudo chmod +x script.ps1
```

#### Issue 2: "Cannot find path"
```bash
# Problem (wrong path style):
powershell.exe -File "/mnt/c/Users/MYCOM/script.ps1"

# Solution (use Windows paths):
powershell.exe -File "C:\Users\MYCOM\script.ps1"
```

#### Issue 3: "Redirection operator '<' is not allowed"
```bash
# Problem (bash interprets redirection):
powershell.exe -Command "Get-Process | Where-Object {$_.CPU > 100}"

# Solution (escape special chars):
powershell.exe -Command "Get-Process | Where-Object {\$_.CPU -gt 100}"
```

#### Issue 4: "Execution policy error"
```bash
# Problem:
powershell.exe -File "script.ps1"
# Execution policy restricted

# Solution (add bypass):
powershell.exe -ExecutionPolicy Bypass -File "script.ps1"
```

#### Issue 5: Script works in PowerShell but not from WSL
```bash
# Problem: Line endings
# PowerShell scripts created in WSL have Unix line endings (LF)
# Windows expects Windows line endings (CRLF)

# Solution: Convert line endings
sudo apt-get install dos2unix
dos2unix /mnt/c/path/script.ps1

# Or use sed:
sed -i 's/\r$//' /mnt/c/path/script.ps1  # LF to CRLF
sed -i 's/$/\r/' /mnt/c/path/script.ps1  # CRLF to LF
```

#### Issue 6: Can't access WSL files from Windows
```bash
# Problem:
# File Explorer can't see /home/username/file.txt

# Solution (use special path):
# In Windows: \\wsl$\Ubuntu\home\username\file.txt
# Or access via: \\wsl.localhost\Ubuntu\home\username\file.txt
```

### Debugging Commands

```bash
# Check if PowerShell is accessible
which powershell.exe

# Test PowerShell execution
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Write-Host 'It works!'"

# Check file permissions
ls -la /mnt/c/path/to/file

# Verify WSL distro
wsl.exe --list --verbose

# Check Windows version from WSL
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "[System.Environment]::OSVersion"
```

---

## Real-World Examples

### Example 1: System Health Check

```bash
#!/bin/bash
# health-check.sh - Check Windows system health from WSL

echo "=== Windows System Health Check ==="

# Get system info
echo "[1] System Information:"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-ComputerInfo | Select-Object CsName, WindowsVersion, OsArchitecture"

# Check disk space
echo -e "\n[2] Disk Space:"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{N='Used(GB)';E={[math]::Round(\$_.Used/1GB,2)}}, @{N='Free(GB)';E={[math]::Round(\$_.Free/1GB,2)}}"

# Check running services
echo -e "\n[3] Critical Services:"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-Service | Where-Object {\$_.Status -eq 'Running' -and \$_.StartType -eq 'Automatic'} | Select-Object -First 10 Name, Status"

# Check memory usage
echo -e "\n[4] Memory Usage:"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Get-CimInstance Win32_OperatingSystem | Select-Object @{N='Total(GB)';E={[math]::Round(\$_.TotalVisibleMemorySize/1MB,2)}}, @{N='Free(GB)';E={[math]::Round(\$_.FreePhysicalMemory/1MB,2)}}"
```

### Example 2: Automated Backup

```bash
#!/bin/bash
# backup.sh - Backup Windows files using WSL

BACKUP_DIR="/mnt/d/Backups/$(date +%Y%m%d)"
SOURCE_DIR="/mnt/c/Users/MYCOM/Documents"

echo "Creating backup: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Copy files using rsync
rsync -av --progress "$SOURCE_DIR/" "$BACKUP_DIR/"

# Create compressed archive
tar -czf "$BACKUP_DIR.tar.gz" -C "$(dirname $BACKUP_DIR)" "$(basename $BACKUP_DIR)"

# Log completion via PowerShell
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Add-Content -Path 'C:\Logs\backup.log' -Value \"$(date): Backup completed\""

echo "Backup complete!"
```

### Example 3: Process Monitor

```bash
#!/bin/bash
# monitor-processes.sh - Monitor Windows processes for suspicious activity

while true; do
    # Get processes using high CPU
    high_cpu=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
        -Command "Get-Process | Where-Object {\$_.CPU -gt 50} | Select-Object Name, CPU, Id | ConvertTo-Json")

    # Check if any found
    if [ -n "$high_cpu" ] && [ "$high_cpu" != "null" ]; then
        echo "[ALERT] High CPU processes detected:"
        echo "$high_cpu" | jq -r '.[] | "\(.Name) - CPU: \(.CPU)s (PID: \(.Id))"'

        # Log to Windows Event Log
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
            -Command "Write-EventLog -LogName Application -Source 'Process Monitor' -EventId 1001 -Message 'High CPU usage detected'"
    fi

    sleep 60
done
```

### Example 4: Integrated Git Workflow

```bash
#!/bin/bash
# git-commit-enhanced.sh - Enhanced git commit with Windows integration

# Stage files
git add .

# Get commit message
read -p "Commit message: " message

# Commit
git commit -m "$message"

# Push
git push

# Notify via Windows notification
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Git push completed!', 'Success')"

# Log to Windows
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -Command "Add-Content -Path 'C:\Logs\git-operations.log' -Value \"$(date): Committed and pushed: $message\""
```

---

## Best Practices Summary

### DO ✅

1. **Use absolute paths** everywhere
2. **Always chmod new files** immediately after creation
3. **Use wrapper scripts** for frequently used commands
4. **Test commands incrementally** before building complex scripts
5. **Use Windows paths** inside PowerShell commands
6. **Escape special characters** (`$`, `<`, `>`, `|`) when using `-Command`
7. **Prefer `-File`** over `-Command` for scripts
8. **Document your wrappers** so others understand what they do

### DON'T ❌

1. **Don't mix path styles** (WSL and Windows) in same command
2. **Don't forget chmod** or scripts won't execute
3. **Don't use admin rights** unless necessary
4. **Don't hardcode paths** - use variables when possible
5. **Don't ignore errors** - always check exit codes
6. **Don't create huge inline commands** - use script files instead
7. **Don't commit without testing** from both WSL and PowerShell

### Quick Reference Card

```bash
# The Universal Command
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile -ExecutionPolicy Bypass -File "C:\Path\Script.ps1"

# Fix permissions
sudo chmod +x /mnt/c/path/to/file.ps1

# Access Windows from WSL
ls /mnt/c/Users/MYCOM/Desktop

# Access WSL from Windows
\\wsl$\Ubuntu\home\username\file.txt

# Escape variables in commands
\$_.Property
```

---

**Last Updated:** 2025-01-24
**Maintained by:** CheckComputer Project
**For issues:** See TROUBLESHOOTING.md or CLAUDE.md
