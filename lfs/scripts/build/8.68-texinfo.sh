#!/bin/bash
set -euo pipefail
log "Building texinfo (0.6 SBU | 114 MB)..."

BUILD_LOGFILE=$LOGDIR/8.68-texinfo.log
VERSION=6.8

pushd /sources
tar xf texinfo-"$VERSION".tar.xz
pushd texinfo-"$VERSION"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
#make check | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
make TEXMF=/usr/share/texmf install-tex | tee -a "$BUILD_LOGFILE"
pushd /usr/share/info
rm -v dir
for f in *; do
    install-info $f dir 2>/dev/null
done
popd
popd
rm -rf texinfo-"$VERSION"
popd
