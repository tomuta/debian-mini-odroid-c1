#!/bin/bash

#
# NOTE: This script is run within the chroot after second stage debootstrap!
#

set -e

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 DIST DIST_URL"
	exit 1
fi

DIST=$1
DIST_URL=$2

echo "Running postinstall.sh script..."

# Set root password
echo "root:odroid" | chpasswd

# Initialize /etc/apt/sources.list
echo "deb $DIST_URL $DIST main contrib non-free" > /etc/apt/sources.list
echo "deb-src $DIST_URL $DIST main contrib non-free" >> /etc/apt/sources.list

# Make apt-get remount /
#echo "DPkg {
#	Pre-Invoke { \"mount -o remount,rw /\"; };
#	Post-Invoke { \"test ${NO_APT_REMOUNT:-no} = yes || mount -o remount,ro / || true\"; |;
#};
#" > /etc/apt/apt.conf.d/00autoremount

# Move resolv.conf to /tmp
#rm /etc/resolv.conf
#ln -s /tmp/resolv.conf /etc/resolv.conf

#rm /etc/ssh/ssh_host_*
# TODO: Add script that re-generates host keys on first startup

# Set hostname
echo "odroidc1" > /etc/hostname

echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
" > /etc/network/interfaces
