#!/bin/bash
set -euo pipefail
log "Building gdbm (0.1 SBU | 13 MB)..."

BUILD_LOGFILE=$LOGDIR/8.36-gdbm.log
VERSION=81.23

pushd /sources
tar xf gdbm-"$VERSION".tar.gz
pushd gdbm-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --enable-libgdbm-compat | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf gdbm-"$VERSION"
popd
