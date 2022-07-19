#!/bin/bash
set -euo pipefail
log "Building python (4.3 SBU | 275 MB)..."

BUILD_LOGFILE=$LOGDIR/8.50-python.log

pushd /sources
tar xf Python-3.10.2.tar.xz
pushd Python-3.10.2
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --with-system-ffi    \
            --with-ensurepip=yes \
            --enable-optimizations | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf Python-3.10.2
popd
