#!/bin/bash
set -euo pipefail
log "Building grep (0.2 SBU | 25 MB)..."

BUILD_LOGFILE=$LOGDIR/6.10-grep.log
VERSION=3.7

pushd "$LFS"/sources
tar xf grep-"$VERSION".tar.xz
pushd grep-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf grep-"$VERSION"
popd
