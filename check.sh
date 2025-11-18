#!/bin/bash
# check.sh - Quick Health Check for Claude AI CLI
# Fast system health assessment with JSON output
# NO ACTIONS - only CHECK and REPORT

set -euo pipefail

POWERSHELL_CMD="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
PYTHON_CMD="python3"

# Function to get Explorer.exe handles (Windows-specific)
get_explorer_handles() {
    # Get the FIRST explorer.exe process (main UI process) handles
    $POWERSHELL_CMD -NoProfile -Command "Get-Process explorer -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Handles" 2>/dev/null | tr -d '\n\r ' || echo "0"
}

# Function to get system memory percentage (cross-platform via psutil)
get_memory_percent() {
    $PYTHON_CMD -c "import psutil; print(round(psutil.virtual_memory().percent, 1))"
}

# Function to get disk usage for critical partitions
get_disk_usage() {
    $PYTHON_CMD << 'EOF'
import psutil
import json

disks = {}
for partition in psutil.disk_partitions():
    try:
        usage = psutil.disk_usage(partition.mountpoint)
        disks[partition.mountpoint] = {
            "total_gb": round(usage.total / (1024**3), 2),
            "used_gb": round(usage.used / (1024**3), 2),
            "free_gb": round(usage.free / (1024**3), 2),
            "percent": round(usage.percent, 1)
        }
    except:
        pass
print(json.dumps(disks))
EOF
}

# Function to count processes
get_process_count() {
    $PYTHON_CMD -c "import psutil; print(len(psutil.pids()))"
}

# Function to get CPU percent
get_cpu_percent() {
    $PYTHON_CMD -c "import psutil; psutil.cpu_percent(interval=0.5); print(round(psutil.cpu_percent(interval=0.5), 1))"
}

# Function to check for critical Windows events (last 15 minutes)
get_recent_critical_events() {
    $POWERSHELL_CMD -NoProfile -Command "
        \$events = Get-WinEvent -FilterHashtable @{LogName='System','Application'; Level=1; StartTime=(Get-Date).AddMinutes(-15)} -MaxEvents 10 -ErrorAction SilentlyContinue
        if (\$events) {
            \$events | ForEach-Object {
                Write-Output \"\$(\$_.TimeCreated.ToString('yyyy-MM-ddTHH:mm:ss'))|\$(\$_.Id)|\$(\$_.ProviderName)\"
            }
        }
    " 2>/dev/null || echo ""
}

# Function to get top memory consumers
get_top_memory_processes() {
    $PYTHON_CMD << 'EOF'
import psutil
import json

procs = []
for proc in psutil.process_iter(['pid', 'name', 'memory_info']):
    try:
        procs.append({
            "pid": proc.info['pid'],
            "name": proc.info['name'],
            "memory_mb": round(proc.info['memory_info'].rss / (1024**2), 1)
        })
    except:
        pass

# Sort by memory and get top 5
procs_sorted = sorted(procs, key=lambda x: x['memory_mb'], reverse=True)[:5]
print(json.dumps(procs_sorted))
EOF
}

# Function to get network connections using ss (famous Linux tool!)
get_network_connections() {
    $PYTHON_CMD << 'EOF'
import psutil
import json

# Use psutil for cross-platform network stats
connections = []
for conn in psutil.net_connections(kind='inet'):
    try:
        if conn.status == 'LISTEN':
            connections.append({
                "local_address": conn.laddr.ip if conn.laddr else "0.0.0.0",
                "local_port": conn.laddr.port if conn.laddr else 0,
                "status": conn.status,
                "pid": conn.pid if conn.pid else 0
            })
    except:
        pass

# Get top 10 listening ports
connections_sorted = sorted(connections, key=lambda x: x['local_port'])[:10]
print(json.dumps(connections_sorted))
EOF
}

# Function to get network stats summary
get_network_summary() {
    # Count listening ports using ss (THE famous network tool!)
    local listening_count=$(ss -tuln 2>/dev/null | grep LISTEN | wc -l || echo "0")
    local established_count=$(ss -tun 2>/dev/null | grep ESTAB | wc -l || echo "0")

    echo "{\"listening_ports\":$listening_count,\"established_connections\":$established_count}"
}

