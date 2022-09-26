#!/bin/bash
set -euo pipefail
log "Building diffutils (0.6 SBU | 35 MB)..."

BUILD_LOGFILE=$LOGDIR/8.56-diffutils.log
VERSION=3.8

pushd /sources
tar xf diffutils-"$VERSION".tar.xz
pushd diffutils-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf diffutils-"$VERSION"
popd
