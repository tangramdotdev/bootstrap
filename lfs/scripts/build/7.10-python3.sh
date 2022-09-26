#!/bin/bash
set -euo pipefail
log "Building python3 (0.9 SBU | 364 MB)..."

BUILD_LOGFILE=$LOGDIR/7.10-python3.log
VERSION=3.10.6

pushd /sources
tar xf Python-"$VERSION".tar.xz
pushd Python-"$VERSION"
./configure \
  --prefix=/usr \
  --enable-shared \
  --without-ensurepip | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf Python-"$VERSION"
popd
