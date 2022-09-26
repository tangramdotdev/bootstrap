#!/bin/bash
set -euo pipefail
log "Building gawk (0.2 SBU | 45 MB)..."

BUILD_LOGFILE=$LOGDIR/6.9-gawk.log
VERSION=5.1.1

pushd "$LFS"/sources
tar xf gawk-"$VERSION".tar.xz
pushd gawk-"$VERSION"
sed -i 's/extras//' Makefile.in | sudo tee -a "$BUILD_LOGFILE"
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf gawk-"$VERSION"
popd
