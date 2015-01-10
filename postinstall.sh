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

insserv framebuffer-start
insserv hostname-init

# Cleanup
apt-get clean

