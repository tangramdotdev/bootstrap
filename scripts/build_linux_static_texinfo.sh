#!/bin/bash
# This script builds a statically-linked, perl-wrapped texinfo suite.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh texinfo "$1"
strip "${ROOTFS}/bin/install-info"
for FILE in makeinfo pod2texi texi2any;  do
	"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/${FILE}"
done
# pdftexi2dvi texi2dvi texi2pdf texindex are shell scripts