#!/bin/bash
set -euo pipefail
log "Building libffi (1.8 SBU | 10 MB)..."

BUILD_LOGFILE=$LOGDIR/8.49-libffi.log
VERSION=3.4.2

pushd /sources
tar xf libffi-"$VERSION".tar.gz
pushd libffi-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --with-gcc-arch=native \
    --disable-exec-static-tramp | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf libffi-"$VERSION"
popd
