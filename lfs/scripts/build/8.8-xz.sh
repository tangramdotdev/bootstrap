#!/bin/bash
set -euo pipefail
log "Building xz (0.2 SBU | 16 MB)..."

BUILD_LOGFILE=$LOGDIR/8.8-xz.log
VERSION=5.2.6

pushd /sources
tar xf xz-"$VERSION".tar.xz
pushd xz-"$VERSION"
./configure --prefix=/usr \
  --disable-static \
  --docdir=/usr/share/doc/xz-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf xz-"$VERSION"
popd
