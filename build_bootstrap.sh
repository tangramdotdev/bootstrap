#!/bin/bash
# This is the top-level driver script for producing all platform bootstrap bundles.

DATE=$(date +"%Y%m%d")

# macos
sh ./build_macos_bootstrap.sh

# aarch64-linux
docker run --rm --platform linux/arm64/v8 --name "aarch64-bootstrap" -v "$PWD":/bootstrap ubuntu /bin/bash /bootstrap/build_busybox_rootfs_aarch64.sh
tar -C aarch64/rootfs -cJf bootstrap_linux_aarch64_"$DATE".tar.xz .

# x86_64-linux
docker run --rm --platform linux/amd64 --name "x86_64-bootstrap" -v "$PWD":/bootstrap ubuntu /bin/bash /bootstrap/build_busybox_rootfs_x86_64.sh
tar -C x86_64/rootfs -cJf bootstrap_linux_x86_64_"$DATE".tar.xz .
