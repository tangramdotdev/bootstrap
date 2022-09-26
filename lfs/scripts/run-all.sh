#!/bin/bash
set -euo pipefail

# Clear logs
sudo rm -rf "$LOGDIR"/*

function log {
  echo "[$(date)] $1" | sudo tee -a "$LOGFILE"
}
export -f log

log "Starting build..."

sh /tools/run-prepare.sh

log "Preparing to enter chroot..."
exec sudo -E -u root /bin/sh - <<EOF
#  change ownership
chown -R root:root $LFS/{usr,lib,lib64,var,etc,bin,sbin,tools,logs}
chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64 | aarch64) chown -R root:root $LFS/lib64 ;;
esac
# prevent "bad interpreter: Text file busy"
sync
# continue
sh /tools/run-build.sh
EOF
