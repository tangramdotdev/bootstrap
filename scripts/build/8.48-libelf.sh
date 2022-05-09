#!/bin/bash
set -euo pipefail
log "Building libelf (0.9 SBU | 116 MB)..."

BUILD_LOGFILE=$LOGDIR/8.48-libelf.log

pushd /sources
tar xf elfutils-0.186.tar.bz2
pushd elfutils-0.186
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make -C libelf install | tee -a "$BUILD_LOGFILE"
install -vm644 config/libelf.pc /usr/lib/pkgconfig | tee -a "$BUILD_LOGFILE"
rm /usr/lib/libelf.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf elfutils-0.186
popd
