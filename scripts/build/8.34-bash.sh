#!/bin/bash
set -euo pipefail
log "Building bash (1.5 SBU | 50 MB)..."

BUILD_LOGFILE=$LOGDIR/8.34-bash.log

pushd /sources
tar xf bash-5.1.16.tar.gz
pushd bash-5.1.16
./configure --prefix=/usr                      \
            --docdir=/usr/share/doc/bash-5.1.16 \
            --without-bash-malloc              \
            --with-installed-readline | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#chown -Rv tester .
#su -s /usr/bin/expect tester << EOF
#set timeout -1
#spawn make tests
#expect eof
#lassign [wait] _ _ _ value
#exit $value
#EOF
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf bash-5.1.16
popd
# switch into newly installed bash
exec /usr/bin/bash --login
