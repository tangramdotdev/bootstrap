#!/bin/bash
set -euo pipefail
log "Building glibc (4.4 SBU | 821 MB)..."

BUILD_LOGFILE=$LOGDIR/5.5-glibc.log
VERSION=2.36

pushd "$LFS"/sources
tar xf glibc-"$VERSION".tar.xz
pushd glibc-"$VERSION"
case $(uname -m) in
  i?86)
    ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3 | tee -a "$BUILD_LOGFILE"
    ;;
  x86_64)
    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64 | tee -a "$BUILD_LOGFILE"
    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3 | tee -a "$BUILD_LOGFILE"
    ;;
  aarch64)
    ln -sfv ../lib/ld-linux-aarch64.so.1 "$LFS"/lib64 | sudo tee -a "$BUILD_LOGFILE"
    ln -sfv ../lib/ld-linux-aarch64.so.1 "$LFS"/lib64/ld-lsb-aarch64.so.3 | sudo tee -a "$BUILD_LOGFILE"
    ;;
esac
patch -Np1 -i ../glibc-"$VERSION"-fhs-1.patch | sudo tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
echo "rootsbindir=/usr/sbin" | sudo tee -a configparams "$BUILD_LOGFILE"
../configure \
  --prefix=/usr \
  --host="$LFS_TGT" \
  --build="$(../scripts/config.guess)" \
  --enable-kernel=3.2 \
  --with-headers="$LFS"/usr/include \
  libc_cv_slibdir=/usr/lib | sudo tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | sudo tee -a "$BUILD_LOGFILE"
make DESTDIR="$LFS" install | sudo tee -a "$BUILD_LOGFILE"
sed '/RTLDLIST=/s@/usr@@g' -i "$LFS"/usr/bin/ldd | sudo tee -a "$BUILD_LOGFILE"
# Do sanity check
echo 'int main(){}' | sudo tee -a dummy.c "$BUILD_LOGFILE"
"$LFS_TGT"-gcc dummy.c | sudo tee -a "$BUILD_LOGFILE"
# should return `[Requesting program interpreter: /lib64/ld-linux-aarch64.so.2]`
readelf -l a.out | grep '/ld-linux' | sudo tee -a "$BUILD_LOGFILE"
rm -v dummy.c a.out | sudo tee -a "$BUILD_LOGFILE"
# Finalize limits.h header
"$LFS"/tools/libexec/gcc/"$LFS_TGT"/12.2.0/install-tools/mkheaders | sudo tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf glibc-"$VERSION"
popd
