#!/bin/bash
set -euo pipefail
log "Building OpenSSL (5.0 SBU | 476 MB)..."

BUILD_LOGFILE=$LOGDIR/8.46-openssl.log
VERSION=3.0.5

pushd /sources
tar xf openssl-"$VERSION".tar.gz
pushd openssl-"$VERSION"
./config --prefix=/usr \
   --openssldir=/etc/ssl \
   --libdir=lib \
   shared \
   zlib-dynamic | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile | tee -a "$BUILD_LOGFILE"
make MANSUFFIX=ssl install install | tee -a "$BUILD_LOGFILE"
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-"$VERSION" | tee -a "$BUILD_LOGFILE"
popd
rm -rf openssl-"$VERSION"
popd
