#!/bin/bash
set -euo pipefail
log "Building texinfo (0.2 SBU | 113 MB)..."

BUILD_LOGFILE=$LOGDIR/7.11-texinfo.log
VERSION=6.8

pushd /sources
tar xf texinfo-"$VERSION".tar.xz
pushd texinfo-"$VERSION"
# Required to build with glibc 2.34+
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf texinfo-"$VERSION"
popd
