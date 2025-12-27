#!/bin/bash
set -e

BASE_DIR=$(pwd)
TOOLCHAIN_BIN="$BASE_DIR/toolchain/bin"
TOOLCHAIN_LIB="$BASE_DIR/toolchain/lib"
SYSROOT="$BASE_DIR/sysroot"
SOURCE="$BASE_DIR/citron-source"
BUILD_DIR="$BASE_DIR/build-pgo"

# Setup environment to use bundled tools
export PATH="$TOOLCHAIN_BIN:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN_LIB:$SYSROOT/lib:$LD_LIBRARY_PATH"

echo "--- Citron PGO Training: Stage 1 (Instrumentation) ---"

# Performance check for Steam Deck
JOBS=$(nproc)
if grep -q "Vangogh" /proc/cpuinfo; then
    echo "Steam Deck detected. Capping build threads to 4 for stability..."
    JOBS=4
fi

mkdir -p "$BUILD_DIR"
mkdir -p "$BASE_DIR/pgo-profiles"
cd "$BUILD_DIR"

# Use the bundled portable CMake
cmake "$SOURCE" -GNinja \
    -DCMAKE_C_COMPILER="$TOOLCHAIN_BIN/gcc" \
    -DCMAKE_CXX_COMPILER="$TOOLCHAIN_BIN/g++" \
    -DCITRON_ENABLE_PGO_GENERATE=ON \
    -DCITRON_PGO_PROFILE_DIR="$BASE_DIR/pgo-profiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-march=native -O3 -w" \
    -DCMAKE_PREFIX_PATH="$SYSROOT" \
    -DENABLE_QT6=ON \
    -DCITRON_USE_BUNDLED_VCPKG=OFF

ninja -j$JOBS

echo ""
echo "=========================================================="
echo "TRAINING READY: Citron will now launch."
echo "1. Play demanding games for 10-15 mins."
echo "2. Close Citron normally when finished."
echo "=========================================================="
echo ""

./bin/citron
