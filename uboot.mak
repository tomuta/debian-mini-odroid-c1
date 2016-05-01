include common.mk

export ARCH := $(UBOOT_ARCH)
export CROSS_COMPILE := $(UBOOT_TC_PREFIX)
export PATH := $(shell pwd)/$(UBOOT_TC_PATH):$(PATH)

UBOOT_BIN := $(UBOOT_SRC)/sd_fuse/uboot.bin

.PHONY: all
all: build

.PHONY: clean
clean:
	if test -d "$(UBOOT_SRC)"; then $(MAKE) -C $(UBOOT_SRC) clean ; fi

.PHONY: distclean
distclean:
	rm -rf $(wildcard $(UBOOT_TC_DIR) $(UBOOT_SRC))

$(UBOOT_TC_DIR): $(UBOOT_TOOLCHAIN)
	mkdir -p $@
	tar xJf $(UBOOT_TOOLCHAIN) -C $@
	touch $@

$(UBOOT_TOOLCHAIN):
	wget -O $@ $(UBOOT_TOOLCHAIN_URL)
	touch $@

.PHONY: build
build: $(UBOOT_BIN)

$(UBOOT_BIN): $(UBOOT_TC_DIR) $(UBOOT_SRC)
	$(MAKE) -C $(UBOOT_SRC) $(UBOOT_CONFIG)
	$(MAKE) -C $(UBOOT_SRC)
	touch $@

$(UBOOT_SRC):
	git clone --depth=1 $(UBOOT_REPO) -b $(UBOOT_BRANCH) $@

