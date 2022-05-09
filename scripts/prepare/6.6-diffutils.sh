#!/bin/bash
set -euo pipefail
log "Building diffutils (0.2 SBU | 27 MB)..."

BUILD_LOGFILE=$LOGDIR/6.6-diffutils.log

pushd "$LFS"/sources
tar xf diffutils-3.8.tar.xz
pushd diffutils-3.8
./configure --prefix=/usr --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf diffutils-3.8
popd
