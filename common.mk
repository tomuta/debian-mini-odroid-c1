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

UBOOT_TOOLCHAIN := gcc-arm-none-eabi-4.4.1-2010q1-188-linux32.tar.gz
UBOOT_TOOLCHAIN_URL := http://arduino.googlecode.com/files/$(UBOOT_TOOLCHAIN)
UBOOT_TC_DIR := uboot_tc
UBOOT_TC_PATH := $(UBOOT_TC_DIR)/g++_arm_none_eabi/bin
UBOOT_REPO := https://github.com/hardkernel/u-boot.git
UBOOT_BRANCH := odroidc-v2011.03
UBOOT_SRC := u-boot

LINUX_TOOLCHAIN := gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
LINUX_TOOLCHAIN_URL := http://releases.linaro.org/14.09/components/toolchain/binaries/$(LINUX_TOOLCHAIN)
LINUX_TC_DIR := linux_tc
LINUX_TC_PATH := $(LINUX_TC_DIR)/bin
LINUX_TC_PREFIX := arm-linux-gnueabihf-
LINUX_REPO := https://github.com/hardkernel/linux.git
LINUX_BRANCH := odroidc-3.10.y
LINUX_SRC := linux

