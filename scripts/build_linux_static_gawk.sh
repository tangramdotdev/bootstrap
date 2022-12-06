#!/bin/bash
# This script builds a statically-linked gawk executable.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh gawk "$1"
strip "${ROOTFS}/bin/gawk"
"$SCRIPTS"/wrap_bash_script.sh "${ROOTFS}/bin/gawkbug"