#!/bin/bash
set -euo pipefail
log "Building patch (0.1 SBU | 12 MB)..."

BUILD_LOGFILE=$LOGDIR/6.13-patch.log
VERSION=2.7.6

pushd "$LFS"/sources
tar xf patch-"$VERSION".tar.xz
pushd patch-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf patch-"$VERSION"
popd
