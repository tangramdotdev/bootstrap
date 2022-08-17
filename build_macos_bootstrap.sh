#!/bin/bash
# This script creates the macos bootstrap
# TODO - use rsync
set -euxo pipefail
MACOS_BOOTSTRAP="macos_bootstrap"
CLI_TOOLS_PATH="/Library/Developer/CommandLineTools"
rm -rf "$MACOS_BOOTSTRAP"
cp -r "$CLI_TOOLS_PATH"/usr ./"$MACOS_BOOTSTRAP"
cp -r "CLI_TOOLS_PATH"/Library ./"$MACOS_BOOTSTRAP"
mkdir -p "MACOS_BOOTSTRAP"/SDKs
cp -r "CLI_TOOLS_PATH"/SDKS/MacOSX12.3.sdk ./"MACOS_BOOTSTRAP"/SDKs
pushd "MACOS_BOOTSTRAP"/SDKs
ln -s MacOSX12.3.sdk MacOSX12.sdk
ln -s MacOSX12.sdk MacOSX.sdk
popd
sh ./build_macos_bash
mv ./bash "$MACOS_BOOTSTRAP"/usr/bin
tar -C "$MACOS_BOOTSTRAP" -cJf macos_bootstrap_universal_"$(date +"%Y%m%d")".tar.xz .
