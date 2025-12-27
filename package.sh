#!/bin/sh
set -ex

# 1. Configuration
ARCH="${ARCH:-$(uname -m)}"
export VERSION="${APP_VERSION:-nightly}"
RELEASE_URL="https://github.com/CollectingW/Citron-CI/releases/download/binary"

# 2. Download Assets
echo "Downloading assets..."
wget -q "$RELEASE_URL/citron" -O ./citron
wget -q "$RELEASE_URL/citron.svg" -O ./citron.svg
wget -q "$RELEASE_URL/org.citron_emu.citron.desktop" -O ./org.citron_emu.citron.desktop
chmod +x ./citron

# 3. Packaging Setup
export DESKTOP="$(pwd)/org.citron_emu.citron.desktop"
export ICON="$(pwd)/citron.svg"
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh -O ./quick-sharun
chmod +x ./quick-sharun

# 4. Bundling with EXPLICIT Boost inclusion
echo "Bundling dependencies..."
# We explicitly add /usr/lib/libboost*.so* to ensure every boost component is inside the AppImage
xvfb-run --auto-servernum ./quick-sharun ./citron \
    /usr/lib/libboost*.so* \
    /usr/lib/libenet.so* \
    /usr/lib/libgamemode.so* \
    /usr/lib/libpulse.so*

# --- BOOST VERSION FIX START ---
# If your local build looks for 1.83.0 but the CI has 1.87.0, we create a link.
# This ensures it runs on Steam Deck even if versions don't match perfectly.
echo "Applying Boost version compatibility fixes..."
cd AppDir/shared/lib/
for lib in libboost*.so*; do
    # Extract the base name (e.g., libboost_context.so)
    base_name=$(echo "$lib" | cut -d. -f1-2)
    # Create a link for the specific version the binary complained about
    ln -sf "$lib" "${base_name}.1.83.0"
done
cd ../../../
# --- BOOST VERSION FIX END ---

echo "Copying Qt translation files..."
mkdir -p ./AppDir/usr/share/qt6
cp -r /usr/share/qt6/translations ./AppDir/usr/share/qt6/

if [ "$DEVEL" = 'true' ]; then
	sed -i 's|Name=citron|Name=citron nightly|' ./AppDir/org.citron_emu.citron.desktop
fi

echo 'SHARUN_ALLOW_SYS_VK_ICD=1' > ./AppDir/.env

# 5. AppImage Creation
wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh -O ./uruntime2appimage
chmod +x ./uruntime2appimage

BUILD_OUTPUT=$(./uruntime2appimage)
SOURCE_APPIMAGE=$(echo "$BUILD_OUTPUT" | grep "All done! AppImage at:" | awk '{print $NF}' | sed 's/\x1b\[[0-9;]*m//g' | xargs basename)

mkdir -p ./dist
mv -v "${SOURCE_APPIMAGE}" "./dist/citron_nightly-${VERSION}-linux-${ARCH}.AppImage"
[ -f "${SOURCE_APPIMAGE}.zsync" ] && mv -v "${SOURCE_APPIMAGE}.zsync" "./dist/citron_nightly-${VERSION}-linux-${ARCH}.AppImage.zsync"
