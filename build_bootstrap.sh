#!/bin/bash
# This is the top-level driver script for producing all platform bootstrap bundles.

DATE=$(date +"%Y%m%d")

# macos
#sh ./build_macos_bootstrap.sh &

# aarch64-linux
{ docker run --rm --platform linux/arm64/v8 --name "aarch64-bootstrap" -v "$PWD":/bootstrap alpine /bin/sh /bootstrap/build_busybox_rootfs.sh &>"$PWD"/aarch64_linux.log;\
  echo "Built aarch64"; \
  tar -C aarch64/rootfs -cJf bootstrap_linux_aarch64_"$DATE".tar.xz .; \
  echo "Compressed aarch64"; } &

# x86_64-linux
{ docker run --rm --platform linux/amd64 --name "x86_64-bootstrap" -v "$PWD":/bootstrap alpine /bin/sh /bootstrap/build_busybox_rootfs.sh &>"$PWD"/x86_64_linux.log; \
  echo "Built x86_64"; \
  tar -C x86_64/rootfs -cJf bootstrap_linux_x86_64_"$DATE".tar.xz .; \
  echo "Compressed x86_64"; } &
