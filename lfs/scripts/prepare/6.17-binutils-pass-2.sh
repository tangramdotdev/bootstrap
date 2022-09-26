#!/bin/bash
set -euo pipefail
log "Building binutils pass 2 (1.4 SBU | 514 MB)..."

BUILD_LOGFILE=$LOGDIR/6.17-binutils-pass-2.log
VERSION=2.39

pushd "$LFS"/sources
tar xf binutils-"$VERSION".tar.xz
pushd binutils-"$VERSION"
sed '6009s/$add_dir//' -i ltmain.sh
mkdir -v build
pushd build
../configure \
  --prefix=/usr \
  --build="$(../config.guess)" \
  --host="$LFS_TGT" \
  --disable-nls \
  --enable-shared \
  --enable-gprofng=no \
  --disable-werror \
  --enable-64-bit-bfd | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la} | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf binutils-"$VERSION"
popd
