#!/bin/bash
set -euo pipefail
log "Building tar (0.2 SBU | 38 MB)..."

BUILD_LOGFILE=$LOGDIR/6.15-tar.log
VERSION=1.34

pushd "$LFS"/sources
tar xf tar-"$VERSION".tar.xz
pushd tar-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf tar-"$VERSION"
popd
