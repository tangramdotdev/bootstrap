#!/bin/bash
set -euo pipefail
log "Building iana-etc (<0.1 SBU | 4.8 MB)..."

BUILD_LOGFILE=$LOGDIR/8.4-iana-etc.log
VERSION=20220812

pushd /sources
tar xf iana-etc-"$VERSION".tar.gz
pushd iana-etc-"$VERSION"
cp services protocols /etc | tee -a "$BUILD_LOGFILE"
popd
rm -rf iana-etc-"$VERSION"
popd
