#!/bin/bash
# This script builds a macos executable for the passed target.
set -x
DIR=$(cd -- "${0%/*}" && pwd)
WORK="$DIR"/../work
PREFIX="${WORK}/macos/${2}/rootfs"
SDK_VER=13.0
TMP=$(mktemp -d)
if [ "$2" = "x86_64" ]; then
	target="x86_64-apple-macos${SDK_VER}"
else
	target="arm64-apple-macos${SDK_VER}"
fi
cd "$TMP" || exit
"$1"/configure CFLAGS="-target ${target}" CXXFLAGS="-target ${target}" --prefix "$PREFIX"
make -j"$(nproc)"
make install
rm -rf "$TMP"