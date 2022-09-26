#!/bin/bash
set -euo pipefail
log "Building perl (9.4 SBU | 236 MB)..."

BUILD_LOGFILE=$LOGDIR/8.41-perl.log
VERSION=5.36.0

pushd /sources
tar xf perl-"$VERSION".tar.xz
pushd perl-"$VERSION"
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des \
    -Dprefix=/usr \
    -Dvendorprefix=/usr \
    -Dprivlib=/usr/lib/perl5/"$VERSION"/core_perl \
    -Darchlib=/usr/lib/perl5/"$VERSION"/core_perl \
    -Dsitelib=/usr/lib/perl5/"$VERSION"/site_perl \
    -Dsitearch=/usr/lib/perl5/"$VERSION"/site_perl \
    -Dvendorlib=/usr/lib/perl5/"$VERSION"/vendor_perl \
    -Dvendorarch=/usr/lib/perl5/"$VERSION"/vendor_perl \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/usr/bin/less -isR" \
    -Duseshrplib \
    -Dusethreads | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# LONG
#make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
unset BUILD_ZLIB BUILD_BZIP2
popd
rm -rf perl-"$VERSION"
popd
