#!/bin/bash
# This script builds a statically-linked grep executable.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh grep "$1"
strip "${ROOTFS}/bin/grep"