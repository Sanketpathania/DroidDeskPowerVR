#!/bin/bash

# Termux packages URL base
URL_BASE="https://packages-cf.termux.dev/apt/termux-main/pool/main"

# Packages we need to download
PACKAGES=(
    "w/wlroots/wlroots_0.17.4-1_aarch64.deb"
    "w/wayland/wayland_1.22.0-1_aarch64.deb"
    "l/libxkbcommon/libxkbcommon_1.7.0-1_aarch64.deb"
    "p/pixman/pixman_0.43.4-1_aarch64.deb"
    "l/libdrm/libdrm_2.4.120-1_aarch64.deb"
    "l/libffi/libffi_3.4.6_aarch64.deb"
)

# Output directories (relative to repository root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JNILIBS_DIR="$SCRIPT_DIR/app/android/app/src/main/jniLibs/arm64-v8a"
INCLUDE_DIR="$SCRIPT_DIR/app/android/app/src/main/cpp/include"

mkdir -p "$JNILIBS_DIR"
mkdir -p "$INCLUDE_DIR"
WORK_DIR="/tmp/wlroots_deps_$$"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

for pkg in "${PACKAGES[@]}"; do
    filename=$(basename "$pkg")
    echo "Downloading $filename..."
    curl -sL "$URL_BASE/$pkg" -o "$filename"
    
    # Extract using dpkg-deb (Linux), bsdtar (macOS), or standard ar + tar
    mkdir -p ./pkg_extracted
    if command -v dpkg-deb >/dev/null 2>&1; then
        dpkg-deb -x "$filename" ./pkg_extracted
    elif command -v bsdtar >/dev/null 2>&1; then
        bsdtar -xf "$filename"
        if [ -f data.tar.xz ]; then bsdtar -xf data.tar.xz -C ./pkg_extracted; fi
        if [ -f data.tar.gz ]; then bsdtar -xf data.tar.gz -C ./pkg_extracted; fi
    else
        ar -x "$filename"
        if [ -f data.tar.xz ]; then tar -xf data.tar.xz -C ./pkg_extracted; fi
        if [ -f data.tar.gz ]; then tar -xf data.tar.gz -C ./pkg_extracted; fi
    fi
    
    # Copy shared libraries
    if [ -d "./pkg_extracted/data/data/com.termux/files/usr/lib" ]; then
        find ./pkg_extracted/data/data/com.termux/files/usr/lib -name "*.so*" -type f -exec cp {} "$JNILIBS_DIR/" \;
        find ./pkg_extracted/data/data/com.termux/files/usr/lib -name "*.so*" -type l -exec cp -a {} "$JNILIBS_DIR/" \;
    fi
    
    # Copy headers
    if [ -d "./pkg_extracted/data/data/com.termux/files/usr/include" ]; then
        cp -r ./pkg_extracted/data/data/com.termux/files/usr/include/* "$INCLUDE_DIR/"
    fi
    
    # Clean up for next package
    rm -rf pkg_extracted data control.tar.* data.tar.* debian-binary "$filename"
done

cd "$SCRIPT_DIR"
rm -rf "$WORK_DIR"

echo "Done fetching wlroots dependencies!"

# Verify or download Termux bootstrap-aarch64.zip required by Flutter assets
BOOTSTRAP_ZIP="$SCRIPT_DIR/app/assets/bootstrap-aarch64.zip"
if [ ! -f "$BOOTSTRAP_ZIP" ] || [ ! -s "$BOOTSTRAP_ZIP" ]; then
    echo "Fetching Termux bootstrap-aarch64.zip asset..."
    mkdir -p "$SCRIPT_DIR/app/assets"
    curl -L --retry 3 "https://github.com/termux/termux-packages/releases/download/bootstrap-2026.09.13-r1%2Bapt.android-7/bootstrap-aarch64.zip" -o "$BOOTSTRAP_ZIP"
    echo "Termux bootstrap-aarch64.zip asset downloaded successfully."
else
    echo "Termux bootstrap-aarch64.zip asset is already present."
fi
