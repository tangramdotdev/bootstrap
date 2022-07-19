#!/bin/bash
set -euo pipefail
log "Building less (0.1 SBU | 4.2 MB)..."

BUILD_LOGFILE=$LOGDIR/8.40-less.log

pushd /sources
tar xf less-590.tar.gz
pushd less-590
./configure --prefix=/usr                \
            --sysconfdir=/etc | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf less-590
popd
