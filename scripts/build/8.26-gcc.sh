#!/bin/bash
set -euo pipefail
log "Building final gcc (153 SBU | 4.3 GB)..."

BUILD_LOGFILE=$LOGDIR/8.26-gcc.log

pushd /sources
tar xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
sed -e '/static.*SIGSTKSZ/d' \
    -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
    -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp | tee -a "$BUILD_LOGFILE"
sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64 | tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#ulimit -s 32768 | tee -a "$BUILD_LOGFILE"
#chown -Rv tester . | tee -a "$BUILD_LOGFILE"
#su tester -c "PATH=$PATH make -k check" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
rm -rf /usr/lib/gcc/"$(gcc -dumpmachine)"/11.2.0/include-fixed/bits/ | tee -a "$BUILD_LOGFILE"
chown -v -R root:root \
    /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed} | tee -a "$BUILD_LOGFILE"
ln -svr /usr/bin/cpp /usr/lib | tee -a "$BUILD_LOGFILE"
ln -sfv ../../libexec/gcc/"$(gcc -dumpmachine)"/11.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/ | tee -a "$BUILD_LOGFILE"
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib' | tee -a "$BUILD_LOGFILE"
# should get:
#/usr/lib/gcc/x86_64-pc-linux-gnu/11.2.0/../../../../lib/crt1.o succeeded
#/usr/lib/gcc/x86_64-pc-linux-gnu/11.2.0/../../../../lib/crti.o succeeded
#/usr/lib/gcc/x86_64-pc-linux-gnu/11.2.0/../../../../lib/crtn.o succeeded
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log | tee -a "$BUILD_LOGFILE"
# should get:
# #include <...> search starts here:
#  /usr/lib/gcc/x86_64-pc-linux-gnu/11.2.0/include
#  /usr/local/include
#  /usr/lib/gcc/x86_64-pc-linux-gnu/11.2.0/include-fixed
#  /usr/include
grep -B4 '^ /usr/include' dummy.log | tee -a "$BUILD_LOGFILE"
# TODO - more tests!
rm -v dummy.c a.out dummy.log | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/share/gdb/auto-load/usr/lib | tee -a "$BUILD_LOGFILE"
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib | tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf gcc-11.2.0
popd
