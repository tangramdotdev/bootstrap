#!/bin/bash
set -euo pipefail
log "Building make (0.5 SBU | 14 MB)..."

BUILD_LOGFILE=$LOGDIR/8.65-make.log
VERSION=4.3

pushd /sources
tar xf make-"$VERSION".tar.gz
pushd make-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf make-"$VERSION"
popd
