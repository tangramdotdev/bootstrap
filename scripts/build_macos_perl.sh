#!/bin/bash
# This script builds a macos executable for the passed target.
set -x
DIR=$(cd -- "${0%/*}" && pwd)
WORK="$DIR"/../work
PREFIX="${WORK}/macos/${2}/rootfs"
SDK_VER=13.0
TMP=$(mktemp -d)
# https://trac.macports.org/ticket/62991#comment:19 - must set --host
if [ "$2" = "x86_64" ]; then
	target="x86_64-apple-macos${SDK_VER}"
else
	target="arm64-apple-macos${SDK_VER}"
fi
cd "$TMP" || exit
sh "$1"/Configure \
	-des \
	-Dmksymlinks \
	-Dusethreads \
	-Duserelocatableinc \
	-Doptimize="-target ${target} -O3 -pipe -fstack-protector -fwrapv -fno-strict-aliasing" \
	-Dprefix="$PREFIX"
make -j"$(nproc)"
make install
rm -rf "$TMP"