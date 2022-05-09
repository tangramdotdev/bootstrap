#!/bin/sh
# per ch 4.4
# Turn off the bash hash function - newly compiled tools are picked up immediately as they're built.
set +h
# Set user file-creation mask - new files are writable by owner, but read/exec by anyone.
umask 022
# Below this is actually redundant, handled in the Dockerfile, but doesn't hurt to enforce
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH="$LFS"/tools/bin:$PATH
# Helps prevent potential contamination from host in configure scripts
CONFIG_SITE="$LFS"/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
