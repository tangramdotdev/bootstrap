#!/bin/bash
set -euo pipefail
log "Building util-linux (1.0 SBU | 283 MB)..."

BUILD_LOGFILE=$LOGDIR/8.73-util-linux.log
VERSION=2.38.1

pushd /sources
tar xf util-linux-"$VERSION".tar.xz
pushd util-linux-"$VERSION"
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --bindir=/usr/bin \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --docdir=/usr/share/doc/util-linux-"$VERSION" \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-static \
    --without-python \
    --without-systemd \
    --without-systemdsystemunitdir | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf util-linux-"$VERSION"
popd
