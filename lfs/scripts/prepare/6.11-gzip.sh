#!/bin/bash
set -euo pipefail
log "Building gzip (0.1 SBU | 11 MB)..."

BUILD_LOGFILE=$LOGDIR/6.11-gzip.log
VERSION=1.12

pushd "$LFS"/sources
tar xf gzip-"$VERSION".tar.xz
pushd gzip-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf gzip-"$VERSION"
popd
