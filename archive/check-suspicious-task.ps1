# Check the suspicious GatherNetworkInfo task
Write-Host "=== Investigating GatherNetworkInfo Task ===" -ForegroundColor Red

# Get detailed task info
$task = Get-ScheduledTask -TaskName "GatherNetworkInfo" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "`nTask Found!" -ForegroundColor Yellow
    Write-Host "Task Name: $($task.TaskName)"
    Write-Host "Task Path: $($task.TaskPath)"
    Write-Host "State: $($task.State)"
    Write-Host "Description: $($task.Description)"
    
    # Check the action
    Write-Host "`nAction Details:" -ForegroundColor Yellow
    $task.Actions | ForEach-Object {
        Write-Host "Execute: $($_.Execute)"
        Write-Host "Arguments: $($_.Arguments)"
        Write-Host "Working Directory: $($_.WorkingDirectory)"
    }
    
    # Check triggers
    Write-Host "`nTriggers:" -ForegroundColor Yellow
    $task.Triggers | ForEach-Object {
        Write-Host "Trigger Type: $($_.CimClass.CimClassName)"
        Write-Host "Enabled: $($_.Enabled)"
    }
    
    # Check the actual file
    $scriptPath = "$env:windir\system32\gatherNetworkInfo.vbs"
    Write-Host "`nChecking script file: $scriptPath" -ForegroundColor Yellow
    if (Test-Path $scriptPath) {
        Write-Host "FILE EXISTS!" -ForegroundColor Red
        $fileInfo = Get-Item $scriptPath
        Write-Host "Size: $($fileInfo.Length) bytes"
        Write-Host "Created: $($fileInfo.CreationTime)"
        Write-Host "Modified: $($fileInfo.LastWriteTime)"
        
        # Try to read first few lines
        Write-Host "`nFirst 10 lines of script:" -ForegroundColor Yellow
        Get-Content $scriptPath -TotalCount 10 -ErrorAction SilentlyContinue
    } else {
        Write-Host "Script file not found" -ForegroundColor Green
    }
    
    # Compare with legitimate Windows task
    Write-Host "`n=== ANALYSIS ===" -ForegroundColor Cyan
    Write-Host "This task appears to be:" -ForegroundColor Yellow
    
    # Check if it's in the legitimate NetTrace path
    if ($task.TaskPath -eq "\Microsoft\Windows\NetTrace\") {
        Write-Host "- Located in official Windows NetTrace folder" -ForegroundColor Green
        Write-Host "- This is likely a LEGITIMATE Windows component" -ForegroundColor Green
        Write-Host "- Used for network diagnostics and troubleshooting" -ForegroundColor Green
    } else {
        Write-Host "- SUSPICIOUS: Not in expected location!" -ForegroundColor Red
    }
    
} else {
    Write-Host "GatherNetworkInfo task not found" -ForegroundColor Green
}

# Also check for the malicious variant mentioned in the report
Write-Host "`n=== Checking for Malicious Variant ===" -ForegroundColor Yellow
$maliciousTask = Get-ScheduledTask | Where-Object {
    $_.TaskName -like "*GatherNetworkInfo*PKP*" -or
    $_.TaskName -eq "GatherNetworkInfodSV2PKPKp"
}

if ($maliciousTask) {
    Write-Host "MALICIOUS VARIANT FOUND!" -ForegroundColor Red
    $maliciousTask | ForEach-Object {
        Write-Host "`nMalicious Task: $($_.TaskName)" -ForegroundColor Red
        Write-Host "Path: $($_.TaskPath)"
        Write-Host "Action: $($_.Actions.Execute) $($_.Actions.Arguments)"
    }
} else {
    Write-Host "No malicious variant found (GatherNetworkInfodSV2PKPKp)" -ForegroundColor Green
}