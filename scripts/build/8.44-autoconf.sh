#!/bin/bash
set -euo pipefail
log "Building autoconf (<0.1 SBU | 24 MB)..."

BUILD_LOGFILE=$LOGDIR/8.44-autoconf.log

pushd /sources
tar xf autoconf-2.71.tar.xz
pushd autoconf-2.71
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# long
#make check TESTSUITEFLAGS=-j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf autoconf-2.71
popd
