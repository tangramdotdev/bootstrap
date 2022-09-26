# This script builds the universe!
# sanity check
echo "We're in!"

#perl
PERL_VER="perl-5.36"
PERL_PKG="$PERL_VER".tar.gz
PERL_URL=https://www.cpan.org/src/5.0/"$PERL_PKG"
preparePerl() {
    fetchSource "$PERL_URL" "$PERL_PKG"
    unpackSource "$PERL_PKG"
    cd "$BUILDS"/"$PERL_PKG"
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	sh Configure -des                                         \
		     -Dprefix="$ROOTFS"/usr                                \
		     -Dvendorprefix="$ROOTFS"/usr                          \
		     -Dprivlib="$ROOTFS"/usr/lib/perl5/5.34/core_perl      \
		     -Darchlib="$ROOTFS"/usr/lib/perl5/5.34/core_perl      \
		     -Dsitelib="$ROOTFS"/usr/lib/perl5/5.34/site_perl      \
		     -Dsitearch="$ROOTFS"/usr/lib/perl5/5.34/site_perl     \
		     -Dvendorlib="$ROOTFS"/usr/lib/perl5/5.34/vendor_perl  \
		     -Dvendorarch="$ROOTFS"/usr/lib/perl5/5.34/vendor_perl \
		     -Dman1dir="$ROOTFS"/usr/share/man/man1                \
		     -Dman3dir="$ROOTFS"/usr/share/man/man3                \
		     -Dpager="$ROOTFS/usr/bin/less -isR"                 \
		     -Duseshrplib                                 \
		     -Dusethreads
	make -j"$(nproc)"
	# LONG
	#make test | tee -a "$BUILD_LOGFILE"
	make install
	unset BUILD_ZLIB BUILD_BZIP2
    cd -
}




# # glibc
# set -eux
# env -i
# DIR="$(cd -- "${0%/*}" && pwd)"
# rm -rf deps
# mkdir -p deps
# cd deps
# ln -s ../../../checkouts/gnumake_static ./gnumake_static
# ln -s ../../../checkouts/linux-headers ./linux-headers
# ln -s ../../../checkouts/toolchain ./toolchain
# cd ..
# PATH="$DIR/deps/gnumake_static/bin:$DIR/deps/toolchain/usr/bin"
# PREFIX="$DIR/../../checkouts/glibc"
# if [ ! -d "$PREFIX" ]; then
# 	mkdir -p "$PREFIX"/share
# else
# 	rm -rf "${PREFIX:?}"/*
# 	mkdir "$PREFIX"/share
# fi
# cat > "$PREFIX"/share/config.site << EOF
# BISON_PKGDATADIR="$DIR/deps/toolchain/usr/share/bison"
# CC="$DIR/deps/toolchain/usr/bin/cc"
# CFLAGS="-O2"
# CPP="$DIR/deps/toolchain/usr/bin/cpp"
# CPPFLAGS="-I$DIR/deps/linux-headers/include"
# LDFLAGS="-L$DIR/usr/lib"
# M4="m4"
# MAKE="$DIR/deps/gnumake_static/bin/make"
# SHELL="$DIR/deps/toolchain/usr/bin/bash"
# EOF
# export BISON_PKGDATADIR="$DIR/deps/toolchain/usr/share/bison"
# export CC="$DIR/deps/toolchain/usr/bin/cc"
# export CFLAGS="-O2"
# export CPP="$DIR/deps/toolchain/usr/bin/cpp"
# export CPPFLAGS="-I$DIR/deps/linux-headers/include"
# export LDFLAGS="-L$DIR/usr/lib"
# export M4="m4"
# export MAKE="$DIR/deps/gnumake_static/bin/make"
# export SHELL="$DIR/deps/toolchain/usr/bin/bash"
# # configure phase
# rm -rf build && mkdir build && cd build && ../configure --prefix="$PREFIX" --with-headers=./deps/linux-headers/include --disable-werror --enable-kernel=3.2 --enable-stack-protector=strong libc_cv_slibdir=$PREFIX/lib use_ldconfig=no
# # build phase
# make -j12
# # install phase
# make install
