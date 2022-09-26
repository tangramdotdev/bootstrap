#!/bin/bash
set -euo pipefail
log "Building libpipeline (0.1 SBU | 10 MB)..."

BUILD_LOGFILE=$LOGDIR/8.64-libpipeline.log
VERSION=1.5.6

pushd /sources
tar xf libpipeline-"$VERSION".tar.gz
pushd libpipeline-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf libpipeline-"$VERSION"
popd
