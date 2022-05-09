#!/bin/bash
set -euo pipefail
log "Building gettext (2.7 SBU | 233 MB)..."

BUILD_LOGFILE=$LOGDIR/8.31-gettext.log

pushd /sources
tar xf gettext-0.21.tar.xz
pushd gettext-0.21
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
chmod -v 0755 /usr/lib/preloadable_libintl.so | tee -a "$BUILD_LOGFILE"
popd
rm -rf gettext-0.21
popd
