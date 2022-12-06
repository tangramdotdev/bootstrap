#!/bin/bash
# This script builds a statically-linked bison.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh bison "$1"
strip "${ROOTFS}/bin/bison"
"$SCRIPTS"/wrap_bash_script.sh "${ROOTFS}/bin/yacc"