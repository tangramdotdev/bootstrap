#!/bin/bash
# This script creates a musl-based bootstrap toolchain.
set -euxo pipefail
### SETUP

apt-get update
apt-get upgrade -y
apt-get install -y build-essential libncurses5-dev gawk m4 wget

NPROC=$(nproc)
ARCH=$(uname -m)

# move into the shared dir.
cd /bootstrap

TOP="/bootstrap/$ARCH"
SOURCES="/bootstrap/sources"
BUILDS="$TOP/builds"
ROOTFS="$TOP/rootfs"
prepareDir() {
    mkdir -p "$SOURCES" # this should already be mounted in
    rm -rf "$BUILDS" && mkdir -p "$BUILDS"
    rm -rf "$ROOTFS" && mkdir -p "$ROOTFS"/{bin,include,share,tmp,usr/bin,usr/lib}
}

# download a tarball
fetchSource() {
    if [ ! -f "$SOURCES"/"$2" ]; then
	cd "$SOURCES"
	wget "$1"
	cd -
    fi
}

unpackSource() {
    sourcePath="$SOURCES"/"$1"
    cd "$BUILDS"
    tar xf "$sourcePath"
    cd -
}

# grab musl toolchain
MUSL="$ARCH"-linux-musl-native
MUSL_PKG="$MUSL".tgz
MUSL_URL=https://musl.cc/"$MUSL_PKG"
prepareToolchain() {
    fetchSource "$MUSL_URL" "$MUSL_PKG"
    cd "$ROOTFS"
    tar xf "$SOURCES"/"$MUSL_PKG"
    mv "$MUSL" toolchain
    cd -
}

MAKE_VER="make-4.3"
MAKE_PKG="$MAKE_VER.tar.gz"
MAKE_URL="https://ftp.gnu.org/gnu/make/$MAKE_PKG"
prepareMake() {
    fetchSource "$MAKE_URL" "$MAKE_PKG"
    unpackSource "$MAKE_PKG"
    cd "$BUILDS"/"$MAKE_VER"
    ./configure \
	CC="$ROOTFS/toolchain/usr/bin/gcc" \
	LDFLAGS="-static" \
	--prefix="$ROOTFS"
    ./build.sh
    ./make install
    cd -
}

# toybox
TOYBOX="toybox-$ARCH"
TOYBOX_URL="http://landley.net/toybox/bin/$TOYBOX"
prepareToybox() {
    cd "$ROOTFS"/bin
    wget $TOYBOX_URL
    mv "$TOYBOX" toybox
    chmod +x toybox
    cd -
    cd "$ROOTFS"/bin
    for i in $(./toybox); do ln -s toybox "$i"; done
    cd -
}

# coreutils
COREUTILS_VER="coreutils-9.1"
COREUTILS_PKG="$COREUTILS_VER.tar.xz"
COREUTILS_URL="https://ftp.gnu.org/gnu/coreutils/$COREUTILS_PKG"
prepareCoreutils() {
    fetchSource "$COREUTILS_URL" "$COREUTILS_PKG"
    unpackSource "$COREUTILS_PKG"
    cd "$BUILDS"/"$COREUTILS_VER"
    export CC="$ROOTFS"/toolchain/usr/bin/gcc
    export CFLAGS="-static -Os -ffunction-sections -fdata-sections"
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
        CFLAGS="$CFLAGS" \
        LDFLAGS="-Wl,--gc-sections" \
        --prefix="$ROOTFS"
    make -j"$NPROC"
    make install
    unset CC
    unset CFLAGS
    cd -
}

# gawk
GAWK_VER="gawk-5.1.1"
GAWK_PKG="$GAWK_VER.tar.xz"
GAWK_URL="https://ftp.gnu.org/gnu/gawk/$GAWK_PKG"
prepareGawk() {
    fetchSource "$GAWK_URL" "$GAWK_PKG"
    unpackSource "$GAWK_PKG"
    cd "$BUILDS"/"$GAWK_VER"
    export CC="$ROOTFS"/toolchain/usr/bin/gcc
    ./configure LDFLAGS="-static" --prefix="$ROOTFS"
    make -j"$NPROC"
    make install
    unset CC
    cd -
}

# grep
GREP_VER="grep-3.7"
GREP_PKG="$GREP_VER.tar.xz"
GREP_URL="https://ftp.gnu.org/gnu/grep/$GREP_PKG"
prepareGrep() {
    fetchSource "$GREP_URL" "$GREP_PKG"
    unpackSource "$GREP_PKG"
    cd "$BUILDS"/"$GREP_VER"
    export CC="$ROOTFS"/toolchain/usr/bin/gcc
    ./configure LDFLAGS="-static" --prefix="$ROOTFS"
    make -j"$NPROC"
    make install
    unset CC
    cd -
}

