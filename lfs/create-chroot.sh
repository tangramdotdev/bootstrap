#!/usr/bin/env bash

# This script prepares and enters the chroot environment after the toolchain is built.

set -euxo pipefail

export PREFIX=$PWD/chroot

# Set ownership
#chown -R root:root "$PREFIX"/{usr,lib,var,etc,bin,tools}

mkdir -pv "$PREFIX"/{dev,proc,sys,run}
mount -v --bind /dev "$PREFIX"/dev
mount -v --bind /dev/pts "$PREFIX"/dev/pts
mount -vt proc proc "$PREFIX"/proc
mount -vt sysfs sysfs "$PREFIX"/sys
mount -vt tmpfs tmpfs "$PREFIX"/run

chroot "$PREFIX" /usr/bin/env -i          \
    HOME=/root                            \
    TERM="$TERM"                          \
    PS1='(tangram chroot) \u:\w\$ '       \
    PATH=/bin:/usr/bin                    \
    /bin/bash --login
