#!/bin/bash
set -euo pipefail
log "Building bzip2 (<0.1 SBU | 7.2 MB)..."

BUILD_LOGFILE=$LOGDIR/8.7-bzip2.log

pushd /sources
tar xf bzip2-1.0.8.tar.gz
pushd bzip2-1.0.8
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch | tee -a "$BUILD_LOGFILE"
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile | tee -a "$BUILD_LOGFILE"
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile | tee -a "$BUILD_LOGFILE"
make -f Makefile-libbz2_so | tee -a "$BUILD_LOGFILE"
make clean | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make PREFIX=/usr install | tee -a "$BUILD_LOGFILE"
cp -av libbz2.so.* /usr/lib | tee -a "$BUILD_LOGFILE"
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so | tee -a "$BUILD_LOGFILE"
cp -v bzip2-shared /usr/bin/bzip2 | tee -a "$BUILD_LOGFILE"
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i | tee -a "$BUILD_LOGFILE"
done
rm -fv /usr/lib/libbz2.a | tee -a "$BUILD_LOGFILE"
popd
rm -rf bzip2-1.0.8
popd
