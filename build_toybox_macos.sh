#!/bin/bash
# This script compiles a universal toybox for MacOS
TOYBOX_VER="toybox-0.8.8"
TOYBOX_PKG="$TOYBOX_VER.tar.gz"
TOYBOX_URL="http://landley.net/toybox/downloads/$TOYBOX_PKG"

if [ ! -f "$TOYBOX_URL" ]; then
	wget "$TOYBOX_URL"
fi

rm -rf "$TOYBOX_VER"
tar -xf "$TOYBOX_PKG"

pushd "$TOYBOX_VER"
CFLAGS="-target arm64-apple-macos12.3" make macos_defconfig toybox
mv toybox ../toybox_arm64
make clean
CFLAGS="-target x86_64-apple-macos12.3" make macos_defconfig toybox
mv toybox ../toybox_x86_64
popd

lipo -create -output toybox toybox_arm64 toybox_x86_64
rm toybox_arm64 toybox_x86_64
rm -rf "$TOYBOX_VER"