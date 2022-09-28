#!/bin/bash
set -euo pipefail
log "Building psmisc (<0.1 SBU | 5.8 MB)..."

BUILD_LOGFILE=$LOGDIR/8.30-psmisc.log
VERSION=23.5

pushd /sources
tar xf psmisc-"$VERSION".tar.xz
pushd psmisc-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf psmisc-"$VERSION"
popd