# Quick check mode (< 5 seconds)
quick_check() {
    local format="${1:-json}"

    # Gather data
    local explorer_handles=$(get_explorer_handles)
    local memory_percent=$(get_memory_percent)
    local process_count=$(get_process_count)
    local cpu_percent=$(get_cpu_percent)
    local disk_info=$(get_disk_usage)
    local top_procs=$(get_top_memory_processes)
    local network_connections=$(get_network_connections)
    local network_summary=$(get_network_summary)
    local critical_events=$(get_recent_critical_events)

    # Determine health status
    local status="healthy"
    local warnings=()
    local errors=()

    # Check Explorer handles (freeze danger zone)
    if [[ $explorer_handles -gt 5000 ]]; then
        status="critical"
        errors+=("Explorer.exe handles critical: $explorer_handles (freeze imminent!)")
    elif [[ $explorer_handles -gt 3500 ]]; then
        status="warning"
        warnings+=("Explorer.exe handles elevated: $explorer_handles")
    fi

    # Check memory (using Python for float comparison - no bc needed!)
    if $PYTHON_CMD -c "exit(0 if $memory_percent > 90 else 1)"; then
        status="critical"
        errors+=("Memory usage critical: ${memory_percent}%")
    elif $PYTHON_CMD -c "exit(0 if $memory_percent > 75 else 1)"; then
        if [[ "$status" != "critical" ]]; then
            status="warning"
        fi
        warnings+=("Memory usage high: ${memory_percent}%")
    fi

    # Check for critical events
    if [[ -n "$critical_events" ]]; then
        local event_count=$(echo "$critical_events" | wc -l)
        if [[ $event_count -gt 0 ]]; then
            if [[ "$status" == "healthy" ]]; then
                status="warning"
            fi
            warnings+=("$event_count critical Windows events in last 15 minutes")
        fi
    fi

    # Output
    if [[ "$format" == "json" ]]; then
        # Build warnings array
        local warnings_json="["
        local first=true
        for warn in "${warnings[@]}"; do
            if [[ "$first" == "false" ]]; then
                warnings_json+=","
            fi
            warnings_json+="\"$warn\""
            first=false
        done
        warnings_json+="]"

        # Build errors array
        local errors_json="["
        first=true
        for err in "${errors[@]}"; do
            if [[ "$first" == "false" ]]; then
                errors_json+=","
            fi
            errors_json+="\"$err\""
            first=false
        done
        errors_json+="]"

        # Build critical events array
        local events_json="["
        if [[ -n "$critical_events" ]]; then
            first=true
            while IFS='|' read -r timestamp event_id provider; do
                if [[ -n "$timestamp" ]]; then
                    if [[ "$first" == "false" ]]; then
                        events_json+=","
                    fi
                    events_json+="{\"timestamp\":\"$timestamp\",\"id\":$event_id,\"provider\":\"$provider\"}"
                    first=false
                fi
            done <<< "$critical_events"
        fi
        events_json+="]"

        cat << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "$status",
  "system": {
    "explorer_handles": $explorer_handles,
    "memory_percent": $memory_percent,
    "cpu_percent": $cpu_percent,
    "process_count": $process_count
  },
  "disk": $disk_info,
  "network": {
    "summary": $network_summary,
    "listening_ports": $network_connections
  },
  "top_memory_processes": $top_procs,
  "recent_critical_events": $events_json,
  "warnings": $warnings_json,
  "errors": $errors_json
}
EOF
    else
        # Human-readable output
        echo "=== QUICK HEALTH CHECK ==="
        echo "Timestamp: $(date)"
        echo ""
        echo "Status: $status"
        echo ""
        echo "System:"
        echo "  Explorer.exe handles: $explorer_handles"
        echo "  Memory usage: ${memory_percent}%"
        echo "  CPU usage: ${cpu_percent}%"
        echo "  Process count: $process_count"
        echo ""
        if [[ ${#warnings[@]} -gt 0 ]]; then
            echo "Warnings:"
            for warn in "${warnings[@]}"; do
                echo "  - $warn"
            done
            echo ""
        fi
        if [[ ${#errors[@]} -gt 0 ]]; then
            echo "ERRORS:"
            for err in "${errors[@]}"; do
                echo "  - $err"
            done
            echo ""
        fi
    fi

    # Exit code based on status
    if [[ "$status" == "critical" ]]; then
        exit 2
    elif [[ "$status" == "warning" ]]; then
        exit 2
    else
        exit 0
    fi
}

# Show usage
show_usage() {
    cat << EOF
check.sh - Quick System Health Check

USAGE:
  ./check.sh [--quick] [--json|--text]
  ./check.sh --help

OPTIONS:
  --quick       Fast check (<5 sec) - default
  --json        Output as JSON (default)
  --text        Output human-readable text
  --help        Show this help

EXAMPLES:
  ./check.sh                    # Quick check, JSON output
  ./check.sh --quick --json     # Same as above
  ./check.sh --quick --text     # Quick check, human-readable

FOR CLAUDE AI:
  Always use: ./check.sh --quick --json
  Parse output with jq: ./check.sh --quick --json | jq '.status'

EXIT CODES:
  0 - Healthy
  2 - Warning or issues found

WHAT IT CHECKS:
  - Explorer.exe handles (freeze danger!)
  - Memory usage percentage
  - CPU usage percentage
  - Disk space on all drives
  - Top memory-consuming processes
  - Recent critical Windows events (last 15 min)

NO ACTIONS TAKEN - READ-ONLY CHECK!

EOF
}

# Main
main() {
    local mode="quick"
    local format="json"

    for arg in "$@"; do
        case "$arg" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --quick)
                mode="quick"
                ;;
            --json)
                format="json"
                ;;
            --text)
                format="text"
                ;;
            *)
                echo "Error: Unknown argument '$arg'"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done

    quick_check "$format"
}

main "$@"
