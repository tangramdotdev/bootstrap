#!/bin/bash
# This script builds a statically-linked bash executable.
set -x
source /envfile
bash=bash-"$1"
TMP=$(mktemp -d)
cd "$TMP"
"$WORK"/"$bash"/configure CFLAGS=-"static -Os" --enable-static-link --without-bash-malloc
make -j"$NPROC"
strip bash
cp bash "$WORK/bash_linux_$ARCH"
rm -rf "$TMP"