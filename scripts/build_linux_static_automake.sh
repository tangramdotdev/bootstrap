#!/bin/bash
# This script builds a wrapped automake distribution.
set -euo pipefail
source /envfile
"$SCRIPTS"/run_linux_static_autotools_build.sh automake "$1"
# NOTE - aclocal-1.16 and automake-1.16 are hardlinks to the non-versioned files, so relink here.
wrapAclocalScript() {
	dirname=${1%/*}
	filename=${1##*/}
	cd "$dirname" || exit
	mv "$filename" ".$filename"
	cat > "$filename" << EOW
#!/bin/bash
DIR="\$(cd -- "\$(dirname -- "\${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ACLOCAL_AUTOMAKE_DIR="\${DIR}/../share/aclocal-1.16"
ACLOCAL_PATH="\${DIR}/../share/aclocal"
autom4te_perllibdir="\${DIR}/../share/autoconf"
AC_MACRODIR="\${DIR}/../share/autoconf"
M4="\${DIR}/m4"
export autom4te_perllibdir
export AC_MACRODIR
export M4
export ACLOCAL_AUTOMAKE_DIR
export ACLOCAL_PATH
"\${DIR}/perl" "\${DIR}/.$filename" --system-acdir="\$ACLOCAL_PATH" "\$@"
EOW
chmod +x "$filename"
}
wrapAclocal() {
	create_wrapper \
		--flavor "script" \
		--executable "$1" \
		--env "ACLOCAL_AUTOMAKE_DIR=../share/aclocal-1.16" \
		--env "ACLOCAL_PATH=../share/aclocal" \
		--env "AC_MACRODIR=../share/autoconf" \
		--env "autom4te_perllibdir=../share/autoconf" \
		--env "M4=./m4" \
		--flag "--system-acdir=$ACLOCAL_PATH"
}
wrapAclocal "${ROOTFS}/bin/aclocal"
wrapAclocal "${ROOTFS}/bin/aclocal-1.16"
# rm "${ROOTFS}/bin/aclocal-1.16"
# ln "${ROOTFS}/bin/aclocal" "${ROOTFS}/bin/aclocal-1.16"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/automake"
"$SCRIPTS"/wrap_perl_script.sh "${ROOTFS}/bin/automake-1.16"
# rm "${ROOTFS}/bin/automake-1.16"
# ln "${ROOTFS}/bin/automake" "${ROOTFS}/bin/automake-1.16"
