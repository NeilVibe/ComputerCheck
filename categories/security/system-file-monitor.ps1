# System File Monitor - Tampering Detection
Write-Host "=== SYSTEM FILE INTEGRITY MONITOR ===" -ForegroundColor Red
Write-Host "Checking for system file tampering..." -ForegroundColor Yellow
Write-Host ""

# Critical system files to monitor
$criticalFiles = @(
    "C:\Windows\System32\notepad.exe",
    "C:\Windows\System32\calc.exe", 
    "C:\Windows\System32\cmd.exe",
    "C:\Windows\System32\powershell.exe",
    "C:\Windows\System32\regedit.exe",
    "C:\Windows\System32\taskmgr.exe",
    "C:\Windows\System32\services.exe",
    "C:\Windows\System32\winlogon.exe",
    "C:\Windows\System32\lsass.exe"
)

# Quick file hash verification (fast alternative to SFC)
Write-Host "Quick system file verification..." -ForegroundColor Cyan

# Check critical file signatures
Write-Host "Checking critical file signatures..." -ForegroundColor Cyan
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        try {
            $hash = Get-FileHash $file -Algorithm SHA256
            $fileInfo = Get-Item $file
            
            # Check if file is signed
            $signature = Get-AuthenticodeSignature $file
            
            if ($signature.Status -eq "Valid") {
                Write-Host "✅ $($fileInfo.Name) - Signed and verified" -ForegroundColor Green
            } elseif ($signature.Status -eq "NotSigned") {
                Write-Host "⚠️ $($fileInfo.Name) - Not digitally signed" -ForegroundColor Yellow
            } else {
                Write-Host "❌ $($fileInfo.Name) - Invalid signature: $($signature.Status)" -ForegroundColor Red
            }
            
        } catch {
            Write-Host "❌ $($fileInfo.Name) - Could not verify" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ $(Split-Path $file -Leaf) - File missing!" -ForegroundColor Red
    }
}

Write-Host ""

# Check for suspicious files in system directories
Write-Host "Scanning for suspicious files in system directories..." -ForegroundColor Cyan
$systemDirs = @("C:\Windows\System32", "C:\Windows\SysWOW64")
$suspiciousExtensions = @("*.tmp", "*.temp", "*.bak", "*.old")

foreach ($dir in $systemDirs) {
    foreach ($ext in $suspiciousExtensions) {
        $suspiciousFiles = Get-ChildItem "$dir\$ext" -ErrorAction SilentlyContinue
        if ($suspiciousFiles) {
            Write-Host "⚠️ Found suspicious files in $dir : $ext" -ForegroundColor Yellow
            $suspiciousFiles | Select-Object Name, LastWriteTime | Format-Table -AutoSize
        }
    }
}

# Check for recently modified system files
Write-Host "Checking for recently modified system files (last 7 days)..." -ForegroundColor Cyan
$recentDate = (Get-Date).AddDays(-7)
$recentSystemFiles = Get-ChildItem "C:\Windows\System32\*.exe" | Where-Object { 
    $_.LastWriteTime -gt $recentDate 
} | Select-Object Name, LastWriteTime -First 10

if ($recentSystemFiles) {
    Write-Host "⚠️ Recently modified system executables:" -ForegroundColor Yellow
    $recentSystemFiles | Format-Table -AutoSize
} else {
    Write-Host "✅ No recently modified system executables" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "System file integrity check complete." -ForegroundColor White
Write-Host "Review any RED (Critical) or YELLOW (Warning) findings above." -ForegroundColor Yellow