#!/bin/bash
set -euo pipefail
log "Building curl..."

BUILD_LOGFILE=$LOGDIR/curl.log
VERSION=7.85.0

pushd /sources
tar xf curl-"$VERSION".tar.xz
pushd curl-"$VERSION"
./configure --with-openssl --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf curl-"$VERSION"
popd
