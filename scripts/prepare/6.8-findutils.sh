#!/bin/bash
set -euo pipefail
log "Building findutils (0.2 SBU | 42 MB)..."

BUILD_LOGFILE=$LOGDIR/6.8-findutils.log

pushd "$LFS"/sources
tar xf findutils-4.9.0.tar.xz
pushd findutils-4.9.0
./configure --prefix=/usr           \
  --localstatedir=/var/lib/locate   \
  --host="$LFS_TGT"                 \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf findutils-4.9.0
popd
