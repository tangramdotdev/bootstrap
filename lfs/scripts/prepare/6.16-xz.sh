#!/bin/bash
set -euo pipefail
log "Building xz (0.1 SBU | 16 MB)..."

BUILD_LOGFILE=$LOGDIR/6.16-xz.log
VERSION=5.2.6

pushd "$LFS"/sources
tar xf xz-"$VERSION".tar.xz
pushd xz-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" \
  --disable-static \
  --docdir=/usr/share/doc/xz-"$VERSION" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
rm -v "$LFS"/usr/lib/liblzma.la | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf xz-"$VERSION"
popd
