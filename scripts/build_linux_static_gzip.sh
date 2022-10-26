#!/bin/bash
# This script builds a statically-linked gzip.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh gzip "$1"
strip "${ROOTFS}/bin/gzip"