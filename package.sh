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

# 3. Debug: Check exactly what the binary wants before we start
echo "Checking binary requirements..."
ldd ./citron || true

# 4. Packaging Setup
export DESKTOP="$(pwd)/org.citron_emu.citron.desktop"
export ICON="$(pwd)/citron.svg"
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh -O ./quick-sharun
chmod +x ./quick-sharun

# 5. Bundling - FORCING the heavy libraries to ensure size and compatibility
echo "Forcing bundling of system libraries..."
xvfb-run --auto-servernum ./quick-sharun ./citron \
    /usr/lib/libboost*.so* \
    /usr/lib/libfmt.so* \
    /usr/lib/libenet.so* \
    /usr/lib/libSDL2-2.0.so* \
    /usr/lib/libssl.so* \
    /usr/lib/libcrypto.so* \
    /usr/lib/libgamemode.so* \
    /usr/lib/libpulse.so*

# 6. THE UNIVERSAL VERSION FIX
# This goes through every major library and tells it: 
# "If the app asks for version X, give it whatever version we have."
echo "Applying universal version compatibility fixes..."
cd AppDir/shared/lib/
for lib_path in libboost_context.so libboost_thread.so libboost_filesystem.so libfmt.so libenet.so; do
    # Find the actual file we bundled (e.g., libfmt.so.11.0.2)
    actual_file=$(ls $lib_path* | head -n 1)
    if [ -f "$actual_file" ]; then
        echo "Linking $actual_file for compatibility..."
        # Link for Steam Deck versions
        ln -sf "$actual_file" "libboost_context.so.1.83.0" || true
        ln -sf "$actual_file" "libfmt.so.10" || true
        ln -sf "$actual_file" "libfmt.so.11" || true
    fi
done
cd ../../../

echo "Copying Qt translation files..."
mkdir -p ./AppDir/usr/share/qt6
cp -r /usr/share/qt6/translations ./AppDir/usr/share/qt6/

if [ "$DEVEL" = 'true' ]; then
	sed -i 's|Name=citron|Name=citron nightly|' ./AppDir/org.citron_emu.citron.desktop
fi

echo 'SHARUN_ALLOW_SYS_VK_ICD=1' > ./AppDir/.env

# 7. AppImage Creation
wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh -O ./uruntime2appimage
chmod +x ./uruntime2appimage

BUILD_OUTPUT=$(./uruntime2appimage)
echo "$BUILD_OUTPUT"

SOURCE_APPIMAGE=$(echo "$BUILD_OUTPUT" | grep "All done! AppImage at:" | awk '{print $NF}' | sed 's/\x1b\[[0-9;]*m//g' | xargs basename)

mkdir -p ./dist
mv -v "${SOURCE_APPIMAGE}" "./dist/citron_nightly-${VERSION}-linux-${ARCH}.AppImage"
