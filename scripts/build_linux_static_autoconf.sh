#!/bin/bash
# This script builds a wrapped autoconf distribution.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh autoconf "$1"
# NOTE - also installs autoconf and autoreconf, which are shebangs to /bin/sh.
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autoheader"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autom4te"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autoscan"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autoupdate"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/ifnames"
