#!/bin/bash
set -euo pipefail
log "Building curl..."

BUILD_LOGFILE=$LOGDIR/curl.log

pushd /sources
tar xf curl-7.82.0.tar.xz
pushd curl-7.82.0
./configure --with-openssl --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf curl-7.82.0
popd
