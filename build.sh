#!/bin/bash

# Run the whole thing and copy the result out to $PWD/lfs.  Logs are available at $PWD/logs.

DEST=chroot
OCI=podman

set -euxo pipefail
if [ "$( $OCI ps -a | grep -c lfs )" -gt 0 ]; then
  $OCI rm lfs
fi
mkdir -p "$PWD"/logs
if [ ! -d "$PWD"/lfs ]; then
  mkdir -p "$PWD"/lfs
fi
$OCI build -t lfs:11.1 .
$OCI run -it --privileged --name lfs lfs:11.1
rm -rf ./lfs/*
$OCI cp lfs:/mnt/lfs .
mv lfs $DEST

# Perform further cleanup
rm -rfv $DEST/usr/share/{doc,man,info}
rm -rfv $DEST/usr/share/i18n/locales/*
find $DEST/usr/share/locale ! \( -name "en_US" -o -name "en_US.utf8" \) -type d -exec rm -rf {} +
find $DEST -depth -name \*.dbg -exec rm -f {} +
rm -rfv $DEST/{lfs,logs,sources,tools}
