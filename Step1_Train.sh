#!/bin/bash
set -e

# Setup internal paths
BASE_DIR=$(pwd)
TOOLCHAIN="$BASE_DIR/toolchain"
SYSROOT="$BASE_DIR/sysroot"
SOURCE="$BASE_DIR/citron-source"
BUILD_DIR="$BASE_DIR/build-pgo"

# Add bundled tools to PATH
export PATH="$TOOLCHAIN:$PATH"
export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"

echo "--- Citron PGO Training: Stage 1 ---"

# Check for RAM/Swap on Steam Deck
if grep -q "Vangogh" /proc/cpuinfo; then
    echo "Detected Steam Deck hardware..."
    MEM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$MEM" -lt 15 ]; then
        echo "WARNING: Low RAM detected. Ensure you have a Swap file enabled!"
    fi
    JOBS=4
else
    JOBS=$(nproc)
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Configuring Instrumented Build..."
cmake "$SOURCE" -GNinja \
    -DCMAKE_C_COMPILER="$TOOLCHAIN/gcc" \
    -DCMAKE_CXX_COMPILER="$TOOLCHAIN/g++" \
    -DCITRON_ENABLE_PGO_GENERATE=ON \
    -DCITRON_PGO_PROFILE_DIR="$BASE_DIR/pgo-profiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-march=native -O3 -w" \
    -DCMAKE_PREFIX_PATH="$SYSROOT" \
    -DENABLE_QT6=ON \
    -DCITRON_USE_BUNDLED_VCPKG=OFF

echo "Building Citron (Stage 1)..."
ninja -j$JOBS

echo ""
echo "=========================================================="
echo "SUCCESS: Instrumented Citron is ready."
echo "The emulator will now launch."
echo "PLEASE DO THE FOLLOWING:"
echo "1. Play demanding games for 30 minutes/an hour (at maximum, albiet not very necessary."
echo "2. Ensure you visit different areas/menus. The best data you can get is various, do not stay in one spot for too long."
echo "3. Close the emulator NORMALLY when finished using either Ctrl-Q or on Steam Deck, ensure in Desktop mode to do the same or use File -> Exit. A good idea is to run in konsole to ensure you see there was no segmentation faults upon closing, so your data is not corrupt."
echo "=========================================================="
echo ""

./bin/citron
