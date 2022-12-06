#!/bin/bash
# This script builds a wrapped autoconf distribution.
set -euo pipefail
wrapAutom4teScript() {
	dirname=${1%/*}
	filename=${1##*/}
	cd "$dirname" || exit
	mv "$filename" ".$filename"
	cat > "$filename" << EOW
#!/bin/bash
DIR="\$(cd -- "\$(dirname -- "\${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
autom4te_perllibdir="\${DIR}/../share/autoconf"
AC_MACRODIR="\${DIR}/../share/autoconf"
M4="\${DIR}/m4"
export autom4te_perllibdir
export AC_MACRODIR
export M4
"\${DIR}/perl" "\${DIR}/.$filename" "\$@"
EOW
chmod +x "$filename"
}
wrapAutom4te() {
	create_wrapper \
		--flavor "script" \
		--executable "$1" \
		--env "autom4te_perllibdir=../share/autoconf" \
		--env "AC_MACRODIR=../share/autoconf" \
		--env "M4=./m4"
}
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh autoconf "$1"
# NOTE - also installs autoconf and autoreconf, which are shebangs to /bin/sh.
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autoheader"
wrapAutom4te "${ROOTFS}/bin/autom4te"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autoscan"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/autoupdate"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/ifnames"
