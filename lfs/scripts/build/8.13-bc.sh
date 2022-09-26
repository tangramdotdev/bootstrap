#!/bin/bash
set -euo pipefail
log "Building bc (<0.1 SBU | 7.4 MB)..."

BUILD_LOGFILE=$LOGDIR/8.13-bc.log
VERSION=6.0.1

pushd /sources
tar xf bc-"$VERSION".tar.xz
pushd bc-"$VERSION"
CC=gcc ./configure --prefix=/usr -G -O3 -r | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf bc-"$VERSION"
popd
