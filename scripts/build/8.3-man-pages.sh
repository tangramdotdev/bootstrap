#!/bin/bash
set -euo pipefail
log "Building man-pages (<0.1 SBU | 33 MB)..."

BUILD_LOGFILE=$LOGDIR/8.3-man-pages.log

pushd /sources
tar xf man-pages-5.13.tar.xz
pushd man-pages-5.13
make prefix=/usr install | tee -a "$BUILD_LOGFILE"
popd
rm -rf man-pages-5.13
popd
