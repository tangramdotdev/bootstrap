#!/bin/bash
# This script builds a macos executable for the passed target.
set -euo pipefail
wrapInterpreter() {
	mv "$1" ."$1"
	cat > "$1" << EOW
	#!/bin/sh
	DIR=\$(cd -- "\${0%/*}" && pwd)
	ARCH=$(uname -m)
	"\${DIR}/../lib/ld-musl-\${ARCH}.so.1" --library-path "\${DIR}/lib" "\${DIR}/.${1}" -- "\$@"
EOW
	chmod +x "$1"
}
source /envfile
name="perl"
version="$1"
pkg="${name}-${version}"
shift
TMP=$(mktemp -d)
cd "$TMP" || exit
sh "$WORK"/"$pkg"/Configure \
	-des \
	-Dmksymlinks \
	-Dusethreads \
	-Duserelocatableinc \
	-Doptimize="-O3 -pipe -fstack-protector -fwrapv -fno-strict-aliasing" \
	-Dprefix="$ROOTFS"
make -j"$(nproc)"
make install
cd -
rm -rf "$TMP"
# install shell wrapper for interpreter to use local musl
cd "$ROOTFS"/bin
wrapInterpreter perl
wrapInterpreter "perl${version}"
perlscripts=(cpan enc2xs encguess h2ph h2xs json_pp libnetcfg perlbug perldoc perlivp perlthanks piconv pl2pm pod2html pod2man pod2text pod2usage podchecker prove ptar ptardiff ptargrep shasum splain zipdetails)
for script in "${perlscripts[@]}"; do
	"$SCRIPTS"/wrap_perl_script.sh "./${script}"
done