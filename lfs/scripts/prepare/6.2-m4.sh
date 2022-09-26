#!/bin/bash
set -euo pipefail
log "Building M4 (0.2 SBU | 32 MB)..."

BUILD_LOGFILE=$LOGDIR/6.2-m4.log
VERSION=1.4.19

pushd "$LFS"/sources
tar xf m4-"$VERSION".tar.xz
pushd m4-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf m4-"$VERSION"
popd
