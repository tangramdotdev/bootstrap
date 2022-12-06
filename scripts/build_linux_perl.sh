#!/bin/bash
# This script builds a macos executable for the passed target.
set -euo pipefail
name="perl"
version="$1"
pkg="${name}-${version}"
shift
wrapInterpreter() {	
# FIXME -how should PERL5LIB work?  Relative paths but colon-separated.
	create_wrapper \
		--flavor "ld_musl" \
		--interpreter "../lib/ld-musl-$(uname -m).so.1" \
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
perlscripts=(corelist cpan enc2xs encguess h2ph h2xs json_pp instmodsh libnetcfg perlbug perldoc perlivp perlthanks piconv pl2pm pod2html pod2man pod2text pod2usage podchecker prove ptar ptardiff ptargrep shasum splain streamzip xsubpp zipdetails)
for script in "${perlscripts[@]}"; do
	"$SCRIPTS"/wrap_perl_script.sh "./${script}"
done