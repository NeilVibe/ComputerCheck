# Check for vmmem and other virtual machine processes
Write-Host "=== CHECKING VIRTUAL MACHINE MEMORY (vmmem) ===" -ForegroundColor Cyan

# Get all processes including vmmem
$allProcesses = Get-Process | Sort-Object WorkingSet -Descending

# Look for vmmem specifically
$vmmem = $allProcesses | Where-Object {$_.Name -eq 'vmmem'}

if ($vmmem) {
    Write-Host "`nFOUND VMMEM PROCESS:" -ForegroundColor Yellow
    $vmmem | Select-Object @{Name="Process";Expression={$_.Name}},
        @{Name="PID";Expression={$_.Id}},
        @{Name="Memory (MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
        @{Name="Memory (GB)";Expression={[math]::Round($_.WorkingSet / 1GB, 2)}},
        @{Name="Description";Expression={"WSL2 Virtual Machine Memory"}} | Format-Table -AutoSize
    
    Write-Host "`nEXPLANATION:" -ForegroundColor Green
    Write-Host "- vmmem is the process that handles memory for WSL2 (Windows Subsystem for Linux)"
    Write-Host "- This is YOUR current terminal session running Claude"
    Write-Host "- It dynamically allocates memory as needed for Linux applications"
    Write-Host "- Completely normal and expected when using WSL2"
} else {
    Write-Host "vmmem process not found (it might be listed under a different view)" -ForegroundColor Yellow
}

# Show top 10 including system processes
Write-Host "`nTOP 10 MEMORY CONSUMERS (INCLUDING SYSTEM PROCESSES):" -ForegroundColor Green
$allProcesses | Select-Object -First 10 | Select-Object @{Name="Process";Expression={$_.Name}},
    @{Name="PID";Expression={$_.Id}},
    @{Name="Memory (GB)";Expression={[math]::Round($_.WorkingSet / 1GB, 2)}},
    @{Name="CPU";Expression={$_.CPU}} | Format-Table -AutoSize

# Check WSL memory configuration
Write-Host "`nWSL MEMORY CONFIGURATION:" -ForegroundColor Yellow
$wslconfig = "$env:USERPROFILE\.wslconfig"
if (Test-Path $wslconfig) {
    Write-Host "WSL config file found at: $wslconfig"
    Get-Content $wslconfig
} else {
    Write-Host "No .wslconfig file found (WSL using default settings)"
    Write-Host "Default: WSL2 can use up to 50% of total RAM or 8GB, whichever is less"
}