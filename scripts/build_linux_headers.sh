#!/bin/bash
# This script bundles the Linux API headers.
set -euo pipefail
source /envfile
if [ "$(uname -m)" = "aarch64" ]; then
	arch="arm64"
else
	arch="x86_64"
fi
dest="${TOP}/linux_headers"
cd "${TOP}/linux-${1}" || exit
make ARCH="$arch" headers
find usr/include -type f ! -name '*.h' -delete
cp -r usr/include "$dest"
mkdir -p "$dest"/config
echo "$1"-default >"$dest"/config/kernel.release