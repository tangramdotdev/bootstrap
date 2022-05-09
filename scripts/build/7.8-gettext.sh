#!/bin/bash
set -euo pipefail
log "Building gettext (1.6 SBU | 280 MB)..."

BUILD_LOGFILE=$LOGDIR/7.8-gettext.log

pushd /sources
tar xf gettext-0.21.tar.xz
pushd gettext-0.21
./configure --disable-shared | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# We just need these tools - this allows us to compile with NLS
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin | tee -a "$BUILD_LOGFILE"
popd
rm -rf gettext-0.21
popd
