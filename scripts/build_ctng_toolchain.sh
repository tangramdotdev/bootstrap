#!/bin/bash
ARCH=$(uname -m)
cd "$HOME"/work || exit
cp /bootstrap/configs/ct-ng-config-"$ARCH" .
ct-ng build
cp -r "$HOME"/x-tools/"$ARCH"-unknwon-linux-gnu /bootstrap/work/"$ARCH"/glibc_toolchain || true