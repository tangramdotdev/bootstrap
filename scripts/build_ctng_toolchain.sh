#!/bin/bash
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
	ARCH_PRETTY="arm64"
else
	ARCH_PRETTY="amd64"
fi
cd "$HOME"/work || exit
cp /bootstrap/configs/ct-ng-config-"$ARCH" .
ct-ng build
cp -r "$HOME"/x-tools/"$ARCH"-unknwon-linux-gnu /bootstrap/work/"$ARCH_PRETTY"/glibc_toolchain || true