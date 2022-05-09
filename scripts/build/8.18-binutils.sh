#!/bin/bash
set -euo pipefail
log "Building final binutils (6.1 SBU | 4.6 GB)..."

BUILD_LOGFILE=$LOGDIR/8.18-binutils.log

pushd /sources
tar xf binutils-2.38.tar.xz
pushd binutils-2.38
# should output "spawn ls"
expect -c "spawn ls" | tee -a "$BUILD_LOGFILE"
patch -Np1 -i ../binutils-2.38-lto_fix-1.patch | tee -a "$BUILD_LOGFILE"
sed -e '/R_386_TLS_LE /i \   || (TYPE) == R_386_TLS_IE \\' \
    -i ./bfd/elfxx-x86.h | tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" tooldir=/usr | tee -a "$BUILD_LOGFILE"
make -k check | tee -a "$BUILD_LOGFILE"
make tooldir=/usr install | tee -a "$BUILD_LOGFILE"
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a | tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf binutils-2.38
popd
