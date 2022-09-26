#!/bin/bash
set -euo pipefail
log "Building flex (0.4 SBU | 33 MB)..."

BUILD_LOGFILE=$LOGDIR/8.14-flex.log
VERSION=2.6.4

pushd /sources
tar xf flex-"$VERSION".tar.gz
pushd flex-"$VERSION"
./configure --prefix=/usr \
  --docdir=/usr/share/doc/flex-"$VERSION" \
  --disable-static | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
ln -sv flex /usr/bin/lex | tee -a "$BUILD_LOGFILE"
popd
rm -rf flex-"$VERSION"
popd
