debian-mini-odroid-c1
=====================

Script to build a minimal Debian read-only root sd card image.

## Prerequisites:
On a Ubuntu system, make sure the following packages are installed:
> sudo apt-get install build-essential wget git lzop u-boot-tools binfmt-support qemu qemu-user-static debootstrap

If you are running 64 bit Ubuntu, you might need to run the following commands to be able to launch the 32 bit toolchain:
> sudo dpkg --add-architecture i386
> sudo apt-get update
> sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1

## Usage:

Just use the make utility to build an sdcard.img.  Be sure to run this with sudo, as root privileges are required to mount the image.

> sudo make

This will install the toolchains, compile u-boot, the kernel, bootstrap Debian and create a 512mb sdcard.img file, which then can be transferred to a sd card (e.g. using dd):

> sudo dd bs=1M if=sdcard.img of=/dev/YOUR_SD_CARD
