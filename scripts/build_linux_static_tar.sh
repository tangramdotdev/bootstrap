#!/bin/bash
# This script builds a statically-linked sed executable.
set -euo pipefail
source /envfile
export FORCE_UNSAFE_CONFIGURE=1
"$SCRIPTS"/run_linux_static_autotools_build.sh tar "$1"
strip "${ROOTFS}/bin/tar"