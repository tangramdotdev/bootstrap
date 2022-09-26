#!/bin/bash
set -euo pipefail
log "Building mpc (0.3 SBU | 21 MB)..."

BUILD_LOGFILE=$LOGDIR/8.21-mpc.log
VERSION=1.2.1

pushd /sources
tar xf mpc-"$VERSION".tar.gz
pushd mpc-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/mpc-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make install-html | tee -a "$BUILD_LOGFILE"
popd
rm -rf mpc-"$VERSION"
popd
