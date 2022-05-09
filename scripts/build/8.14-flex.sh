#!/bin/bash
set -euo pipefail
log "Building flex (0.4 SBU | 32 MB)..."

BUILD_LOGFILE=$LOGDIR/8.14-flex.log

pushd /sources
tar xf flex-2.6.4.tar.gz
pushd flex-2.6.4
./configure --prefix=/usr \
  --docdir=/usr/share/doc/flex-2.6.4 \
  --disable-static | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
ln -sv flex /usr/bin/lex | tee -a "$BUILD_LOGFILE"
popd
rm -rf flex-2.6.4
popd
