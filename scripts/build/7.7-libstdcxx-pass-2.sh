#!/bin/bash
set -euo pipefail
log "Building libstdc++ pass 2 (0.8 SBU | 1.1 GB)..."

BUILD_LOGFILE=$LOGDIR/7.7-libstdcxx-pass-2.log

pushd /sources
tar xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
ln -s gthr-posix.h libgcc/gthr-default.h | tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
../libstdc++-v3/configure              \
  CXXFLAGS="-g -O2 -D_GNU_SOURCE"      \
  --prefix=/usr                        \
  --disable-multilib                   \
  --disable-nls                        \
  --host="$(uname -m)"-lfs-linux-gnu   \
  --disable-libstdcxx-pch | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf gcc-11.2.0
popd
