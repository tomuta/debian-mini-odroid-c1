include common.mk

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
	tar xf $(UBOOT_TOOLCHAIN) --strip-components=1 -C $@
	touch $@

$(UBOOT_TOOLCHAIN):
	wget -O $@ $(UBOOT_TOOLCHAIN_URL)
	touch $@

.PHONY: build
build: $(UBOOT_BIN)

$(UBOOT_BIN): $(UBOOT_TC_DIR) $(UBOOT_SRC)
	$(MAKE) -C $(UBOOT_SRC) odroidc_config
	$(MAKE) -C $(UBOOT_SRC)
	touch $@

$(UBOOT_SRC):
	git clone --depth=1 $(UBOOT_REPO) -b $(UBOOT_BRANCH)

