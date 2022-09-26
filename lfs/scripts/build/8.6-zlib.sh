#!/bin/bash
set -euo pipefail
log "Building zlib (<0.1 SBU | 6.1 MB)..."

BUILD_LOGFILE=$LOGDIR/8.6-zlib.log
VERSION=1.2.12

pushd /sources
tar xf zlib-"$VERSION".tar.xz
pushd zlib-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
rm -fv /usr/lib/libz.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf zlib-"$VERSION"
popd
