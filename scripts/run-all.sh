#!/bin/bash
set -euo pipefail

# Clear logs
sudo rm -rf "$LOGDIR"/*

function log {
  echo "[$(date)] $1" | sudo tee -a "$LOGFILE"
}
export -f log

log "Starting build..."

# Run preparation
case "$EXISTING_CROSS_TOOLCHAIN" in
  "0")
    sh /tools/run-prepare.sh
    ;;
  "1")
    log "Using existing cross toolchain!!"
    ;;
  *)
    log "Unrecognized EXISTING_CROSS_TOOLCHAIN value!!!"
    false
    ;;
esac

log "Preparing to enter chroot..."
exec sudo -E -u root /bin/sh - <<EOF
#  change ownership
chown -R root:root $LFS/{usr,lib,lib64,var,etc,bin,sbin,tools,logs}
# prevent "bad interpreter: Text file busy"
sync
# continue
sh /tools/run-build.sh
# sh /tools/run-image.sh
EOF
