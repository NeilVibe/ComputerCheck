# Universal Drive Checker - Works for ANY drive!
# Usage: .\check-any-drive.ps1 -DriveLetter D
#        .\check-any-drive.ps1 -DriveLetter E
#        .\check-any-drive.ps1 -DriveLetter C

param(
    [Parameter(Mandatory=$false)]
    [string]$DriveLetter = "D",
    [switch]$ShowLocks = $false,
    [switch]$Release = $false
)

$DriveLetter = $DriveLetter.TrimEnd(':').ToUpper()

Write-Host "`n=== UNIVERSAL DRIVE CHECKER - $DriveLetter Drive ===`n" -ForegroundColor Cyan

# 1. Check processes running FROM this drive
Write-Host "[1] Processes Running FROM ${DriveLetter}: Drive:" -ForegroundColor Yellow
$pattern = "${DriveLetter}:*"
$processes = Get-Process | Where-Object { $_.Path -like $pattern } | Select-Object Name, Id, Path
if ($processes) {
    $processes | Format-Table -AutoSize
    Write-Host "   Found $($processes.Count) processes" -ForegroundColor Red
} else {
    Write-Host "   No processes running from ${DriveLetter}: drive" -ForegroundColor Green
}

# 2. Check services installed on this drive
Write-Host "`n[2] Services Installed on ${DriveLetter}: Drive:" -ForegroundColor Yellow
$services = Get-WmiObject Win32_Service | Where-Object { $_.PathName -like "*${DriveLetter}:*" } | Select-Object Name, State, StartMode, PathName
if ($services) {
    $services | Format-Table -AutoSize -Wrap
    Write-Host "   Found $($services.Count) services" -ForegroundColor Red
} else {
    Write-Host "   No services on ${DriveLetter}: drive" -ForegroundColor Green
}

# 3. Check scheduled tasks using this drive
Write-Host "`n[3] Scheduled Tasks Using ${DriveLetter}: Drive:" -ForegroundColor Yellow
$tasks = Get-ScheduledTask | Where-Object {
    $_.Actions.Execute -like "*${DriveLetter}:*" -or $_.Actions.WorkingDirectory -like "*${DriveLetter}:*"
}
if ($tasks) {
    $tasks | Select-Object TaskName, State, @{N='Execute';E={$_.Actions.Execute}} | Format-Table -AutoSize
    Write-Host "   Found $($tasks.Count) tasks" -ForegroundColor Red
} else {
    Write-Host "   No scheduled tasks using ${DriveLetter}: drive" -ForegroundColor Green
}

# 4. Check loaded DLLs/modules from this drive
Write-Host "`n[4] Loaded DLLs/Modules from ${DriveLetter}: Drive:" -ForegroundColor Yellow
$modules = @()
Get-Process | ForEach-Object {
    try {
        $proc = $_
        $_.Modules | Where-Object { $_.FileName -like "${DriveLetter}:*" } | ForEach-Object {
            $modules += [PSCustomObject]@{
                ProcessName = $proc.Name
                ProcessId = $proc.Id
                Module = $_.FileName
            }
        }
    } catch {}
}
if ($modules) {
    $modules | Select-Object -Unique ProcessName, ProcessId, Module | Format-Table -AutoSize -Wrap
    Write-Host "   Found $($modules.Count) loaded modules" -ForegroundColor Red
} else {
    Write-Host "   No DLLs/modules loaded from ${DriveLetter}: drive" -ForegroundColor Green
}

# 5. Check drive space
Write-Host "`n[5] ${DriveLetter}: Drive Space:" -ForegroundColor Yellow
try {
    $drive = Get-PSDrive $DriveLetter -ErrorAction Stop
    $usedGB = [math]::Round($drive.Used / 1GB, 2)
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    $totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
    $percentUsed = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 1)

    Write-Host "   Total: $totalGB GB"
    Write-Host "   Used: $usedGB GB ($percentUsed%)"
    Write-Host "   Free: $freeGB GB"
} catch {
    Write-Host "   Could not access ${DriveLetter}: drive" -ForegroundColor Red
}

