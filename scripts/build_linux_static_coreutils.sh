#!/bin/bash
# This script builds a statically-linked coreutils suite.
set -euo pipefail
source /envfile
export FORCE_UNSAFE_CONFIGURE=1
"$SCRIPTS"/run_linux_static_autotools_build.sh coreutils "$1" CFLAGS="-static -Os -ffunction-sections -fdata-sections" LDFLAGS="-Wl,--gc-sections" 
for FILE in \[ base32 base64 b2sum basename basenc cat chcon chgrp chmod chown chroot cksum comm cp csplit cut date dd df dir dircolors dirname du echo env expand expr factor false fmt fold groups head hostid id install join link ln logname ls md5sum mkdir mkfifo mknod mktemp mv nice nl nohup nproc numfmt od paste pathchk pinky pr printenv printf ptx pwd readlink realpath rm rmdir runcon seq sha1sum sha224sum sha256sum sha384sum sha512sum shred shuf sleep sort split stat stty sum sync tac tail tee test timeout touch tr true truncate tsort tty uname unexpand uniq unlink users vdir wc who whoami yes; do
	strip "${ROOTFS}/bin/${FILE}"
done