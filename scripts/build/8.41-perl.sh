#!/bin/bash
set -euo pipefail
log "Building perl (9.3 SBU | 226 MB)..."

BUILD_LOGFILE=$LOGDIR/8.41-perl.log

pushd /sources
tar xf perl-5.34.0.tar.xz
pushd perl-5.34.0
patch -Np1 -i ../perl-5.34.0-upstream_fixes-1.patch
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.34/core_perl      \
             -Darchlib=/usr/lib/perl5/5.34/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.34/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.34/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# LONG
#make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
unset BUILD_ZLIB BUILD_BZIP2
popd
rm -rf perl-5.34.0
popd
