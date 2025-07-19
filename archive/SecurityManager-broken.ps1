# Security Manager - Main Entry Point
# Combines all our learned techniques into a unified tool

param(
    [Parameter(Position=0)]
    [string]$Action = "help",
    
    [Parameter(Position=1)]
    [string]$Target = "",
    
    [switch]$Deep = $false,
    [switch]$Quick = $false,
    [switch]$Export = $false,
    [string]$ExportPath = ".\security-report-$(Get-Date -Format 'yyyy-MM-dd').txt"
)

# Import our modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\lib\PSRunner.ps1"

# Banner
Write-Host @"
===================================
   Security & System Manager v2.0
   Built with lessons learned!
===================================
"@ -ForegroundColor Cyan

# Main action switch
switch ($Action.ToLower()) {
    "help" {
        Write-Host @"
USAGE: SecurityManager.ps1 <action> [target] [options]

ACTIONS:
  scan-malware [name]     - Search for specific malware (e.g., KOS, Kings)
  scan-process [name]     - Find suspicious processes
  scan-network           - Check network connections
  scan-tasks             - Review scheduled tasks
  scan-startup           - Check startup items
  monitor-memory         - Show memory usage
  monitor-events [id]    - Monitor specific event IDs
  search-file [name]     - Find files across system
  clean-temp             - Clean temporary files
  quick-health           - Quick system health check
  deep-scan              - Comprehensive security scan
  help                   - Show this help

OPTIONS:
  -Deep                  - Thorough scan (slower)
  -Quick                 - Quick scan (faster)
  -Export                - Export results to file
  -ExportPath [path]     - Custom export location

EXAMPLES:
  .\SecurityManager.ps1 scan-malware KOS
  .\SecurityManager.ps1 monitor-memory
  .\SecurityManager.ps1 scan-process -Deep
  .\SecurityManager.ps1 quick-health -Export
"@ -ForegroundColor Green
    }
    
    "scan-malware" {
        Write-Host "[SCAN] Searching for malware: $Target" -ForegroundColor Yellow
        
        $scanScript = @"
# Malware scan for: $Target
Write-Host 'Checking processes...' -ForegroundColor Cyan
`$procs = Get-Process | Where-Object {
    `$_.Name -like "*$Target*" -or 
    `$_.Path -like "*$Target*" -or
    `$_.Company -like "*$Target*"
}
if (`$procs) {
    Write-Host "FOUND PROCESSES:" -ForegroundColor Red
    `$procs | Format-Table Name, Id, Path, Company -AutoSize
} else {
    Write-Host "No processes found" -ForegroundColor Green
}

Write-Host "`nChecking services..." -ForegroundColor Cyan
`$svcs = Get-Service | Where-Object {
    `$_.Name -like "*$Target*" -or 
    `$_.DisplayName -like "*$Target*"
}
if (`$svcs) {
    Write-Host "FOUND SERVICES:" -ForegroundColor Red
    `$svcs | Format-Table Name, Status, DisplayName -AutoSize
} else {
    Write-Host "No services found" -ForegroundColor Green
}

Write-Host "`nChecking scheduled tasks..." -ForegroundColor Cyan
`$tasks = Get-ScheduledTask | Where-Object {
    `$_.TaskName -like "*$Target*" -or
    `$_.Actions.Execute -like "*$Target*"
}
if (`$tasks) {
    Write-Host "FOUND TASKS:" -ForegroundColor Red
    `$tasks | Format-Table TaskName, State, TaskPath -AutoSize
} else {
    Write-Host "No scheduled tasks found" -ForegroundColor Green
}

$(if ($Deep) { @"
Write-Host "`nChecking file system..." -ForegroundColor Cyan
`$paths = @('C:\Program Files', 'C:\Program Files (x86)', 'C:\ProgramData', `$env:APPDATA, `$env:LOCALAPPDATA)
foreach (`$path in `$paths) {
    `$files = Get-ChildItem -Path `$path -Filter "*$Target*" -Recurse -ErrorAction SilentlyContinue
    if (`$files) {
        Write-Host "Found in `$path`:" -ForegroundColor Red
        `$files | Select-Object FullName, Length | Format-Table -AutoSize
    }
}
"@ })
"@
        
        if ($Export) {
            $scanScript | Out-File temp_scan.ps1
            $results = & powershell -ExecutionPolicy Bypass -File temp_scan.ps1
            $results | Out-File $ExportPath -Append
            Remove-Item temp_scan.ps1
            Write-Host "[EXPORT] Results saved to: $ExportPath" -ForegroundColor Green
        } else {
            $scanScript | Out-File temp_scan.ps1
            & powershell -ExecutionPolicy Bypass -File temp_scan.ps1
            Remove-Item temp_scan.ps1
        }
    }
    
    "scan-process" {
        $procScript = @"
# Suspicious process detection
`$suspicious = Get-Process | Where-Object {
    (`$_.Path -like '*\Temp\*' -or 
     `$_.Path -like '*\AppData\Local\Temp\*' -or
     `$_.Path -like '*\Users\*\AppData\Roaming\*') -and
    `$_.Company -eq `$null
} | Select-Object Name, Id, Path, StartTime

$(if ($Target) { "| Where-Object { `$_.Name -like '*$Target*' }" })

if (`$suspicious) {
    Write-Host "SUSPICIOUS PROCESSES:" -ForegroundColor Red
    `$suspicious | Format-Table -AutoSize
} else {
    Write-Host "No suspicious processes found" -ForegroundColor Green
}

$(if ($Deep) { @"
# Check for process hiding techniques
Write-Host "`nChecking for hidden processes..." -ForegroundColor Cyan
`$wmi = Get-WmiObject Win32_Process | Select-Object Name, ProcessId, ExecutablePath
`$ps = Get-Process | Select-Object Name, Id, Path
`$hidden = Compare-Object `$wmi `$ps -Property ProcessId -PassThru
if (`$hidden) {
    Write-Host "Potential hidden processes detected!" -ForegroundColor Red
    `$hidden
}
"@ })
"@
        
        $procScript | Out-File temp_proc.ps1
        & powershell -ExecutionPolicy Bypass -File temp_proc.ps1
        Remove-Item temp_proc.ps1
    }
    
    "scan-network" {
        Write-Host "[NETWORK] Checking connections..." -ForegroundColor Cyan
        
        $netScript = @"
`$connections = Get-NetTCPConnection -State Established |
    Where-Object { `$_.RemoteAddress -notlike '127.*' -and `$_.RemoteAddress -ne '::1' } |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess

# Add process names
`$connections | ForEach-Object {
    `$proc = Get-Process -Id `$_.OwningProcess -ErrorAction SilentlyContinue
    `$_ | Add-Member -NotePropertyName ProcessName -NotePropertyValue `$proc.Name -PassThru
} | Format-Table -AutoSize

$(if ($Deep) { @"
# Check for suspicious ports
Write-Host "`nChecking suspicious ports..." -ForegroundColor Cyan
`$suspiciousPorts = @(4444, 5555, 6666, 7777, 8888, 9999, 31337)
`$suspicious = `$connections | Where-Object { `$_.RemotePort -in `$suspiciousPorts -or `$_.LocalPort -in `$suspiciousPorts }
if (`$suspicious) {
    Write-Host "SUSPICIOUS PORTS DETECTED:" -ForegroundColor Red
    `$suspicious | Format-Table -AutoSize
}
"@ })
"@
        
        $netScript | Out-File temp_net.ps1
        & powershell -ExecutionPolicy Bypass -File temp_net.ps1
        Remove-Item temp_net.ps1
    }
    
    "monitor-memory" {
        Write-Host "[MEMORY] Current usage:" -ForegroundColor Cyan
        
        $memScript = @"
`$os = Get-CimInstance Win32_OperatingSystem
`$total = [math]::Round(`$os.TotalVisibleMemorySize / 1MB, 2)
`$free = [math]::Round(`$os.FreePhysicalMemory / 1MB, 2)
`$used = `$total - `$free
`$percent = [math]::Round((`$used / `$total) * 100, 2)

Write-Host "Total Memory: `$(`$total) GB" -ForegroundColor White
Write-Host "Used Memory: `$(`$used) GB (`$(`$percent)%)" -ForegroundColor `$(if (`$percent -gt 80) { 'Red' } elseif (`$percent -gt 60) { 'Yellow' } else { 'Green' })
Write-Host "Free Memory: `$(`$free) GB" -ForegroundColor White

Write-Host "`nTop 10 Memory Consumers:" -ForegroundColor Cyan
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 |
    Select-Object Name, Id, @{n='Memory(MB)';e={[math]::Round(`$_.WorkingSet/1MB,2)}}, 
                  @{n='CPU';e={`$_.CPU}}, Path |
    Format-Table -AutoSize
"@
        
        $memScript | Out-File temp_mem.ps1
        & powershell -ExecutionPolicy Bypass -File temp_mem.ps1
        Remove-Item temp_mem.ps1
    }
    
    "quick-health" {
        Write-Host "[HEALTH CHECK] Running quick diagnostics..." -ForegroundColor Cyan
        
        # This combines our safe, proven checks
        & powershell -ExecutionPolicy Bypass -File "$scriptPath\safe-event-monitor.ps1"
        
        Start-Sleep -Seconds 2
        Write-Host "`n[MEMORY CHECK]" -ForegroundColor Cyan
        & $MyInvocation.MyCommand.Path monitor-memory
    }
    
    default {
        Write-Host "[ERROR] Unknown action: $Action" -ForegroundColor Red
        Write-Host "Use 'help' to see available actions" -ForegroundColor Yellow
    }
}

# Cleanup function for temp files
if (Test-Path temp_*.ps1) {
    Remove-Item temp_*.ps1 -Force
}