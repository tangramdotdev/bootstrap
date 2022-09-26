#!/bin/bash
set -euo pipefail
log "Building acl (0.1 SBU | 6.1 MB)..."

BUILD_LOGFILE=$LOGDIR/8.23-acl.log
VERSION=2.3.1

pushd /sources
tar xf acl-"$VERSION".tar.xz
pushd acl-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/acl-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf acl-"$VERSION"
popd
