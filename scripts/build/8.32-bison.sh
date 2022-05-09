#!/bin/bash
set -euo pipefail
log "Building bison (6.3 SBU | 53 MB)..."

BUILD_LOGFILE=$LOGDIR/8.32-bison.log

pushd /sources
tar xf bison-3.8.2.tar.xz
pushd bison-3.8.2
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# super long test suite - does succeed!
#make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf bison-3.8.2
popd
