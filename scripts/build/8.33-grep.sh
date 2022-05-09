#!/bin/bash
set -euo pipefail
log "Building grep (0.9 SBU | 36 MB)..."

BUILD_LOGFILE=$LOGDIR/8.33-grep.log

pushd /sources
tar xf grep-3.7.tar.xz
pushd grep-3.7
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf grep-3.7
popd
