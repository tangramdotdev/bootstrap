#!/bin/bash
set -euo pipefail
log "Building libffi (1.9 SBU | 10 MB)..."

BUILD_LOGFILE=$LOGDIR/8.49-libffi.log

pushd /sources
tar xf libffi-3.4.2.tar.gz
pushd libffi-3.4.2
./configure --prefix=/usr                \
            --disable-static             \
            --with-gcc-arch=native       \
            --disable-exec-static-tramp | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf libffi-3.4.2
popd
