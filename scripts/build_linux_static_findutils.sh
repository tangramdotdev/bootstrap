#!/bin/bash
# This script builds a statically-linked findutils suite.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh findutils "$1"
for FILE in find locate xargs; do strip "${ROOTFS}/bin/${FILE}"; done
"$SCRIPTS"/wrap_bash_script.sh "${ROOTFS}/bin/updatedb"