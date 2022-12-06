#!/bin/bash
# This script builds a statically-linked bash executable.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh bash "$1" CFLAGS="-Os" --enable-static-link --without-bash-malloc 
cd "$ROOTFS"/bin || exit
strip bash
"$SCRIPTS"/wrap_bash_script.sh "${ROOTFS}/bin/bashbug"
ln -s bash sh