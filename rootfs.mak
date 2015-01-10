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
	debootstrap --foreign --no-check-gpg --include=ca-certificates,ssh,vim,usbmount,initramfs-tools --arch=$(DIST_ARCH) $(DIST) $@.tmp $(DIST_URL)
	cp `which qemu-arm-static` $@.tmp/usr/bin
	chroot $@.tmp /bin/bash -c "/debootstrap/debootstrap --second-stage"
	rm $@.tmp/etc/hostname
	rm $@.tmp/etc/ssh/ssh_host_*
	ln -s /proc/mounts $@.tmp/etc/mtab
	mv $@.tmp $@
	touch $@

$(ROOTFS_DIR): $(ROOTFS_DIR).base
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(ROOTFS_DIR).base/* $@
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(MODS_DIR)/* $@
	cd $@/lib/modules ; if [ ! -d "$(LINUX_VERSION)" ] ; then ln -s $(LINUX_VERSION)* $(LINUX_VERSION) ; fi
	cd files ; find . -type f ! -name '*~' -exec cp --preserve=mode,timestamps --parents \{\} ../$@ \;
	mount -o bind /proc $@/proc
	mount -o bind /sys $@/sys
	mount -o bind /dev $@/dev
	cp postinstall.sh $@
	chroot $@ /bin/bash -c "/postinstall.sh $(DIST) $(DIST_URL) $(LINUX_VERSION)"
	for i in patches/*.patch ; do patch -p0 -d $@ < $$i ; done
	umount $@/proc
	umount $@/sys
	umount $@/dev
	rm $@/postinstall.sh
	rm $@/usr/bin/qemu-arm-static
	touch $@

$(RAMDISK_FILE): $(ROOTFS_DIR)
	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d $(ROOTFS_DIR)/boot/initrd.img-* uInitrd

$(IMAGE_FILE): $(ROOTFS_DIR) $(RAMDISK_FILE)
	if test -f "$@.tmp"; then rm "$@.tmp" ; fi
	./createimg.sh $@.tmp 32 768 $(BOOT_DIR) $(ROOTFS_DIR) $(UBOOT_BIN_DIR) $(RAMDISK_FILE)
	mv $@.tmp $@
	touch $@

