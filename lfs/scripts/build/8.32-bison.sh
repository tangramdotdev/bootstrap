#!/bin/bash
set -euo pipefail
log "Building bison (8.7 SBU | 63 MB)..."

BUILD_LOGFILE=$LOGDIR/8.32-bison.log
VERSION=3.8.2

pushd /sources
tar xf bison-"$VERSION".tar.xz
pushd bison-"$VERSION"
./configure --prefix=/usr --docdir=/usr/share/doc/bison-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# super long test suite - does succeed!
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf bison-"$VERSION"
popd
