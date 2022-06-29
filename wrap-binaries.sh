#!/bin/sh

set -eux

export PREFIX="$PWD"/bootstrap_toolchain
# should be relative to root of chroot!
lib_dir=$PREFIX/usr/lib
dynamic_linker=$PREFIX/usr/lib/ld-linux-aarch64.so.1
triple=aarch64-unknown-linux-gnu
elf_magic_bytes=$(echo '\0x7f\0x45\0x4c\0x46' | xxd -r)

is_elf() {
   [ ! -d "$1" ] && [ "$(head -c 4 "$1")" = "$elf_magic_bytes" ]
}

is_dynamic() {
  ldd "$1" >/dev/null 2>&1
}

patch() {
  "$PREFIX"/usr/bin/patchelf --set-interpreter "$dynamic_linker" --set-rpath "$lib_dir" "$1"
}

wrap() {
  # Rename file
  mv "$1" "$1_unwrapped"
  # Create wrapper
  # TODO - should point relative to current file, not absolute path.
  cat > "$1" <<EOF
DIR=\$(cd \$(dirname \$0); pwd)
INTERPRETER=$libdir/ld-linux-x86-64.so.2
LC_ALL=C \${INTERPRETER} --inhibit-cache --library-path $libdir \$DIR/"$1_unwrapped"
EOF
  # Make it executable
  chmod +x "$1"
}

wrap_all_elfs() {
  # This function searches for all dyanmically-linked elf binaries in the provided dir
  cd "$1"
  for FILE in *; do
    if is_elf "$FILE" && is_dynamic "$FILE" && [ ! "$FILE" = liblto_plugin.so ] && [ ! "$FILE" = ld.so ]; then
      wrap "$FILE"
    fi
  done
  cd -
}

wrap_all_elfs "$PREFIX"/usr/bin
wrap "$PREFIX"/usr/libexec/gcc/$triple/11.2.0/cc1
wrap "$PREFIX"/usr/libexec/gcc/$triple/11.2.0/collect2
