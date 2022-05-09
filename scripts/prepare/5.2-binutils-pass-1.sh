#!/bin/bash
set -euo pipefail
log "Building binutils pass 1 (1 SBU | 620 MB)..."

BUILD_LOGFILE=$LOGDIR/5.2-binutils-pass-1.log

pushd "$LFS"/sources
tar xf binutils-2.38.tar.xz
pushd binutils-2.38
mkdir -v build
pushd build
../configure --prefix="$LFS"/tools    \
  --with-sysroot="$LFS"               \
  --target="$LFS_TGT"                 \
  --disable-nls                       \
  --disable-werror | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make install | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf binutils-2.38
popd
