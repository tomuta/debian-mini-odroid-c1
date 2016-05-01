include common.mk

export ARCH := $(LINUX_ARCH)
export CROSS_COMPILE := $(LINUX_TC_PREFIX)
export PATH := $(shell pwd)/$(LINUX_TC_PATH):$(PATH)

.PHONY: all
all: build

.PHONY: clean
clean:
	if test -d "$(LINUX_SRC)"; then $(MAKE) -C $(LINUX_SRC) clean ; fi
	rm -rf $(wildcard $(BOOT_DIR) $(BOOT_DIR).tmp $(MODS_DIR) $(MODS_DIR).tmp)

.PHONY: distclean
distclean:
	rm -rf $(wildcard $(LINUX_TC_DIR) $(LINUX_SRC) $(BOOT_DIR) $(MODS_DIR) $(MODS_DIR).tmp)

$(LINUX_TC_DIR): $(LINUX_TOOLCHAIN)
	mkdir -p $@
	tar xf $(LINUX_TOOLCHAIN) --strip-components=1 -C $@

$(LINUX_TOOLCHAIN):
	wget -O $@ $(LINUX_TOOLCHAIN_URL)
	touch $@

.PHONY: build
build: $(BOOT_DIR) $(MODS_DIR)

$(BOOT_DIR): $(LINUX_IMAGE_BIN)
	if test -d "$@.tmp"; then rm -rf "$@.tmp" ; fi
	if test -d "$@"; then rm -rf "$@" ; fi
	mkdir -p "$@.tmp"
	cp -p $(LINUX_IMAGE_BIN) "$@.tmp"
	cp -p $(LINUX_DTS_PATH)/$(LINUX_DTB_FILE) "$@.tmp"
	mv "$@.tmp" $@
	touch $@

$(LINUX_IMAGE_BIN): $(LINUX_TC_DIR) $(LINUX_SRC)
	$(MAKE) -C $(LINUX_SRC) $(LINUX_CONFIG)
	$(MAKE) -C $(LINUX_SRC) $(LINUX_IMAGE_FILE)
	$(MAKE) -C $(LINUX_SRC) dtbs
	$(MAKE) -C $(LINUX_SRC) modules
	touch $@

$(MODS_DIR): $(LINUX_IMAGE_BIN)
	if test -d "$@.tmp"; then rm -rf "$@.tmp" ; fi
	if test -d "$@"; then rm -rf "$@" ; fi
	mkdir -p "$@.tmp"
	$(MAKE) -C $(LINUX_SRC) modules
	$(MAKE) -C $(LINUX_SRC) INSTALL_MOD_PATH=$(abspath $(MODS_DIR).tmp) modules_install
	mv "$@.tmp" $@
	touch $@

$(LINUX_SRC):
	git clone --depth=1 $(LINUX_REPO) -b $(LINUX_BRANCH) $@

