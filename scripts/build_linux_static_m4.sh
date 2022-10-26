#!/bin/bash
# This script builds a statically-linked m4.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh m4 "$1"
strip "${ROOTFS}/bin/m4"