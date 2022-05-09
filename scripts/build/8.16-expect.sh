#!/bin/bash
set -euo pipefail
log "Building expect (0.2 SBU | 3.9 MB)..."

BUILD_LOGFILE=$LOGDIR/8.16-expect.log

pushd /sources
tar xf expect5.45.4.tar.gz
pushd expect5.45.4
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib | tee -a "$BUILD_LOGFILE"
popd
rm -rf expect5.45.4
popd
