# PowerShell from WSL - Lessons Learned

## Key Syntax Issues We Encountered

### 1. **Redirection Operator Error**
```bash
# ❌ WRONG - Causes "< /dev/null" error
"/mnt/c/Program Files/gsudo/Current/gsudo.exe" powershell -Command "Get-Process | Where-Object {$_.Name -like '*test*'}"

# ✅ CORRECT - Escape the $ signs
"/mnt/c/Program Files/gsudo/Current/gsudo.exe" powershell -Command "Get-Process | Where-Object {\$_.Name -like '*test*'}"
```

### 2. **Path Variables in Strings**
```powershell
# ❌ WRONG - Variable reference error with drive
Write-Host "Found at $path:" 

# ✅ CORRECT - Use ${} for variables with special chars
Write-Host "Found at ${path}:"
```

### 3. **Complex Commands from WSL**
```bash
# ❌ WRONG - Inline complex commands often fail
gsudo powershell -Command "complex | pipeline | commands"

# ✅ CORRECT - Write to script file first
echo 'complex | pipeline | commands' > script.ps1
gsudo powershell -ExecutionPolicy Bypass -File "script.ps1"
```

## Best Practices Discovered

1. **Always use script files for complex operations**
2. **Escape $ signs when passing PowerShell commands through bash**
3. **Use full paths for gsudo**
4. **Add -NoProfile to avoid profile script errors**
5. **Use -ExecutionPolicy Bypass for script execution**

## Performance Lessons

1. **Avoid recursive searches on C:\ root** - Takes forever
2. **Use targeted searches with specific paths**
3. **Filter early in the pipeline to reduce processing**
4. **Use -ErrorAction SilentlyContinue for cleaner output**

## Security Scanning Insights

1. **Check exact process names** to avoid false positives
2. **Legitimate software can have similar names** (e.g., Kingston RAM vs Kings Online Security)
3. **Always verify file paths and digital signatures**
4. **Windows has legitimate tasks with suspicious-sounding names**