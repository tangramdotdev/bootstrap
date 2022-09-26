#!/usr/bin/env bash

# Run the whole thing and copy the result out to $PWD/lfs.  Logs are available at $PWD/logs.
DIR=$(cd -- "${0%/*}" && pwd)
OCI=docker
LFS_VER="11.2"

set -euxo pipefail

buildLfs() {
  lfs_arch="lfs_$1"
  dest="$DIR"/"$1"
  if [ "$($OCI ps -a | grep -c "$lfs_arch")" -gt 0 ]; then
    $OCI rm lfs
  fi
  mkdir -p "$DIR"/logs
  if [ ! -d "$DIR"/"$lfs_arch" ]; then
    mkdir -p "$DIR"/"$lfs_arch"
  fi
  $OCI build --platform linux/"$1" -t "$lfs_arch":"$LFS_VER" "$DIR"
  $OCI run --privileged --name "$lfs_arch" "$lfs_arch":"$LFS_VER"
  rm -rf ./"$lfs_arch"/*
  $OCI cp "$lfs_arch":/mnt/lfs .
  mv "$lfs_arch" "$dest"

  # Perform further cleanup
  rm -rfv "$dest"/usr/share/{doc,man,info}
  rm -rfv "$dest"/usr/share/i18n/locales/*
  find "$dest"/usr/share/locale ! \( -name "en_US" -o -name "en_US.utf8" \) -type d -exec rm -rf {} +
  find "$dest" -depth -name \*.dbg -exec rm -f {} +
  rm -rfv "$dest"/{lfs,logs,sources,tools}
}

{
  buildLfs arm64 >"$DIR/arm64.log" 2>&1
} &
{
  buildLfs amd64 >"$DIR/amd64.log" 2>&1
} &
