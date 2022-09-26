#!/bin/bash
set -euo pipefail
log "Building gawk (0.4 SBU | 44 MB)..."

BUILD_LOGFILE=$LOGDIR/8.57-gawk.log
VERSION=5.1.1

pushd /sources
tar xf diffutils-"$VERSION".tar.xz
pushd diffutils-"$VERSION"
sed -i 's/extras//' Makefile.in | tee -a "$BUILD_LOGFILE"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf diffutils-"$VERSION"
popd
