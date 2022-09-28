#!/bin/bash
set -euo pipefail
log "Building expat (0.1 SBU | 12 MB)..."

BUILD_LOGFILE=$LOGDIR/8.38-expat.log
VERSION=2.4.9

pushd /sources
tar xf expat-"$VERSION".tar.xz
pushd expat-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/expat-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf expat-"$VERSION"
popd
