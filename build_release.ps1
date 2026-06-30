# Build Flutter AAB
#flutter build appbundle 
#flutter build appbundle --split-debug-info=build/symbols
# Build Flutter AAB (Production)
flutter build appbundle `
    --dart-define=BASE_URL=https://license-server-0zfe.onrender.com `
    --split-debug-info=build/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter build failed"
    exit 1
}

# Read version from pubspec.yaml
$pubspec = Get-Content pubspec.yaml
$versionLine = $pubspec | Select-String "^version:"
$version = $versionLine.ToString().Split(" ")[1]

# File paths
$src = "build/app/outputs/bundle/release/app-release.aab"
$destFolder = "builds_prod"

# Create folder if not exists
New-Item -ItemType Directory -Force -Path $destFolder | Out-Null

# Destination file
$dest = "$destFolder/DocAutomations_v$version.aab"

if (!(Test-Path $src)) {
    Write-Host "❌ AAB file not found: $src"
    exit 1
}

# copy file
Copy-Item $src $dest -Force

Write-Host ""
Write-Host "✅ Build completed"
Write-Host "Saved to: $dest"