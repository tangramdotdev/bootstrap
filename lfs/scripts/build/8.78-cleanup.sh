#!/bin/bash
set -euo pipefail

BUILD_LOGFILE=$LOGDIR/8.78-cleanup.sh

# Remove any fields created in test phases
rm -rfv /tmp/* | tee -a "$BUILD_LOGFILE"
# Remove libtool archive files
find /usr/lib /usr/libexec -name \*.la -delete | tee -a "$BUILD_LOGFILE"
# Remove remnants of cross-compiler
find /usr -depth -name "$(uname -m)"-lfs-linux-gnu\* | xargs rm -rf | tee -a "$BUILD_LOGFILE"
# Remove temp user created for testing
# NOTE - would require util-linux in the chroot!
# userdel -r tester | tee -a "$BUILD_LOGFILE"
