#!/bin/sh
# This script builds a statically-linked bash executable.
# docker run --rm --platform linux/arm64/v8 --name "aarch64-static-bash" -v "$PWD":/bootstrap ubuntu /bin/bash /bootstrap/build_linux_static_bash.sh
# docker run --rm --platform linux/amd64 --name "x86-64-static-bash" -v "$PWD":/bootstrap ubuntu /bin/bash /bootstrap/build_linux_static_bash.sh
set -x

apt-get update
apt-get upgrade -y
apt-get install -y build-essential wget zstd

ARCH=$(uname -m)
NPROC=$(nproc)

SHARED="/bootstrap"
SOURCES="$SHARED/sources"
TOP="$SHARED/linux_bash/$ARCH"

rm -rf "$TOP"
mkdir -p "$TOP"
mkdir -p "$SOURCES"

# download a tarball
fetchSource() {
	if [ ! -f "$SOURCES"/"$2" ]; then
		cd "$SOURCES"
		wget "$1"
		cd -
  fi
}

# grab musl toolchain
MUSL="$ARCH"-linux-musl-native
MUSL_PKG="$MUSL".tgz
MUSL_URL=https://musl.cc/"$MUSL_PKG"
prepareToolchain() {
    fetchSource "$MUSL_URL" "$MUSL_PKG"
    cd "$TOP"
    tar -xf "$SOURCES"/"$MUSL_PKG"
    mv "$MUSL" toolchain
    cd -
}

BASH_VER="bash-5.1.16"
BASH_PKG="$BASH_VER.tar.gz"
BASH_URL="https://ftp.gnu.org/gnu/bash/$BASH_PKG"
prepareBash() {
	fetchSource "$BASH_URL" "$BASH_PKG"
	cd "$TOP"
	tar xf "$SOURCES"/"$BASH_PKG"
	cd "$TOP"/"$BASH_VER"
	export CC="$TOP/toolchain/usr/bin/gcc"
	export CFLAGS="-static -Os"
	./configure --enable-static-link --without-bash-malloc
	make -j"$NPROC"
	strip bash
	unset CC
	unset CFLAGS
	cd -
	mkdir -p "$TOP/bundle/bin"
	cp "$TOP"/"$BASH_VER"/bash "$TOP/bundle/bin"
	tar -C "$TOP/bundle" --zstd -cf bash_static_"$ARCH"_"$(date +"%Y%m%d")".tar.zstd .
}

prepareToolchain
prepareBash