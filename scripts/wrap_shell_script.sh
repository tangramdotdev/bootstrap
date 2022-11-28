#!/bin/bash
# This script wraps a shell script to point to a `perl` in the same directory.
## TODO - more general wrapper program?
dirname=${1%/*}
filename=${1##*/}
cd "$dirname" || exit
mv "$filename" ".$filename"
cat > "$filename" << EOW
#!/bin/sh
DIR=\$(cd -- "\${0%/*}" && pwd)
"\${DIR}/perl" ".$filename" -- "\$@"
EOW
chmod +x "$filename"