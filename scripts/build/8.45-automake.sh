#!/bin/bash
set -euo pipefail
log "Building automake (<0.1 SBU | 115 MB)..."

BUILD_LOGFILE=$LOGDIR/8.45-automake.log

pushd /sources
tar xf automake-1.16.5.tar.xz
pushd automake-1.16.5
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# long
#make -j4 check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf automake-1.16.5
popd
