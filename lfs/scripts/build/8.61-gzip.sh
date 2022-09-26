#!/bin/bash
set -euo pipefail
log "Building gzip (0.3 SBU | 21 MB)..."

BUILD_LOGFILE=$LOGDIR/8.61-gzip.log
VERSION=1.12

pushd /sources
tar xf gzip-"$VERSION".tar.xz
pushd gzip-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf gzip-"$VERSION"
popd
