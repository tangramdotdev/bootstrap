#!/bin/bash
set -euo pipefail
log "Building mpc (0.3 SBU | 21 MB)..."

BUILD_LOGFILE=$LOGDIR/8.21-mpc.log

pushd /sources
tar xf mpc-1.2.1.tar.gz
pushd mpc-1.2.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make install-html | tee -a "$BUILD_LOGFILE"
popd
rm -rf mpc-1.2.1
popd
