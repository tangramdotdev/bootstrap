#!/bin/bash
set -euo pipefail
log "Building xz (0.2 SBU | 15 MB)..."

BUILD_LOGFILE=$LOGDIR/8.8-xz.log

pushd /sources
tar xf xz-5.2.5.tar.xz
pushd xz-5.2.5
./configure --prefix=/usr    \
  --disable-static            \
  --docdir=/usr/share/doc/xz-5.2.5 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf xz-5.2.5
popd
