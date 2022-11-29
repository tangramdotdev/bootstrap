#!/bin/bash
# This script builds a statically-linked perl with a set of CPAN modules compiled in.
set -euo pipefail
source /envfile
TMP=$(mktemp -d)
cd "$TMP" || exit
"${WORK}/staticperl" install
# FIXME - determine more minimal module set and configure here to save considerable build time and bundle size.
# Install AutoMake perl module - makefile will ensure this exists
"${WORK}/staticperl" instcpan Alien::autoconf Alien::automake
#"${WORK}/staticperl" instsrc "${ROOTFS}/share/automake-1.16/Automake"
#"${WORK}/staticperl" instsrc "${ROOTFS}/share/autoconf/Autom4te"
"${WORK}/staticperl" mkperl -v --strip ppi --incglob '*' --static
strip ./perl
mv ./perl "${ROOTFS}/bin/perl"