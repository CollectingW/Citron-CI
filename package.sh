#!/bin/sh
set -ex

# 1. Configuration
ARCH="${ARCH:-$(uname -m)}"
if [ -z "$APP_VERSION" ]; then
    echo "Error: APP_VERSION environment variable is not set."
    exit 1
fi

# Link to your release assets
RELEASE_URL="https://github.com/CollectingW/Citron-CI/releases/download/binary"

# 2. Download Assets from the Release
echo "Downloading assets from GitHub..."
wget -q "$RELEASE_URL/citron" -O ./citron
wget -q "$RELEASE_URL/citron.svg" -O ./citron.svg
wget -q "$RELEASE_URL/org.citron_emu.citron.desktop" -O ./org.citron_emu.citron.desktop

# Ensure binary is executable
chmod +x ./citron

# Naming setup
OUTNAME_BASE="citron_nightly-${APP_VERSION}-linux-${ARCH}"
export OUTNAME_APPIMAGE="${OUTNAME_BASE}.AppImage"
export OUTNAME_TAR="${OUTNAME_BASE}.tar.zst"

# External tools
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

# 3. Point Metadata to the downloaded files
export DESKTOP="$(pwd)/org.citron_emu.citron.desktop"
export ICON="$(pwd)/citron.svg"

export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

# Fetch and run sharun
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun

# Pass the local binary to sharun
# Wrap with xvfb-run to ensure a display environment is present
xvfb-run --auto-servernum ./quick-sharun ./citron /usr/lib/libgamemode.so* /usr/lib/libpulse.so*

echo "Copying Qt translation files..."
mkdir -p ./AppDir/usr/share/qt6
# Note: CI environment (Arch) provides the latest translations
cp -r /usr/share/qt6/translations ./AppDir/usr/share/qt6/

if [ "$DEVEL" = 'true' ]; then
	sed -i 's|Name=citron|Name=citron nightly|' ./AppDir/*.desktop
fi

echo 'SHARUN_ALLOW_SYS_VK_ICD=1' > ./AppDir/.env

echo "Creating tar.zst archive..."
(cd AppDir && tar -c --zstd -f ../"$OUTNAME_TAR" usr)

# 4. AppImage Creation
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage

BUILD_OUTPUT=$(./uruntime2appimage)
echo "$BUILD_OUTPUT"

SOURCE_APPIMAGE=$(basename "$(echo "$BUILD_OUTPUT" | grep "All done! AppImage at:" | awk '{print $NF}' | sed 's/\x1b\[[0-9;]*m//g')")

# Finalize organization
mkdir -p ./dist
mv -v "${SOURCE_APPIMAGE}" "./dist/${OUTNAME_APPIMAGE}"
[ -f "${SOURCE_APPIMAGE}.zsync" ] && mv -v "${SOURCE_APPIMAGE}.zsync" "./dist/${OUTNAME_APPIMAGE}.zsync"
mv -v ./*.tar.zst ./dist/
