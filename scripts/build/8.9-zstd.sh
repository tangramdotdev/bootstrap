#!/bin/bash
set -euo pipefail
log "Building zstd (1.1 SBU | 55 MB)..."

BUILD_LOGFILE=$LOGDIR/8.9-zstd.log

pushd /sources
tar xf zstd-1.5.2.tar.gz
pushd zstd-1.5.2
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make prefix=/usr install | tee -a "$BUILD_LOGFILE"
rm -v /usr/lib/libzstd.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf zstd-1.5.2
popd
