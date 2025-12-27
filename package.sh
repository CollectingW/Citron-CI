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

# 3. Packaging Setup
export DESKTOP="$(pwd)/org.citron_emu.citron.desktop"
export ICON="$(pwd)/citron.svg"
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh -O ./quick-sharun
chmod +x ./quick-sharun

# 4. THE BRUTE FORCE BUNDLE
# We are going to explicitly tell sharun to grab every single library
# Citron needs, using wildcards to ensure we get the full ~150MB.
xvfb-run --auto-servernum ./quick-sharun ./citron \
    /usr/lib/libboost_*.so* \
    /usr/lib/libavcodec.so* \
    /usr/lib/libavutil.so* \
    /usr/lib/libavformat.so* \
    /usr/lib/libavfilter.so* \
    /usr/lib/libavdevice.so* \
    /usr/lib/libswscale.so* \
    /usr/lib/libswresample.so* \
    /usr/lib/libfmt.so* \
    /usr/lib/libenet.so* \
    /usr/lib/libSDL2*.so* \
    /usr/lib/libcrypto.so* \
    /usr/lib/libssl.so*

# 5. THE COMPATIBILITY BRIDGE (Inside the AppDir)
# Now that the files are safely inside the AppImage folder, 
# we create the specific names Citron is looking for.
echo "Creating compatibility links inside AppDir..."
cd AppDir/shared/lib/

# This loop finds whatever version was bundled and creates the "v1.83" or "v11" link Citron wants.
fix_link() {
    local target=$1
    local link_name=$2
    # Find the actual file (e.g., libboost_context.so.1.89.0)
    local actual=$(ls $target* 2>/dev/null | head -n 1)
    if [ -n "$actual" ]; then
        ln -sf "$(basename "$actual")" "$link_name"
    fi
}

fix_link "libboost_context.so" "libboost_context.so.1.83.0"
fix_link "libboost_thread.so" "libboost_thread.so.1.83.0"
fix_link "libfmt.so" "libfmt.so.11"
fix_link "libavcodec.so" "libavcodec.so.61"
fix_link "libavformat.so" "libavformat.so.61"
fix_link "libavutil.so" "libavutil.so.59"
fix_link "libavfilter.so" "libavfilter.so.10"
fix_link "libavdevice.so" "libavdevice.so.61"
fix_link "libswscale.so" "libswscale.so.8"
fix_link "libswresample.so" "libswresample.so.5"

cd ../../../

# 6. Copy translations
mkdir -p ./AppDir/usr/share/qt6
cp -r /usr/share/qt6/translations ./AppDir/usr/share/qt6/

if [ "$DEVEL" = 'true' ]; then
	sed -i 's|Name=citron|Name=citron nightly|' ./AppDir/org.citron_emu.citron.desktop
fi

echo 'SHARUN_ALLOW_SYS_VK_ICD=1' > ./AppDir/.env

# 7. Create AppImage
wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh -O ./uruntime2appimage
chmod +x ./uruntime2appimage

BUILD_OUTPUT=$(./uruntime2appimage)
echo "$BUILD_OUTPUT"

SOURCE_APPIMAGE=$(echo "$BUILD_OUTPUT" | grep "All done! AppImage at:" | awk '{print $NF}' | sed 's/\x1b\[[0-9;]*m//g' | xargs basename)

mkdir -p ./dist
mv -v "${SOURCE_APPIMAGE}" "./dist/citron_nightly-${VERSION}-linux-${ARCH}.AppImage"
