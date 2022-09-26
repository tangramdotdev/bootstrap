#!/bin/bash
set -euo pipefail
log "Building sed (0.1 SBU | 20 MB)..."

BUILD_LOGFILE=$LOGDIR/6.14-sed.log
VERSION=4.8

pushd "$LFS"/sources
tar xf sed-"$VERSION".tar.xz
pushd sed-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf sed-"$VERSION"
popd
