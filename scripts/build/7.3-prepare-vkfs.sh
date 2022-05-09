#!/bin/bash
set -euo pipefail
log "Preparing virtual kernel file system..."

BUILD_LOGFILE=$LOGDIR/7.3-prepare-vkfs.log

mkdir -pv "$LFS"/{dev,proc,sys,run} | tee -a "$BUILD_LOGFILE"
mknod -m 600 "$LFS"/dev/console c 5 1 | tee -a "$BUILD_LOGFILE"
mknod -m 666 "$LFS"/dev/null c 1 3 | tee -a "$BUILD_LOGFILE"
mount -v --bind /dev "$LFS"/dev | tee -a "$BUILD_LOGFILE"
mount -v --bind /dev/pts "$LFS"/dev/pts | tee -a "$BUILD_LOGFILE"
mount -vt proc proc "$LFS"/proc | tee -a "$BUILD_LOGFILE"
mount -vt sysfs sysfs "$LFS"/sys | tee -a "$BUILD_LOGFILE"
mount -vt tmpfs tmpfs "$LFS"/run | tee -a "$BUILD_LOGFILE"
if [ -h "$LFS"/dev/shm ]; then
  mkdir -pv "$LFS"/"$(readlink "$LFS"/dev/shm)" | tee -a "$BUILD_LOGFILE"
fi
