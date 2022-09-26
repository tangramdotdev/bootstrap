#!/bin/bash
# This script assumes a busybox rootfs has been created, and runs a script inside a chroot created from it
set -euxo pipefail

TOP="$PWD/bootstrap_musl"
ROOTFS="$TOP/rootfs"

setupChroot() {
	mkdir -pv "$ROOTFS"/{dev,proc,sys,run,scripts}
	mknod -m 600 "$ROOTFS"/dev/console c 5 1
	mknod -m 666 "$ROOTFS"/dev/null c 1 3
	mount -v --bind /dev "$ROOTFS"/dev
	mount -v --bind /dev/pts "$ROOTFS"/dev/pts
	mount -vt proc proc "$ROOTFS"/proc
	mount -vt sysfs sysfs "$ROOTFS"/sys
	mount -vt tmpfs tmpfs "$ROOTFS"/run
	if [ -h "$ROOTFS"/dev/shm ]; then
	  mkdir -pv "$ROOTFS"/"$(readlink "$ROOTFS"/dev/shm)" | tee -a "$BUILD_LOGFILE"
	fi
	cp ./build_packages.sh "$ROOTFS"/scripts
}

cleanupChroot() {
	umount --recursive "$ROOTFS"/dev
	umount --recursive "$ROOTFS"/proc
	umount --recursive "$ROOTFS"/run
	umount --recursive "$ROOTFS"/sys
}

setupChroot
cp "$PWD"/build_packages.sh "$ROOTFS"/scripts
chroot "$ROOTFS" /usr/bin/env -i  \
    HOME=/root                    \
    TERM="$TERM"                  \
    PS1='(chroot) \u:\w\$ '       \
    PATH=/bin:/usr/bin            \
    /bin/sh --login               \
    -c "sh /scripts/build_packages.sh"
cleanupChroot
