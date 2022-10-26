#!/bin/bash
# This script builds a statically-linked make executable.
set -x
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh make "$1"
strip "${ROOTFS}/bin/make"