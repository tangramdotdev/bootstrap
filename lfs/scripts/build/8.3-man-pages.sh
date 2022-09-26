#!/bin/bash
set -euo pipefail
log "Building man-pages (<0.1 SBU | 33 MB)..."

BUILD_LOGFILE=$LOGDIR/8.3-man-pages.log
VERSION=5.13

pushd /sources
tar xf man-pages-"$VERSION".tar.xz
pushd man-pages-"$VERSION"
make prefix=/usr install | tee -a "$BUILD_LOGFILE"
popd
rm -rf man-pages-"$VERSION"
popd
