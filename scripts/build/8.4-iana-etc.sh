#!/bin/bash
set -euo pipefail
log "Building iana-etc (<0.1 SBU | 4.7 MB)..."

BUILD_LOGFILE=$LOGDIR/8.4-iana-etc.log

pushd /sources
tar xf iana-etc-20220207.tar.gz
pushd iana-etc-20220207
cp services protocols /etc | tee -a "$BUILD_LOGFILE"
popd
rm -rf iana-etc-20220207
popd
