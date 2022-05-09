#!/bin/bash
set -euo pipefail
log "Building libcap (<0.1 SBU | 2.7 MB)..."

BUILD_LOGFILE=$LOGDIR/8.24-libcap.log

pushd /sources
tar xf libcap-2.63.tar.xz
pushd libcap-2.63
sed -i '/install -m.*STA/d' libcap/Makefile | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" prefix=/usr lib=lib | tee -a "$BUILD_LOGFILE"
make test | tee -a "$BUILD_LOGFILE"
make prefix=/usr lib=lib install | tee -a "$BUILD_LOGFILE"
popd
rm -rf libcap-2.63
popd
