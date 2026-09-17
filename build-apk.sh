#!/usr/bin/env bash
# ==============================================================================
# DroidDesk - Pixel 10 Pro XL PowerVR Edition APK Build Script
# ==============================================================================
set -e

echo "=== Building DroidDesk Android APK (PowerVR / Pixel 10 Pro XL) ==="

# Check for Flutter
if ! command -v flutter &> /dev/null; then
    echo "[!] Error: Flutter SDK is not installed or not in PATH."
    echo "    Please install Flutter from https://flutter.dev and ensure Android SDK + NDK are configured."
    exit 1
fi

echo "[*] Fetching internal native dependencies..."
if [ -f "./fetch_deps.sh" ]; then
    ./fetch_deps.sh || true
fi

echo "[*] Resolving Flutter packages..."
cd app
flutter pub get

echo "[*] Compiling Release APK for ARM64-v8a (PowerVR / Tensor G5)..."
flutter build apk --release

echo ""
echo "=============================================================================="
echo "[+] Build complete!"
echo "    APK Output Location: app/build/app/outputs/flutter-apk/app-release.apk"
echo "=============================================================================="
