#!/bin/bash
set -euo pipefail
log "Building pkg-config (0.3 SBU | 29 MB)..."

BUILD_LOGFILE=$LOGDIR/8.27-pkg-config.log
VERSION=0.29.2

pushd /sources
tar xf pkg-config-"$VERSION".tar.gz
pushd pkg-config-"$VERSION"
./configure --prefix=/usr \
    --with-internal-glib \
    --disable-host-tool \
    --docdir=/usr/share/doc/pkg-config-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf pkg-config-"$VERSION"
popd
