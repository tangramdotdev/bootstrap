#!/bin/bash
set -euo pipefail
log "Building tcl (3.2 SBU | 88 MB)..."

BUILD_LOGFILE=$LOGDIR/8.15-tcl.log
VERSION=8.6.12

pushd /sources
tar xf tcl"$VERSION"-src.tar.gz
pushd tcl"$VERSION"
tar -xf ../tcl"$VERSION"-html.tar.gz --strip-components=1 | tee -a "$BUILD_LOGFILE"
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr \
    --mandir=/usr/share/man \
    "$([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)" | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|" \
    -i tclConfig.sh | tee -a "$BUILD_LOGFILE"

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.3|/usr/lib/tdbc1.1.3|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.3/generic|/usr/include|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.3/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.3|/usr/include|" \
    -i pkgs/tdbc1.1.3/tdbcConfig.sh | tee -a "$BUILD_LOGFILE"

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.2|/usr/lib/itcl4.2.2|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.2/generic|/usr/include|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.2|/usr/include|" \
    -i pkgs/itcl4.2.2/itclConfig.sh | tee -a "$BUILD_LOGFILE"

unset SRCDIR
#make test | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
chmod -v u+w /usr/lib/libtcl8.6.so | tee -a "$BUILD_LOGFILE"
make install-private-headers | tee -a "$BUILD_LOGFILE"
ln -sfv tclsh8.6 /usr/bin/tclsh | tee -a "$BUILD_LOGFILE"
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3 | tee -a "$BUILD_LOGFILE"
mkdir -v -p /usr/share/doc/tcl-"$VERSION" | tee -a "$BUILD_LOGFILE"
cp -v -r ../html/* /usr/share/doc/tcl-"$VERSION" | tee -a "$BUILD_LOGFILE"
popd
rm -rf tcl"$VERSION"
popd
