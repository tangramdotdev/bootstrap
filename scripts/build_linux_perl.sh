#!/bin/bash
# This script builds a macos executable for the passed target.
set -euo pipefail
name="perl"
version="$1"
pkg="${name}-${version}"
shift
wrapInterpreterShell() {
	mv "$1" ."$1"
	cat > "$1" << EOW
#!/bin/bash
DIR="\$(cd -- "\$(dirname -- "\${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ARCH="\$(uname -m)"
ACLOCAL_AUTOMAKE_DIR="\${DIR}/../share/aclocal-1.16"
ACLOCAL_PATH="\${DIR}/../share/aclocal"
PERL5LIB="\${DIR}/../lib/perl5/$version:\${DIR}/../share/aclocal-1.16:\${DIR}/../share/autoconf:\${DIR}/../share/automake-1.16"
export ACLOCAL_AUTOMAKE_DIR
export ACLOCAL_PATH
export PERL5LIB
"\${DIR}/../lib/ld-musl-\${ARCH}.so.1" --library-path "\${DIR}/../lib" "\${DIR}/.${1}" "\$@"
EOW
	chmod +x "$1"
}
wrapInterpreter() {	
# FIXME -how should PERL5LIB work?  Relative paths but colon-separated.
	"$SCRIPTS"/create_wrapper \
		--flavor "ld_musl" \
		--executable "$1" \
		--env "ACLOCAL_AUTOMAKE_DIR=../share/aclocal-1.16" \
		--env "ACLOCAL_PATH=../share/aclocal" \
		--env "PERL5LIB=../lib/perl5/${version}"
}
source /envfile
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
wrapInterpreter ./perl
wrapInterpreter "perl${version}"
perlscripts=(cpan enc2xs encguess h2ph h2xs json_pp libnetcfg perlbug perldoc perlivp perlthanks piconv pl2pm pod2html pod2man pod2text pod2usage podchecker prove ptar ptardiff ptargrep shasum splain zipdetails)
for script in "${perlscripts[@]}"; do
	"$SCRIPTS"/wrap_perl_script.sh "./${script}"
done