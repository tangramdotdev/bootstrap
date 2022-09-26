#!/bin/bash
set -euo pipefail
log "Building check (0.1 SBU | 12 MB)..."

BUILD_LOGFILE=$LOGDIR/8.54-check.log
VERSION=0.15.2

pushd /sources
tar xf check-"$VERSION".tar.gz
pushd check-"$VERSION"
./configure --prefix=/usr --disable-static | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make docdir=/usr/share/doc/check-"$VERSION" install | tee -a "$BUILD_LOGFILE"
popd
rm -rf check-"$VERSION"
popd
