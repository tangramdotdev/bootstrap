#!/bin/bash
set -euo pipefail
log "Building DejaGNU (<0.1 SBU | 6.9 MB)..."

BUILD_LOGFILE=$LOGDIR/8.17-dejagnu.log

pushd /sources
tar xf dejagnu-1.6.3.tar.gz
pushd dejagnu-1.6.3
mkdir -v build
pushd build
../configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi | tee -a "$BUILD_LOGFILE"
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
install -v -dm755  /usr/share/doc/dejagnu-1.6.3 | tee -a "$BUILD_LOGFILE"
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3 | tee -a "$BUILD_LOGFILE"
make check | tee -a "$BUILD_LOGFILE"
popd
popd
rm -rf dejagnu-1.6.3
popd
