#!/bin/bash
# This script builds a statically-linked diffutils suite.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh diffutils "$1"
for FILE in cmp diff diff3 sdiff; do strip "${ROOTFS}/bin/${FILE}"; done