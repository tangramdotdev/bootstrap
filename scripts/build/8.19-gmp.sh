#!/bin/bash
set -euo pipefail
log "Building gmp (1.0 SBU | 52 MB)..."

BUILD_LOGFILE=$LOGDIR/8.19-gmp.log

pushd /sources
tar xf gmp-6.2.1.tar.xz
pushd gmp-6.2.1
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make html | tee -a "$BUILD_LOGFILE"
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make install-html | tee -a "$BUILD_LOGFILE"
popd
rm -rf gmp-6.2.1
popd
