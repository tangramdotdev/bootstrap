#!/bin/bash
set -euo pipefail
export LOGDIR="$LFS"/logs
export LOGFILE=$LOGDIR/build-lfs.log
function log {
    echo "[$(date)] $1" | tee -a "$LOGFILE"
}
export -f log
log "Running build..."

sh /tools/7.3-prepare-vkfs.sh

# Enter chroot environment with existing tools (7.4)
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login +h \
    -c "sh /tools/chroot-with-tools.sh"

# Cleanly dismount
umount --recursive "$LFS"/dev
umount --recursive "$LFS"/proc
umount --recursive "$LFS"/run
umount --recursive "$LFS"/sys

rm -fv "$LFS"/dev/{console,null}

log "Finished!"
