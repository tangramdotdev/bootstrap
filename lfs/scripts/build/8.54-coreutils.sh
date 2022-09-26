#!/bin/bash
set -euo pipefail
log "Building coreutils (2.8 SBU | 159 MB)..."

BUILD_LOGFILE=$LOGDIR/8.53-coreutils.log
VERSION=9.1

pushd /sources
tar xf coreutils-"$VERSION".tar.xz
pushd coreutils-"$VERSION"
patch -Np1 -i ../coreutils-"$VERSION"-i18n-1.patch | tee -a "$BUILD_LOGFILE"
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
    --prefix=/usr \
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
rm -rf coreutils-"$VERSION"
popd
