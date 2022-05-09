#!/bin/bash
set -euo pipefail
log "Building gzip (0.1 SBU | 11 MB)..."

BUILD_LOGFILE=$LOGDIR/6.11-gzip.log

pushd "$LFS"/sources
tar xf gzip-1.11.tar.xz
pushd gzip-1.11
./configure --prefix=/usr         \
  --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf gzip-1.11
popd
