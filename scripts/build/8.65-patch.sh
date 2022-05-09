#!/bin/bash
set -euo pipefail
log "Building patch (0.2 SBU | 12 MB)..."

BUILD_LOGFILE=$LOGDIR/8.65-patch.log

pushd /sources
tar xf patch-2.7.6.tar.xz
pushd patch-2.7.6
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf patch-2.7.6
popd
