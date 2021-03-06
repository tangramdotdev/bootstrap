#!/bin/bash
set -euo pipefail
log "Building make (0.1 SBU | 15 MB)..."

BUILD_LOGFILE=$LOGDIR/6.12-make.log

pushd "$LFS"/sources
tar xf make-4.3.tar.gz
pushd make-4.3
./configure --prefix=/usr     \
  --without-guile             \
  --host="$LFS_TGT"           \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf make-4.3
popd
