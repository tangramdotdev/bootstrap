#!/bin/bash
set -euo pipefail
log "Building bison (0.3 SBU | 50 MB)..."

BUILD_LOGFILE=$LOGDIR/7.9-bison.log

pushd /sources
tar xf bison-3.8.2.tar.xz
pushd bison-3.8.2
./configure --prefix=/usr \
  --docdir=/usr/share/doc/bison-3.8.2 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf bison-3.8.2
popd
