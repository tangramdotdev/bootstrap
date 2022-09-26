#!/bin/bash
set -euo pipefail
log "Building file (0.2 SBU | 34 MB)..."

BUILD_LOGFILE=$LOGDIR/6.7-file.log
VERSION=5.42

pushd "$LFS"/sources
tar xf file-"$VERSION".tar.gz
pushd file-"$VERSION"
mkdir build
pushd build
../configure --disable-bzlib \
  --disable-libseccomp \
  --disable-xzlib \
  --disable-zlib | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
popd
./configure --prefix=/usr --host="$LFS_TGT" --build="$(./config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make FILE_COMPILE="$(pwd)"/build/src/file | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
rm -v "$LFS"/usr/lib/libmagic.la | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf file-"$VERSION"
popd
