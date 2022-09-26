#!/bin/bash
set -euo pipefail
log "Building automake (<0.1 SBU | 116 MB)..."

BUILD_LOGFILE=$LOGDIR/8.45-automake.log
VERSION=1.16.5

pushd /sources
tar xf automake-"$VERSION".tar.xz
pushd automake-"$VERSION"
./configure --prefix=/usr --docdir=/usr/share/doc/automake-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# long
#make -j4 check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf automake-"$VERSION"
popd
