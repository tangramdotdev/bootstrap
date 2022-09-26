#!/bin/bash
set -euo pipefail
log "Preparing environment..."

# download tools
sh /tools/3.1-download-tools.sh

# build toolchain

log "Building cross toolchain..."
sh /tools/5.2-binutils-pass-1.sh
sh /tools/5.3-gcc-pass-1.sh
sh /tools/5.4-linux-api-headers.sh
sh /tools/5.5-glibc.sh
sh /tools/5.6-libstdcxx-pass-1.sh
log "Cross-compiling temporary tools..."
sh /tools/6.2-m4.sh
sh /tools/6.3-ncurses.sh
sh /tools/6.4-bash.sh
sh /tools/6.5-coreutils.sh
sh /tools/6.6-diffutils.sh
sh /tools/6.7-file.sh
sh /tools/6.8-findutils.sh
sh /tools/6.9-gawk.sh
sh /tools/6.10-grep.sh
sh /tools/6.11-gzip.sh
sh /tools/6.12-make.sh
sh /tools/6.13-patch.sh
sh /tools/6.14-sed.sh
sh /tools/6.15-tar.sh
sh /tools/6.16-xz.sh
sh /tools/6.17-binutils-pass-2.sh
sh /tools/6.18-gcc-pass-2.sh
