#!/bin/sh
set -eux
#PREFIX=/
#CFLAGS="-Wl,-dynamic-linker=/usr/lib/ld-linux-x86-64.so.2 -Wl,-rpath,$SYSROOT/usr/lib"

# Ensure C file exists
hello=hello.c
if [ ! -f $hello ]; then
  cat <<EOF >$hello
#include <stdio.h>

int main(void)
{
	char* hello = "Hello, world!";
	printf("%s\n", hello);
	return 0;
}
EOF
fi
# Build program
exe=hello
rm -f $exe
gcc -o $exe $hello
