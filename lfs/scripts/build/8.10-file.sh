#!/bin/bash
set -euo pipefail
log "Building file (0.1 SBU | 16 MB)..."

BUILD_LOGFILE=$LOGDIR/8.10-file.log
VERSION=5.42

pushd /sources
tar xf file-"$VERSION".tar.gz
pushd file-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf file-"$VERSION"
popd
