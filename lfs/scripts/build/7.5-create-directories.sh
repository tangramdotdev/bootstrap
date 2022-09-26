#!/bin/bash
set -euo pipefail
log "Creating FHS directories..."

BUILD_LOGFILE=$LOGDIR/7.5-create-directories.log

mkdir -pv /{boot,home,mnt,opt,srv} | tee -a "$BUILD_LOGFILE"
mkdir -pv /etc/{opt,sysconfig} | tee -a "$BUILD_LOGFILE"
mkdir -pv /lib/firmware | tee -a "$BUILD_LOGFILE"
mkdir -pv /media/{floppy,cdrom} | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/{,local/}{include,src} | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/local/{bin,lib,sbin} | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man} | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo} | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/{,local/}share/man/man{1..8} | tee -a "$BUILD_LOGFILE"
mkdir -pv /var/{cache,local,log,mail,opt,spool} | tee -a "$BUILD_LOGFILE"
mkdir -pv /var/lib/{color,misc,locate} | tee -a "$BUILD_LOGFILE"

ln -sfv /run /var/run | tee -a "$BUILD_LOGFILE"
ln -sfv /run/lock /var/lock | tee -a "$BUILD_LOGFILE"

# Above all created with permissions 0755

# Restrict /root access
install -dv -m 0750 /root | tee -a "$BUILD_LOGFILE"
# Make tmpdirs read/write for all but sticky - cannot remove another user's files.
install -dv -m 1777 /tmp /var/tmp | tee -a "$BUILD_LOGFILE"
