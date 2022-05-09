#!/bin/bash
set -euo pipefail
log "Building OpenSSL (5.4 SBU | 474 MB)..."

BUILD_LOGFILE=$LOGDIR/8.46-openssl.log

pushd /sources
tar xf openssl-3.0.1.tar.gz
pushd openssl-3.0.1
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile | tee -a "$BUILD_LOGFILE"
make MANSUFFIX=ssl install install | tee -a "$BUILD_LOGFILE"
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.1 | tee -a "$BUILD_LOGFILE"
popd
rm -rf openssl-3.0.1
popd
