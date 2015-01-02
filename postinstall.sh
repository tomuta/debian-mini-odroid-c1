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

# Make apt-get remount /
echo "DPkg {
	Pre-Invoke { \"mount -n -o remount,rw /\"; };
	Post-Invoke { \"test ${NO_APT_REMOUNT:-no} = yes || mount -n -o remount,ro / || true\"; };
};
" > /etc/apt/apt.conf.d/00autoremount

# resolv.conf needs to live in /tmp, but we still need /etc/resolv.conf as well
rm /etc/resolv.conf
ln -s /tmp/resolv.conf /etc/resolv.conf
echo "#!/bin/bash
#
# This script overrides the make_resolv_conf() function in
# /sbin/dhclient-script and replaces /etc/resolv.conf with
# /tmp/resolv.conf

cur_make_resolv_conf=\$(declare -f make_resolv_conf)
eval \${cur_make_resolv_conf//\/etc\/resolv.conf/\/tmp\/resolv.conf}
" > /etc/dhcp/dhclient-enter-hooks.d/00-make_resolv_conf
chmod +x /etc/dhcp/dhclient-enter-hooks.d/00-make_resolv_conf

# Make /etc/udev/rules.d point to a directory in /tmp (which is created at boot time)
rm -rf /etc/udev/rules.d
ln -s /tmp/udev-rules.d /etc/udev/rules.d

# Set hostname
echo "odroidc1" > /etc/hostname

# Default networking
echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
" > /etc/network/interfaces

# Cleanup
apt-get clean

