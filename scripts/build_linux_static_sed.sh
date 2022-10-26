#!/bin/bash
# This script builds a statically-linked sed executable.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh sed "$1"
strip "${ROOTFS}/bin/sed"