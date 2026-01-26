# 🍋 The Official Citron-CI

[![GitHub Downloads](https://img.shields.io/github/downloads/Zephyron-Dev/Citron-CI/total?logo=github&label=GitHub%20Downloads)](https://github.com/Zephyron-Dev/Citron-CI/releases/latest)
[![Build Citron (Android)](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-android.yml/badge.svg)](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-android.yml)
[![Build Citron (Windows)](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-windows.yml/badge.svg)](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-windows.yml)
[![Build Citron (Linux)](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-linux.yml/badge.svg)](https://github.com/Zephyron-Dev/Citron-CI/actions/workflows/build-linux.yml)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Zephyron-Dev/Citron-CI&type=date&legend=top-left)](https://www.star-history.com/#Zephyron-Dev/Citron-CI&type=date&legend=top-left)

---

This repository makes Nightly builds for **x86_64** (Standard), **x86_64_v3** (CPU's that are from 2013+) & **aarch64** on Linux, and also Windows, Android & macOS builds! These builds are all produced @ 12 AM UTC every single day.

Would you like to submit a compatibility report for the emulator? You can do so here:

* [Submit Compatibility Report](https://github.com/CollectingW/Citron-Compatability)

---

Direct links for other information you may need can also be found below:

* [Latest Commits Can Be Found Here](https://git.citron-emu.org/Citron/Emulator/commits/branch/main)

* [Latest Android Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-android)

* [Latest Linux Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-linux)

* [Latest Windows Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-windows)

* [Latest macOS Nightly Release](https://github.com/Zephyron-Dev/Citron-CI/releases/tag/nightly-macos)

---

# READ THIS IF YOU HAVE ISSUES

If you are on wayland (specially GNOME wayland) and get freezes or crashes, you are likely affected by this issue that affects all Qt6 apps: https://github.com/Zephyron-Dev/Citron-CI/issues/50

To fix it simply set the env variable `QT_QPA_PLATFORM=xcb`

**Also, are you looking for AppImages of other emulators? Check:** [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/) 

----

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks.

**These AppImages bundle everything and should work on any Linux distro, even on musl based ones.**

It is possible that the AppImages may fail to work with appimagelauncher, we recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i citron` or `appman -i citron`

* [dbin](https://github.com/xplshn/dbin) `dbin install citron.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install citron`

These AppImages works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

**The following information above and the creation of the AppImages Citron currently creates & distributes derives from Pkgforges previous work. You can find their repository here: https://github.com/pkgforge-dev/Citron-AppImage**

---

Thank-you for being apart of & using Citron, we value all members of the community whom help shape the emulator into what it is today!
- The Citron Team
