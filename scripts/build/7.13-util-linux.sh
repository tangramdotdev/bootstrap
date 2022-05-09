#!/bin/bash
set -euo pipefail
log "Building util-linux (0.7 SBU | 129 MB)..."

BUILD_LOGFILE=$LOGDIR/7.13-util-linux.log

pushd /sources
tar xf util-linux-2.37.4.tar.xz
pushd util-linux-2.37.4
# for maximum FHS compliance
mkdir -pv /var/lib/hwclock | tee -a "$BUILD_LOGFILE"
./configure                                 \
  ADJTIME_PATH=/var/lib/hwclock/adjtime     \
  --libdir=/usr/lib                         \
  --docdir=/usr/share/doc/util-linux-2.37.4 \
  --disable-chfn-chsh                       \
  --disable-login                           \
  --disable-nologin                         \
  --disable-su                              \
  --disable-setpriv                         \
  --disable-runuser                         \
  --disable-pylibmount                      \
  --disable-static                          \
  --without-python                          \
  runstatedir=/run | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf util-linux-2.37.4
popd
