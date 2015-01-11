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

# Prevent apt-get from starting services
echo "#!/bin/sh
exit 101
" > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

# Run custom install scripts
if [ -d "/postinst" ]; then
	for i in /postinst/* ; do
		echo "Running post-install script $i..."
		$i
	done
fi

# Re-enable services to start
rm /usr/sbin/policy-rc.d

# Cleanup
apt-get clean

