#!/bin/bash
set -euo pipefail
log "Building libcap (<0.1 SBU | 2.7 MB)..."

BUILD_LOGFILE=$LOGDIR/8.24-libcap.log
VERSION=2.65

pushd /sources
tar xf libcap-"$VERSION".tar.xz
pushd libcap-"$VERSION"
sed -i '/install -m.*STA/d' libcap/Makefile | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" prefix=/usr lib=lib | tee -a "$BUILD_LOGFILE"
# make test | tee -a "$BUILD_LOGFILE"
make prefix=/usr lib=lib install | tee -a "$BUILD_LOGFILE"
popd
rm -rf libcap-"$VERSION"
popd
