#!/bin/sh
set -ex

# 1. Setup
ARCH="${ARCH:-$(uname -m)}"
export VERSION="${APP_VERSION:-nightly}"
RELEASE_URL="https://github.com/CollectingW/Citron-CI/releases/download/binary"

# 2. Assets
wget -q "$RELEASE_URL/citron" -O ./citron
wget -q "$RELEASE_URL/citron.svg" -O ./citron.svg
wget -q "$RELEASE_URL/org.citron_emu.citron.desktop" -O ./org.citron_emu.citron.desktop
chmod +x ./citron

echo "Creating System-level Compatibility Links..."
sudo ln -sf /usr/lib/libboost_context.so /usr/lib/libboost_context.so.1.83.0
sudo ln -sf /usr/lib/libboost_thread.so /usr/lib/libboost_thread.so.1.83.0
sudo ln -sf /usr/lib/libfmt.so /usr/lib/libfmt.so.11
# Refresh the system library cache
sudo ldconfig

# 4. Final Verification (Should show NO 'not found' now)
ldd ./citron

# 5. Packaging Setup
export DESKTOP="$(pwd)/org.citron_emu.citron.desktop"
export ICON="$(pwd)/citron.svg"
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh -O ./quick-sharun
chmod +x ./quick-sharun

# 6. HEAVY BUNDLING
# We tell sharun exactly where the heavy files are
xvfb-run --auto-servernum ./quick-sharun ./citron \
    /usr/lib/libboost_*.so* \
    /usr/lib/libavcodec.so* \
    /usr/lib/libavutil.so* \
    /usr/lib/libavformat.so* \
    /usr/lib/libswscale.so* \
    /usr/lib/libfmt.so* \
    /usr/lib/libenet.so* \
    /usr/lib/libSDL2*.so*

# 7. THE STEAM DECK INTERNAL FIX
# Now we make sure those links exist INSIDE the AppImage too
echo "Fixing internal AppImage links..."
cd AppDir/shared/lib/
ln -sf libboost_context.so.1.89.0 libboost_context.so.1.83.0 || true
ln -sf libboost_thread.so.1.89.0 libboost_thread.so.1.83.0 || true
ln -sf libfmt.so.11.* libfmt.so.11 || true
cd ../../../

echo "Copying translations..."
mkdir -p ./AppDir/usr/share/qt6
cp -r /usr/share/qt6/translations ./AppDir/usr/share/qt6/

# 8. Create AppImage
wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh -O ./uruntime2appimage
chmod +x ./uruntime2appimage

BUILD_OUTPUT=$(./uruntime2appimage)
echo "$BUILD_OUTPUT"

SOURCE_APPIMAGE=$(echo "$BUILD_OUTPUT" | grep "All done! AppImage at:" | awk '{print $NF}' | sed 's/\x1b\[[0-9;]*m//g' | xargs basename)

mkdir -p ./dist
mv -v "${SOURCE_APPIMAGE}" "./dist/citron_nightly-${VERSION}-linux-${ARCH}.AppImage"
