#!/bin/bash
set -euo pipefail
log "Building python3 (1.2 SBU | 359 MB)..."

BUILD_LOGFILE=$LOGDIR/7.11-python3.log

pushd /sources
tar xf Python-3.10.2.tar.xz
pushd Python-3.10.2
./configure        \
  --prefix=/usr    \
  --enable-shared  \
  --without-ensurepip | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf Python-3.10.2
popd
