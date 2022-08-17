#!/bin/bash
# This script creates a musl-based bootstrap toolchain.
set -x
### SETUP

apt-get update
apt-get upgrade -y
apt-get install -y build-essential libncurses5-dev gawk wget

# move into the shared dir.
cd /bootstrap

TOP="/bootstrap/aarch64"
SOURCES="/bootstrap/sources"
BUILDS="$TOP/builds"
ROOTFS="$TOP/rootfs"
prepareDir() {
    mkdir -p "$SOURCES" # this should already be mounted in
    rm -rf "$BUILDS" && mkdir -p "$BUILDS"
    rm -rf "$ROOTFS" && mkdir -p "$ROOTFS"/{bin,sbin,include,etc/init.d,home/root,proc,share,sys,usr/lib}
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
MUSL=aarch64-linux-musl-native
MUSL_PKG="$MUSL".tgz
MUSL_URL=https://musl.cc/"$MUSL_PKG"
prepareToolchain() {
    fetchSource "$MUSL_URL" "$MUSL_PKG"
    cd "$ROOTFS"
    tar xf "$SOURCES"/"$MUSL_PKG"
    mv "$MUSL" toolchain
}

MAKE_VER="make-4.3"
MAKE_PKG="$MAKE_VER.tar.gz"
MAKE_URL="https://ftp.gnu.org/gnu/make/$MAKE_PKG"
prepareMake() {
    fetchSource "$MAKE_URL" "MAKE_PKG"
    unpackSource "$MAKE_PKG"
    cd "$BUILDS"/"$MAKE_VER"
    ./configure \
	CC="$ROOTFS/toolchain/usr/bin/gcc" \
	LDFLAGS="-static" \
	--enable-static \
	--disable-shared \
	--prefix="$ROOTFS"
    ./build.sh
    ./make install
    cd -
}

# TODO - switch to tinybox
BUSYBOX_CONFIG="/bootstrap/busybox-static-config"
BUSYBOX_VER=busybox-1.35.0
BUSYBOX_PKG="$BUSYBOX_VER.tar.bz2"
BUSYBOX_URL="https://busybox.net/downloads/$BUSYBOX_PKG"
prepareBusybox() {
    fetchSource "$BUSYBOX_URL" "$BUSYBOX_PKG"
    unpackSource "$BUSYBOX_PKG"
    cd "$BUILDS"/"$BUSYBOX_VER"
    cp "$BUSYBOX_CONFIG" ./.config
    make
    CONFIG_PREFIX="$ROOTFS" make install
    cd -
}

# linux-headers
LINUX_VER="5.18.4"
LINUX="linux-$LINUX_VER"
LINUX_PKG="$LINUX.tar.xz"
LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v5.x/$LINUX_PKG"
LINUX_HEADER_PREFIX="$ROOTFS/include/linux"
prepareLinuxHeaders() {
    fetchSource "$LINUX_URL" "$LINUX_PKG"
    unpackSource "LINUX_PKG"
	cd "BUILDS"/"$LINUX"
	make mrproper
	make headers
	mkdir -p "$LINUX_HEADER_PREFIX"
	cp -r usr/include "$LINUX_HEADER_PREFIX"
	find "$LINUX_HEADER_PREFIX" -type f ! -name '*.h' -delete
	mkdir -p "$LINUX_HEADER_PREFIX"/include/config
	echo "$LINUX_VER"-default > "$LINUX_HEADER_PREFIX"/include/config/kernel.release
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
    TOOLCHAIN="$ROOTFS"/toolchain
    ./configure CC="$TOOLCHAIN"/bin/gcc LDFLAGS="-static" --prefix="$ROOTFS"/usr        \
            --disable-shared      \
            --enable-optimizations
    # TODO - actually resolve errors but for now, just ignore
    make LDFLAGS="-static" LINKFORSAHRED=" " -j"$(nproc)"
    make install 2>/dev/null
    cd -
}

### RUN

# Set up chroot
prepareDir
prepareToolchain
prepareMake
export PATH="$ROOTFS/bin:$PATH"
prepareBusybox
export PATH="$ROOTFS/usr/bin:$PATH"
prepareLinuxHeaders
preparePython
