#!/bin/bash
# This script builds a statically-linked patchelf.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh patchelf "$1"
strip "${ROOTFS}/bin/patchelf"