DIST := stable
DIST_URL := http://http.debian.net/debian/
DIST_ARCH := armhf

BOOT_MB := 32
ROOT_MB := 768

BOOT_DIR := boot
MODS_DIR := mods
ROOTFS_DIR := rootfs
RAMDISK_FILE := uInitrd
IMAGE_FILE := sdcard.img

UBOOT_TOOLCHAIN := gcc-linaro-4.9-2014.11-x86_64_arm-eabi.tar.xz
UBOOT_TOOLCHAIN_URL := http://releases.linaro.org/14.11/components/toolchain/binaries/arm-none-eabi/$(UBOOT_TOOLCHAIN)
UBOOT_TC_DIR := uboot_tc
UBOOT_TC_PATH := $(UBOOT_TC_DIR)/bin
UBOOT_REPO := https://github.com/hardkernel/u-boot.git
UBOOT_BRANCH := odroidc-v2011.03
UBOOT_SRC := u-boot

LINUX_TOOLCHAIN := gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf.tar.xz
LINUX_TOOLCHAIN_URL := http://releases.linaro.org/14.11/components/toolchain/binaries/arm-linux-gnueabihf/$(LINUX_TOOLCHAIN)
LINUX_TC_DIR := linux_tc
LINUX_TC_PATH := $(LINUX_TC_DIR)/bin
LINUX_TC_PREFIX := arm-linux-gnueabihf-
LINUX_REPO := https://github.com/hardkernel/linux.git
LINUX_BRANCH := odroidc-3.10.y
LINUX_SRC := linux

