TOOLCHAIN := gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux.tar.bz2
TOOLCHAIN_URL := https://releases.linaro.org/13.04/components/toolchain/binaries/$(TOOLCHAIN)

TC_DIR := linux_tc

export ARCH := arm
export CROSS_COMPILE := arm-linux-gnueabihf-
export PATH := $(shell pwd)/$(TC_DIR)/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin:$(PATH)

LINUX_REPO := https://github.com/hardkernel/linux.git
LINUX_BRANCH := odroidc-3.10.y
LINUX_SRC := linux
BOOT_DIR := boot

UIMAGE_BIN := $(LINUX_SRC)/arch/arm/boot/uImage

.PHONY: all
all: build

.PHONY: clean
clean:
	if test -d "$(LINUX_SRC)"; then $(MAKE) -C $(LINUX_SRC) clean ; fi
	rm -rf $(wildcard $(BOOT_DIR))

.PHONY: distclean
distclean:
	rm -rf $(wildcard $(TC_DIR) $(LINUX_SRC) $(BOOT_DIR))

$(TC_DIR): $(TOOLCHAIN)
	mkdir -p $@
	tar xjf $(TOOLCHAIN) -C $@

$(TOOLCHAIN):
	wget -O $@ $(TOOLCHAIN_URL)
	touch $@

.PHONY: build
build: $(BOOT_DIR)

$(BOOT_DIR): $(UIMAGE_BIN) $(MESON8B_ODROIDC_DTB_BIN)
	if test -d "$@.tmp"; then rm -rf "$@.tmp" ; fi
	mkdir -p "$@.tmp"
	cp -p $(LINUX_SRC)/arch/arm/boot/uImage "$@.tmp"
	cp -p $(LINUX_SRC)/arch/arm/boot/dts/amlogic/meson8b_odroidc.dtb "$@.tmp"
	mv "$@.tmp" $@

$(UIMAGE_BIN): $(TC_DIR) $(LINUX_SRC)
	$(MAKE) -C $(LINUX_SRC) odroidc_defconfig
	$(MAKE) -C $(LINUX_SRC) uImage
	$(MAKE) -C $(LINUX_SRC) meson8b_odroidc.dtd
	$(MAKE) -C $(LINUX_SRC) meson8b_odroidc.dtb
	touch $@

$(LINUX_SRC):
	git clone --depth=1 $(LINUX_REPO) -b $(LINUX_BRANCH)

