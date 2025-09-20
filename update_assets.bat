@echo off
echo Updating app icon...
flutter pub run flutter_launcher_icons:main

echo Updating splash screen...
flutter pub run flutter_native_splash:create

echo Done! App icon and splash screen updated.
pause
