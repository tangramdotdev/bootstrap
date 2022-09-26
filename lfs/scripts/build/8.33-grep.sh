#!/bin/bash
set -euo pipefail
log "Building grep (0.8 SBU | 37 MB)..."

BUILD_LOGFILE=$LOGDIR/8.33-grep.log
VERSION="3.7"

pushd /sources
tar xf grep-"$VERSION".tar.xz
pushd grep-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf grep-"$VERSION"
popd
