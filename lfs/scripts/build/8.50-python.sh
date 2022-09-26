#!/bin/bash
set -euo pipefail
log "Building python (3.4 SBU | 283 MB)..."

BUILD_LOGFILE=$LOGDIR/8.50-python.log
VERSION=3.10.6

pushd /sources
tar xf Python-"$VERSION".tar.xz
pushd Python-"$VERSION"
./configure --prefix=/usr \
    --enable-shared \
    --with-system-expat \
    --with-system-ffi \
    --enable-optimizations | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
cat >/etc/pip.conf <<EOS
[global]
root-user-action = ignore
disable-pip-version-check = true
EOS
popd
rm -rf Python-"$VERSION"
popd
