#!/bin/sh
set -eu
PREFIX=$PWD/chroot
CFLAGS="--sysroot=$PREFIX -Wl,-dynamic-linker=$PREFIX/usr/lib/ld-linux-x86-64.so.2 -Wl,-rpath,$PREFIX/usr/lib"
mirror=http://ftpmirror.gnu.org
# get source
hello='hello-2.12'
hello_src=$hello.tar.gz
if [ ! -f $hello_src ]; then
  curl -OL $mirror/hello/$hello_src
fi
# extract
rm -rf ./$hello
tar xf ./$hello_src
# build
cd $hello
./configure                              \
  CC="$PREFIX/usr/bin/gcc"               \
  CFLAGS="$CFLAGS"                       \
  CPPFLAGS="$CFLAGS"                     \
  LDFLAGS="$CFLAGS"                      \
  CPP="$PREFIX/usr/bin/cpp"
make -j"$(nproc)"
