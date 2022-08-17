#!/bin/bash
# This script produces a statically linked bash executable for macOS.
set -euo pipefail
BASH_VER="bash-5.1.16"
BASH_PKG="$BASH_VER.tar.gz"
BASH_URL="https://ftp.gnu.org/gnu/make/$BASH_PKG"

# download
if [ ! -f "$BASH_PKG" ]; then
    wget "$BASH_URL"
fi

# unpack
rm -rf "$BASH_VER"
tar -xf "$BASH_PKG"

# compile arm
pushd "$BASH_VER"
./configure CFLAGS="-target arm64-apple-macos12.3"
make -j$(nproc)
popd
mv "$BASH_VER"/bash ./bash_arm

# compile arm
pushd "$BASH_VER"
make clean
./configure CFLAGS="-target x86_64-apple-macos12.3"
make -j$(nproc)
popd
mv "$BASH_VER"/bash ./bash_x86

# combine
lipo -create -output bash bash_arm bash_x86
rm bash_arm bash_x86

rm -rf "$BASH_VER"
# Don't compress - it will be added to the macos bootstrap bundle.
#tar -cJf bash_aarch64_macos.tar.xz ./bash
