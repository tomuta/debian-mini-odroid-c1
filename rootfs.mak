include common.mk

UBOOT_BIN_DIR := $(UBOOT_SRC)/sd_fuse

.PHONY: all
all: build

.PHONY: clean
clean: delete-rootfs
	rm -rf $(wildcard $(IMAGE_FILE) $(IMAGE_FILE).tmp)

.PHONY: distclean
distclean: delete-rootfs
	rm -rf $(wildcard $(ROOTFS_DIR).base $(ROOTFS_DIR).base.tmp)

.PHONY: delete-rootfs
delete-rootfs:
	if mountpoint -q $(ROOTFS_DIR)/proc ; then umount $(ROOTFS_DIR)/proc ; fi
	if mountpoint -q $(ROOTFS_DIR)/sys ; then umount $(ROOTFS_DIR)/sys ; fi
	if mountpoint -q $(ROOTFS_DIR)/dev ; then umount $(ROOTFS_DIR)/dev ; fi
	rm -rf $(wildcard $(ROOTFS_DIR) uInitrd)
	
.PHONY: build
build: $(IMAGE_FILE)

$(ROOTFS_DIR).base:
	if test -d "$@.tmp"; then rm -rf "$@.tmp" ; fi
	mkdir -p $@.tmp
	debootstrap --foreign --no-check-gpg --include=ca-certificates,ssh,vim,locales,ntpdate,usbmount,initramfs-tools --arch=$(DIST_ARCH) $(DIST) $@.tmp $(DIST_URL)
	cp `which $(QEMU_STATIC_BIN)` $@.tmp/usr/bin
	chroot $@.tmp /bin/bash -c "/debootstrap/debootstrap --second-stage"
	rm $@.tmp/etc/hostname
	rm $@.tmp/etc/ssh/ssh_host_*
	ln -s /proc/mounts $@.tmp/etc/mtab
	mv $@.tmp $@
	touch $@

$(ROOTFS_DIR): $(ROOTFS_DIR).base
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(ROOTFS_DIR).base/* $@
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(MODS_DIR)/* $@
	LINUX_VERSION="$(shell cat $(LINUX_SRC)/include/config/kernel.release)" && cd $@/lib/modules ; if [ ! -d "$$LINUX_VERSION" ] ; then ln -s "$$LINUX_VERSION*" "$$LINUX_VERSION" ; fi
	cd files/common ; find . -type f ! -name '*~' -exec cp --preserve=mode,timestamps --parents \{\} ../../$@ \;
	if [ -d files/$(DIST) ]; then cd files/$(DIST) ; mkdir -p ../../$@/$(DIST); find . -type f ! -name '*~' -exec cp --preserve=mode,timestamps --parents \{\} ../../$@ \; ; fi
	mount -o bind /proc $@/proc
	mount -o bind /sys $@/sys
	mount -o bind /dev $@/dev
	cp postinstall $@
	if [ -d "postinst" ]; then cp -r postinst $@ ; fi
	LINUX_VERSION="$(shell cat $(LINUX_SRC)/include/config/kernel.release)" && chroot $@ /bin/bash -c "/postinstall $(DIST) $(DIST_URL) $$LINUX_VERSION $(ODROID) $(ROOT_RW_FLAG)"
	if ls patches/*.patch 1> /dev/null 2>&1; then for i in patches/*.patch ; do patch -p0 -d $@ < $$i ; done fi
	if [ -d patches/$(DIST) ]; then if ls patches/$(DIST)/*.patch 1> /dev/null 2>&1; then for i in patches/$(DIST)/*.patch; do patch -p0 -d $@ < $$i ; done fi fi
	umount $@/proc
	umount $@/sys
	umount $@/dev
	rm $@/postinstall
	rm -rf $@/postinst/
	rm $@/usr/bin/$(QEMU_STATIC_BIN)
	touch $@

$(RAMDISK_FILE): $(ROOTFS_DIR)
	mkimage -A $(LINUX_ARCH) -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d $(ROOTFS_DIR)/boot/initrd.img-* uInitrd

$(IMAGE_FILE): $(ROOTFS_DIR) $(RAMDISK_FILE)
	if test -f "$@.tmp"; then rm "$@.tmp" ; fi
	./createimg $(ODROID) $@.tmp $(BOOT_MB) $(ROOT_MB) $(BOOT_DIR) $(ROOTFS_DIR) $(UBOOT_BIN_DIR) $(RAMDISK_FILE) "$(ROOT_DEV)" $(ROOT_RW_FLAG)
	mv $@.tmp $@
	touch $@

