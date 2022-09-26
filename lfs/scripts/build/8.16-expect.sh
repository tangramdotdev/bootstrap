#!/bin/bash
set -euo pipefail
log "Building expect (0.2 SBU | 3.9 MB)..."

BUILD_LOGFILE=$LOGDIR/8.16-expect.log
VERSION=5.45.4

pushd /sources
tar xf expect"$VERSION".tar.gz
pushd expect"$VERSION"
./configure --prefix=/usr \
    --with-tcl=/usr/lib \
    --enable-shared \
    --mandir=/usr/share/man \
    --with-tclinclude=/usr/include | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
ln -svf expect"$VERSION"/libexpect"$VERSION".so /usr/lib | tee -a "$BUILD_LOGFILE"
popd
rm -rf expect"$VERSION"
popd
