#!/bin/bash
# This script builds a statically-linked python distribution.
set -euo pipefail
source /envfile
export CFLAGS="-static"
export CPPFLAGS="-static"
export LDFLAGS="-static"
export LINKFORVOLMOUNT=" "
# FIXME - make this compile without errors!
"$SCRIPTS"/run_linux_static_autotools_build.sh Python "$1" \
	--disable-shared \
	--enable-optimizations \
	CFLAGS="-static" \
	CPPFLAGS="-static" \
	LDFLAGS="-static" \
	LINKFORVOLMOUNT=" " || true
strip "${ROOTFS}/bin/python3"
"$SCRIPTS"/wrap_python_script.sh "$ROOTFS"/bin/2to3
"$SCRIPTS"/wrap_python_script.sh "$ROOTFS"/bin/2to3-3.11
"$SCRIPTS"/wrap_python_script.sh "$ROOTFS"/bin/idle3
"$SCRIPTS"/wrap_python_script.sh "$ROOTFS"/bin/idle3.11
"$SCRIPTS"/wrap_python_script.sh "$ROOTFS"/bin/pydoc3
"$SCRIPTS"/wrap_python_script.sh "$ROOTFS"/bin/pydoc3.11
"$SCRIPTS"/wrap_bash_script.sh "$ROOTFS"/bin/python-config
"$SCRIPTS"/wrap_bash_script.sh "$ROOTFS"/bin/python-config3.11