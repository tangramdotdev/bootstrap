#!/bin/bash
set -euo pipefail
log "Building patchelf..."

BUILD_LOGFILE=$LOGDIR/patchelf.log
VERSION=0.15.0

pushd /sources
tar xf patchelf-"$VERSION".tar.bz2
pushd patchelf-"$VERSION"
./configure \
  CFLAGS=-static \
  CPPFLAGS=-static \
  LDFLAGS=-static \
  --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf patchelf-"$VERSION"
popd
