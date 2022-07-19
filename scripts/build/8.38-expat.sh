#!/bin/bash
set -euo pipefail
log "Building expat (0.1 SBU | 12 MB)..."

BUILD_LOGFILE=$LOGDIR/8.38-expat.log

pushd /sources
tar xf expat-2.4.6.tar.xz
pushd expat-2.4.6
./configure --prefix=/usr                \
            --disable-static             \
            --docdir=/usr/share/doc/expat-2.4.6 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf expat-2.4.6
popd
