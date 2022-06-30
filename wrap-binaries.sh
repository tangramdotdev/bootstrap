#!/bin/sh

set -eux

if [ "$#" -ne 1 ]; then
  echo "You must provide the directory to process: ./wrap-binaries.sh ./bootstrap_toolchain"
  exit 1
fi

export PREFIX="$1"
arch=$(uname -m)

lib_dir=$PREFIX/usr/lib

if [ "$arch" = "aarch64" ]; then
  dynamic_linker=ld-linux-aarch64.so.1
elif [ "$arch" = "x86_64" ]; then
  dynamic_linker=ld-linux-x86-64.so.2
else
  echo "Unsupported architecture!"
  exit 1
fi

triple="$arch"-unknown-linux-gnu
echo $triple

wrap() {
  # Rename file
  local dir=${1%/*}
  local file=${1##*/}
  mv "$1" "$dir"/"$file"_unwrapped
  # Create wrapper
  cat > "$1" <<EOF
DIR=\$( cd -- "\${BASH_SOURCE[0]%/*}" &> /dev/null && pwd )
# TODO traverse a certain amount?
LIB_DIR="\$DIR"/../lib
INTERPRETER=\${LIB_DIR}/"$dynamic_linker"
LC_ALL=C \${INTERPRETER} --inhibit-cache --library-path \${LIB_DIR} \$DIR/"$file"_unwrapped
EOF
  # Make it executable
  chmod +x "$1"
}

wrap_all_elfs() {
  # $1 is the file to wrap
  # $2 is how many levels to traverse up to find $PREFIX/usr
  # This function wraps all executable binaries in the provided dir, excluding shell scripts
  find "$1" -type f -executable -exec sh -c "file -i '{}' | grep -q 'x-executable; charset=binary'" \; -print | while read line; do wrap $line $2; done
}

#repeat() {
#  # $1 is the string to repeat
#  # $2 is the number of times
#  for i in {1.."$2"}; do echo -n "$1"; done
#}

#repeat "../" 4

wrap_all_elfs "$PREFIX"/usr/bin 1
#wrap "$PREFIX"/usr/libexec/gcc/$triple/11.2.0/cc1 5
#wrap "$PREFIX"/usr/libexec/gcc/$triple/11.2.0/collect2 5
