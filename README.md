debian-mini-odroid-c1
=====================

Script to build a minimal Debian read-only root sd card image.

## Features:
* SSH root login password: odroid
* Host name: odroidc1-MACADDRESS (e.g. odroidc1-1a2b3c4d5e6f)
* Read-only root file system: /tmp, /root, /var/log, /media are tmpfs file systems and are writable, but won't persist
* SSH host keys are generated and saved permanently on first boot
* Automatic mounting of USB storage devices using usbmount

## TODO:
* Move parts or all of /var to tmpfs:
  * can't create /var/lib/dhcp/dhclient.eth0.leases: Read-only file system
* apt-get update doesn't work unless you remount,rw / first, even though there is a hook in /etc/apt/apt.conf.d/00autoremount that should be doing this...

## Prerequisites:
On a Ubuntu system, make sure the following packages are installed:
> sudo apt-get install build-essential wget git lzop u-boot-tools binfmt-support qemu qemu-user-static debootstrap parted

If you are running 64 bit Ubuntu, you might need to run the following commands to be able to launch the 32 bit toolchain:
> sudo dpkg --add-architecture i386
> sudo apt-get update
> sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1

## Build the image:
Just use the make utility to build an sdcard.img.  Be sure to run this with sudo, as root privileges are required to mount the image.

> sudo make

This will install the toolchains, compile u-boot, the kernel, bootstrap Debian and create a 512mb sdcard.img file, which then can be transferred to a sd card (e.g. using dd):

> sudo dd bs=1M if=sdcard.img of=/dev/YOUR_SD_CARD
