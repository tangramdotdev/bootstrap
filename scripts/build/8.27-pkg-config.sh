#!/bin/bash
set -euo pipefail
log "Building pkg-config (0.3 SBU | 29 MB)..."

BUILD_LOGFILE=$LOGDIR/8.27-pkg-config.log

pushd /sources
tar xf pkg-config-0.29.2.tar.gz
pushd pkg-config-0.29.2
./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf pkg-config-0.29.2
popd
