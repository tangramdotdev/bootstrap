#!/bin/bash
set -euo pipefail
log "Building texinfo (0.2 SBU | 109 MB)..."

BUILD_LOGFILE=$LOGDIR/7.12-texinfo.log

pushd /sources
tar xf texinfo-6.8.tar.xz
pushd texinfo-6.8
# Required to build with glibc 2.34+
sed -e 's/__attribute_nonnull__/__nonnull/' \
  -i gnulib/lib/malloc/dynarray-skeleton.c | tee -a "$BUILD_LOGFILE"
./configure --prefix=/usr | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf texinfo-6.8
popd
