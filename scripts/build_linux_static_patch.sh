#!/bin/bash
# This script builds a statically-linked patch executable.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh patch "$1"
strip "${ROOTFS}/bin/patch"