#!/bin/bash
# This script builds a statically-linked gzip.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh gzip "$1"
strip "${ROOTFS}/bin/gzip"
for FILE in gunzip gzexe uncompress zcat zcmp zdiff zegrep zfgrep zforce zgrep zless zmore znew; do
	"$SCRIPTS"/wrap_bash_script.sh "${ROOTFS}/bin/${FILE}"
done