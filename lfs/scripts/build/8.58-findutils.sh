#!/bin/bash
set -euo pipefail
log "Building findutils (0.8 SBU | 52 MB)..."

BUILD_LOGFILE=$LOGDIR/8.58-findutils.log
VERSION=4.9.0

pushd /sources
tar xf findutils-"$VERSION".tar.xz
pushd findutils-"$VERSION"
case $(uname -m) in
    i?86) TIME_T_32_BIT_OK=yes ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
    x86_64 | aarch64) ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
esac
sed -i 's/extras//' Makefile.in | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf findutils-"$VERSION"
popd
