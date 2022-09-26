#!/bin/bash
set -euo pipefail
log "Building patch (0.2 SBU | 12 MB)..."

BUILD_LOGFILE=$LOGDIR/8.66-patch.log
VERSION=2.7.6

pushd /sources
tar xf patch-"$VERSION".tar.xz
pushd patch-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf patch-"$VERSION"
popd
