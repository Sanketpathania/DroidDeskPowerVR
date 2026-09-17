#!/usr/bin/env bash
# ==============================================================================
# DroidDesk - Pixel 10 Pro XL PowerVR Edition APK Build Script
# ==============================================================================
set -e

echo "=== Building DroidDesk Android APK (PowerVR / Pixel 10 Pro XL) ==="

# Check for Flutter
if ! command -v flutter &> /dev/null; then
    echo "[!] Error: Flutter SDK is not installed or not in PATH."
    echo "    Please install Flutter from https://flutter.dev and ensure Android SDK + NDK (28.2.13676358) are configured."
    exit 1
fi

echo "[*] Fetching internal native dependencies..."
if [ -f "./fetch_deps.sh" ]; then
    chmod +x ./fetch_deps.sh
    ./fetch_deps.sh || true
fi

# Ensure bootstrap-aarch64.zip asset is present
if [ ! -f "app/assets/bootstrap-aarch64.zip" ] || [ ! -s "app/assets/bootstrap-aarch64.zip" ]; then
    echo "[*] Downloading Termux bootstrap asset..."
    mkdir -p app/assets
    curl -L --retry 3 "https://github.com/termux/termux-packages/releases/download/bootstrap-2026.09.13-r1%2Bapt.android-7/bootstrap-aarch64.zip" -o "app/assets/bootstrap-aarch64.zip"
fi

# Ensure stable release keystore
if [ ! -f "app/android/app/release.keystore" ]; then
    echo "[*] Generating release keystore..."
    mkdir -p app/android/app
    openssl req -x509 -newkey rsa:2048 -keyout /tmp/key.pem -out /tmp/cert.pem -days 10000 -nodes -subj "/CN=DroidDesk/O=DroidDesk/C=US"
    openssl pkcs12 -export -out app/android/app/release.keystore -inkey /tmp/key.pem -in /tmp/cert.pem -name droiddesk -password pass:droiddesk_release_password
    rm -f /tmp/key.pem /tmp/cert.pem
fi

echo "[*] Resolving Flutter packages..."
cd app
flutter pub get

echo "[*] Compiling Release APK for ARM64-v8a (PowerVR / Tensor G5)..."
flutter build apk --release --android-skip-build-dependency-validation

echo ""
echo "=============================================================================="
echo "[+] Build complete!"
echo "    APK Output Location: app/build/app/outputs/flutter-apk/app-release.apk"
echo "=============================================================================="
