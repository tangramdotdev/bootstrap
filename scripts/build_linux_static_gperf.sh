#!/bin/bash
# This script builds a statically-linked gperf.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh gperf "$1"
strip "${ROOTFS}/bin/gperf"