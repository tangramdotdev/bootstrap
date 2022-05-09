#!/bin/bash
set -euo pipefail
log "Building xz (0.1 SBU | 15 MB)..."

BUILD_LOGFILE=$LOGDIR/6.16-xz.log

pushd "$LFS"/sources
tar xf xz-5.2.5.tar.xz
pushd xz-5.2.5
./configure --prefix=/usr             \
  --host="$LFS_TGT"                   \
  --build="$(build-aux/config.guess)" \
  --disable-static                    \
  --docdir=/usr/share/doc/xz-5.2.5 | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf xz-5.2.5
popd
