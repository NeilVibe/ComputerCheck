# PowerShell Runner Module - Core execution functions
# Handles all the syntax escaping and error handling we learned

param(
    [Parameter(Position=0)]
    [string]$Command = "",
    
    [Parameter(Position=1)]
    [string]$Mode = "simple",  # simple, script, search, monitor
    
    [Parameter(Position=2)]
    [string]$Target = "",
    
    [Parameter(Position=3)]
    [string]$OutputFormat = "table",  # table, list, json, csv
    
    [switch]$Admin = $false,
    [switch]$VerboseOutput = $false
)

# Function to safely execute commands
function Invoke-SafeCommand {
    param(
        [string]$CommandString,
        [boolean]$RequiresAdmin = $false
    )
    
    try {
        if ($VerboseOutput) {
            Write-Host "[DEBUG] Executing: $CommandString" -ForegroundColor Gray
        }
        
        if ($RequiresAdmin -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "[ERROR] This command requires administrator privileges" -ForegroundColor Red
            return $null
        }
        
        Invoke-Expression $CommandString
    }
    catch {
        Write-Host "[ERROR] Command failed: $_" -ForegroundColor Red
        return $null
    }
}

# Main execution logic
switch ($Mode) {
    "simple" {
        if ($Command) {
            Invoke-SafeCommand -CommandString $Command -RequiresAdmin $Admin
        } else {
            Write-Host "Usage: PSRunner.ps1 -Command 'your command' [-Admin]" -ForegroundColor Yellow
        }
    }
    
    "search" {
        # Modular search function
        if (-not $Target) {
            Write-Host "[ERROR] Search mode requires -Target parameter" -ForegroundColor Red
            exit 1
        }
        
        $searchCmd = @"
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue |
Where-Object { `$_.Name -like '*$Target*' -or `$_.FullName -like '*$Target*' } |
Select-Object FullName, Length, LastWriteTime |
Select-Object -First 20
"@
        
        Write-Host "[SEARCH] Looking for: $Target" -ForegroundColor Cyan
        $results = Invoke-SafeCommand -CommandString $searchCmd
        
        if ($results) {
            switch ($OutputFormat) {
                "table" { $results | Format-Table -AutoSize }
                "list" { $results | Format-List }
                "json" { $results | ConvertTo-Json }
                "csv" { $results | ConvertTo-Csv -NoTypeInformation }
            }
        } else {
            Write-Host "[INFO] No results found" -ForegroundColor Yellow
        }
    }
    
    "monitor" {
        # Process monitoring
        $monitorCmd = @"
Get-Process |
Where-Object { `$_.WorkingSet -gt 100MB } |
Sort-Object WorkingSet -Descending |
Select-Object -First 10 Name, Id, @{n='Memory(MB)';e={[math]::Round(`$_.WorkingSet/1MB,2)}}, Path
"@
        
        Write-Host "[MONITOR] Top memory consumers:" -ForegroundColor Cyan
        Invoke-SafeCommand -CommandString $monitorCmd
    }
    
    "script" {
        # Execute a script file
        if (Test-Path $Target) {
            Write-Host "[SCRIPT] Executing: $Target" -ForegroundColor Cyan
            if ($Admin) {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$Target`"" -Verb RunAs
            } else {
                & $Target
            }
        } else {
            Write-Host "[ERROR] Script not found: $Target" -ForegroundColor Red
        }
    }
}