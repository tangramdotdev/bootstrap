#!/bin/bash
set -euo pipefail
log "Building coreutils (0.6 SBU | 163 MB)..."

BUILD_LOGFILE=$LOGDIR/6.5-coreutils.log
VERSION=9.1

pushd "$LFS"/sources
tar xf coreutils-"$VERSION".tar.xz
pushd coreutils-"$VERSION"
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(build-aux/config.guess)" \
  --enable-install-program=hostname \
  --enable-no-install-program=kill,uptime | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
mv -v "$LFS"/usr/bin/chroot "$LFS"/usr/sbin | sudo tee -a "$BUILD_LOGFILE"
mkdir -pv "$LFS"/usr/share/man/man8 | sudo tee -a "$BUILD_LOGFILE"
mv -v "$LFS"/usr/share/man/man1/chroot.1 "$LFS"/usr/share/man/man8/chroot.8 | sudo tee -a "$BUILD_LOGFILE"
sed -i 's/"1"/"8"/' "$LFS"/usr/share/man/man8/chroot.8 | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf coreutils-"$VERSION"
popd
