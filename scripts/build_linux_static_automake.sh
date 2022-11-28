#!/bin/bash
# This script builds a wrapped automake distribution.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh automake "$1"
# NOTE - aclocal-1.16 and automake-1.16 are hardlinks to the non-versioned files, so relink here.
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/aclocal"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/aclocal-1.16"
# rm "${ROOTFS}/bin/aclocal-1.16"
# ln "${ROOTFS}/bin/aclocal" "${ROOTFS}/bin/aclocal-1.16"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/automake"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/automake-1.16"
# rm "${ROOTFS}/bin/automake-1.16"
# ln "${ROOTFS}/bin/automake" "${ROOTFS}/bin/automake-1.16"
