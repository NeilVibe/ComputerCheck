# Avoiding Confusion - Clear Guidelines

## The Core Problem
When calling PowerShell from WSL/bash, special characters get interpreted differently, causing:
- Variable expansion issues ($var becomes empty)
- Redirection errors (< /dev/null)
- Quote escaping problems

## The Simple Solution
**ALWAYS write scripts to files first, then execute them!**

## Clear Rules

### Rule 1: Simple Commands from WSL
```bash
# ✅ GOOD - Write to file, then execute
echo 'Get-Process | Where-Object {$_.Name -like "*chrome*"}' > temp.ps1
powershell.exe -ExecutionPolicy Bypass -File temp.ps1

# ❌ BAD - Direct command with complex syntax
powershell.exe -Command "Get-Process | Where-Object {$_.Name -like '*chrome*'}"
```

### Rule 2: For Admin Commands
```bash
# ✅ GOOD - Use gsudo with file
echo 'Get-Service | Format-Table' > temp.ps1
"/mnt/c/Program Files/gsudo/Current/gsudo.exe" powershell -ExecutionPolicy Bypass -File temp.ps1

# ❌ BAD - Complex inline commands
gsudo powershell -Command "complex | pipeline"
```

### Rule 3: Script Organization
```
✅ GOOD Structure:
- main-script.ps1      # The actual PowerShell logic
- run-main.sh         # Simple bash wrapper that calls the .ps1

❌ BAD Structure:
- complex-wrapper.sh  # Trying to build PS commands in bash
- inline-everything.sh # Mixing bash and PS syntax
```

## What Actually Works

### 1. Direct PowerShell Scripts
Create standalone .ps1 files that work perfectly when called directly:
```powershell
# scan-memory.ps1
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10
```

### 2. Simple Bash Wrappers
```bash
#!/bin/bash
# Just call the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "scan-memory.ps1" "$@"
```

### 3. No Variable Interpolation
Never try to build PowerShell commands with bash variables. Instead:
```bash
# ✅ GOOD - Pass as arguments
powershell.exe -File script.ps1 -Target "$1"

# ❌ BAD - Variable interpolation
powershell.exe -Command "Get-Process $1"
```

## Testing Checklist
Before considering a script "done":
1. ✅ Test from PowerShell directly
2. ✅ Test from WSL
3. ✅ Test with admin rights
4. ✅ Test with parameters
5. ✅ Verify no syntax errors