#!/bin/bash
set -euo pipefail
log "Building tar (0.2 SBU | 38 MB)..."

BUILD_LOGFILE=$LOGDIR/6.15-tar.log

pushd "$LFS"/sources
tar xf tar-1.34.tar.xz
pushd tar-1.34
./configure --prefix=/usr     \
  --host="$LFS_TGT"           \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf tar-1.34
popd
