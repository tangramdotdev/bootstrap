#!/bin/bash
set -euo pipefail
log "Building perl (1.6 SBU | 272 MB)..."

BUILD_LOGFILE=$LOGDIR/7.10-perl.log

pushd /sources
tar xf perl-5.34.0.tar.xz
pushd perl-5.34.0
sh Configure -des                             \
  -Dprefix=/usr                               \
  -Dvendorprefix=/usr                         \
  -Dprivlib=/usr/lib/perl5/5.34/core_perl     \
  -Darchlib=/usr/lib/perl5/5.34/core_perl     \
  -Dsitelib=/usr/lib/perl5/5.34/site_perl     \
  -Dsitearch=/usr/lib/perl5/5.34/site_perl    \
  -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl \
  -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf perl-5.34.0
popd
