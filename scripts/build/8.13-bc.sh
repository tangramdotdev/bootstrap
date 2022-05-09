#!/bin/bash
set -euo pipefail
log "Building bc (<0.1 SBU | 7.1 MB)..."

BUILD_LOGFILE=$LOGDIR/8.13-bc.log

pushd /sources
tar xf bc-5.2.2.tar.xz
pushd bc-5.2.2
CC=gcc ./configure --prefix=/usr -G -O3 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf bc-5.2.2
popd
