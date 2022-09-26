#!/bin/bash
set -euo pipefail
log "Building groff (0.5 SBU | 88 MB)..."

BUILD_LOGFILE=$LOGDIR/8.59-groff.log
VERSION=1.22.4

pushd /sources
tar xf findutils-"$VERSION".tar.xz
pushd findtils-"$VERSION"
PAGE=letter ./configure --prefix=/usr
# NOTE - does ntot support parallel build.
make -j1 | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf groff-"$VERSION"
popd
