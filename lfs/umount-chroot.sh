#!/bin/sh

# Helper to clean up mounted filesystems

set -eux

PREFIX="$PWD"/chroot

umount --recursive "$PREFIX"/dev
umount --recursive "$PREFIX"/proc
umount --recursive "$PREFIX"/run
umount --recursive "$PREFIX"/sys
