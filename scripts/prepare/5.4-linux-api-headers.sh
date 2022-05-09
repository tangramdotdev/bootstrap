#!/bin/bash
set -euo pipefail
log "Installing Linux API headers (0.1 SBU | 1.2 GB)..."

BUILD_LOGFILE=$LOGDIR/5.4-linux-api-headers.log

pushd "$LFS"/sources
tar xf linux-5.16.9.tar.xz
pushd linux-5.16.9
make mrproper | sudo tee -a "$BUILD_LOGFILE"
# NOTE - cannot use headers_install, no rsync
make headers | sudo tee -a "$BUILD_LOGFILE"
find usr/include -name '.*' -delete | sudo tee -a "$BUILD_LOGFILE"
rm usr/include/Makefile | sudo tee -a "$BUILD_LOGFILE"
cp -rv usr/include "$LFS"/usr | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf linux-5.16.9
popd
