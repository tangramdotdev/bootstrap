#!/bin/bash
set -euo pipefail
log "Building findutils (0.2 SBU | 42 MB)..."

BUILD_LOGFILE=$LOGDIR/6.8-findutils.log
VERSION=4.9.0

pushd "$LFS"/sources
tar xf findutils-"$VERSION".tar.xz
pushd findutils-"$VERSION"
./configure --prefix=/usr \
  --localstatedir=/var/lib/locate \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf findutils-"$VERSION"
popd
