#!/bin/bash
set -euo pipefail
log "Building gcc pass 2 (11 SBU | 3.3 GB)..."

BUILD_LOGFILE=$LOGDIR/6.18-gcc-pass-2.log

pushd "$LFS"/sources
tar xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
tar xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 | sudo tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
mkdir -pv "$LFS_TGT"/libgcc
ln -s ../../../libgcc/gthr-posix.h "$LFS_TGT"/libgcc/gthr-default.h | sudo tee -a "$BUILD_LOGFILE"
../configure                                       \
  --build="$(../config.guess)"                     \
  --host="$LFS_TGT"                                \
  --prefix=/usr                                    \
  CC_FOR_TARGET="$LFS_TGT"-gcc                     \
  --with-build-sysroot="$LFS"                      \
  --enable-initfini-array                          \
  --disable-nls                                    \
  --disable-multilib                               \
  --disable-decimal-float                          \
  --disable-libatomic                              \
  --disable-libgomp                                \
  --disable-libquadmath                            \
  --disable-libssp                                 \
  --disable-libvtv                                 \
  --disable-libstdcxx                              \
  --enable-languages=c,c++ | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
ln -sv gcc "$LFS"/usr/bin/cc | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf gcc-11.2.0
popd
