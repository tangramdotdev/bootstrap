#!/usr/bin/env sh

# This script uses the dockerfile provided by the crosstools-ng project for execution on Alpine to create a Tangram-ready rootfs.
img_name="alpine-crosstools"

docker build -t $img_name - <"$PWD"/$img_name-dockerfile
docker export "$(docker create $img_name)" --output="$img_name".tar
