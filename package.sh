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

# ---------------------------------------------------------
# 3. THE ULTIMATE COMPATIBILITY BRIDGE
# ---------------------------------------------------------
echo "Fixing missing system links..."

# Fix Boost and Fmt (Already proven to work)
sudo ln -sf /usr/lib/libboost_context.so /usr/lib/libboost_context.so.1.83.0
sudo ln -sf /usr/lib/libboost_thread.so /usr/lib/libboost_thread.so.1.83.0
sudo ln -sf /usr/lib/libfmt.so /usr/lib/libfmt.so.11

# Fix FFmpeg (The missing 40MB)
# We map the generic Arch FFmpeg libs to the specific versions Citron wants
sudo ln -sf /usr/lib/libavcodec.so    /usr/lib/libavcodec.so.61
sudo ln -sf /usr/lib/libavdevice.so   /usr/lib/libavdevice.so.61
sudo ln -sf /usr/lib/libavfilter.so   /usr/lib/libavfilter.so.10
sudo ln -sf /usr/lib/libavformat.so   /usr/lib/libavformat.so.61
sudo ln -sf /usr/lib/libavutil.so     /usr/lib/libavutil.so.59
sudo ln -sf /usr/lib/libswresample.so /usr/lib/libswresample.so.5
sudo ln -sf /usr/lib/libswscale.so    /usr/lib/libswscale.so.8

# Refresh the system library cache
sudo ldconfig

# 4. FINAL VERIFICATION (Ensure NOTHING is 'not found')
echo "Verifying all dependencies are found..."
ldd ./citron

# 5. Packaging Setup
export DESKTOP="$(pwd)/org.citron_emu.citron.desktop"
export ICON="$(pwd)/citron.svg"
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh -O ./quick-sharun
chmod +x ./quick-sharun

# 6. BUNDLING
# We include FFmpeg explicitly to be 100% safe
xvfb-run --auto-servernum ./quick-sharun ./citron \
    /usr/lib/libboost_*.so* \
    /usr/lib/libav*.so* \
    /usr/lib/libsw*.so* \
    /usr/lib/libfmt.so* \
    /usr/lib/libenet.so* \
    /usr/lib/libSDL2*.so* \
    /usr/lib/libgamemode.so* \
    /usr/lib/libpulse.so*

# 7. STEAM DECK INTERNAL LINKS
# This ensures that inside the AppImage, Citron finds the version names it expects
echo "Fixing internal AppImage links..."
cd AppDir/shared/lib/
# Get the actual version names from the bundled files and link them
ln -sf libboost_context.so.1.* libboost_context.so.1.83.0 || true
ln -sf libboost_thread.so.1.* libboost_thread.so.1.83.0 || true
ln -sf libfmt.so.11.* libfmt.so.11 || true
# FFmpeg links
ln -sf libavcodec.so.61.* libavcodec.so.61 || true
ln -sf libavdevice.so.61.* libavdevice.so.61 || true
ln -sf libavfilter.so.10.* libavfilter.so.10 || true
ln -sf libavformat.so.61.* libavformat.so.61 || true
ln -sf libavutil.so.59.* libavutil.so.59 || true
ln -sf libswresample.so.5.* libswresample.so.5 || true
ln -sf libswscale.so.8.* libswscale.so.8 || true
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
