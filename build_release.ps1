# Build Flutter AAB
#flutter build appbundle 
flutter build appbundle --split-debug-info=build/symbols

# Read version from pubspec.yaml
$pubspec = Get-Content pubspec.yaml
$versionLine = $pubspec | Select-String "^version:"
$version = $versionLine.ToString().Split(" ")[1]

# File paths
$src = "build/app/outputs/bundle/release/app-release.aab"
$destFolder = "builds"

# Create folder if not exists
New-Item -ItemType Directory -Force -Path $destFolder | Out-Null

# Destination file
$dest = "$destFolder/DocAutomations_v$version.aab"

# Move file
Move-Item $src $dest -Force

Write-Host ""
Write-Host "✅ Build completed"
Write-Host "Saved to: $dest"