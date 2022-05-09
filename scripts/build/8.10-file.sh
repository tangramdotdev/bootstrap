#!/bin/bash
set -euo pipefail
log "Building file (0.1 SBU | 15 MB)..."

BUILD_LOGFILE=$LOGDIR/8.10-file.log

pushd /sources
tar xf file-5.41.tar.gz
pushd file-5.41
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf file-5.41
popd
