#!/bin/bash
set -euo pipefail

nproc=$(sysctl -n hw.ncpu)
mirror=http://ftpmirror.gnu.org

# keyring
keyring="gnu-keyring.gpg"
keyring_url="$mirror"/gnu/"$keyring"
if [ ! -f "$keyring" ]; then
	curl -OL "$keyring_url"
	gpg --import "$keyring"
fi

# Download if not exists
version=5.1.16
name=bash
pkg="$name"-"$version"
tarball="$pkg".tar.gz
sig="$tarball".sig
base_url="$mirror"/gnu/"$name"
tarball_url="$base_url"/"$tarball"
sig_url="$base_url"/"$sig"
if [ ! -f "$tarball" ]; then
	rm -f "$sig"
	curl -OL "$tarball_url"
	curl -OL "$sig_url"
	gpg --verify "$sig" "$tarball"
	rm "$sig"
fi

# Unpack
rm -rf "$pkg"
tar xf "$tarball"

# Compile
pushd "$pkg"
./configure --enable-static   
make -j"$nproc"
popd

# Package
gtar -C "$pkg" -cJf "$pkg"-arm64-macos.tar.xz "$name"

# Cleanup
# rm -rf "$pkg"