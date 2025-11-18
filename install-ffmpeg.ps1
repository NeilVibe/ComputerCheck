# FFmpeg Installation Helper for Audacity
# Run as Administrator

param(
    [string]$InstallPath = "C:\ffmpeg"
)

Write-Host "FFmpeg Installation Helper for Audacity" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again" -ForegroundColor Yellow
    exit 1
}

# Check if ffmpeg already exists
$existingFFmpeg = where.exe ffmpeg 2>$null
if ($existingFFmpeg) {
    Write-Host "FFmpeg already found at: $existingFFmpeg" -ForegroundColor Green
    $response = Read-Host "Do you want to continue anyway? (y/n)"
    if ($response -ne 'y') { exit 0 }
}

Write-Host "`nInstallation Options:" -ForegroundColor Yellow
Write-Host "1. Download and install FFmpeg automatically"
Write-Host "2. I already downloaded FFmpeg, just configure PATH"
Write-Host "3. Just show me Audacity FFmpeg download page"

$choice = Read-Host "Choose option (1-3)"

switch ($choice) {
    "1" {
        Write-Host "`nDownloading FFmpeg..." -ForegroundColor Yellow
        $url = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        $tempZip = "$env:TEMP\ffmpeg.zip"

        try {
            Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing
            Write-Host "Download complete!" -ForegroundColor Green

            Write-Host "Extracting to $InstallPath..." -ForegroundColor Yellow
            Expand-Archive -Path $tempZip -DestinationPath $env:TEMP -Force

            # Find the extracted folder
            $extractedFolder = Get-ChildItem "$env:TEMP" -Filter "ffmpeg-*" | Select-Object -First 1
            if ($extractedFolder) {
                # Create target directory
                if (Test-Path $InstallPath) {
                    Remove-Item $InstallPath -Recurse -Force
                }
                Move-Item $extractedFolder.FullName $InstallPath -Force
                Write-Host "Extraction complete!" -ForegroundColor Green
            }

            Remove-Item $tempZip -Force
        }
        catch {
            Write-Host "ERROR: Failed to download/extract FFmpeg" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            exit 1
        }
    }
    "2" {
        $customPath = Read-Host "Enter the path where you extracted FFmpeg (e.g., C:\ffmpeg)"
        if (Test-Path "$customPath\bin\ffmpeg.exe") {
            $InstallPath = $customPath
            Write-Host "Found FFmpeg at $InstallPath" -ForegroundColor Green
        }
        else {
            Write-Host "ERROR: ffmpeg.exe not found in $customPath\bin\" -ForegroundColor Red
            exit 1
        }
    }
    "3" {
        Write-Host "`nOpening Audacity FFmpeg download page..." -ForegroundColor Yellow
        Start-Process "https://support.audacityteam.org/basics/installing-ffmpeg"
        Write-Host "Download the Windows installer from that page and run it." -ForegroundColor Cyan
        Write-Host "It will automatically configure FFmpeg for Audacity." -ForegroundColor Cyan
        exit 0
    }
    default {
        Write-Host "Invalid choice" -ForegroundColor Red
        exit 1
    }
}

# Add to PATH
if ($choice -eq "1" -or $choice -eq "2") {
    Write-Host "`nConfiguring PATH environment variable..." -ForegroundColor Yellow
    $ffmpegBin = "$InstallPath\bin"

    if (Test-Path $ffmpegBin) {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
        if ($currentPath -notlike "*$ffmpegBin*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$ffmpegBin", [EnvironmentVariableTarget]::Machine)
            Write-Host "Added to PATH successfully!" -ForegroundColor Green
            Write-Host "You may need to restart Audacity for changes to take effect." -ForegroundColor Yellow
        }
        else {
            Write-Host "Path already contains FFmpeg" -ForegroundColor Yellow
        }

        # Test installation
        Write-Host "`nTesting FFmpeg installation..." -ForegroundColor Yellow
        & "$ffmpegBin\ffmpeg.exe" -version | Select-Object -First 1

        Write-Host "`n✓ FFmpeg installed successfully!" -ForegroundColor Green
        Write-Host "`nFor Audacity:" -ForegroundColor Cyan
        Write-Host "1. Open Audacity" -ForegroundColor White
        Write-Host "2. Go to Edit > Preferences > Libraries" -ForegroundColor White
        Write-Host "3. Click 'Locate' next to FFmpeg library" -ForegroundColor White
        Write-Host "4. Navigate to: $ffmpegBin" -ForegroundColor White
        Write-Host "5. Select 'avformat-*.dll' file" -ForegroundColor White
    }
    else {
        Write-Host "ERROR: bin folder not found at $InstallPath" -ForegroundColor Red
        exit 1
    }
}