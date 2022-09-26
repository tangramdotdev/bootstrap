#!/bin/bash
set -euo pipefail
log "Installing Linux API headers (0.1 SBU | 1.4 GB)..."

BUILD_LOGFILE=$LOGDIR/5.4-linux-api-headers.log
VERSION=5.19.2

pushd "$LFS"/sources
tar xf linux-"$VERSION".tar.xz
pushd linux-"$VERSION"
make mrproper | sudo tee -a "$BUILD_LOGFILE"
# NOTE - cannot use headers_install, no rsync
make headers | sudo tee -a "$BUILD_LOGFILE"
find usr/include -type f ! -name '*.h' -delete | sudo tee -a "$BUILD_LOGFILE"
cp -rv usr/include "$LFS"/usr | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf linux-"$VERSION"
popd
