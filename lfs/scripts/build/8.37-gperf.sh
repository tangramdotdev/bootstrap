#!/bin/bash
set -euo pipefail
log "Building gperf (<0.1 SBU | 6 MB)..."

BUILD_LOGFILE=$LOGDIR/8.37-gperf.log
VERSION=3.1

pushd /sources
tar xf gperf-"$VERSION".tar.gz
pushd gperf-"$VERSION"
./configure --prefix=/usr \
    --docdir=/usr/share/doc/gperf-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make -j1 check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf gperf-"$VERSION"
popd
