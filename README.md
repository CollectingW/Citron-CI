# Citron-Nightly 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/Zephyron-Dev/Citron-CI/total?logo=github&label=GitHub%20Downloads)](https://github.com/Zephyron-Dev/Citron-CI/releases/latest)
[![CI Build Status](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-stable.yml/badge.svg)](https://github.com/Zephyron-Dev/Citron-CI/releases/latest)

This repository makes Nightly builds for **x86_64** (generic) and **x86_64_v3** on Linux, and also Windows & Android builds! If your CPU is less than 10 years old, for Linux, use the x86_64_v3 build since it has a significant performance boost. These builds are all produced @ 12 AM UTC every single day.

* [Latest Commits Can Be Found Here](https://git.citron-emu.org/citron/emulator/-/commits/f3374ea7e61cb0bba79d17272964717e37935575)

* [Latest Android Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-android)

* [Latest Linux Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-linux)

* [Latest Windows Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-windows)

# READ THIS IF YOU HAVE ISSUES

If you are on wayland (specially GNOME wayland) and get freezes or crahes you are likely affected by this issue that affects all Qt6 apps: https://github.com/Zephyron-Dev/Citron-CI/issues/50

To fix it simply set the env variable `QT_QPA_PLATFORM=xcb`

---

**Looking for AppImages of other emulators? Check:** [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/) 

----

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks.

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i citron` or `appman -i citron`

* [dbin](https://github.com/xplshn/dbin) `dbin install citron.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install citron`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

