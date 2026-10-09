# PowerShell script to build Release APK for My Medical History
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Building 'My Medical History' Android APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Check Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Flutter is not in PATH." -ForegroundColor Yellow
    Write-Host "    If you installed Flutter in 'C:\src\flutter\bin', add it to your PATH." -ForegroundColor Yellow
    Write-Host "    Then re-run this script." -ForegroundColor Yellow
    exit 1
}

# 2. Get packages
Write-Host "`n[1/3] Fetching Flutter dependencies..." -ForegroundColor Green
flutter pub get

# 3. Build APK
Write-Host "`n[2/3] Compiling Release APK (Please wait 2-4 minutes)..." -ForegroundColor Green
flutter build apk --release

# 4. Locate APK
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    Write-Host "`n[3/3] SUCCESS! APK created at:" -ForegroundColor Green
    Write-Host (Resolve-Path $apkPath) -ForegroundColor Cyan
    Write-Host "`nAap is file ko direct apne Android phone me send karke install kar sakte hain!" -ForegroundColor White
    explorer.exe "build\app\outputs\flutter-apk"
} else {
    Write-Host "`n[!] APK build failed. Please review error messages above." -ForegroundColor Red
}
