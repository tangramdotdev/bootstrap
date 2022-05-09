#!/bin/sh
# This script prepares the lfs/ dir using th tarball to begin at chapter 7.
set -eu
rm -rf "$PWD"/lfs/*
tar xpvf lfs-11.1-initial-chroot.tar.xz
