#!/bin/sh
set -eu
PREFIX=$PWD/chroot
GCC_DEST=$PWD/gcc-prefix
CFLAGS="--sysroot=$PREFIX -Wl,-dynamic-linker=$PREFIX/usr/lib/ld-linux-x86-64.so.2 -Wl,-rpath,$PREFIX/usr/lib"
mirror=http://ftpmirror.gnu.org
# get source
version=11.2.0
gcc=gcc-$version
gcc_src=$gcc.tar.xz
if [ ! -f $gcc_src ]; then
  curl -OL $mirror/gcc/$gcc/$gcc_src
fi
# extract
rm -rf ./$gcc
tar xf ./$gcc_src
# build
cd $gcc
./contrib/download_prerequisites
mkdir -p build
cd build
../configure                             \
  CFLAGS="$CFLAGS"                       \
  --prefix="$GCC_DEST"                   \
  --with-sysroot="$PREFIX"               \
  --enable-languages=c,c++               \
  --disable-multilib                     \
  --disable-bootstrap
make -j"$(nproc)"
make install
cd ..
