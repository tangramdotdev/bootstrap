#!/bin/bash
set -euo pipefail
log "Building libstdc++ pass 1 (0.4 SBU | 1.1GB)..."

BUILD_LOGFILE=$LOGDIR/5.6-libstdcxx-pass-1.log
VERSION=12.2.0

pushd "$LFS"/sources
tar xf gcc-"$VERSION".tar.xz
pushd gcc-"$VERSION"
mkdir -v build
pushd build
../libstdc++-v3/configure \
  --host="$LFS_TGT" \
  --build="$(../config.guess)" \
  --prefix=/usr \
  --disable-multilib \
  --disable-nls \
  --disable-libstdcxx-pch \
  --with-gxx-include-dir=/tools/"$LFS_TGT"/include/c++/12.2.0 | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf gcc-"$VERSION"
popd
