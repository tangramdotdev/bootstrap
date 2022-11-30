#!/bin/bash
# This script builds a statically-linked perl with a set of CPAN modules compiled in.
set -euo pipefail
source /envfile
TMP=$(mktemp -d)
cd "$TMP" || exit
"${WORK}/staticperl" install
# FIXME - determine more minimal module set and configure here to save considerable build time and bundle size.
# Install AutoMake perl module - makefile will ensure this exists
# "${WORK}/staticperl" instcpan Alien::autoconf Alien::automake
# "${WORK}/staticperl" instsrc "${ROOTFS}/share/automake-1.16/Automake"
# "${WORK}/staticperl" instsrc "${ROOTFS}/share/autoconf/Autom4te"
# FIXME - switch --strip none back to --strip ppi when done iterating.
"${WORK}/staticperl" mkperl -v \
	--strip none \
	--add "${ROOTFS}/share/automake-1.16/Automake/Config.pm Automake/Config.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/ChannelDefs.pm Automake/ChannelDefs.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Channels.pm Automake/Channels.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Condition.pm Automake/Condition.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Config.pm Automake/Config.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Configure_ac.pm Automake/Configure_ac.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/DisjConditions.pm Automake/DisjConditions.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/FileUtils.pm Automake/FileUtils.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/General.pm Automake/General.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Getopt.pm Automake/Getopt.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Item.pm Automake/Item.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/ItemDef.pm Automake/ItemDef.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Language.pm Automake/Language.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Location.pm Automake/Location.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Options.pm Automake/Options.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Rule.pm Automake/Rule.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/RuleDef.pm Automake/RuleDef.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/VarDef.pm Automake/VarDef.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Variable.pm Automake/Variable.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Version.pm Automake/Version.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/Wrap.pm Automake/Wrap.pm" \
	--add "${ROOTFS}/share/automake-1.16/Automake/XFile.pm Automake/XFile.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/C4che.pm Autom4te/C4che.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/ChannelDefs.pm Autom4te/ChannelDefs.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/Channels.pm Autom4te/Channels.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/Config.pm Autom4te/Config.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/Configure_ac.pm Autom4te/Configure_ac.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/FileUtils.pm Autom4te/FileUtils.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/General.pm Autom4te/General.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/Getopt.pm Autom4te/Getopt.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/Request.pm Autom4te/Request.pm" \
	--add "${ROOTFS}/share/autoconf/Autom4te/XFile.pm Autom4te/XFile.pm" \
	--incglob '*' --static
strip ./perl
mv ./perl "${ROOTFS}/bin/perl"