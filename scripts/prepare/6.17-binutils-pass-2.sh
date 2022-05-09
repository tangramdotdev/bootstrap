#!/bin/bash
set -euo pipefail
log "Building binutils pass 2 (1.3 SBU | 520 MB)..."

BUILD_LOGFILE=$LOGDIR/6.17-binutils-pass-2.log

pushd "$LFS"/sources
tar xf binutils-2.38.tar.xz
pushd binutils-2.38
sed '6009s/$add_dir//' -i ltmain.sh
mkdir -v build
pushd build
../configure                   \
  --prefix=/usr                \
  --build="$(../config.guess)" \
  --host="$LFS_TGT"            \
  --disable-nls                \
  --enable-shared              \
  --disable-werror             \
  --enable-64-bit-bfd | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf binutils-2.38
popd
