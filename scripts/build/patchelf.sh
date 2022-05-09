#!/bin/bash
set -euo pipefail
log "Building patchelf..."

BUILD_LOGFILE=$LOGDIR/patchelf.log

pushd /sources
tar xf patchelf-0.14.5.tar.bz2
pushd patchelf-0.14.5
./configure   \
    CFLAGS=-static              \
    CPPFLAGS=-static            \
    LDFLAGS=-static             \
    --prefix=/usr | tee -a "$BUILD_LOGFILE"
  make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
  make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf patchelf-0.14.5
popd
