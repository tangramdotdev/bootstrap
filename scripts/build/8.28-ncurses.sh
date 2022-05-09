#!/bin/bash
set -euo pipefail
log "Building ncurses (0.4 SBU | 45 MB)..."

BUILD_LOGFILE=$LOGDIR/8.28-ncurses.log

pushd /sources
tar xf ncurses-6.3.tar.gz
pushd ncurses-6.3
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make DESTDIR="$PWD"/dest install | tee -a "$BUILD_LOGFILE"
install -vm755 dest/usr/lib/libncursesw.so.6.3 /usr/lib | tee -a "$BUILD_LOGFILE"
rm -v  dest/usr/lib/{libncursesw.so.6.3,libncurses++w.a} | tee -a "$BUILD_LOGFILE"
cp -av dest/* / | tee -a "$BUILD_LOGFILE"
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so | tee -a "$BUILD_LOGFILE"
    echo "INPUT(-l${lib}w)" | tee -a /usr/lib/lib${lib}.so "$BUILD_LOGFILE"
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc | tee -a "$BUILD_LOGFILE"
done
rm -vf                     /usr/lib/libcursesw.so | tee -a "$BUILD_LOGFILE"
echo "INPUT(-lncursesw)" | tee -a /usr/lib/libcursesw.so "$BUILD_LOGFILE"
ln -sfv libncurses.so      /usr/lib/libcurses.so | tee -a "$BUILD_LOGFILE"
popd
rm -rf ncurses-6.3
popd
