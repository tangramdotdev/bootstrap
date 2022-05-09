#!/bin/bash
set -euo pipefail
log "Building shadow (0.2 SBU | 49 MB)..."

BUILD_LOGFILE=$LOGDIR/8.25-shadow.log

pushd /sources
tar xf shadow-4.11.1.tar.xz
pushd shadow-4.11.1
sed -i 's/groups$(EXEEXT) //' src/Makefile.in | tee -a "$BUILD_LOGFILE"
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \; | tee -a "$BUILD_LOGFILE"
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; | tee -a "$BUILD_LOGFILE"
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; | tee -a "$BUILD_LOGFILE"
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
    -i etc/login.defs | tee -a "$BUILD_LOGFILE"
touch /usr/bin/passwd
./configure --sysconfdir=/etc \
            --disable-static  \
            --with-group-name-max-length=32 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make exec_prefix=/usr install | tee -a "$BUILD_LOGFILE"
make -C man install-man | tee -a "$BUILD_LOGFILE"

# configure
pwconv | tee -a "$BUILD_LOGFILE"
grpconv | tee -a "$BUILD_LOGFILE"

# passwd root # TODO - how to set inline?

popd
rm -rf shadow-4.11.1
popd
