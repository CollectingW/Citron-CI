#!/bin/bash
set -e

BASE_DIR=$(pwd)
TOOLCHAIN="$BASE_DIR/toolchain"
SYSROOT="$BASE_DIR/sysroot"
SOURCE="$BASE_DIR/citron-source"
BUILD_DIR="$BASE_DIR/build-pgo"
PROFILE_DIR="$BASE_DIR/pgo-profiles"

export PATH="$TOOLCHAIN:$PATH"
export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"

if [ ! -d "$PROFILE_DIR" ] || [ -z "$(ls -A "$PROFILE_DIR")" ]; then
    echo "ERROR: No PGO profile data found in $PROFILE_DIR."
    echo "Did you run Step 1 and play a game?"
    exit 1
fi

echo "--- Citron PGO Optimization: Stage 2 ---"

cd "$BUILD_DIR"

# Clean the instrumented object files but keep the profiles
echo "Cleaning Stage 1 files..."
ninja clean

echo "Configuring Optimized Build..."
cmake "$SOURCE" -GNinja \
    -DCMAKE_C_COMPILER="$TOOLCHAIN/gcc" \
    -DCMAKE_CXX_COMPILER="$TOOLCHAIN/g++" \
    -DCITRON_ENABLE_PGO_USE=ON \
    -DCITRON_PGO_PROFILE_DIR="$PROFILE_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-march=native -O3 -fprofile-correction" \
    -DCMAKE_PREFIX_PATH="$SYSROOT"

echo "Building Optimized Citron (Final Stage)..."
JOBS=$(nproc)
[ "$JOBS" -gt 4 ] && JOBS=4 # Safety cap for Deck
ninja -j$JOBS

echo "Build Complete! Starting AppImage Packaging..."
cd "$BASE_DIR"
./package-local.sh
