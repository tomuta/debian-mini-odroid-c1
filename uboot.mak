TOOLCHAIN := gcc-arm-none-eabi-4.4.1-2010q1-188-linux32.tar.gz
TOOLCHAIN_URL := http://arduino.googlecode.com/files/$(TOOLCHAIN)

TC_DIR := uboot_tc

export PATH := $(shell pwd)/$(TC_DIR)/g++_arm_none_eabi/bin:$(PATH)

UBOOT_REPO := https://github.com/hardkernel/u-boot.git
UBOOT_BRANCH := odroidc-v2011.03
UBOOT_SRC := u-boot

UBOOT_BIN := $(UBOOT_SRC)/sd_fuse/uboot.bin

.PHONY: all
all: build

.PHONY: clean
clean:
	if test -d "$(UBOOT_SRC)"; then $(MAKE) -C $(UBOOT_SRC) clean ; fi

.PHONY: distclean
distclean:
	rm -rf $(wildcard $(TC_DIR) $(UBOOT_SRC))

$(TC_DIR): $(TOOLCHAIN)
	mkdir -p $@
	tar xzf $(TOOLCHAIN) -C $@

$(TOOLCHAIN):
	wget -O $@ $(TOOLCHAIN_URL)
	touch $@

.PHONY: build
build: $(UBOOT_BIN)

$(UBOOT_BIN): $(TC_DIR) $(UBOOT_SRC)
	$(MAKE) -C $(UBOOT_SRC) odroidc_config
	$(MAKE) -C $(UBOOT_SRC)
	touch $@

$(UBOOT_SRC):
	git clone --depth=1 $(UBOOT_REPO) -b $(UBOOT_BRANCH)

