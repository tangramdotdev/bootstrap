#!/bin/bash
set -euo pipefail
log "Building zlib (<0.1 SBU | 5.0 MB)..."

BUILD_LOGFILE=$LOGDIR/8.6-zlib.log

pushd /sources
tar xf zlib-1.2.12.tar.xz
pushd zlib-1.2.12
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
rm -fv /usr/lib/libz.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf zlib-1.2.12
popd
