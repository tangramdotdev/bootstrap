#!/bin/bash
set -euo pipefail
log "Building less (0.1 SBU | 4.2 MB)..."

BUILD_LOGFILE=$LOGDIR/8.40-less.log
VERSION=590

pushd /sources
tar xf less-"$VERSION".tar.gz
pushd less-"$VERSION"
./configure --prefix=/usr \
    --sysconfdir=/etc | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf less-"$VERSION"
popd
