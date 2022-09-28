#!/bin/bash
set -euo pipefail
log "Building perl (1.6 SBU | 222 MB)..."

BUILD_LOGFILE=$LOGDIR/7.9-perl.log
VERSION=5.36.0

pushd /sources
tar xf perl-"$VERSION".tar.xz
pushd perl-"$VERSION"
sh Configure -des \
  -Dprefix=/usr \
  -Dvendorprefix=/usr \
  -Dprivlib=/usr/lib/perl5/"$VERSION"/core_perl \
  -Darchlib=/usr/lib/perl5/"$VERSION"/core_perl \
  -Dsitelib=/usr/lib/perl5/"$VERSION"/site_perl \
  -Dsitearch=/usr/lib/perl5/"$VERSION"/site_perl \
  -Dvendorlib=/usr/lib/perl5/"$VERSION"/vendor_perl \
  -Dvendorarch=/usr/lib/perl5/"$VERSION"/vendor_perl | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf perl-"$VERSION"
popd