# 6. If -ShowLocks, check hidden Windows ties
if ($ShowLocks) {
    Write-Host "`n=== HIDDEN WINDOWS LOCKS ===" -ForegroundColor Cyan

    # Windows Search
    Write-Host "`n[6] Windows Search Indexing:" -ForegroundColor Yellow
    $searchService = Get-Service -Name "WSearch" -ErrorAction SilentlyContinue
    if ($searchService.Status -eq "Running") {
        Write-Host "   Search Service: RUNNING (may be indexing ${DriveLetter}:)" -ForegroundColor Yellow
    } else {
        Write-Host "   Search Service: Stopped" -ForegroundColor Green
    }

    # BitLocker
    Write-Host "`n[7] BitLocker Status:" -ForegroundColor Yellow
    try {
        $bitlocker = Get-BitLockerVolume -MountPoint "${DriveLetter}:" -ErrorAction Stop
        if ($bitlocker.ProtectionStatus -eq "On") {
            Write-Host "   WARNING: BitLocker ENABLED on ${DriveLetter}:" -ForegroundColor Red
            Write-Host "   Encryption: $($bitlocker.EncryptionPercentage)%" -ForegroundColor Red
        } else {
            Write-Host "   BitLocker not enabled" -ForegroundColor Green
        }
    } catch {
        Write-Host "   BitLocker not enabled" -ForegroundColor Green
    }

    # Shadow Copies
    Write-Host "`n[8] Shadow Copies:" -ForegroundColor Yellow
    $shadowCopies = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.VolumeName -like "*${DriveLetter}:*" }
    if ($shadowCopies) {
        Write-Host "   WARNING: $($shadowCopies.Count) shadow copies on ${DriveLetter}:" -ForegroundColor Red
    } else {
        Write-Host "   No shadow copies" -ForegroundColor Green
    }

    # Recycle Bin
    Write-Host "`n[9] Recycle Bin:" -ForegroundColor Yellow
    $recycleBin = "${DriveLetter}:\`$Recycle.Bin"
    if (Test-Path $recycleBin) {
        $items = Get-ChildItem $recycleBin -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object
        if ($items.Count -gt 0) {
            Write-Host "   Recycle Bin has $($items.Count) items" -ForegroundColor Yellow
        } else {
            Write-Host "   Recycle Bin is empty" -ForegroundColor Green
        }
    }
}

# 7. If -Release, release all locks
if ($Release) {
    Write-Host "`n=== RELEASING LOCKS ON ${DriveLetter}: ===" -ForegroundColor Cyan

    # Empty Recycle Bin
    Write-Host "`n[1] Emptying Recycle Bin..." -ForegroundColor Yellow
    try {
        Clear-RecycleBin -DriveLetter $DriveLetter -Force -ErrorAction Stop
        Write-Host "   ✓ Done" -ForegroundColor Green
    } catch {
        Write-Host "   ! Could not empty recycle bin" -ForegroundColor Red
    }

    # Stop Windows Search
    Write-Host "`n[2] Stopping Windows Search..." -ForegroundColor Yellow
    try {
        Stop-Service -Name "WSearch" -Force -ErrorAction Stop
        Write-Host "   ✓ Stopped" -ForegroundColor Green
    } catch {
        Write-Host "   ! Could not stop search" -ForegroundColor Red
    }

    # Delete shadow copies
    Write-Host "`n[3] Deleting shadow copies..." -ForegroundColor Yellow
    $result = vssadmin delete shadows /for=${DriveLetter}: /all /quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Done" -ForegroundColor Green
    } else {
        Write-Host "   No shadow copies to delete" -ForegroundColor Gray
    }

    # Disable System Protection
    Write-Host "`n[4] Disabling System Protection..." -ForegroundColor Yellow
    try {
        Disable-ComputerRestore -Drive "${DriveLetter}:\" -ErrorAction Stop
        Write-Host "   ✓ Done" -ForegroundColor Green
    } catch {
        Write-Host "   Was not enabled" -ForegroundColor Gray
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
$totalIssues = 0
if ($processes) { $totalIssues += $processes.Count }
if ($services) { $totalIssues += $services.Count }
if ($tasks) { $totalIssues += $tasks.Count }
if ($modules) { $totalIssues += $modules.Count }

if ($totalIssues -eq 0) {
    Write-Host "✓ ${DriveLetter}: drive is safe to format!" -ForegroundColor Green
} else {
    Write-Host "⚠ ${DriveLetter}: drive has $totalIssues active tie(s)" -ForegroundColor Yellow
    Write-Host "  Run with -ShowLocks to see hidden Windows locks" -ForegroundColor Cyan
    Write-Host "  Run with -Release to release all locks`n" -ForegroundColor Cyan
}

Write-Host "`nUSAGE EXAMPLES:" -ForegroundColor Gray
Write-Host "  .\check-any-drive.ps1 -DriveLetter E" -ForegroundColor Gray
Write-Host "  .\check-any-drive.ps1 -DriveLetter D -ShowLocks" -ForegroundColor Gray
Write-Host "  .\check-any-drive.ps1 -DriveLetter D -Release`n" -ForegroundColor Gray
