#!/bin/bash
set -euo pipefail
log "Building mpfr (0.8 SBU | 39 MB)..."

BUILD_LOGFILE=$LOGDIR/8.20-mpfr.log
VERSION=4.1.0

pushd /sources
tar xf mpfr-"$VERSION".tar.xz
pushd mpfr-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --enable-thread-safe \
    --docdir=/usr/share/doc/mpfr-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make install-html | tee -a "$BUILD_LOGFILE"
popd
rm -rf mpfr-"$VERSION"
popd
