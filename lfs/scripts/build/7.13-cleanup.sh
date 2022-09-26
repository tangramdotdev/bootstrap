#!/bin/bash
set -euo pipefail
log "Cleaning unnecessary files from chroot..."
BUILD_LOGFILE=$LOGDIR/7.14-cleanup.log
rm -rf /usr/share/{info,man,doc}/* | tee -a "$BUILD_LOGFILE"
find /usr/{lib,libexec} -name \*.la -delete | tee -a "$BUILD_LOGFILE"
# Note - we still need this through the rest of the process.  Delete AFTER!
# rm -rf /tools  | tee -a "$BUILD_LOGFILE"
