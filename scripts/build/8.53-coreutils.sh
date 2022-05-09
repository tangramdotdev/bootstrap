#!/bin/bash
set -euo pipefail
log "Building coreutils (2.6 SBU | 153 MB)..."

BUILD_LOGFILE=$LOGDIR/8.53-coreutils.log

pushd /sources
tar xf coreutils-9.0.tar.xz
pushd coreutils-9.0
patch -Np1 -i ../coreutils-9.0-i18n-1.patch | tee -a "$BUILD_LOGFILE"
patch -Np1 -i ../coreutils-9.0-chmod_fix-1.patch | tee -a "$BUILD_LOGFILE"
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#make NON_ROOT_USERNAME=tester check-root | tee -a "$BUILD_LOGFILE"
#echo "dummy:x:102:tester" >> /etc/group | tee -a "$BUILD_LOGFILE"
#chown -Rv tester . | tee -a "$BUILD_LOGFILE"
#su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check" | tee -a "$BUILD_LOGFILE"
#sed -i '/dummy/d' /etc/group | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
mv -v /usr/bin/chroot /usr/sbin | tee -a "$BUILD_LOGFILE"
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8 | tee -a "$BUILD_LOGFILE"
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8 | tee -a "$BUILD_LOGFILE"
popd
rm -rf coreutils-9.0
popd
