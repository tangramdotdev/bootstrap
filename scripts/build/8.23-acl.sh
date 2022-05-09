#!/bin/bash
set -euo pipefail
log "Building acl (0.1 SBU | 6.1 MB)..."

BUILD_LOGFILE=$LOGDIR/8.23-acl.log

pushd /sources
tar xf acl-2.3.1.tar.xz
pushd acl-2.3.1
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.1 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf acl-2.3.1
popd
