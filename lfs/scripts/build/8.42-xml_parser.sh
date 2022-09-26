#!/bin/bash
set -euo pipefail
log "Building XML::Parser (<0.1 SBU | 2.3 MB)..."

BUILD_LOGFILE=$LOGDIR/8.42-xml_parser.log
VERSION=2.46

pushd /sources
tar xf XML-Parser"$VERSION".tar.gz
pushd XML-Parser-"$VERSION"
perl Makefile.PL | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
popd
rm -rf XML-Parser-"$VERSION"
popd
