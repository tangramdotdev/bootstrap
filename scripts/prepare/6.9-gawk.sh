#!/bin/bash
set -euo pipefail
log "Building gawk (0.2 SBU | 45 MB)..."

BUILD_LOGFILE=$LOGDIR/6.9-gawk.log

pushd "$LFS"/sources
tar xf gawk-5.1.1.tar.xz
pushd gawk-5.1.1
sed -i 's/extras//' Makefile.in | sudo tee -a "$BUILD_LOGFILE"
./configure --prefix=/usr     \
  --host="$LFS_TGT"           \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf gawk-5.1.1
popd
