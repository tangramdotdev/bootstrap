#!/bin/bash
# This script performs a standard Autotools build with static linking.
set -euo pipefail
source /envfile
name="$1"
version="$2"
pkg="${name}-${version}"
shift 2
TMP=$(mktemp -d)
cd "$TMP" || exit
"$WORK"/"$pkg"/configure LDFLAGS="--static" --prefix="$ROOTFS" "$@"
make -j"$NPROC"
make install