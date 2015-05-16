DIST ?= jessie
DIST_URL := http://http.debian.net/debian/
DIST_ARCH := armhf

ifneq ($(findstring $(DIST),jessie stable),)
# ROOT_DEV is needed for jessie, it will cause boot.ini to boot from /dev/mmcblk0p2 rather than from UUID.
# For some reason, booting by UUID is broken with jessie...
ROOT_DEV := /dev/mmcblk0p2
endif

IMAGE_MB ?= 2048
BOOT_MB ?= 32
ROOT_MB=$(shell expr $(IMAGE_MB) - $(BOOT_MB))

BOOT_DIR := boot
MODS_DIR := mods
ROOTFS_DIR := rootfs
RAMDISK_FILE := uInitrd
IMAGE_FILE := sdcard-$(DIST).img

UBOOT_TOOLCHAIN := gcc-linaro-arm-none-eabi-4.8-2014.04_linux.tar.xz
UBOOT_TOOLCHAIN_URL := http://releases.linaro.org/14.04/components/toolchain/binaries/$(UBOOT_TOOLCHAIN)
UBOOT_TC_DIR := uboot_tc
UBOOT_TC_PATH := $(UBOOT_TC_DIR)/gcc-linaro-arm-none-eabi-4.8-2014.04_linux/bin
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

