# Deep Process Security Check
Write-Host "=== DEEP PROCESS SECURITY CHECK ===" -ForegroundColor Cyan

# Check for processes with suspicious characteristics
Write-Host "`nChecking for suspicious process characteristics..." -ForegroundColor Yellow

$processes = Get-WmiObject Win32_Process | Select-Object Name, ProcessId, ExecutablePath, CommandLine, CreationDate

# Look for:
# 1. Processes running from temp folders
# 2. Processes with encoded PowerShell commands
# 3. Processes masquerading as system files but in wrong location
# 4. Processes with very long command lines (often obfuscated malware)

$suspicious = @()

foreach ($proc in $processes) {
    if ($proc.ExecutablePath) {
        # Check temp folder execution
        if ($proc.ExecutablePath -match '\\Temp\\|\\tmp\\|%TEMP%') {
            $suspicious += [PSCustomObject]@{
                Name = $proc.Name
                PID = $proc.ProcessId
                Path = $proc.ExecutablePath
                Reason = "Running from TEMP folder"
            }
        }
        
        # Check for fake system processes in wrong location
        $systemProcesses = @('svchost.exe', 'csrss.exe', 'winlogon.exe', 'services.exe', 'lsass.exe', 'explorer.exe')
        if ($systemProcesses -contains $proc.Name.ToLower() -and $proc.ExecutablePath -notmatch 'Windows\\System32|Windows\\SysWOW64') {
            $suspicious += [PSCustomObject]@{
                Name = $proc.Name
                PID = $proc.ProcessId
                Path = $proc.ExecutablePath
                Reason = "System process in wrong location"
            }
        }
    }
    
    # Check command line for suspicious patterns
    if ($proc.CommandLine) {
        if ($proc.CommandLine -match '-EncodedCommand|-WindowStyle\s+hidden|-ep\s+bypass') {
            $suspicious += [PSCustomObject]@{
                Name = $proc.Name
                PID = $proc.ProcessId
                Path = $proc.ExecutablePath
                Reason = "Suspicious command line"
                CommandLine = $proc.CommandLine.Substring(0, [Math]::Min(100, $proc.CommandLine.Length)) + "..."
            }
        }
        
        # Check for very long command lines
        if ($proc.CommandLine.Length -gt 500) {
            $suspicious += [PSCustomObject]@{
                Name = $proc.Name
                PID = $proc.ProcessId
                Path = $proc.ExecutablePath
                Reason = "Extremely long command line (possible obfuscation)"
                CommandLineLength = $proc.CommandLine.Length
            }
        }
    }
}

if ($suspicious.Count -gt 0) {
    Write-Host "`nSUSPICIOUS PROCESSES FOUND:" -ForegroundColor Red
    $suspicious | Format-Table -AutoSize -Wrap
} else {
    Write-Host "`nNo suspicious processes detected!" -ForegroundColor Green
}

# Check for process injection indicators
Write-Host "`nChecking for process injection indicators..." -ForegroundColor Yellow
$injectionTargets = Get-Process | Where-Object {
    $_.ProcessName -match 'explorer|svchost|rundll32|regsvr32' -and
    $_.Modules.ModuleName -match '\.tmp$|\.dat$' 
} | Select-Object Name, Id, @{Name="SuspiciousModules";Expression={($_.Modules | Where-Object {$_.ModuleName -match '\.tmp$|\.dat$'}).ModuleName -join ', '}}

if ($injectionTargets) {
    Write-Host "Possible injection detected:" -ForegroundColor Red
    $injectionTargets | Format-Table -AutoSize
} else {
    Write-Host "No obvious injection indicators found" -ForegroundColor Green
}

Write-Host "`n=== CHECK COMPLETE ===" -ForegroundColor Cyan