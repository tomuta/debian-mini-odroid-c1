#!/bin/bash

#
# NOTE: This script is run within the chroot after second stage debootstrap!
#

set -e

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 DIST DIST_URL KERNEL_VERSION"
	exit 1
fi

DIST=$1
DIST_URL=$2
KERNEL_VERSION=$3

echo "Running postinstall.sh script..."

# Set root password
echo "root:odroid" | chpasswd

# Initialize /etc/apt/sources.list
echo "deb $DIST_URL $DIST main contrib non-free" > /etc/apt/sources.list
echo "deb-src $DIST_URL $DIST main contrib non-free" >> /etc/apt/sources.list

# Update apt
apt-get update

# Generate the initial ramfs
update-initramfs -c -t -k $KERNEL_VERSION

# resolv.conf needs to live in /tmp, but we still need /etc/resolv.conf as well
rm /etc/resolv.conf
ln -s /tmp/resolv.conf /etc/resolv.conf

# Make /etc/udev/rules.d point to a directory in /tmp (which is created at boot time)
rm -rf /etc/udev/rules.d
ln -s /tmp/udev-rules.d /etc/udev/rules.d

# Set hostname
echo "odroidc1" > /etc/hostname

insserv usbmount-start
insserv framebuffer-start

# Cleanup
apt-get clean

# Make apt-get remount /
echo "DPkg {
	Pre-Invoke { \"mount -n -o remount,rw /\"; };
	Post-Invoke { \"test ${NO_APT_REMOUNT:-no} = yes || mount -n -o remount,ro / || true\"; };
};
" > /etc/apt/apt.conf.d/00autoremount

