#!/bin/sh

set -eux

export PREFIX="$PWD"/bootstrap_toolchain
# should be relative to root of chroot!
lib_dir=$PREFIX/usr/lib
dynamic_linker=$PREFIX/usr/lib/ld-linux-aarch64.so.1
triple=aarch64-unknown-linux-gnu

wrap() {
  # Rename file
  local dir=$(dirname -- $1)
  local file=$(basename -- $1)
  mv "$1" "$dir"/"$file"_unwrapped
  # Create wrapper
  # TODO - should point relative to current file, not absolute path.
  cat > "$1" <<EOF
DIR=\$(cd \$(dirname \$0); pwd)
INTERPRETER=$dynamic_linker
LC_ALL=C \${INTERPRETER} --inhibit-cache --library-path "$lib_dir" \$DIR/"$file"_unwrapped
EOF
  # Make it executable
  chmod +x "$1"
}

wrap_all_elfs() {
  # This function wraps all executable binaries in the provided dir, excluding shell scripts
  find "$1" -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' | while read line; do wrap $line; done
}

wrap_all_elfs "$PREFIX"/usr/bin
wrap "$PREFIX"/usr/libexec/gcc/$triple/11.2.0/cc1
wrap "$PREFIX"/usr/libexec/gcc/$triple/11.2.0/collect2
