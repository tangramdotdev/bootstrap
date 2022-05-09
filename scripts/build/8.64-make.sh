#!/bin/bash
set -euo pipefail
log "Building make (0.5 SBU | 13 MB)..."

BUILD_LOGFILE=$LOGDIR/8.64-make.log

pushd /sources
tar xf make-4.3.tar.gz
pushd make-4.3
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf make-4.3
popd
