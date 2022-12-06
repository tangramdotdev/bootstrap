#!/bin/bash
# This script builds a wrapped automake distribution.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh automake "$1"
# NOTE - aclocal-1.16 and automake-1.16 are hardlinks to the non-versioned files, so relink here.
wrapAclocal() {
	create_wrapper \
		--flavor "script" \
		--interpreter "./perl" \
		--executable "$1" \
		--env "ACLOCAL_AUTOMAKE_DIR=../share/aclocal-1.16" \
		--env "ACLOCAL_PATH=../share/aclocal" \
		--env "AC_MACRODIR=../share/autoconf" \
		--env "autom4te_perllibdir=../share/autoconf" \
		--env "M4=./m4" \
# Try to do this without embedding flags - env vars should suffice!
		# --flag "'--system-acdir=../share/aclocal'"
}
wrapAclocal "${ROOTFS}/bin/aclocal"
wrapAclocal "${ROOTFS}/bin/aclocal-1.16"
# rm "${ROOTFS}/bin/aclocal-1.16"
# ln "${ROOTFS}/bin/aclocal" "${ROOTFS}/bin/aclocal-1.16"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/automake"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/automake-1.16"
# rm "${ROOTFS}/bin/automake-1.16"
# ln "${ROOTFS}/bin/automake" "${ROOTFS}/bin/automake-1.16"
