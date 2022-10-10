#!/usr/bin/env bash
# Build a container from the bootstrap-minimal.tar.xz tarball
set -euo pipefail
tarball=bootstrap.tar.xz
image_dir="$PWD"/images
container=bootstrap-container.tar
# Uncomment just one of these:
tangram_container="cargo run --release"
# tangram_container="cargo run -p tangram_container --release"
# tangram_container="tangram_container"
if [ ! -d "$image_dir" ]; then
  echo 'Please create image dir with bootstrap tarball inside first'
  exit 1
fi
if [ ! -f "$image_dir"/"$tarball" ]; then
  echo 'Please create image dir with bootstrap tarball inside first'
  exit 1
fi
pushd "$image_dir"
rm -rf chroot/ bootstrap/
tar xpf "$tarball"
$tangram_container --                                 \
  --image bootstrap:latest                    \
  --author "Tangram <root@tangram.dev>"       \
  --created-at epoch                          \
  --compression fast                          \
  --entrypoint "/usr/bin/bash"                \
  --env "PATH=/bin:/usr/bin"                  \
  --env "PS1=(tangram) \u:\w # "              \
  --package "$PWD"/chroot/
rm -rf chroot/ "$container"
tar -C "$PWD"/bootstrap -cf "$container" ./
popd
