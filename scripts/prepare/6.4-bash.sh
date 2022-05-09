#!/bin/bash
set -euo pipefail
log "Building bash (0.4 SBU | 64 MB)..."

BUILD_LOGFILE=$LOGDIR/6.4-bash.log

pushd "$LFS"/sources
tar xf bash-5.1.16.tar.gz
pushd bash-5.1.16
./configure --prefix=/usr           \
  --build="$(support/config.guess)" \
  --host="$LFS_TGT"                 \
  --without-bash-malloc | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
ln -sv bash "$LFS"/bin/sh | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf bash-5.1.16
popd
