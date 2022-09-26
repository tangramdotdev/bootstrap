#!/bin/bash
set -euo pipefail
log "Building gettext (2.7 SBU | 235 MB)..."

BUILD_LOGFILE=$LOGDIR/8.31-gettext.log
VERSION=0.21

pushd /sources
tar xf gettext-"$VERSION".tar.xz
pushd gettext-"$VERSION"
./configure --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/gettext-"$VERSION" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
chmod -v 0755 /usr/lib/preloadable_libintl.so | tee -a "$BUILD_LOGFILE"
popd
rm -rf gettext-"$VERSION"
popd
