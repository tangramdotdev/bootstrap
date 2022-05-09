#!/bin/bash
set -euo pipefail
log "Building libtool (1.5 SBU | 43 MB)..."

BUILD_LOGFILE=$LOGDIR/8.35-libtool.log

pushd /sources
tar xf libtool-2.4.6.tar.xz
pushd libtool-2.4.6
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#make check TESTSUITEFLAGS=-j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
rm -fv /usr/lib/libltdl.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf libtool-2.4.6
popd
