#!/bin/bash
# This script builds a statically-linked flex executable.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh flex "$1" --disable-shared --enable-static
for FILE in flex flex++; do strip "${ROOTFS}/bin/${FILE}"; done