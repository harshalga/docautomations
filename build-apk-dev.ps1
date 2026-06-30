# ==============================================
# Build Development APK
# ==============================================

Write-Host ""
Write-Host "=========================================="
Write-Host " Building Development APK"
Write-Host "=========================================="
Write-Host ""

flutter build apk `
    --release `
    --dart-define=BASE_URL=https://license-server-dev-now9.onrender.com `
    --split-debug-info=build/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Flutter build failed"
    exit 1
}

# Read version from pubspec.yaml
$pubspec = Get-Content pubspec.yaml
$versionLine = $pubspec | Select-String "^version:"
$version = $versionLine.ToString().Split(" ")[1]

# Source APK
$src = "build/app/outputs/flutter-apk/app-release.apk"

# Destination folder
$destFolder = "builds_dev"

# Create folder if it doesn't exist
New-Item -ItemType Directory -Force -Path $destFolder | Out-Null

# Destination filename
$dest = "$destFolder/DocAutomations_DEV_v$version.apk"

if (!(Test-Path $src)) {
    Write-Host ""
    Write-Host "❌ APK file not found: $src"
    exit 1
}

# Copy APK
Copy-Item $src $dest -Force

Write-Host ""
Write-Host "=========================================="
Write-Host "✅ Development APK Created Successfully"
Write-Host "=========================================="
Write-Host ""
Write-Host "Saved to:"
Write-Host $dest
Write-Host ""