#!/bin/bash
set -euo pipefail
log "Building attr (<0.1 SBU | 4.1 MB)..."

BUILD_LOGFILE=$LOGDIR/8.3-man-pages.log
VERSION=2.5.1

pushd /sources
tar xf attr-"$VERSION".tar.gz
pushd attr-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --sysconfdir=/etc \
    --docdir=/usr/share/doc/attr-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf attr-"$VERSION"
popd
