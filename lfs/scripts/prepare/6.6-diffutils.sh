#!/bin/bash
set -euo pipefail
log "Building diffutils (0.2 SBU | 26 MB)..."

BUILD_LOGFILE=$LOGDIR/6.6-diffutils.log
VERSION="3.8"

pushd "$LFS"/sources
tar xf diffutils-"$VERSION".tar.xz
pushd diffutils-"$VERSION"
./configure --prefix=/usr --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf diffutils-"$VERSION"
popd
