#!/bin/bash
# This script builds a macos bash executable for the passed target.
set -x
TMP=$(mktemp -d)
cd "$TMP"
"$1"/configure CFLAGS="-target $3"
make -j"$(nproc)"
strip bash
cp bash "$2"
rm -rf "$TMP"