# texinfo
TEXINFO_VER="texinfo-6.8"
TEXINFO_PKG="$TEXINFO_VER.tar.xz"
TEXINFO_URL="https://ftp.gnu.org/gnu/texinfo/$TEXINFO_PKG"
prepareTexinfo() {
    fetchSource "$TEXINFO_URL" "$TEXINFO_PKG"
    unpackSource "$TEXINFO_PKG"
    cd "$BUILDS"/"$TEXINFO_VER"
    export CC="$ROOTFS"/toolchain/usr/bin/gcc
    ./configure LDFLAGS="-static" --prefix="$ROOTFS"
    make -j"$NPROC"
    make install
    unset CC
    cd -
}

# # linux-headers
# LINUX_VER="5.18.4"
# LINUX="linux-$LINUX_VER"
# LINUX_PKG="$LINUX.tar.xz"
# LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v5.x/$LINUX_PKG"
# LINUX_HEADER_PREFIX="$ROOTFS/include/linux"
# prepareLinuxHeaders() {
#     fetchSource "$LINUX_URL" "$LINUX_PKG"
#     unpackSource "$LINUX_PKG"
# 	cd "$BUILDS"/"$LINUX"
# 	make mrproper
# 	make headers
# 	mkdir -p "$LINUX_HEADER_PREFIX"
# 	cp -r usr/include "$LINUX_HEADER_PREFIX"
# 	find "$LINUX_HEADER_PREFIX" -type f ! -name '*.h' -delete
# 	mkdir -p "$LINUX_HEADER_PREFIX"/include/config
# 	echo "$LINUX_VER"-default > "$LINUX_HEADER_PREFIX"/include/config/kernel.release
# 	cd -
# }
if [ "$ARCH" = "aarch64" ]; then
    LINUX_HEADERS="linux-headers-prebuild-aarch64-linux"
else
    LINUX_HEADERS="linux-headers-prebuild-amd64-linux"
fi
LINUX_HEADERS_PKG="$LINUX_HEADERS.tar.xz"
LINUX_HEADERS_URL="https://github.com/tangramdotdev/bootstrap/releases/download/v0.0.0/$LINUX_HEADERS_PKG"
LINUX_HEADER_PREFIX="$ROOTFS/include/linux"
prepareLinuxHeaders() {
    fetchSource "$LINUX_HEADERS_URL" "$LINUX_HEADERS_PKG"
    unpackSource "$LINUX_HEADERS_PKG"
    mkdir -p "$LINUX_HEADER_PREFIX"
    mv "$BUILDS"/include "$LINUX_HEADER_PREFIX"
}

# bison
BISON_VER="bison-3.8.2"
BISON_PKG="$BISON_VER.tar.xz"
BISON_URL="https://ftp.gnu.org/gnu/bison/$BISON_PKG"
prepareBison() {
    fetchSource "$BISON_URL" "$BISON_PKG"
    unpackSource "$BISON_PKG"
    cd "$BUILDS"/"$BISON_VER"
    ./configure --prefix="$ROOTFS"
    make -j"$NPROC"
    make install
    cd -
}

# python
PYVER="3.10.6"
PYTHON_VER="Python-$PYVER"
PYTHON_PKG="$PYTHON_VER.tar.xz"
PYTHON_URL=https://www.python.org/ftp/python/"$PYVER"/"$PYTHON_PKG"
preparePython() {
    fetchSource "$PYTHON_URL" "$PYTHON_PKG"
    unpackSource "$PYTHON_PKG"
    cd "$BUILDS"/"$PYTHON_VER"
    ./configure LDFLAGS="-static" --prefix="$ROOTFS"        \
            --disable-shared      \
            --enable-optimizations
    # TODO - actually resolve errors but for now, just ignore
    make LDFLAGS="-static" LINKFORSHARED=" " -j"$NPROC"
    make install 2>/dev/null
    cd -
}

fixSymlinks() {
    # the ld-linux symlink is absolute.  Point to libc in current dir by relative path instead.
    cd "$ROOTFS"/toolchain/lib
    interp="ld-musl-$ARCH.so.1"
    rm "$interp"
    ln -s ./libc.so "$interp"
    cd -
}

### RUN

# Set up chroot
prepareDir
prepareToolchain
prepareMake
prepareToybox
prepareCoreutils
prepareGawk
prepareGrep
prepareTexinfo
prepareLinuxHeaders
prepareBison
fixSymlinks
preparePython
