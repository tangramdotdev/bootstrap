#!/bin/bash
set -euo pipefail
log "Building ncurses (0.7 SBU | 50 MB)..."

BUILD_LOGFILE=$LOGDIR/6.3-ncurses.log
VERSION=6.3

pushd "$LFS"/sources
tar xf ncurses-"$VERSION".tar.gz
pushd ncurses-"$VERSION"
sed -i s/mawk// configure | sudo tee -a "$BUILD_LOGFILE"
mkdir build
pushd build
../configure | sudo tee -a "$BUILD_LOGFILE"
make -C include | sudo tee -a "$BUILD_LOGFILE"
make -C progs tic | sudo tee -a "$BUILD_LOGFILE"
popd
./configure --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(./config.guess)" \
  --mandir=/usr/share/man \
  --with-manpage-format=normal \
  --with-shared \
  --with-cxx-shared \
  --without-debug \
  --without-ada \
  --without-normal \
  --disable-stripping \
  --enable-widec | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" TIC_PATH="$(pwd)"/build/progs/tic install | sudo tee -a "$BUILD_LOGFILE"
echo "INPUT(-lncursesw)" | sudo tee -a "$LFS"/usr/lib/libncurses.so "$BUILD_LOGFILE"
popd
rm -rf ncurses-"$VERSION"
popd
