#!/bin/bash
set -euo pipefail
log "Building tar (1.7 SBU | 40 MB)..."

BUILD_LOGFILE=$LOGDIR/8.66-tar.log

pushd /sources
tar xf tar-1.34.tar.xz
pushd tar-1.34
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make -C doc install-html docdir=/usr/share/doc/tar-1.34 | tee -a "$BUILD_LOGFILE"
popd
rm -rf tar-1.34
popd
