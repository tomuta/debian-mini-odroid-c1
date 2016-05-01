DIST ?= jessie
DIST_URL := http://http.debian.net/debian/

IMAGE_MB ?= 2048
BOOT_MB ?= 128
ROOT_MB=$(shell expr $(IMAGE_MB) - $(BOOT_MB))

ifeq ($(findstring $(ODROID),c1 c2),)
    $(error No ODROID specified! Supported targets: c1, c2)
endif

ifeq ($(DIST),stable)
    $(warning You should not specify stable for DIST.  Supported distributions: jessie, wheezy)
endif

ifeq ($(ROOT_RW),)
    ROOT_RW_FLAG := rw
else
    ifeq ($(findstring $(ROOT_RW),yes no),)
        $(error ROOT_RW must be one of the following: yes, no)
    endif
    
    ifeq ($(ROOT_RW),yes)
        ROOT_RW_FLAG := rw
    else
        ifeq ($(ROOT_RW),no)
            ROOT_RW_FLAG := ro
        endif
    endif
endif

UBOOT_REPO := https://github.com/hardkernel/u-boot.git
UBOOT_SRC := u-boot-$(ODROID)
UBOOT_TC_DIR := uboot_$(ODROID)_tc

LINUX_REPO := https://github.com/hardkernel/linux.git
LINUX_SRC := linux-$(ODROID)
LINUX_TC_DIR := linux_$(ODROID)_tc

ifeq ($(ODROID),c1)
    DIST_ARCH := armhf

    UBOOT_TOOLCHAIN := gcc-linaro-arm-none-eabi-4.8-2014.04_linux.tar.xz
    UBOOT_TOOLCHAIN_URL := https://releases.linaro.org/14.04/components/toolchain/binaries/$(UBOOT_TOOLCHAIN)
    UBOOT_TC_PATH := $(UBOOT_TC_DIR)/gcc-linaro-arm-none-eabi-4.8-2014.04_linux/bin
    UBOOT_TC_PREFIX := arm-linux-gnueabihf-
    UBOOT_BRANCH := odroidc-v2011.03
    UBOOT_CONFIG := odroidc_config
    UBOOT_ARCH := arm

    LINUX_TOOLCHAIN := gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
    LINUX_TOOLCHAIN_URL := https://releases.linaro.org/14.09/components/toolchain/binaries/$(LINUX_TOOLCHAIN)
    LINUX_TC_PATH := $(LINUX_TC_DIR)/bin
    LINUX_TC_PREFIX := arm-linux-gnueabihf-
    LINUX_BRANCH := odroidc-3.10.y
    LINUX_CONFIG := odroidc_defconfig
    LINUX_ARCH := arm
    LINUX_IMAGE_FILE := uImage
    LINUX_DTB_FILE := meson8b_odroidc.dtb

    QEMU_STATIC_BIN := qemu-arm-static

    ifneq ($(findstring $(DIST),jessie),)
        # ROOT_DEV is needed for jessie, it will cause boot.ini to boot from /dev/mmcblk0p2 rather than from UUID.
        # For some reason, booting by UUID is broken with jessie...
        ROOT_DEV := /dev/mmcblk0p2
    endif
endif

ifeq ($(ODROID),c2)
    ifeq ($(DIST),wheezy)
        $(error Wheezy does not support the arm64 architecture!)
    endif

    DIST_ARCH := arm64

    UBOOT_TOOLCHAIN := gcc-linaro-aarch64-none-elf-4.9-2014.09_linux.tar.xz
    UBOOT_TOOLCHAIN_URL := https://releases.linaro.org/14.09/components/toolchain/binaries/$(UBOOT_TOOLCHAIN)
    UBOOT_TC_PATH := $(UBOOT_TC_DIR)/gcc-linaro-aarch64-none-elf-4.9-2014.09_linux/bin
    UBOOT_TC_PREFIX := aarch64-none-elf-
    UBOOT_BRANCH := odroidc2-v2015.01
    UBOOT_CONFIG := odroidc2_config
    UBOOT_ARCH := arm

    LINUX_TOOLCHAIN := gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux.tar.xz
    LINUX_TOOLCHAIN_URL := https://releases.linaro.org/14.09/components/toolchain/binaries/$(LINUX_TOOLCHAIN)
    LINUX_TC_PATH := $(LINUX_TC_DIR)/bin
    LINUX_TC_PREFIX := aarch64-linux-gnu-
    LINUX_BRANCH := odroidc2-3.14.y
    LINUX_CONFIG := odroidc2_defconfig
    LINUX_ARCH := arm64
    LINUX_IMAGE_FILE := Image
    LINUX_DTB_FILE := meson64_odroidc2.dtb

    QEMU_STATIC_BIN := qemu-aarch64-static
endif

LINUX_IMAGE_BIN := $(LINUX_SRC)/arch/$(LINUX_ARCH)/boot/$(LINUX_IMAGE_FILE)
LINUX_DTS_PATH := $(LINUX_SRC)/arch/$(LINUX_ARCH)/boot/dts

BOOT_DIR := $(ODROID)-boot
MODS_DIR := $(ODROID)-mods
ROOTFS_DIR := $(ODROID)-rootfs
RAMDISK_FILE := uInitrd
IMAGE_FILE := sdcard-$(ODROID)-$(DIST).img
