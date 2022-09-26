#!/bin/bash
set -euo pipefail
log "Building libtool (1.5 SBU | 43 MB)..."

BUILD_LOGFILE=$LOGDIR/8.35-libtool.log
VERSION=2.4.7

pushd /sources
tar xf libtool-"$VERSION".tar.xz
pushd libtool-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#make check TESTSUITEFLAGS=-j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
rm -fv /usr/lib/libltdl.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf libtool-"$VERSION"
popd
