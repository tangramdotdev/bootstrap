#!/bin/bash
set -euo pipefail
log "Building binutils pass 1 (1 SBU | 620 MB)..."

BUILD_LOGFILE=$LOGDIR/5.2-binutils-pass-1.log
VERSION=2.39

pushd "$LFS"/sources
tar xf binutils-"$VERSION".tar.xz
pushd binutils-"$VERSION"
mkdir -v build
pushd build
../configure --prefix="$LFS"/tools \
  --with-sysroot="$LFS" \
  --target="$LFS_TGT" \
  --enable-gprofng=no \
  --disable-nls \
  --disable-werror | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make install | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf binutils-"$VERSION"
popd
