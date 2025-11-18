# Restore Windows 10 Classic Context Menu in Windows 11
# This script modifies the registry to bring back the full right-click menu

param(
    [Parameter(Position=0)]
    [ValidateSet("Restore", "Revert", "Status")]
    [string]$Action = "Status"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows 10 Context Menu Restorer     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "How to run as admin:" -ForegroundColor Cyan
    Write-Host "1. Press Win + X" -ForegroundColor White
    Write-Host "2. Select 'Windows Terminal (Admin)' or 'PowerShell (Admin)'" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    exit 1
}

# Registry path for context menu control
$registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

function Get-ContextMenuStatus {
    if (Test-Path $registryPath) {
        $value = Get-ItemProperty -Path $registryPath -Name "(Default)" -ErrorAction SilentlyContinue
        if ($value -and $value."(Default)" -eq "") {
            return "Windows10"
        }
    }
    return "Windows11"
}

function Show-Status {
    $currentStatus = Get-ContextMenuStatus

    Write-Host "Current Status:" -ForegroundColor Yellow
    Write-Host "──────────────────────────────────────" -ForegroundColor Gray

    if ($currentStatus -eq "Windows10") {
        Write-Host "  ✓ Using Windows 10 Classic Context Menu" -ForegroundColor Green
        Write-Host "    (Full menu with all options visible)" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ Using Windows 11 Simplified Context Menu" -ForegroundColor Red
        Write-Host "    (Options hidden behind 'Show more options')" -ForegroundColor Gray
    }

    Write-Host ""

    # Check Windows version
    $winVersion = [System.Environment]::OSVersion.Version
    Write-Host "Windows Version: $($winVersion.Major).$($winVersion.Minor) Build $($winVersion.Build)" -ForegroundColor Cyan

    if ($winVersion.Build -ge 26100) {
        Write-Host "⚠ Warning: Windows 11 24H2 detected" -ForegroundColor Yellow
        Write-Host "  Registry fix may not work on latest builds" -ForegroundColor Gray
        Write-Host "  Consider using Shift+Right-Click as alternative" -ForegroundColor Gray
    }

    Write-Host ""
}

function Restore-Windows10Menu {
    Write-Host "Restoring Windows 10 Classic Context Menu..." -ForegroundColor Yellow
    Write-Host ""

    try {
        # Create the registry key path if it doesn't exist
        $parentPath = Split-Path $registryPath -Parent
        if (-not (Test-Path $parentPath)) {
            Write-Host "  Creating registry path..." -ForegroundColor Cyan
            New-Item -Path $parentPath -Force | Out-Null
        }

        # Create/set the key with empty value
        if (-not (Test-Path $registryPath)) {
            Write-Host "  Creating InprocServer32 key..." -ForegroundColor Cyan
            New-Item -Path $registryPath -Force | Out-Null
        }

        # Set default value to empty string (this is the magic!)
        Write-Host "  Setting registry value..." -ForegroundColor Cyan
        New-ItemProperty -Path $registryPath -Name "(Default)" -Value "" -PropertyType String -Force | Out-Null

        Write-Host ""
        Write-Host "✓ Registry modified successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Yellow
        Write-Host "  1. Restart File Explorer (or reboot)" -ForegroundColor White
        Write-Host "  2. Right-click any file to test" -ForegroundColor White
        Write-Host ""

        $restart = Read-Host "Restart File Explorer now? (yes/no)"
        if ($restart -eq "yes" -or $restart -eq "y") {
            Write-Host ""
            Write-Host "Restarting File Explorer..." -ForegroundColor Cyan
            Stop-Process -Name "explorer" -Force
            Start-Sleep -Seconds 2
            Start-Process "explorer.exe"
            Write-Host "✓ File Explorer restarted!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Try right-clicking a file now - you should see the full menu!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "Please restart File Explorer or reboot to apply changes" -ForegroundColor Yellow
        }

    } catch {
        Write-Host ""
        Write-Host "✗ Error modifying registry: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible reasons:" -ForegroundColor Yellow
        Write-Host "  - Not running as Administrator" -ForegroundColor White
        Write-Host "  - Windows 11 24H2 (method deprecated)" -ForegroundColor White
        Write-Host "  - Registry permissions issue" -ForegroundColor White
        exit 1
    }
}

function Revert-Windows11Menu {
    Write-Host "Reverting to Windows 11 Context Menu..." -ForegroundColor Yellow
    Write-Host ""

    if (-not (Test-Path $registryPath)) {
        Write-Host "✓ Already using Windows 11 menu (nothing to revert)" -ForegroundColor Green
        return
    }

    try {
        Write-Host "  Removing registry key..." -ForegroundColor Cyan
        Remove-Item -Path $registryPath -Recurse -Force -ErrorAction Stop

        Write-Host ""
        Write-Host "✓ Registry key removed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Yellow
        Write-Host "  1. Restart File Explorer (or reboot)" -ForegroundColor White
        Write-Host "  2. Right-click any file to test" -ForegroundColor White
        Write-Host ""

        $restart = Read-Host "Restart File Explorer now? (yes/no)"
        if ($restart -eq "yes" -or $restart -eq "y") {
            Write-Host ""
            Write-Host "Restarting File Explorer..." -ForegroundColor Cyan
            Stop-Process -Name "explorer" -Force
            Start-Sleep -Seconds 2
            Start-Process "explorer.exe"
            Write-Host "✓ File Explorer restarted!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Windows 11 simplified menu has been restored" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "Please restart File Explorer or reboot to apply changes" -ForegroundColor Yellow
        }

    } catch {
        Write-Host ""
        Write-Host "✗ Error removing registry key: $_" -ForegroundColor Red
        exit 1
    }
}

# Main execution
switch ($Action) {
    "Status" {
        Show-Status
        Write-Host "Usage:" -ForegroundColor Cyan
        Write-Host "  .\restore-windows10-context-menu.ps1 Restore  - Enable Windows 10 menu" -ForegroundColor White
        Write-Host "  .\restore-windows10-context-menu.ps1 Revert   - Go back to Windows 11 menu" -ForegroundColor White
        Write-Host "  .\restore-windows10-context-menu.ps1 Status   - Check current status" -ForegroundColor White
        Write-Host ""
    }

    "Restore" {
        Show-Status
        Write-Host ""
        Write-Host "This will modify the registry to restore Windows 10 context menu" -ForegroundColor Yellow
        Write-Host "Registry path: $registryPath" -ForegroundColor Gray
        Write-Host ""

        $confirm = Read-Host "Continue? (yes/no)"
        if ($confirm -eq "yes" -or $confirm -eq "y") {
            Restore-Windows10Menu
        } else {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
        }
    }

    "Revert" {
        Show-Status
        Write-Host ""
        Write-Host "This will remove the registry modification and restore Windows 11 menu" -ForegroundColor Yellow
        Write-Host ""

        $confirm = Read-Host "Continue? (yes/no)"
        if ($confirm -eq "yes" -or $confirm -eq "y") {
            Revert-Windows11Menu
        } else {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "         Operation Complete            " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Alternative methods reminder
Write-Host "Alternative Methods (if registry fix doesn't work):" -ForegroundColor Cyan
Write-Host "  1. Press Shift + Right-Click for full menu (temporary)" -ForegroundColor White
Write-Host "  2. Use ExplorerPatcher (third-party tool)" -ForegroundColor White
Write-Host "     Download: https://github.com/valinet/ExplorerPatcher" -ForegroundColor Gray
Write-Host ""
