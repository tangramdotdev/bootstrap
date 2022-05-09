#!/bin/bash
set -euo pipefail
log "Building readline (0.1 SBU | 15 MB)..."

BUILD_LOGFILE=$LOGDIR/8.11-readline.log

pushd /sources
tar xf readline-8.1.2.tar.gz
pushd readline-8.1.2
sed -i '/MV.*old/d' Makefile.in | tee -a "$BUILD_LOGFILE"
sed -i '/{OLDSUFF}/c:' support/shlib-install | tee -a "$BUILD_LOGFILE"
./configure --prefix=/usr    \
  --disable-static \
  --with-curses    \
  --docdir=/usr/share/doc/readline-8.1.2 | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" SHLIB_LIBS="-lncursesw" | tee -a "$BUILD_LOGFILE"
make SHLIB_LIBS="-lncursesw" install | tee -a "$BUILD_LOGFILE"
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1.2 | tee -a "$BUILD_LOGFILE"
popd
rm -rf readline-8.1.2
popd
