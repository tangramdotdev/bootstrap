#!/bin/bash
set -euo pipefail
log "Building gcc pass 1 (11 SBU | 3.3 GB)..."

BUILD_LOGFILE=$LOGDIR/5.3-gcc-pass-1.log
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
    sed -e '/m64=/s/lib64/lib/' \
      -i.orig gcc/config/i386/t-linux64 | sudo tee -a "$BUILD_LOGFILE"
    ;;
esac
mkdir -v build
pushd build
../configure \
  --target="$LFS_TGT" \
  --prefix="$LFS"/tools \
  --with-glibc-version=2.36 \
  --with-sysroot="$LFS" \
  --with-newlib \
  --without-headers \
  --disable-nls \
  --disable-shared \
  --disable-multilib \
  --disable-decimal-float \
  --disable-threads \
  --disable-libatomic \
  --disable-libgomp \
  --disable-libquadmath \
  --disable-libssp \
  --disable-libvtv \
  --disable-libstdcxx \
  --enable-languages=c,c++ | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make install | sudo tee -a "$BUILD_LOGFILE"
popd
log "Manually building limits.h..."
cat gcc/limitx.h gcc/glimits.h gcc/limity.h | sudo tee -a \
  "$(dirname "$("$LFS_TGT"-gcc -print-libgcc-file-name)")"/install-tools/include/limits.h "$BUILD_LOGFILE"
popd
rm -rf gcc-"$VERSION"
popd
