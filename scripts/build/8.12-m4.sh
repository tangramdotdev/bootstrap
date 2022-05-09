#!/bin/bash
set -euo pipefail
log "Building M4 (0.7 SBU | 49 MB)..."

BUILD_LOGFILE=$LOGDIR/8.12-m4.log

pushd /sources
tar xf m4-1.4.19.tar.xz
pushd m4-1.4.19
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf m4-1.4.19
popd
