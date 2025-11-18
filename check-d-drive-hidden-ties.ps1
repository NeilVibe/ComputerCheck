# D Drive Hidden Ties Checker
# Checks for hidden Windows features that can lock a drive

Write-Host "`n=== D DRIVE HIDDEN TIES CHECK ===`n" -ForegroundColor Cyan

# 1. Check if Windows Search is indexing D drive
Write-Host "[1] Windows Search Indexing:" -ForegroundColor Yellow
try {
    $searchService = Get-Service -Name "WSearch" -ErrorAction Stop
    Write-Host "   Search Service Status: $($searchService.Status)"

    # Check indexed locations
    Write-Host "`n   Checking if D drive is indexed..."
    $indexed = Get-ChildItem "D:\" -ErrorAction SilentlyContinue -Force
    if ($indexed) {
        Write-Host "   D drive is accessible to indexing" -ForegroundColor Yellow
        Write-Host "   ACTION: Stop Windows Search service before formatting" -ForegroundColor Red
        Write-Host "   Command: Stop-Service -Name WSearch -Force" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   Search service check failed: $($_.Exception.Message)"
}

# 2. Check System Restore Points on D drive
Write-Host "`n[2] System Restore Points:" -ForegroundColor Yellow
try {
    $restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
    Write-Host "   Total Restore Points: $($restorePoints.Count)"

    # Check if System Protection is enabled on D
    $vol = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -eq "D:" }
    if ($vol) {
        Write-Host "   System Protection might be enabled on D drive"
        Write-Host "   ACTION: Disable System Protection on D drive" -ForegroundColor Red
        Write-Host "   Go to: Control Panel > System > System Protection > Select D: > Configure > Disable" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   No restore point issues detected"
}

# 3. Check BitLocker Encryption
Write-Host "`n[3] BitLocker Status:" -ForegroundColor Yellow
try {
    $bitlocker = Get-BitLockerVolume -MountPoint "D:" -ErrorAction Stop
    if ($bitlocker.ProtectionStatus -eq "On") {
        Write-Host "   WARNING: D drive is BitLocker encrypted!" -ForegroundColor Red
        Write-Host "   Protection Status: $($bitlocker.ProtectionStatus)"
        Write-Host "   Encryption Percentage: $($bitlocker.EncryptionPercentage)%"
        Write-Host "   ACTION: Disable BitLocker before formatting!" -ForegroundColor Red
        Write-Host "   Command: Disable-BitLocker -MountPoint D:" -ForegroundColor Cyan
    } else {
        Write-Host "   BitLocker not enabled on D drive" -ForegroundColor Green
    }
} catch {
    Write-Host "   BitLocker not enabled on D drive" -ForegroundColor Green
}

# 4. Check if D drive is part of Storage Spaces
Write-Host "`n[4] Storage Spaces:" -ForegroundColor Yellow
try {
    $storagePools = Get-StoragePool -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -ne "Primordial" }
    if ($storagePools) {
        Write-Host "   Storage pools detected - checking if D is part of one..."
        foreach ($pool in $storagePools) {
            $physicalDisks = Get-PhysicalDisk -StoragePool $pool
            Write-Host "   Pool: $($pool.FriendlyName) - Disks: $($physicalDisks.Count)"
        }
        Write-Host "   If D is in a storage pool, remove it first!" -ForegroundColor Yellow
    } else {
        Write-Host "   No storage pools using D drive" -ForegroundColor Green
    }
} catch {
    Write-Host "   No storage pool issues" -ForegroundColor Green
}

# 5. Check Windows Defender Scanning
Write-Host "`n[5] Windows Defender:" -ForegroundColor Yellow
$defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($defender) {
    if ($defender.RealTimeProtectionEnabled) {
        Write-Host "   Real-time protection is ON"
        if ($defender.AntivirusEnabled) {
            Write-Host "   Defender might be scanning D drive"
            Write-Host "   ACTION: Temporarily disable real-time protection" -ForegroundColor Yellow
            Write-Host "   Or wait for any active scan to complete" -ForegroundColor Yellow
        }
    }
}

# 6. Check for Shadow Copies (Volume Snapshots)
Write-Host "`n[6] Shadow Copies (Volume Snapshots):" -ForegroundColor Yellow
try {
    $shadowCopies = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.VolumeName -like "*D:*" }
    if ($shadowCopies) {
        Write-Host "   WARNING: $($shadowCopies.Count) shadow copies found on D drive!" -ForegroundColor Red
        Write-Host "   ACTION: Delete shadow copies before formatting" -ForegroundColor Red
        Write-Host "   Command: vssadmin delete shadows /for=D: /all" -ForegroundColor Cyan
    } else {
        Write-Host "   No shadow copies on D drive" -ForegroundColor Green
    }
} catch {
    Write-Host "   No shadow copy issues" -ForegroundColor Green
}

# 7. Check Recycle Bin
Write-Host "`n[7] Recycle Bin:" -ForegroundColor Yellow
$recycleBin = "D:\`$Recycle.Bin"
if (Test-Path $recycleBin) {
    $items = Get-ChildItem $recycleBin -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object
    if ($items.Count -gt 0) {
        Write-Host "   Recycle Bin has $($items.Count) items on D drive" -ForegroundColor Yellow
        Write-Host "   ACTION: Empty Recycle Bin first!" -ForegroundColor Red
        Write-Host "   Right-click Recycle Bin > Empty Recycle Bin" -ForegroundColor Cyan
    } else {
        Write-Host "   Recycle Bin is empty" -ForegroundColor Green
    }
} else {
    Write-Host "   No Recycle Bin on D drive" -ForegroundColor Green
}

# 8. Check antivirus/security software
Write-Host "`n[8] Security Software:" -ForegroundColor Yellow
$securityProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct -ErrorAction SilentlyContinue
if ($securityProducts) {
    Write-Host "   Security products detected:"
    $securityProducts | ForEach-Object {
        Write-Host "   - $($_.displayName)"
    }
    Write-Host "   If formatting fails, temporarily disable antivirus" -ForegroundColor Yellow
}

Write-Host "`n=== RECOMMENDED ACTIONS ===" -ForegroundColor Cyan
Write-Host "1. Empty Recycle Bin completely"
Write-Host "2. Stop Windows Search: Stop-Service -Name WSearch -Force"
Write-Host "3. Delete shadow copies: vssadmin delete shadows /for=D: /all"
Write-Host "4. Disable System Protection on D drive (System Properties)"
Write-Host "5. Close ALL programs and try formatting from Disk Management"
Write-Host "6. If still fails: Reboot and format immediately after login"
Write-Host "`n"
