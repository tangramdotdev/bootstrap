#!/bin/bash
# This script performs a standard Autotools build with static linking.
set -euo pipefail
source /envfile
version="$1"
pkg="musl-${version}"
shift
TMP=$(mktemp -d)
cd "$TMP" || exit
"$WORK"/"$pkg"/configure \
	CFLAGS="-O2 -pipe" \
	--prefix="$ROOTFS" \
	--syslibdir="$ROOTFS"/lib
make -j"$NPROC"
make install
# Change absolute symlink to relative
ARCH=$(uname -m)
LD="ld-musl-${ARCH}.so.1"
cd "$ROOTFS"/lib
rm "$LD"
ln -s libc.so "$LD"