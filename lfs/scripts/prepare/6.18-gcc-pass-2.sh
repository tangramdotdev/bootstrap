#!/bin/bash
set -euo pipefail
log "Building gcc pass 2 (15 SBU | 4.5 GB)..."

BUILD_LOGFILE=$LOGDIR/6.18-gcc-pass-2.log
VERSION=12.2.0

pushd "$LFS"/sources
tar xf gcc-"$VERSION".tar.xz
pushd gcc-"$VERSION"
tar xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc
case $(uname -m) in
  x86_64 | aarch64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 | sudo tee -a "$BUILD_LOGFILE"
    ;;
esac
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
  -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in | sudo tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
mkdir -pv "$LFS_TGT"/libgcc
../configure \
  --build="$(../config.guess)" \
  --host="$LFS_TGT" \
  --prefix=/usr \
  LDFLAGS_FOR_TARGET=-L"$PWD/$LFS_TGT"/libgcc \
  --with-build-sysroot="$LFS" \
  --enable-initfini-array \
  --disable-nls \
  --disable-multilib \
  --disable-decimal-float \
  --disable-libatomic \
  --disable-libgomp \
  --disable-libquadmath \
  --disable-libssp \
  --disable-libvtv \
  --enable-languages=c,c++ | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
ln -sv gcc "$LFS"/usr/bin/cc | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf gcc-"$VERSION"
popd
