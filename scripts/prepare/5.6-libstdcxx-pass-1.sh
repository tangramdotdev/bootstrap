#!/bin/bash
set -euo pipefail
log "Building libstdc++ pass 1 (0.4 SBU | 818 MB)..."

BUILD_LOGFILE=$LOGDIR/5.6-libstdcxx-pass-1.log

pushd "$LFS"/sources
tar xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
mkdir -v build
pushd build
../libstdc++-v3/configure             \
  --host="$LFS_TGT"                   \
  --build="$(../config.guess)"        \
  --prefix=/usr                       \
  --disable-multilib                  \
  --disable-nls                       \
  --disable-libstdcxx-pch             \
  --with-gxx-include-dir=/tools/"$LFS_TGT"/include/c++/11.2.0 | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf gcc-11.2.0
popd
