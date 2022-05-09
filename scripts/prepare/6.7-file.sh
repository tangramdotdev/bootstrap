#!/bin/bash
set -euo pipefail
log "Building file (0.1 SBU | 32 MB)..."

BUILD_LOGFILE=$LOGDIR/6.7-file.log

pushd "$LFS"/sources
tar xf file-5.41.tar.gz
pushd file-5.41
mkdir build
pushd build
../configure --disable-bzlib      \
  --disable-libseccomp            \
  --disable-xzlib                 \
  --disable-zlib | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
popd
./configure --prefix=/usr --host="$LFS_TGT" --build="$(./config.guess)" | sudo tee -a "$BUILD_LOGFILE"
make FILE_COMPILE="$(pwd)"/build/src/file | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
popd
rm -rf file-5.41
popd
