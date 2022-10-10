#!/bin/sh
# This script replaces the absolute symlink found in the musl.cc toolchain with a relative one.
TMP=$(mktemp -d)
cd "$TMP"
tar -xf "$1"
top="$3"-linux-musl-native
cd "$top"/lib
INTERP=ld-musl-"$3".so.1
rm "$INTERP"
ln -s libc.so "$INTERP"
tar -C "$TMP"/"$top" -cJf "$2" .
rm -rf "$TMP"