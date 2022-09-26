#!/bin/bash
set -euo pipefail
log "Building wheel (<0.1 SBU | 956 KB)..."

BUILD_LOGFILE=$LOGDIR/8.51-wheel.log
VERSION=0.37.1

pushd /sources
tar xf wheel-"$VERSION".tar.gz
pushd wheel-"$VERSION"
pip3 install --no-index "$PWD" | tee -a "$BUILD_LOGFILE"
popd
rm -rf wheel-"$VERSION"
popd
