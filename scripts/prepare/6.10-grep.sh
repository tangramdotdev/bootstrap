#!/bin/bash
set -euo pipefail
log "Building grep (0.2 SBU | 26 MB)..."

BUILD_LOGFILE=$LOGDIR/6.10-grep.log

pushd "$LFS"/sources
tar xf grep-3.7.tar.xz
pushd grep-3.7
./configure --prefix=/usr         \
  --host="$LFS_TGT" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf grep-3.7
popd
