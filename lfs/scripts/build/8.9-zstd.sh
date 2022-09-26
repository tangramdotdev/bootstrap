#!/bin/bash
set -euo pipefail
log "Building zstd (1.1 SBU | 56 MB)..."

BUILD_LOGFILE=$LOGDIR/8.9-zstd.log
VERSION=1.5.2

pushd /sources
tar xf zstd-"$VERSION".tar.gz
pushd zstd-"$VERSION"
patch -Np1 -i ../zstd-"$VERSION"-upstream_fixes-1.patch
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make prefix=/usr install | tee -a "$BUILD_LOGFILE"
rm -v /usr/lib/libzstd.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf zstd-"$VERSION"
popd
