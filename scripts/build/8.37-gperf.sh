#!/bin/bash
set -euo pipefail
log "Building gperf (<0.1 SBU | 6 MB)..."

BUILD_LOGFILE=$LOGDIR/8.37-gperf.log

pushd /sources
tar xf gperf-3.1.tar.gz
pushd gperf-3.1
./configure --prefix=/usr                \
            --docdir=/usr/share/doc/gperf-3.1 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make -j1 check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf gperf-3.1
popd
