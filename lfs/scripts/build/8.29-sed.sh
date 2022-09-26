#!/bin/bash
set -euo pipefail
log "Building sed (0.4 SBU | 31 MB)..."

BUILD_LOGFILE=$LOGDIR/8.29-sed.log
VERSION=4.8

pushd /sources
tar xf sed-"$VERSION".tar.xz
pushd sed-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
# chown -Rv tester . | tee -a "$BUILD_LOGFILE"
# su tester -c "PATH=$PATH make check" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
install -d -m755 /usr/share/doc/sed-"$VERSION" | tee -a "$BUILD_LOGFILE"
install -m644 doc/sed.html /usr/share/doc/sed-"$VERSION" | tee -a "$BUILD_LOGFILE"
popd
rm -rf sed-"$VERSION"
popd
