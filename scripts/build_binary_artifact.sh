#!/bin/sh
# This script creates a compressed Tangram artifact from the first arg, placing it at the second arg.
# You can optionally pass a third argument to rename the executable.
exe=$1
destination=$2
out=${3:-$exe}
TMP=$(mktemp -d)

mkdir -p "$TMP"/bin
cp "$exe" "$TMP"/bin/"$out"
tar -C "$TMP" --zstd -cf "$destination" .
rm -rf "$TMP"