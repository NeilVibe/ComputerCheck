# D Drive Handles/Locks Checker
# Finds what's actively using/accessing D drive

Write-Host "`n=== D DRIVE ACTIVE USAGE CHECK ===`n" -ForegroundColor Cyan

# 1. Check what processes have D drive as current directory
Write-Host "[1] Processes with D Drive as Working Directory:" -ForegroundColor Yellow
$dWorkingDir = Get-Process | Where-Object {
    try { $_.Path -ne $null -and (Get-Location -ErrorAction SilentlyContinue).Path -like "D:*" } catch { $false }
}
if ($dWorkingDir) {
    $dWorkingDir | Select-Object Name, Id, Path | Format-Table -AutoSize
} else {
    Write-Host "   None found" -ForegroundColor Green
}

# 2. Check if Explorer has D drive open
Write-Host "`n[2] Explorer Windows Open on D Drive:" -ForegroundColor Yellow
$shell = New-Object -ComObject Shell.Application
$explorerWindows = $shell.Windows() | Where-Object { $_.LocationURL -like "*D:*" }
if ($explorerWindows) {
    $explorerWindows | Select-Object LocationURL | Format-Table -AutoSize
    Write-Host "   ACTION NEEDED: Close these Explorer windows!" -ForegroundColor Red
} else {
    Write-Host "   No Explorer windows on D drive" -ForegroundColor Green
}

# 3. Check User Shell Folders pointing to D drive
Write-Host "`n[3] User Folders Pointing to D Drive:" -ForegroundColor Yellow
$userFolders = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue
$dUserFolders = @()
$userFolders.PSObject.Properties | Where-Object { $_.Value -like "*D:*" } | ForEach-Object {
    $dUserFolders += [PSCustomObject]@{
        FolderName = $_.Name
        Path = $_.Value
    }
}
if ($dUserFolders) {
    $dUserFolders | Format-Table -AutoSize
    Write-Host "   ACTION NEEDED: Move these folders to C drive!" -ForegroundColor Red
} else {
    Write-Host "   No user folders on D drive" -ForegroundColor Green
}

# 4. Check if D drive is mapped or has drive letter conflicts
Write-Host "`n[4] D Drive Info:" -ForegroundColor Yellow
$dDrive = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
if ($dDrive) {
    Write-Host "   Drive Label: $($dDrive.FileSystemLabel)"
    Write-Host "   File System: $($dDrive.FileSystem)"
    Write-Host "   Health Status: $($dDrive.HealthStatus)"
    Write-Host "   Operational Status: $($dDrive.OperationalStatus)"
}

# 5. Check if any applications have D drive in their settings/recent files
Write-Host "`n[5] Programs That May Reference D Drive:" -ForegroundColor Yellow
Write-Host "   Checking common applications..." -ForegroundColor Gray

# Check if current user's temp/cache uses D drive
$tempPath = [System.IO.Path]::GetTempPath()
if ($tempPath -like "D:*") {
    Write-Host "   WARNING: TEMP folder is on D drive: $tempPath" -ForegroundColor Red
    Write-Host "   ACTION: Move TEMP to C drive before formatting!" -ForegroundColor Red
}

# 6. Check for open file handles (requires admin)
Write-Host "`n[6] Checking Open File Handles (requires admin):" -ForegroundColor Yellow
try {
    $openFiles = Get-SmbOpenFile -ErrorAction Stop | Where-Object { $_.Path -like "D:*" }
    if ($openFiles) {
        $openFiles | Select-Object ClientUserName, Path | Format-Table -AutoSize
        Write-Host "   ACTION NEEDED: Close these files!" -ForegroundColor Red
    } else {
        Write-Host "   No SMB open files on D drive" -ForegroundColor Green
    }
} catch {
    Write-Host "   (Run as admin to check SMB file handles)" -ForegroundColor Gray
}

# 7. Check page file
Write-Host "`n[7] Page File Check:" -ForegroundColor Yellow
$pageFile = Get-WmiObject Win32_PageFileUsage | Where-Object { $_.Name -like "D:*" }
if ($pageFile) {
    Write-Host "   WARNING: Page file is on D drive!" -ForegroundColor Red
    Write-Host "   Path: $($pageFile.Name)" -ForegroundColor Red
    Write-Host "   ACTION: Move page file to C drive before formatting!" -ForegroundColor Red
} else {
    Write-Host "   No page file on D drive" -ForegroundColor Green
}

Write-Host "`n=== QUICK FIXES ===" -ForegroundColor Cyan
Write-Host "1. Close ALL File Explorer windows"
Write-Host "2. Close any programs that might have files open from D drive"
Write-Host "3. Open Disk Management and make sure D drive shows as 'Healthy'"
Write-Host "4. Try formatting again from Disk Management instead of Explorer"
Write-Host "`nIf still blocked, reboot and try immediately after login.`n"
