# Release D Drive - Remove all Windows ties
# Run this before formatting D drive

Write-Host "`n=== RELEASING D DRIVE ===`n" -ForegroundColor Cyan

# 1. Empty Recycle Bin
Write-Host "[1] Emptying Recycle Bin on D drive..." -ForegroundColor Yellow
try {
    Clear-RecycleBin -DriveLetter D -Force -ErrorAction Stop
    Write-Host "   ✓ Recycle Bin emptied" -ForegroundColor Green
} catch {
    Write-Host "   ! Could not empty recycle bin: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Try manually: Right-click Recycle Bin > Empty" -ForegroundColor Yellow
}

# 2. Stop Windows Search Service
Write-Host "`n[2] Stopping Windows Search Service..." -ForegroundColor Yellow
try {
    Stop-Service -Name "WSearch" -Force -ErrorAction Stop
    Write-Host "   ✓ Windows Search stopped" -ForegroundColor Green
    Write-Host "   (It will restart automatically later)" -ForegroundColor Gray
} catch {
    Write-Host "   ! Could not stop search: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Delete shadow copies from D drive
Write-Host "`n[3] Deleting shadow copies..." -ForegroundColor Yellow
try {
    $result = vssadmin delete shadows /for=D: /all /quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Shadow copies deleted" -ForegroundColor Green
    } else {
        Write-Host "   No shadow copies to delete" -ForegroundColor Gray
    }
} catch {
    Write-Host "   No shadow copies found" -ForegroundColor Gray
}

# 4. Disable System Protection on D drive
Write-Host "`n[4] Disabling System Protection on D drive..." -ForegroundColor Yellow
try {
    Disable-ComputerRestore -Drive "D:\" -ErrorAction Stop
    Write-Host "   ✓ System Protection disabled on D drive" -ForegroundColor Green
} catch {
    Write-Host "   System Protection was not enabled or could not disable" -ForegroundColor Gray
}

# 5. Check final status
Write-Host "`n[5] Final Status Check..." -ForegroundColor Yellow
$searchService = Get-Service -Name "WSearch"
Write-Host "   Windows Search: $($searchService.Status)"

$recycleBin = Get-ChildItem "D:\`$Recycle.Bin" -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object
Write-Host "   Recycle Bin items: $($recycleBin.Count)"

Write-Host "`n=== D DRIVE RELEASED ===`n" -ForegroundColor Green
Write-Host "Now try formatting D drive from:" -ForegroundColor Cyan
Write-Host "1. Disk Management (diskmgmt.msc)" -ForegroundColor White
Write-Host "2. Right-click D drive > Format" -ForegroundColor White
Write-Host "`nIf still fails, reboot and try immediately after login.`n" -ForegroundColor Yellow
