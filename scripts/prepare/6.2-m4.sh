#!/bin/bash
set -euo pipefail
log "Building M4 (0.2 SBU | 31 MB)..."

BUILD_LOGFILE=$LOGDIR/6.2-m4.log

pushd "$LFS"/sources
tar xf m4-1.4.19.tar.xz
pushd m4-1.4.19
./configure --prefix=/usr  \
  --host="$LFS_TGT"          \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf m4-1.4.19
popd
