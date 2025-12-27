#!/bin/bash
set -ex

BASE_DIR=$(pwd)
BUILD_DIR="$BASE_DIR/build-pgo"
DIST_DIR="$BASE_DIR/dist"
APPDIR="$BASE_DIR/AppDir"

mkdir -p "$DIST_DIR"
rm -rf "$APPDIR" && mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"

echo "Collecting binaries..."
cp "$BUILD_DIR/bin/citron" "$APPDIR/usr/bin/"

# Use Sharun logic to make it portable
# Note: We assume quick-sharun was bundled in the zip
chmod +x ./quick-sharun
./quick-sharun "$APPDIR/usr/bin/citron"

# Copy Desktop/Icons from source
cp "$BASE_DIR/citron-source/dist/citron.svg" "$APPDIR/citron.svg"
cp "$BASE_DIR/citron-source/dist/org.citron_emu.citron.desktop" "$APPDIR/"

echo "Generating AppImage..."
# Use the bundled uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage --appdir "$APPDIR"

mv *.AppImage "$DIST_DIR/Citron-PGO-Optimized-$(uname -m).AppImage"
echo "DONE! Your optimized AppImage is in the /dist folder."
