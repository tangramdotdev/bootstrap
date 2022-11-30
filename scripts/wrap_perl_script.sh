#!/bin/bash
# This script wraps a perl script to point to a `perl` in the same directory.
## TODO - more general wrapper program?
dirname=${1%/*}
filename=${1##*/}
cd "$dirname" || exit
mv "$filename" ".$filename"
cat > "$filename" << EOW
#!/bin/bash
DIR="\$(cd -- "\$(dirname -- "\${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ACLOCAL_AUTOMAKE_DIR="\${DIR}/../share/aclocal-1.16"
ACLOCAL_PATH="\${DIR}/../share/aclocal"
export ACLOCAL_AUTOMAKE_DIR
export ACLOCAL_PATH
"\${DIR}/perl" "\${DIR}/.$filename" "\$@"
EOW
chmod +x "$filename"