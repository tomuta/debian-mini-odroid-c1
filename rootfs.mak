UBOOT_BIN_DIR := u-boot/sd_fuse
ROOTFS_DIR := rootfs
BOOT_DIR := boot
LINUX_SRC := linux
IMAGE_FILE := sdcard.img

DIST := stable
DIST_URL := http://ftp.debian.org/debian/
DIST_ARCH := armel

.PHONY: all
all: build

.PHONY: clean
clean:
	rm -rf $(wildcard $(ROOTFS_DIR) $(IMAGE_FILE) $(IMAGE_FILE).tmp)

.PHONY: distclean
distclean:
	rm -rf $(wildcard $(ROOTFS_DIR) $(ROOTFS_DIR).base $(ROOTFS_DIR).base.tmp)

.PHONY: build
build: $(IMAGE_FILE)

$(ROOTFS_DIR).base:
	if test -d "$@.tmp"; then rm -rf "$@.tmp" ; fi
	mkdir -p $@.tmp
	debootstrap --foreign --no-check-gpg --include=ca-certificates,ssh --arch=$(DIST_ARCH) $(DIST) $@.tmp $(DIST_URL)
	cp `which qemu-arm-static` $@.tmp/usr/bin
	chroot $@.tmp /bin/bash -c "/debootstrap/debootstrap --second-stage"
	mv $@.tmp $@

$(ROOTFS_DIR): $(ROOTFS_DIR).base
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(ROOTFS_DIR).base/* $@
	cp postinstall.sh $@
	chroot $@ /bin/bash -c "/postinstall.sh $(DIST) $(DIST_URL)"
	rm $@/postinstall.sh
	rm $@/usr/bin/qemu-arm-static

$(IMAGE_FILE): $(ROOTFS_DIR)
	if test -f "$@.tmp"; then rm "$@.tmp" ; fi
	./createimg.sh $@.tmp 32 512 $(BOOT_DIR) $(ROOTFS_DIR) $(UBOOT_BIN_DIR)
	mv $@.tmp $@

