#!/usr/bin/env sh

# This script is intended to run inside the container described in alpine-crosstools-dockerfile

# starts as root, switch immediately
su ctng
cd ~

# build ctng
CROSSTOOL_VER="crosstool-ng-1.25.0"
wget http://crosstool-ng.org/download/crosstool-ng/$CROSSTOOL_VER.tar.xz
tar xf $CROSSTOOL_VER.tar.xz
cd $CROSSTOOL_VER
./configure --prefix="$HOME"/ctng
make
make install
export PATH="${PATH}:${HOME}/ctng/bin"
cd -

# gather all sources
mkdir "$HOME"/sources
cd "$HOME"/sources
# NOTE - versions selected for what ct-ng expects.
# NOTE - 5.19.10 is current
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz
wget https://zlib.net/zlib-1.2.12.tar.xz
wget https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz
wget https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.xz
wget https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
# NOTE - 0.25 is current
wget https://libisl.sourceforge.io/isl-0.24.tar.xz
# NOTE - 2.4.9 is current
wget https://github.com/libexpat/libexpat/releases/download/R_2_4_1/expat-2.4.1.tar.xz
# NOTE 6.3 is current
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz
# NOTE 1.17 is current
wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz
# NOTE 2.39 is current
wget https://ftp.gnu.org/gnu/binutils/binutils-2.39.tar.xz
# NOTE 12.2.0 is current
wget https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.xz
# NOTE 2.36 is current
wget https://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.xz
# NOTE 12.1 is current
wget https://ftp.gnu.org/gnu/gdb/gdb-11.2.tar.xz
wget https://ftp.gnu.org/gnu/make/make-4.3.tar.lz
wget https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz
# NOTE 1.16.5 is current
wget https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.xz
# NOTE 2.4.7 is current
wget https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz
# NOTE 1.6.1 is current
wget https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-1.6.0.tar.gz
# NOTE 3.8.2 is current
wget https://ftp.gnu.org/gnu/bison/bison-3.5.tar.xz
cd -

# acquire premade config

# build cross-native toolchain
mkdir "$HOME"/work
cd "$HOME"/work

# first, build simple cross, build & host = musl, target = gnu
ct-ng aarch64-unknown-linux-gnu
# CP "$VOLMOUNT"/cross-config .config
ct-ng build
# then, use that to build trivial case of canadian cross, build = musl, host & target = musl
PATH=~/x-tools/aarch64-unknown-linux-gnu/bin:$PATH
cp "$VOLMOUNT"/canadian-config .config
ct-ng build
cd -

# first, build cross musl -> gnu
# then, build native using aboce toolchain.

# for some reason, $TRIPLE/debug_root/usr/share needs to be removed.  Permission issue unpacking.
tar -C "$HOME"/x-tools/HOST-aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/ -cJf aarch64_cross_native_"$(date +"%Y%m%d")".tar.xz .
