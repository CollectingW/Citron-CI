#!/bin/bash
set -e

BASE_DIR=$(pwd)
TOOLCHAIN_BIN="$BASE_DIR/toolchain/bin"
TOOLCHAIN_LIB="$BASE_DIR/toolchain/lib"
SYSROOT="$BASE_DIR/sysroot"
SOURCE="$BASE_DIR/citron-source"
BUILD_DIR="$BASE_DIR/build-pgo"
PROFILE_DIR="$BASE_DIR/pgo-profiles"

export PATH="$TOOLCHAIN_BIN:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN_LIB:$SYSROOT/lib:$LD_LIBRARY_PATH"

if [ ! -d "$PROFILE_DIR" ] || [ -z "$(ls -A "$PROFILE_DIR")" ]; then
    echo "ERROR: Profile data missing. Please run Step 1 first."
    exit 1
fi

echo "--- Citron PGO Optimization: Stage 2 (Final Build) ---"

cd "$BUILD_DIR"
ninja clean

cmake "$SOURCE" -GNinja \
    -DCMAKE_C_COMPILER="$TOOLCHAIN_BIN/gcc" \
    -DCMAKE_CXX_COMPILER="$TOOLCHAIN_BIN/g++" \
    -DCITRON_ENABLE_PGO_USE=ON \
    -DCITRON_PGO_PROFILE_DIR="$PROFILE_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-march=native -O3 -fprofile-correction" \
    -DCMAKE_PREFIX_PATH="$SYSROOT"

JOBS=$(nproc)
[ "$JOBS" -gt 4 ] && [ -f /etc/steamos-release ] && JOBS=4
ninja -j$JOBS

echo "Optimization complete. Creating your portable AppImage..."
cd "$BASE_DIR"
./package-local.sh
