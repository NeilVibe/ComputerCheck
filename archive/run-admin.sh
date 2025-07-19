#!/bin/bash
# Run PowerShell command with admin rights (will show UAC prompt)

if [ -z "$1" ]; then
    echo "Usage: ./run-admin.sh 'PowerShell command'"
    exit 1
fi

# This will open a new PowerShell window with admin rights
powershell.exe -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"$1\"' -Verb RunAs"