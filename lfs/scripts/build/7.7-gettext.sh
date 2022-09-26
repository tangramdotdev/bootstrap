#!/bin/bash
set -euo pipefail
log "Building gettext (1.6 SBU | 282 MB)..."

BUILD_LOGFILE=$LOGDIR/7.7-gettext.log
VERSION=0.21

pushd /sources
tar xf gettext-"$VERSION".tar.xz
pushd gettext-"$VERSION"
./configure --disable-shared | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# We just need these tools - this allows us to compile with NLS
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin | tee -a "$BUILD_LOGFILE"
popd
rm -rf gettext-"$VERSION"
popd
