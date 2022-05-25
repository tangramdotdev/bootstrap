#!/bin/bash
set -euxo pipefail

# Install dependencies
if [ ! -x "$(command -v wget)" ]; then
	brew install wget
fi

# Obtain DMG.
# TODO host this somewhere else so we don't need developer.apple.com auth
COOKIES_FILE="apple.com_cookies.txt"
PKG="Command_Line_Tools_for_Xcode_13.4"
DMG="$PKG.dmg"
URL="https://download.developer.apple.com/Developer_Tools/$PKG/$DMG"
if [ ! -f "$DMG" ]; then
	wget --load-cookies="$COOKIES_FILE" "$URL"
fi

# Prepare output locations.
TMPDIR="$PWD/tmp"
OUTDIR="$PWD/sdk"
if [ ! -d "$TMPDIR" ]; then
	mkdir -p "$TMPDIR"
else
	rm -rf "$TMPDIR"/*
fi
if [ ! -d "$OUTDIR" ]; then
	mkdir -p "$OUTDIR"
else
	rm -rf "$OUTDIR"/*
fi

# Extract dmg.
7z x -o"$TMPDIR" "$DMG"

# Unpack inner package.
pushd "$TMPDIR"/"Command Line Developer Tools"
pkgutil --expand-full "Command Line Tools.pkg" "$TMPDIR"/unpacked

# Copy contents to final location.
pushd ..
cp -r -H -n "unpacked/CLTools_macOSNMOS_SDK.pkg/Payload/Library" "$OUTDIR"
cp -r -H -n "unpacked/CLTools_macOS_SDK.pkg/Payload/Library" "$OUTDIR"
cp -r -H -n "unpacked/CLTools_Executables.pkg/Payload/Library" "$OUTDIR"
popd
popd

# Package SDK
tar -C "$OUTDIR"/Library/Developer/CommandLineTools -cJpof toolchain-arm64-macos.tar.xz .

# Cleanup.
rm -rf "$TMPDIR"