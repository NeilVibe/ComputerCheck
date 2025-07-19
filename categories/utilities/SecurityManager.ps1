# Security Manager V2 - Simplified and Working
# No more confusion, just clear working code

param(
    [string]$Action = "help",
    [string]$Target = ""
)

Write-Host "`n=== Security Manager V2 ===" -ForegroundColor Cyan

switch ($Action) {
    "help" {
        Write-Host @"

USAGE: .\SecurityManager.ps1 <action> [target]

ACTIONS:
  malware <name>   - Search for malware by name
  memory           - Show memory usage
  network          - Show network connections
  process          - Show suspicious processes
  tasks            - Show scheduled tasks
  help             - Show this help

EXAMPLES:
  .\SecurityManager.ps1 malware KOS
  .\SecurityManager.ps1 memory
  .\SecurityManager.ps1 network

"@ -ForegroundColor Green
    }
    
    "malware" {
        if (-not $Target) {
            Write-Host "Please specify malware name to search" -ForegroundColor Red
            exit
        }
        
        Write-Host "`nSearching for: $Target" -ForegroundColor Yellow
        
        # Check processes
        Write-Host "`n[PROCESSES]" -ForegroundColor Cyan
        $procs = Get-Process | Where-Object {
            $_.Name -like "*$Target*" -or 
            ($_.Path -and $_.Path -like "*$Target*")
        }
        if ($procs) {
            $procs | Format-Table Name, Id, Path -AutoSize
        } else {
            Write-Host "No processes found" -ForegroundColor Green
        }
        
        # Check services
        Write-Host "`n[SERVICES]" -ForegroundColor Cyan
        $svcs = Get-Service | Where-Object {
            $_.Name -like "*$Target*" -or 
            $_.DisplayName -like "*$Target*"
        }
        if ($svcs) {
            $svcs | Format-Table Name, Status, DisplayName -AutoSize
        } else {
            Write-Host "No services found" -ForegroundColor Green
        }
        
        # Check scheduled tasks
        Write-Host "`n[SCHEDULED TASKS]" -ForegroundColor Cyan
        $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
            $_.TaskName -like "*$Target*"
        }
        if ($tasks) {
            $tasks | Format-Table TaskName, State -AutoSize
        } else {
            Write-Host "No scheduled tasks found" -ForegroundColor Green
        }
    }
    
    "memory" {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedGB = $totalGB - $freeGB
        $usedPercent = [math]::Round(($usedGB / $totalGB) * 100, 2)
        
        Write-Host "`n[MEMORY STATUS]" -ForegroundColor Cyan
        Write-Host "Total: $totalGB GB"
        Write-Host "Used:  $usedGB GB ($usedPercent%)" -ForegroundColor $(
            if ($usedPercent -gt 80) { 'Red' } 
            elseif ($usedPercent -gt 60) { 'Yellow' } 
            else { 'Green' }
        )
        Write-Host "Free:  $freeGB GB"
        
        Write-Host "`n[TOP 10 MEMORY USERS]" -ForegroundColor Cyan
        Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 |
            Select-Object Name, Id, @{n='Memory(MB)';e={[math]::Round($_.WorkingSet/1MB,2)}} |
            Format-Table -AutoSize
    }
    
    "network" {
        Write-Host "`n[NETWORK CONNECTIONS]" -ForegroundColor Cyan
        $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
            Where-Object { $_.RemoteAddress -notlike '127.*' -and $_.RemoteAddress -ne '::1' }
        
        $connections | ForEach-Object {
            $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            $_ | Add-Member -NotePropertyName ProcessName -NotePropertyValue $proc.Name -PassThru
        } | Select-Object LocalPort, RemoteAddress, RemotePort, ProcessName |
            Sort-Object ProcessName | Format-Table -AutoSize
    }
    
    "process" {
        Write-Host "`n[SUSPICIOUS PROCESSES]" -ForegroundColor Cyan
        Write-Host "Checking for processes in temp folders..." -ForegroundColor Gray
        
        $suspicious = Get-Process | Where-Object {
            $_.Path -and (
                $_.Path -like '*\Temp\*' -or 
                $_.Path -like '*\AppData\Local\Temp\*' -or
                $_.Path -like '*\AppData\Roaming\*'
            )
        }
        
        if ($suspicious) {
            Write-Host "Found processes running from temporary locations:" -ForegroundColor Yellow
            $suspicious | Select-Object Name, Id, Path | Format-Table -AutoSize
        } else {
            Write-Host "No suspicious processes found" -ForegroundColor Green
        }
    }
    
    "tasks" {
        Write-Host "`n[SCHEDULED TASKS WITH HIDDEN EXECUTION]" -ForegroundColor Cyan
        $hidden = Get-ScheduledTask | Where-Object {
            $_.Actions.Execute -like "*powershell*" -and 
            $_.Actions.Arguments -like "*-WindowStyle hidden*"
        }
        
        if ($hidden) {
            Write-Host "Found tasks with hidden PowerShell execution:" -ForegroundColor Yellow
            $hidden | ForEach-Object {
                Write-Host "`nTask: $($_.TaskName)" -ForegroundColor Yellow
                Write-Host "State: $($_.State)"
                Write-Host "Action: $($_.Actions.Execute) $($_.Actions.Arguments)"
            }
        } else {
            Write-Host "No hidden PowerShell tasks found" -ForegroundColor Green
        }
    }
    
    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Use 'help' to see available actions"
    }
}