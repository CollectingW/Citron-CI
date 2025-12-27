#!/bin/bash
set -ex

BASE_DIR=$(pwd)
BUILD_DIR="$BASE_DIR/build-pgo"
DIST_DIR="$BASE_DIR/dist"
APPDIR="$BASE_DIR/AppDir"
HELPERS="$BASE_DIR/helpers"
SYSROOT="$BASE_DIR/sysroot"

mkdir -p "$DIST_DIR"
rm -rf "$APPDIR" && mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"

# 1. Copy the optimized binary
cp "$BUILD_DIR/bin/citron" "$APPDIR/usr/bin/"

# 2. Use sharun to bundle sysroot libraries into the AppImage
# This makes the build portable across different distros
export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"
chmod +x "$HELPERS/quick-sharun"
"$HELPERS/quick-sharun" "$APPDIR/usr/bin/citron"

# 3. Copy metadata
cp "$BASE_DIR/citron-source/dist/citron.svg" "$APPDIR/citron.svg"
cp "$BASE_DIR/citron-source/dist/org.citron_emu.citron.desktop" "$APPDIR/"

# 4. Final AppImage creation
chmod +x "$HELPERS/uruntime2appimage"
"$HELPERS/uruntime2appimage" --appdir "$APPDIR"

mv *.AppImage "$DIST_DIR/Citron-PGO-Optimized-$(uname -m).AppImage"
echo "=========================================================="
echo "SUCCESS! Your optimized AppImage is in the 'dist' folder."
echo "=========================================================="
