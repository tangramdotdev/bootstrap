#!/bin/bash
set -euo pipefail
log "Building final binutils (8.2 SBU | 2.7 GB)..."

BUILD_LOGFILE=$LOGDIR/8.18-binutils.log
VERSION=2.39

pushd /sources
tar xf binutils-"$VERSION".tar.xz
pushd binutils-"$VERSION"
# should output "spawn ls"
# expect -c "spawn ls" | tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
../configure --prefix=/usr \
    --sysconfdir=/etc \
    --enable-gold \
    --enable-ld=default \
    --enable-plugins \
    --enable-shared \
    --disable-werror \
    --enable-64-bit-bfd \
    --with-system-zlib | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" tooldir=/usr | tee -a "$BUILD_LOGFILE"
# make -k check | tee -a "$BUILD_LOGFILE"
make tooldir=/usr install | tee -a "$BUILD_LOGFILE"
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a | tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf binutils-"$VERSION"
popd
