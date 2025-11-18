# PowerShell Administrator Rights & Registry Manipulation Guide

**Complete guide to using PowerShell with full admin privileges and manipulating Windows Registry safely**

Last Updated: 2025-01-26

---

## Table of Contents

1. [Understanding Administrator Privileges](#understanding-administrator-privileges)
2. [Getting Admin Rights](#getting-admin-rights)
3. [Registry Operations with Full Power](#registry-operations-with-full-power)
4. [Service Management](#service-management)
5. [System-Level Operations](#system-level-operations)
6. [WSL to Windows Admin Operations](#wsl-to-windows-admin-operations)
7. [Safety Guidelines](#safety-guidelines)
8. [Practical Examples](#practical-examples)
9. [Troubleshooting](#troubleshooting)

---

## Understanding Administrator Privileges

### What is Administrator Mode?

Windows has two permission levels:
- **Standard User**: Can read most files, run programs, modify user-level settings
- **Administrator**: Can modify system files, install software, change security settings, modify registry HKLM

### What Requires Admin Rights?

✅ **Works WITHOUT Admin:**
- Read registry (HKCU, some HKLM paths)
- Read event logs (Application, System - limited)
- Monitor processes and memory
- File system reads
- Query services

🔒 **Requires Admin:**
- Modify registry (HKLM)
- Start/stop services
- Read Security event log
- Modify system files
- Shadow copy management
- System Protection settings
- Recycle bin management (on other drives)
- Port forwarding configuration

### How to Check if You Have Admin Rights

**Method 1: PowerShell Script**
```powershell
# Check admin status
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($isAdmin) {
    Write-Host "✓ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "✗ Not running as Administrator" -ForegroundColor Red
}
```

**Method 2: Use Project Tool**
```bash
# From WSL
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\MYCOM\Desktop\CheckComputer\categories\utilities\test-admin.ps1"
```

**Method 3: Window Title**
- Admin PowerShell shows: `Administrator: Windows PowerShell`
- Normal PowerShell shows: `Windows PowerShell`

---

## Getting Admin Rights

### Method 1: Right-Click → Run as Administrator (Recommended)

**For Windows 11:**
1. Press `Win + X` or right-click Start menu
2. Select "Windows Terminal (Admin)" or "PowerShell (Admin)"
3. Click "Yes" on UAC prompt

**For Windows 10:**
1. Press `Win + X`
2. Select "Windows PowerShell (Admin)"
3. Click "Yes" on UAC prompt

### Method 2: Start-Process with Verb RunAs

**From normal PowerShell to elevated:**
```powershell
# Elevate current script
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs

# Elevate specific script
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"C:\Path\To\Script.ps1`"" -Verb RunAs

# Elevate with parameters
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"C:\Path\Script.ps1`" -Param1 Value1" -Verb RunAs
```

**What happens:**
- UAC dialog appears
- User must click "Yes"
- New PowerShell window opens with admin rights
- Original window continues running (if not closed)

### Method 3: From WSL with UAC Elevation

```bash
# Trigger UAC prompt from WSL
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\release-d-drive.ps1'"
```

### Method 4: #Requires Statement (Script Self-Check)

**Add to top of your script:**
```powershell
#Requires -RunAsAdministrator

# Script will refuse to run if not admin
# User must manually run as admin
```

**Note:** This project intentionally does NOT use this approach - scripts check but don't force elevation.

---

## Registry Operations with Full Power

### Understanding Registry Structure

```
Registry Root Keys:
├── HKEY_LOCAL_MACHINE (HKLM)   - System-wide settings (REQUIRES ADMIN to modify)
├── HKEY_CURRENT_USER (HKCU)    - Current user settings (NO ADMIN needed)
├── HKEY_CLASSES_ROOT (HKCR)    - File associations (ADMIN for system changes)
├── HKEY_USERS (HKU)             - All user profiles (REQUIRES ADMIN)
└── HKEY_CURRENT_CONFIG (HKCC)  - Hardware profiles (REQUIRES ADMIN)
```

### Critical Registry Locations Monitored by This Project

```powershell
# SYSTEM STARTUP (REQUIRES ADMIN for write)
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"

# USER STARTUP (NO ADMIN needed)
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"

# SYSTEM SERVICES (REQUIRES ADMIN)
"HKLM:\SYSTEM\CurrentControlSet\Services"

# SECURITY-CRITICAL (REQUIRES ADMIN)
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# SOFTWARE UNINSTALL INFO (READ: no admin, WRITE: admin)
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
```

### Reading Registry (No Admin Usually Needed)

**Pattern 1: Simple Read**
```powershell
# Check if path exists
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run") {
    # Read all properties
    $entries = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue

    # Display all entries
    $entries.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
        Write-Host "$($_.Name) = $($_.Value)"
    }
}
```

**Pattern 2: Read Specific Value**
```powershell
# Get specific registry value
$shellValue = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -ErrorAction SilentlyContinue

if ($shellValue) {
    Write-Host "Windows Shell: $($shellValue.Shell)"

    # Check if it's been modified
    if ($shellValue.Shell -ne "explorer.exe") {
        Write-Host "[CRITICAL] Shell has been modified!" -ForegroundColor Red
    }
}
```

**Pattern 3: Enumerate Registry Keys**
```powershell
# List all subkeys
$uninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$subKeys = Get-ChildItem $uninstallPath -ErrorAction SilentlyContinue

foreach ($key in $subKeys) {
    $props = Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue

    if ($props.DisplayName) {
        Write-Host "Installed: $($props.DisplayName) - Version: $($props.DisplayVersion)"
    }
}
```

### Writing Registry (REQUIRES ADMIN for HKLM)

**Pattern 1: Create New Key**
```powershell
# Create new registry key
$keyPath = "HKLM:\SOFTWARE\MyApplication"

if (-not (Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force | Out-Null
    Write-Host "✓ Registry key created" -ForegroundColor Green
}
```

**Pattern 2: Set Registry Value**
```powershell
# Create or update registry value
$keyPath = "HKLM:\SOFTWARE\MyApplication"
$valueName = "InstallPath"
$valueData = "C:\Program Files\MyApp"

# Create new property
New-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PropertyType String -Force | Out-Null
Write-Host "✓ Registry value set: $valueName = $valueData" -ForegroundColor Green

# Or modify existing
Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
```

**Pattern 3: Remove Startup Entry (Common Security Task)**
```powershell
# Remove malware from startup (REQUIRES ADMIN for HKLM)
$startupPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$malwareName = "SuspiciousProgram"

try {
    Remove-ItemProperty -Path $startupPath -Name $malwareName -ErrorAction Stop
    Write-Host "✓ Removed startup entry: $malwareName" -ForegroundColor Green
} catch {
    Write-Host "✗ Could not remove entry: $_" -ForegroundColor Red
}

# Remove from user startup (NO ADMIN needed)
$userStartupPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Remove-ItemProperty -Path $userStartupPath -Name $malwareName -ErrorAction SilentlyContinue
```

**Pattern 4: Remove Entire Key**
```powershell
# Remove entire registry key and all subkeys
$keyPath = "HKLM:\SOFTWARE\UnwantedSoftware"

if (Test-Path $keyPath) {
    Remove-Item -Path $keyPath -Recurse -Force -ErrorAction Stop
    Write-Host "✓ Registry key removed completely" -ForegroundColor Green
}
```

### Registry Safety Pattern (Used in This Project)

```powershell
# ALWAYS use error handling
if (Test-Path $registryPath) {
    try {
        # Attempt operation
        $result = Get-ItemProperty $registryPath -ErrorAction Stop

        # Process result
        Write-Host "✓ Success" -ForegroundColor Green
    } catch {
        # Handle failure gracefully
        Write-Host "! Warning: Could not access $registryPath" -ForegroundColor Yellow
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray

        # Continue execution (don't crash)
    }
} else {
    Write-Host "! Registry path does not exist: $registryPath" -ForegroundColor Yellow
}
```

### Real Example from This Project

**From: `categories/security/registry-comprehensive-audit.ps1`**
```powershell
function Analyze-SecuritySettings {
    # Check Windows logon settings (CRITICAL SECURITY CHECK)
    $winlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    if (Test-Path $winlogonPath) {
        try {
            $winlogon = Get-ItemProperty $winlogonPath -ErrorAction SilentlyContinue

            # Check if Shell has been modified (malware indicator)
            if ($winlogon -and $winlogon.PSObject.Properties.Name -contains "Shell") {
                if ($winlogon.Shell -ne "explorer.exe") {
                    Write-Host "  [CRITICAL] Windows Shell modified: $($winlogon.Shell)" -ForegroundColor Red
                    # This is a major red flag for rootkit/malware
                } else {
                    Write-Host "  [OK] Windows Shell: explorer.exe" -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "  Warning: Could not check Winlogon settings" -ForegroundColor Yellow
        }
    }
}
```

---

## Service Management

### Service Operations (REQUIRES ADMIN)

**Get Service Status (No Admin)**
```powershell
# Query service status (works without admin)
Get-Service -Name "WSearch" | Select-Object Name, Status, StartType

# List all running services
Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object Name, DisplayName
```

**Stop Service (REQUIRES ADMIN)**
```powershell
# Stop service forcefully
try {
    Stop-Service -Name "WSearch" -Force -ErrorAction Stop
    Write-Host "✓ Windows Search stopped" -ForegroundColor Green
} catch {
    Write-Host "✗ Could not stop service: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Reason: Requires Administrator privileges" -ForegroundColor Yellow
}
```

**Start Service (REQUIRES ADMIN)**
```powershell
# Start service
Start-Service -Name "WSearch" -ErrorAction Stop
```

**Change Service Startup Type (REQUIRES ADMIN)**
```powershell
# Disable service
Set-Service -Name "WSearch" -StartupType Disabled

# Set to Manual
Set-Service -Name "WSearch" -StartupType Manual

# Set to Automatic
Set-Service -Name "WSearch" -StartupType Automatic
```

**Real Example from This Project:**

**From: `release-d-drive.ps1:17-24`**
```powershell
# Stop Windows Search before formatting drive
Write-Host "[2] Stopping Windows Search Service..." -ForegroundColor Yellow
try {
    Stop-Service -Name "WSearch" -Force -ErrorAction Stop
    Write-Host "   ✓ Windows Search stopped" -ForegroundColor Green
    Write-Host "   (It will restart automatically later)" -ForegroundColor Gray
} catch {
    Write-Host "   ! Could not stop search: $($_.Exception.Message)" -ForegroundColor Red
}
```

---

## System-Level Operations

### Shadow Copy Management (REQUIRES ADMIN)

**List Shadow Copies**
```powershell
# List all shadow copies
vssadmin list shadows
```

**Delete Shadow Copies**
```powershell
# Delete all shadow copies for D: drive
try {
    $result = vssadmin delete shadows /for=D: /all /quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Shadow copies deleted" -ForegroundColor Green
    } else {
        Write-Host "No shadow copies to delete" -ForegroundColor Gray
    }
} catch {
    Write-Host "No shadow copies found" -ForegroundColor Gray
}
```

### System Protection (REQUIRES ADMIN)

**Disable System Restore**
```powershell
# Disable system protection on D: drive
try {
    Disable-ComputerRestore -Drive "D:\" -ErrorAction Stop
    Write-Host "✓ System Protection disabled on D drive" -ForegroundColor Green
} catch {
    Write-Host "System Protection was not enabled or could not disable" -ForegroundColor Gray
}
```

**Enable System Restore**
```powershell
# Enable system protection
Enable-ComputerRestore -Drive "C:\"
```

### Recycle Bin Management (REQUIRES ADMIN for other drives)

**Empty Recycle Bin**
```powershell
# Empty recycle bin on D: drive
try {
    Clear-RecycleBin -DriveLetter D -Force -ErrorAction Stop
    Write-Host "✓ Recycle Bin emptied" -ForegroundColor Green
} catch {
    Write-Host "! Could not empty recycle bin: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Try manually: Right-click Recycle Bin > Empty" -ForegroundColor Yellow
}
```

### Port Forwarding (REQUIRES ADMIN)

**Add Port Forwarding (for WSL SSH)**
```powershell
# Forward port 22 to WSL IP
$wslIP = "172.28.150.120"  # Get from: wsl hostname -I

# Remove old forwarding if exists
netsh interface portproxy delete v4tov4 listenport=22 listenaddress=0.0.0.0

# Add new forwarding
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=$wslIP

Write-Host "✓ Port forwarding configured: 0.0.0.0:22 → $wslIP:22" -ForegroundColor Green
```

**View Port Forwarding**
```powershell
# Show all port forwarding rules
netsh interface portproxy show all
```

---

## WSL to Windows Admin Operations

### Basic Pattern (No Elevation)

```bash
# Run PowerShell script from WSL (uses current user rights)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile \
  -ExecutionPolicy Bypass \
  -File "C:\Users\MYCOM\Desktop\CheckComputer\MegaManager.ps1" security comprehensive
```

### Elevated Pattern (UAC Prompt)

**Method 1: Elevate Script Execution**
```bash
# Trigger UAC elevation from WSL
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile \
  -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\Users\MYCOM\Desktop\CheckComputer\release-d-drive.ps1'"
```

**Method 2: Elevate Direct Command**
```bash
# Elevate single command
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile \
  -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -Command Stop-Service WSearch -Force'"
```

**Method 3: Elevate with Wait (Blocks until complete)**
```bash
# Wait for elevated operation to complete
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile \
  -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -Command Get-Service' -Wait"
```

### Using gsudo (if installed)

**Install gsudo:**
```powershell
# From elevated PowerShell
winget install gsudo
```

**Use from WSL:**
```bash
# Direct elevation (prompts UAC once)
gsudo powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Path\Script.ps1"

# Or with gsudo cached credentials (no repeated prompts)
gsudo cache on
gsudo powershell -Command "Stop-Service WSearch -Force"
gsudo powershell -Command "Clear-RecycleBin -DriveLetter D -Force"
```

---

## Safety Guidelines

### Golden Rules

1. **Always Test in Safe Mode First**
   - Read before you write
   - Query before you modify
   - Backup before you delete

2. **Use Error Handling**
   ```powershell
   try {
       [Risky operation]
   } catch {
       Write-Host "Failed: $_" -ForegroundColor Red
       # Don't continue if critical
       exit 1
   }
   ```

3. **Verify Before Destructive Operations**
   ```powershell
   # Ask for confirmation
   $confirm = Read-Host "Are you sure you want to delete? (yes/no)"
   if ($confirm -ne "yes") {
       Write-Host "Operation cancelled" -ForegroundColor Yellow
       exit 0
   }
   ```

4. **Use -WhatIf When Available**
   ```powershell
   # Dry run - shows what would happen without doing it
   Remove-Item "C:\Path\*" -Recurse -WhatIf
   ```

5. **Export Registry Before Modifying**
   ```powershell
   # Export registry key to .reg file
   reg export "HKLM\SOFTWARE\MyApp" "C:\Backup\MyApp_backup.reg"

   # Or in PowerShell
   $regPath = "HKLM:\SOFTWARE\MyApp"
   $backupFile = "C:\Backup\MyApp_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
   reg export $regPath.Replace(":\", "\") $backupFile
   ```

### High-Risk Operations (Always Backup First)

🔴 **DANGER ZONE:**
- Modifying `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`
- Deleting registry keys under `HKLM:\SYSTEM`
- Stopping critical services (wuauserv, BITS, Winmgmt)
- Disabling Windows Defender
- Modifying boot configuration

✅ **Usually Safe:**
- Reading any registry path
- Adding startup entries (can always remove)
- Stopping user-level services
- Querying system information
- Monitoring processes/events

---

## Practical Examples

### Example 1: Remove Malware from Startup

**Scenario:** Found suspicious "CryptoMiner.exe" in startup

```powershell
# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "ERROR: This operation requires Administrator privileges" -ForegroundColor Red
    Write-Host "Right-click PowerShell → Run as Administrator" -ForegroundColor Yellow
    exit 1
}

# Define malware name
$malwareName = "CryptoMiner"

# Check all startup locations
$startupLocations = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($location in $startupLocations) {
    if (Test-Path $location) {
        $entries = Get-ItemProperty $location -ErrorAction SilentlyContinue

        # Check if malware entry exists
        if ($entries.PSObject.Properties.Name -contains $malwareName) {
            try {
                # Remove it
                Remove-ItemProperty -Path $location -Name $malwareName -ErrorAction Stop
                Write-Host "✓ Removed $malwareName from $location" -ForegroundColor Green
            } catch {
                Write-Host "✗ Failed to remove from $location : $_" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`nCleanup complete. Reboot to ensure malware doesn't start." -ForegroundColor Cyan
```

### Example 2: Safely Release Drive Before Formatting

**Scenario:** Need to format D: drive but Windows has locks on it

```powershell
# This is the release-d-drive.ps1 pattern
Write-Host "=== RELEASING D DRIVE ===" -ForegroundColor Cyan

# Step 1: Empty Recycle Bin
Write-Host "[1] Emptying Recycle Bin..." -ForegroundColor Yellow
try {
    Clear-RecycleBin -DriveLetter D -Force -ErrorAction Stop
    Write-Host "   ✓ Recycle Bin emptied" -ForegroundColor Green
} catch {
    Write-Host "   ! Could not empty: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Stop Windows Search
Write-Host "[2] Stopping Windows Search..." -ForegroundColor Yellow
try {
    Stop-Service -Name "WSearch" -Force -ErrorAction Stop
    Write-Host "   ✓ Windows Search stopped" -ForegroundColor Green
} catch {
    Write-Host "   ! Could not stop: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Delete Shadow Copies
Write-Host "[3] Deleting shadow copies..." -ForegroundColor Yellow
try {
    $result = vssadmin delete shadows /for=D: /all /quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Shadow copies deleted" -ForegroundColor Green
    }
} catch {
    Write-Host "   No shadow copies found" -ForegroundColor Gray
}

# Step 4: Disable System Protection
Write-Host "[4] Disabling System Protection..." -ForegroundColor Yellow
try {
    Disable-ComputerRestore -Drive "D:\" -ErrorAction Stop
    Write-Host "   ✓ System Protection disabled" -ForegroundColor Green
} catch {
    Write-Host "   Not enabled or could not disable" -ForegroundColor Gray
}

Write-Host "`n✓ D drive released. Ready to format!" -ForegroundColor Green
```

### Example 3: Check and Fix USB Storage Policy

**Scenario:** USB drives blocked by policy - need to enable them

```powershell
# Check USB storage policy
$usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR"

if (Test-Path $usbPath) {
    $usbProps = Get-ItemProperty $usbPath -ErrorAction SilentlyContinue

    if ($usbProps.Start -eq 4) {
        Write-Host "USB Storage is DISABLED (Start = 4)" -ForegroundColor Red

        # Ask before changing
        $confirm = Read-Host "Enable USB storage? (yes/no)"

        if ($confirm -eq "yes") {
            # Requires admin
            try {
                Set-ItemProperty -Path $usbPath -Name "Start" -Value 3 -ErrorAction Stop
                Write-Host "✓ USB Storage enabled (Start = 3)" -ForegroundColor Green
                Write-Host "Reboot to apply changes" -ForegroundColor Yellow
            } catch {
                Write-Host "✗ Failed: Requires Administrator privileges" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "USB Storage is enabled (Start = $($usbProps.Start))" -ForegroundColor Green
    }
}
```

### Example 4: Comprehensive System Cleanup

**Scenario:** Clean system before performance optimization

```powershell
#Requires -RunAsAdministrator

Write-Host "=== SYSTEM CLEANUP ===" -ForegroundColor Cyan

# 1. Clean temporary files
Write-Host "[1] Cleaning temporary files..." -ForegroundColor Yellow
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   ✓ Temp files cleaned" -ForegroundColor Green

# 2. Empty all recycle bins
Write-Host "[2] Emptying recycle bins..." -ForegroundColor Yellow
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "   ✓ Recycle bins emptied" -ForegroundColor Green

# 3. Clear Windows Update cache
Write-Host "[3] Clearing Windows Update cache..." -ForegroundColor Yellow
Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
Write-Host "   ✓ Update cache cleared" -ForegroundColor Green

# 4. Run Disk Cleanup (silent mode)
Write-Host "[4] Running Disk Cleanup..." -ForegroundColor Yellow
Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -Wait -NoNewWindow
Write-Host "   ✓ Disk cleanup complete" -ForegroundColor Green

Write-Host "`n✓ System cleanup complete!" -ForegroundColor Green
```

---

## Troubleshooting

### "Access Denied" Errors

**Problem:** Registry or file operation fails with access denied

**Solutions:**
```powershell
# 1. Check if admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
Write-Host "Admin: $isAdmin"

# 2. If not admin, elevate
if (-not $isAdmin) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 3. Check if registry key is protected (may need TrustedInstaller)
# For most operations, Administrator is enough
```

### "Cannot stop service" Errors

**Problem:** Service won't stop even with admin rights

**Solutions:**
```powershell
# 1. Check service dependencies
Get-Service -Name "ServiceName" | Select-Object -ExpandProperty DependentServices

# 2. Force stop with timeout
Stop-Service -Name "ServiceName" -Force -NoWait

# 3. Kill process directly (last resort)
$service = Get-WmiObject -Class Win32_Service -Filter "Name='ServiceName'"
Stop-Process -Id $service.ProcessId -Force
```

### UAC Prompt Not Appearing from WSL

**Problem:** `-Verb RunAs` doesn't show UAC dialog from WSL

**Solutions:**
```bash
# 1. Make sure you're not using -WindowStyle Hidden
# BAD:
Start-Process powershell -Verb RunAs -WindowStyle Hidden  # UAC won't show

# GOOD:
Start-Process powershell -Verb RunAs

# 2. Use gsudo instead (if installed)
gsudo powershell -Command "Your-Command"

# 3. Run from Windows directly
# Open PowerShell as admin from Start menu instead
```

### Registry Changes Not Taking Effect

**Problem:** Modified registry but changes not visible

**Solutions:**
```powershell
# 1. Some changes require reboot
Write-Host "Changes may require system reboot" -ForegroundColor Yellow

# 2. Some changes require process restart
# Example: Explorer restart
Stop-Process -Name "explorer" -Force
Start-Process "explorer.exe"

# 3. Flush registry cache (rare)
# Usually automatic, but can force with reboot
```

### Port Forwarding Not Working

**Problem:** WSL SSH not accessible after configuring port forwarding

**Solutions:**
```powershell
# 1. Check if port forwarding is active
netsh interface portproxy show all

# 2. Remove and re-add (WSL IP may have changed)
$wslIP = (wsl hostname -I).Trim()
netsh interface portproxy delete v4tov4 listenport=22 listenaddress=0.0.0.0
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=$wslIP

# 3. Check Windows Firewall
New-NetFirewallRule -DisplayName "WSL SSH" -Direction Inbound -LocalPort 22 -Protocol TCP -Action Allow

# 4. Verify WSL SSH is running
wsl sudo service ssh status
```

---

## Quick Reference

### Admin Check One-Liner
```powershell
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
```

### Self-Elevate One-Liner
```powershell
if(-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")){Start-Process powershell -ArgumentList"-ExecutionPolicy Bypass -File `"$PSCommandPath`""-Verb RunAs;exit}
```

### Registry Quick Operations
```powershell
# Read
Get-ItemProperty "HKLM:\Path" -Name "ValueName"

# Write
New-ItemProperty "HKLM:\Path" -Name "ValueName" -Value "Data" -PropertyType String -Force

# Delete
Remove-ItemProperty "HKLM:\Path" -Name "ValueName" -Force
```

### Service Quick Operations
```powershell
# Stop
Stop-Service "ServiceName" -Force

# Start
Start-Service "ServiceName"

# Disable
Set-Service "ServiceName" -StartupType Disabled
```

---

## Related Documentation

- [WSL-Windows Integration Guide](./WSL-WINDOWS-INTEGRATION.md) - WSL to Windows patterns
- [SSH-WSL Troubleshooting](./SSH-WSL-TROUBLESHOOTING.md) - SSH and port forwarding
- [Project Structure](./PROJECT_STRUCTURE.md) - Overview of all tools
- [CLAUDE.md](../CLAUDE.md) - Quick reference for common operations

---

**Last Updated:** 2025-01-26
**Version:** 1.0
**Author:** Windows Security Toolkit Project

**Note:** Always test operations in a safe environment first. This guide assumes Windows 10/11 with PowerShell 5.1 or higher.
