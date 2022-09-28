#!/bin/bash
set -euo pipefail
log "Building groff (0.5 SBU | 88 MB)..."

BUILD_LOGFILE=$LOGDIR/8.59_groff.log
VERSION=1.22.4

pushd /sources
tar xf groff-"$VERSION".tar.xz
pushd groff-"$VERSION"
PAGE=letter ./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j1 | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf groff-"$VERSION"
popd
