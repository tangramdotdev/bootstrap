#!/bin/bash
set -euo pipefail
export LOGDIR=/logs
export LOGFILE=$LOGDIR/build-lfs.log
function log {
  echo "[$(date)] $1" | tee -a $LOGFILE
}
export -f log
log "Continuing in chroot with tools..."

sh /tools/7.5-create-directories.sh
sh /tools/7.6-create-essential-files.sh
sh /tools/7.7-gettext.sh
sh /tools/7.8-bison.sh
sh /tools/7.9-perl.sh
sh /tools/7.10-python3.sh
sh /tools/7.11-texinfo.sh
sh /tools/7.12-util-linux.sh
sh /tools/7.13-cleanup.sh
# NOTE - lfs-11.1-completed-chroot tarball is created here.
sh /tools/8.3-man-pages.sh
sh /tools/8.4-iana-etc.sh
sh /tools/8.5-glibc.sh
sh /tools/8.6-zlib.sh
sh /tools/8.7-bzip2.sh
sh /tools/8.8-xz.sh
sh /tools/8.9-zstd.sh
sh /tools/8.10-file.sh
sh /tools/8.11-readline.sh
sh /tools/8.12-m4.sh
sh /tools/8.13-bc.sh
sh /tools/8.14-flex.sh
#sh /tools/8.15-tcl.sh
#sh /tools/8.16-expect.sh
#sh /tools/8.17-dejagnu.sh
sh /tools/8.18-binutils.sh
sh /tools/8.19-gmp.sh
sh /tools/8.20-mpfr.sh
sh /tools/8.21-mpc.sh
sh /tools/8.22-attr.sh
sh /tools/8.23-acl.sh
sh /tools/8.24-libcap.sh
sh /tools/8.25-shadow.sh
sh /tools/8.26-gcc.sh
sh /tools/8.27-pkg-config.sh
sh /tools/8.28-ncurses.sh
sh /tools/8.29-sed.sh
sh /tools/8.30-psmisc.sh
sh /tools/8.31-gettext.sh
sh /tools/8.32-bison.sh
sh /tools/8.33-grep.sh
sh /tools/8.34-bash.sh
sh /tools/8.35-libtool.sh
sh /tools/8.36-gdbm.sh
sh /tools/8.37-gperf.sh
sh /tools/8.38-expat.sh
sh /tools/8.40-less.sh
sh /tools/8.41-perl.sh
sh /tools/8.42-xml_parser.sh
sh /tools/8.44-autoconf.sh
sh /tools/8.45-automake.sh
sh /tools/8.46-openssl.sh
sh /tools/8.48-libelf.sh
sh /tools/8.49-libffi.sh
sh /tools/8.50-python.sh
sh /tools/8.51-wheel.sh
sh /tools/8.54-coreutils.sh
sh /tools/8.55-check.sh
sh /tools/8.56-diffutils.sh
sh /tools/8.57-gawk.sh
sh /tools/8.58-findutils.sh
sh /tools/8.59-groff.sh
sh /tools/8.61.gzip.sh
sh /tools/8.64-libpipiepline.sh
sh /tools/8.65-make.sh
sh /tools/8.66-patch.sh
sh /tools/8.67-tar.sh
sh /tools/8.68-texinfo.sh
sh /tools/8.73-util-linux.sh
sh /tools/patchelf.sh
sh /tools/curl.sh
# Cleanup
sh /tools/8.77-strip.sh
sh /tools/8.78-cleanup.sh
# Final configuration
sh /tools/9.5-network-config.sh
