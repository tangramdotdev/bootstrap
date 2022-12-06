#!/bin/bash
# This script builds a statically-linked xz.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh xz "$1" \
	--disable-debug \
	--disable-dependency-tracking \
	--disable-silent-rules \
	--disable-shared \
	--disable-nls
for FILE in lzma lzmadec lzmainfo unlzma unxz xz xzcat xzdec; do
	strip "${ROOTFS}/bin/${FILE}"
done
for FILE in lzfgrep lzgrep lzless lzmore xzcmp xzdiff xzegrep xzfgrep xzgrep xzless xzmore; do
	"$SCRIPTS"/wrap_bash_script.sh "${ROOTFS}/bin/${FILE}"
done