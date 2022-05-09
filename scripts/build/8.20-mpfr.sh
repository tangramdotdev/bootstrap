#!/bin/bash
set -euo pipefail
log "Building mpfr (0.8 SBU | 38 MB)..."

BUILD_LOGFILE=$LOGDIR/8.20-mpfr.log

pushd /sources
tar xf mpfr-4.1.0.tar.xz
pushd mpfr-4.1.0
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make install-html | tee -a "$BUILD_LOGFILE"
popd
rm -rf mpfr-4.1.0
popd
