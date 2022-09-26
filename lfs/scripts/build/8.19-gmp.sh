#!/bin/bash
set -euo pipefail
log "Building gmp (0.9 SBU | 53 MB)..."

BUILD_LOGFILE=$LOGDIR/8.19-gmp.log
VERSION=6.2.1

pushd /sources
tar xf gmp-"$VERSION".tar.xz
pushd gmp-"$VERSION"
./configure --prefix=/usr \
    --enable-cxx \
    --disable-static \
    --docdir=/usr/share/doc/gmp-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
# make check 2>&1 | tee gmp-check-log
# awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make install-html | tee -a "$BUILD_LOGFILE"
popd
rm -rf gmp-"$VERSION"
popd
