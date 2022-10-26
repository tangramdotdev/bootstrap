# Directories
DIST=$(PWD)/dist
SCRIPTS=$(PWD)/scripts
SOURCES=$(PWD)/sources
WORK=$(PWD)/work

# Constants
DATE=$(shell date +"%Y%m%d")

# Build details
OCI=docker
IMAGE_FILE=static-tools-dockerfile
IMAGE_AMD64=static-tools-amd64
IMAGE_ARM64=static-tools-arm64
VOLMOUNT=/bootstrap

# Static tools
# Some packages use a single installed binary to catalyze the build:
# cp: coreutils
# diff: diffutils
# find: findutils
# makeinfo: texinfo
STATIC_TOOLS:=bash bison cp diff find gawk gperf grep gzip make makeinfo m4 patchelf

# Package versions
BASH_VER=5.1.16
BISON_VER=3.8.2
COREUTILS_VER=9.1
DIFFUTILS_VER=3.8
FINDUTILS_VER=4.9.0
GAWK_VER=5.2.0
GPERF_VER=3.1
GREP_VER=3.8
GZIP_VER=1.12
# TODO - Linux headers belongs in its own artifact, not in static_tools
LINUX_VER=6.0.3
MAKE_VER=4.3
M4_VER=1.4.19
PATCHELF_VER=0.15.0
TEXINFO_VER=6.8
TOYBOX_VER=0.8.8

# Interface targets

.PHONY: all
all: dist

.PHONY: clean
clean: clean_dist clean_bash clean_static_tools clean_toybox

.PHONY: clean_sources
clean_sources:
	rm -rfv $(SOURCES)/*

.PHONY: deps
deps: dirs images

.PHONY: dirs
dirs:
	mkdir -p $(DIST) $(SOURCES) $(WORK)

.PHONY: dist
dist: bash_dist musl_toolchain_dist static_tools_dist toybox_dist

.PHONY: images
images: image_amd64 image_arm64

# https://stackoverflow.com/a/26339924/7163088
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Docker build environment

.PHONY: image_amd64
image_amd64:
	$(OCI) build --platform linux/amd64 -t $(IMAGE_AMD64) -f $(IMAGE_FILE) .

.PHONY: image_arm64
image_arm64:
	$(OCI) build --platform linux/arm64/v8 -t $(IMAGE_ARM64) -f $(IMAGE_FILE) .

# Static tools

# FIXME - add amd64
.PHONY: static_tools
static_tools: static_tools_arm64

.PHONY: static_tools_amd64
static_tools_amd64: $(STATIC_TOOLS:%=$(WORK)/x86_64/rootfs/bin/%)

.PHONY: static_tools_arm64
static_tools_arm64: $(STATIC_TOOLS:%=$(WORK)/aarch64/rootfs/bin/%)

.PHONY: clean_static_tools
clean_static_tools:
	rm -rfv $(WORK)/{aarch64,x86_64}

# Toybox
## TODO - add static_tools version, with installed symlinks

.PHONY: toybox
toybox: toybox_linux_amd64 toybox_linux_arm64 toybox_macos

.PHONY: toybox_linux_amd64
toybox_linux_amd64: $(WORK)/toybox_linux_aarch64

.PHONY: toybox_linux_arm64
toybox_linux_arm64: $(WORK)/toybox_linux_x86_64

.PHONY: toybox_macos
toybox_macos: $(WORK)/toybox_macos_universal

.PHONY: clean_toybox
clean_toybox:
	rm -rfv $(WORK)/toybox*

# Dist targets

.PHONY: bash_dist
bash_dist: $(DIST)/bash_linux_aarch64_$(DATE).tar.xz $(DIST)/bash_linux_x86_64_$(DATE).tar.xz $(DIST)/bash_macos_universal_$(DATE).tar.xz

.PHONY: musl_toolchain_dist
musl_toolchain_dist: $(DIST)/musl_toolchain_linux_aarch64_$(DATE).tar.xz $(DIST)/musl_toolchain_linux_x86_64_$(DATE).tar.xz

# FIXME - add amd64
.PHONY: static_tools_dist
static_tools_dist: static_tools_arm64_dist

.PHONY: static_tools_amd64_dist
static_tools_amd64_dist: $(DIST)/static_tools_linux_x86_64_$(DATE).tar.xz 

.PHONY: static_tools_arm64_dist
static_tools_arm64_dist: $(DIST)/static_tools_linux_aarch64_$(DATE).tar.xz 

.PHONY: toybox_dist
toybox_dist: $(DIST)/toybox_linux_aarch64_$(DATE).tar.xz $(DIST)/toybox_linux_x86_64_$(DATE).tar.xz $(DIST)/toybox_macos_universal_$(DATE).tar.xz

.PHONY: clean_dist
clean_dist:
	rm -rfv $(DIST)/*

# Static tools individual targets

## bash

.PHONY: bash
bash: bash_linux_amd64 bash_linux_arm64 bash_macos

.PHONY: bash_linux_amd64
bash_linux_amd64: $(WORK)/bash_linux_x86_64

.PHONY: bash_linux_arm64
bash_linux_arm64: $(WORK)/bash_linux_aarch64

.PHONY: bash_macos
bash_macos: $(WORK)/bash_macos_universal

.PHONY: clean_bash
clean_bash:
	rm -rfv $(WORK)/bash* $(WORK)/aarch64/rootfs/bin/bash $(WORK)/x86_64/rootfs/bin/bash

## bison

.PHONY: bison
bison: bison_linux_amd64 bison_linux_arm64

.PHONY: bison_linux_amd64
bison_linux_amd64: $(WORK)/x86_64/rootfs/bin/bison

.PHONY: bison_linux_arm64
bison_linux_arm64: $(WORK)/aarch64/rootfs/bin/bison

.PHONY: clean_bison
clean_bison:
	rm -rfv $(WORK)/bison* $(WORK)/aarch64/rootfs/bin/bison $(WORK)/x86_64/rootfs/bin/bison

## coreutils

.PHONY: coreutils
coreutils: coreutils_linux_amd64 coreutils_linux_arm64

.PHONY: coreutils_linux_amd64
coreutils_linux_amd64: $(WORK)/x86_64/rootfs/bin/cp

.PHONY: coreutils_linux_arm64
coreutils_linux_arm64: $(WORK)/aarch64/rootfs/bin/cp

.PHONY: clean_coreutils
clean_coreutils:
	rm -rfv $(WORK)/coreutils* $(WORK)/aarch64/rootfs/bin/cp $(WORK)/x86_64/rootfs/bin/cp

## diffutils

.PHONY: diffutils
diffutils: diffutils_linux_amd64 diffutils_linux_arm64

.PHONY: diffutils_linux_amd64
diffutils_linux_amd64: $(WORK)/x86_64/rootfs/bin/diff

.PHONY: diffutils_linux_arm64
diffutils_linux_arm64: $(WORK)/aarch64/rootfs/bin/diff

.PHONY: clean_diffutils
clean_diffutils:
	rm -rfv $(WORK)/diffutils* $(WORK)/aarch64/rootfs/bin/diff $(WORK)/x86_64/rootfs/bin/diff

## findutils

.PHONY: findutils
findutils: findutils_linux_amd64 findutils_linux_arm64

.PHONY: findutils_linux_amd64
findutils_linux_amd64: $(WORK)/x86_64/rootfs/bin/find

.PHONY: findutils_linux_arm64
findutils_linux_arm64: $(WORK)/aarch64/rootfs/bin/find

.PHONY: clean_findutils
clean_findutils:
	rm -rfv $(WORK)/findutils* $(WORK)/aarch64/rootfs/bin/find $(WORK)/x86_64/rootfs/bin/find

## gawk

.PHONY: gawk
gawk: gawk_linux_amd64 gawk_linux_arm64

.PHONY: gawk_linux_amd64
gawk_linux_amd64: $(WORK)/x86_64/rootfs/bin/gawk

.PHONY: gawk_linux_arm64
gawk_linux_arm64: $(WORK)/aarch64/rootfs/bin/gawk

.PHONY: clean_gawk
clean_gawk:
	rm -rfv $(WORK)/gawk* $(WORK)/aarch64/rootfs/bin/gawk $(WORK)/x86_64/rootfs/bin/gawk

## gperf

.PHONY: gperf
gperf: gperf_linux_amd64 gperf_linux_arm64

.PHONY: gperf_linux_amd64
gperf_linux_amd64: $(WORK)/x86_64/rootfs/bin/gperf

.PHONY: gperf_linux_arm64
gperf_linux_arm64: $(WORK)/aarch64/rootfs/bin/gperf

.PHONY: clean_gperf
clean_gperf:
	rm -rfv $(WORK)/gperf* $(WORK)/aarch64/rootfs/bin/gperf $(WORK)/x86_64/rootfs/bin/gperf

## grep

.PHONY: grep
grep: grep_linux_amd64 grep_linux_arm64

.PHONY: grep_linux_amd64
grep_linux_amd64: $(WORK)/x86_64/rootfs/bin/grep

.PHONY: grep_linux_arm64
grep_linux_arm64: $(WORK)/aarch64/rootfs/bin/grep

.PHONY: clean_grep
clean_grep:
	rm -rfv $(WORK)/grep* $(WORK)/aarch64/rootfs/bin/grep $(WORK)/x86_64/rootfs/bin/grep

## gzip

.PHONY: gzip
gzip: gzip_linux_amd64 gzip_linux_arm64

.PHONY: bzip_linux_amd64
gzip_linux_amd64: $(WORK)/x86_64/rootfs/bin/gzip

.PHONY: gzip_linux_arm64
gzip_linux_arm64: $(WORK)/aarch64/rootfs/bin/gzip

.PHONY: clean_gzip
clean_gzip:
	rm -rfv $(WORK)/gzip* $(WORK)/aarch64/rootfs/bin/gzip $(WORK)/x86_64/rootfs/bin/gzip

## make

.PHONY: make
make: make_linux_amd64 make_linux_arm64

.PHONY: make_linux_amd64
make_linux_amd64: $(WORK)/x86_64/rootfs/bin/make

.PHONY: make_linux_arm64
make_linux_arm64: $(WORK)/aarch64/rootfs/bin/make

.PHONY: clean_make
clean_make:
	rm -rfv $(WORK)/make* $(WORK)/aarch64/rootfs/bin/make $(WORK)/x86_64/rootfs/bin/make

## patchelf

.PHONY: patchelf
patchelf: patchelf_linux_amd64 patchelf_linux_arm64

.PHONY: patchelf_linux_amd64
patchelf_linux_amd64: $(WORK)/x86_64/rootfs/bin/patchelf

.PHONY: patchelf_linux_arm64
patchelf_linux_arm64: $(WORK)/aarch64/rootfs/bin/patchelf

.PHONY: clean_patchelf
clean_patchelf:
	rm -rfv $(WORK)/patchelf* $(WORK)/aarch64/rootfs/bin/patchelf $(WORK)/x86_64/rootfs/bin/patchelf

## texinfo

.PHONY: texinfo
texinfo: texinfo_linux_amd64 texinfo_linux_arm64

.PHONY: texinfo_linux_amd64
texinfo_linux_amd64: $(WORK)/x86_64/rootfs/bin/makeinfo

.PHONY: texinfo_linux_arm64
texinfo_linux_arm64: $(WORK)/aarch64/rootfs/bin/makeinfo

.PHONY: clean_texinfo
clean_texinfo:
	rm -rfv $(WORK)/texinfo* $(WORK)/aarch64/rootfs/bin/makeinfo $(WORK)/x86_64/rootfs/bin/makeinfo

# Work targets

## Bash

$(DIST)/bash_linux_%_$(DATE).tar.xz: $(WORK)/%/rootfs/bin/bash
	$(SCRIPTS)/build_binary_artifact.sh $< $@ bash

$(DIST)/bash_macos_universal_$(DATE).tar.xz: $(WORK)/bash_macos_universal
	$(SCRIPTS)/build_binary_artifact.sh $< $@ bash

$(WORK)/x86_64/rootfs/bin/bash: $(WORK)/bash-$(BASH_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_bash.sh $(BASH_VER)

$(WORK)/aarch64/rootfs/bin/bash: $(WORK)/bash-$(BASH_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_bash.sh $(BASH_VER)

$(WORK)/bash_linux_%: $(WORK)/%/rootfs/bin/bash
	cp $< $@

$(WORK)/bash_macos_universal: $(WORK)/bash_macos_arm $(WORK)/bash_macos_x86
	lipo -create -output $@ $^

$(WORK)/bash_macos_arm: $(WORK)/bash-$(BASH_VER)
	$(SCRIPTS)/build_macos_bash.sh $< $@ arm64-apple-macos12.3

$(WORK)/bash_macos_x86: $(WORK)/bash-$(BASH_VER)
	$(SCRIPTS)/build_macos_bash.sh $< $@ x86_64-apple-macos12.3

## Bison

$(WORK)/x86_64/rootfs/bin/bison: $(WORK)/bison-$(BISON_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_bison.sh $(BISON_VER)

$(WORK)/aarch64/rootfs/bin/bison: $(WORK)/bison-$(BISON_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_bison.sh $(BISON_VER)

## Coreutils

$(WORK)/x86_64/rootfs/bin/cp: $(WORK)/coreutils-$(COREUTILS_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_coreutils.sh $(COREUTILS_VER)

$(WORK)/aarch64/rootfs/bin/cp: $(WORK)/coreutils-$(COREUTILS_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_coreutils.sh $(COREUTILS_VER)

## Diffutils

$(WORK)/x86_64/rootfs/bin/diff: $(WORK)/diffutils-$(DIFFUTILS_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_diffutils.sh $(DIFFUTILS_VER)

$(WORK)/aarch64/rootfs/bin/diff: $(WORK)/diffutils-$(DIFFUTILS_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_diffutils.sh $(DIFFUTILS_VER)

## Findutils

$(WORK)/x86_64/rootfs/bin/find: $(WORK)/findutils-$(FINDUTILS_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_findutils.sh $(FINDUTILS_VER)

$(WORK)/aarch64/rootfs/bin/find: $(WORK)/findutils-$(FINDUTILS_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_findutils.sh $(FINDUTILS_VER)

## Gawk

$(WORK)/x86_64/rootfs/bin/gawk: $(WORK)/gawk-$(GAWK_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_gawk.sh $(GAWK_VER)

$(WORK)/aarch64/rootfs/bin/gawk: $(WORK)/gawk-$(GAWK_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_gawk.sh $(GAWK_VER)

## Gperf

$(WORK)/x86_64/rootfs/bin/gperf: $(WORK)/gperf-$(GPERF_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_gperf.sh $(GPERF_VER)

$(WORK)/aarch64/rootfs/bin/gperf: $(WORK)/gperf-$(GPERF_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_gperf.sh $(GPERF_VER)

## Grep

$(WORK)/x86_64/rootfs/bin/grep: $(WORK)/grep-$(GREP_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_grep.sh $(GREP_VER)

$(WORK)/aarch64/rootfs/bin/grep: $(WORK)/grep-$(GREP_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_grep.sh $(GREP_VER)

## Gzip

$(WORK)/x86_64/rootfs/bin/gzip: $(WORK)/gzip-$(GZIP_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_gzip.sh $(GZIP_VER)

$(WORK)/aarch64/rootfs/bin/gzip: $(WORK)/gzip-$(GZIP_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_gzip.sh $(GZIP_VER)

## Texinfo

$(WORK)/x86_64/rootfs/bin/makeinfo: $(WORK)/texinfo-$(TEXINFO_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_texinfo.sh $(TEXINFO_VER)

$(WORK)/aarch64/rootfs/bin/makeinfo: $(WORK)/texinfo-$(TEXINFO_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_texinfo.sh $(TEXINFO_VER)

## Make

$(WORK)/x86_64/rootfs/bin/make: $(WORK)/make-$(MAKE_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_make.sh $(MAKE_VER)

$(WORK)/aarch64/rootfs/bin/make: $(WORK)/make-$(MAKE_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_make.sh $(MAKE_VER)

## M4

$(WORK)/x86_64/rootfs/bin/m4: $(WORK)/m4-$(M4_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_m4.sh $(M4_VER)

$(WORK)/aarch64/rootfs/bin/m4: $(WORK)/m4-$(M4_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_m4.sh $(M4_VER)

## Patchelf

$(WORK)/x86_64/rootfs/bin/patchelf: $(WORK)/patchelf-$(PATCHELF_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) amd64 build_linux_static_patchelf.sh $(PATCHEFL_VER)

$(WORK)/aarch64/rootfs/bin/patchelf: $(WORK)/patchelf-$(PATCHELF_VER)
	$(SCRIPTS)/run_linux_build.sh $(OCI) arm64 build_linux_static_patchelf.sh $(PATCHELF_VER)

## Musl toolchain

$(DIST)/musl_toolchain_linux_%_$(DATE).tar.xz: $(WORK)/musl_toolchain_linux_%.tar.xz
	cp $< $@ 

$(WORK)/musl_toolchain_linux_aarch64.tar.xz: $(SOURCES)/aarch64-linux-musl-native.tgz
	$(SCRIPTS)/fix_musl_toolchain_symlink.sh $< $@ aarch64

$(WORK)/musl_toolchain_linux_x86_64.tar.xz: $(SOURCES)/x86_64-linux-musl-native.tgz
	$(SCRIPTS)/fix_musl_toolchain_symlink.sh $< $@ x86_64

## Toybox

$(DIST)/toybox_linux_aarch64_$(DATE).tar.xz: $(WORK)/toybox_linux_aarch64
	$(SCRIPTS)/build_binary_artifact.sh $< $@ toybox

$(DIST)/toybox_linux_x86_64_$(DATE).tar.xz: $(WORK)/toybox_linux_x86_64
	$(SCRIPTS)/build_binary_artifact.sh $< $@ toybox

$(DIST)/toybox_macos_universal_$(DATE).tar.xz: $(WORK)/toybox_macos_universal
	$(SCRIPTS)/build_binary_artifact.sh $< $@ toybox

$(WORK)/toybox_linux_%: $(SOURCES)/toybox-%
	cp $< $@ && \
	chmod +x $@

$(WORK)/toybox_macos_universal: $(WORK)/toybox_macos_arm $(WORK)/toybox_macos_x86
	lipo -create -output $@ $^

$(WORK)/toybox_macos_arm:
	cd $(WORK) && \
	rm -rf $(WORK)/toybox-$(TOYBOX_VER) && \
	tar -xf $(SOURCES)/toybox-$(TOYBOX_VER).tar.gz && \
	cd toybox-$(TOYBOX_VER) && \
	rm -rf toybox; \
	CFLAGS="-target arm64-apple-macos12.3" make macos_defconfig toybox && \
	mv toybox $@

$(WORK)/toybox_macos_x86:
	cd $(WORK) && \
	rm -rf $(WORK)/toybox-$(TOYBOX_VER) && \
	tar -xf $(SOURCES)/toybox-$(TOYBOX_VER).tar.gz && \
	cd toybox-$(TOYBOX_VER) && \
	rm -rf toybox; \
	CFLAGS="-target x86_64-apple-macos12.3" make macos_defconfig toybox && \
	mv toybox $@

## Static Tools

${DIST}/static_tools_linux_aarch64_$(DATE).tar.xz: static_tools_arm64
	tar -C $(WORK)/aarch64/rootfs -cJf $@ .

${DIST}/static_tools_linux_x86_64_$(DATE).tar.xz: static_tools_amd64
	tar -C $(WORK)/x86_64/rootfs -cJf $@ .

# Sources

$(WORK)/%: $(SOURCES)/%.tar.bz2
	cd $(WORK) && \
	tar -xf $<

$(WORK)/%: $(SOURCES)/%.tar.gz
	cd $(WORK) && \
	tar -xf $<

$(WORK)/%: $(SOURCES)/%.tar.lz
	cd $(WORK) && \
	tar -xf $<

$(WORK)/%: $(SOURCES)/%.tar.xz
	cd $(WORK) && \
	tar -xf $<

$(SOURCES)/bash-$(BASH_VER).tar.gz:
	wget -O $@ https://ftp.gnu.org/gnu/bash/bash-$(BASH_VER).tar.gz
	
$(SOURCES)/bison-$(BISON_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/bison/bison-$(BISON_VER).tar.xz

$(SOURCES)/coreutils-$(COREUTILS_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/coreutils/coreutils-$(COREUTILS_VER).tar.xz

$(SOURCES)/diffutils-$(DIFFUTILS_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/diffutils/diffutils-$(DIFFUTILS_VER).tar.xz

$(SOURCES)/findutils-$(FINDUTILS_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/findutils/findutils-$(FINDUTILS_VER).tar.xz

$(SOURCES)/gawk-$(GAWK_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/gawk/gawk-$(GAWK_VER).tar.xz

$(SOURCES)/gperf-$(GPERF_VER).tar.gz:
	wget -O $@ https://ftp.gnu.org/gnu/gperf/gperf-$(GPERF_VER).tar.gz

$(SOURCES)/grep-$(GREP_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/grep/grep-$(GREP_VER).tar.xz

$(SOURCES)/gzip-$(GZIP_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/gzip/gzip-$(GZIP_VER).tar.xz

$(SOURCES)/make-$(MAKE_VER).tar.lz:
	wget -O $@ https://ftp.gnu.org/gnu/make/make-$(MAKE_VER).tar.lz

$(SOURCES)/m4-$(M4_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/m4/m4-$(M4_VER).tar.xz

$(SOURCES)/patchelf-$(PATCHELF_VER).tar.bz2:
	wget -O $@ https://github.com/NixOS/patchelf/releases/download/$(PATCHELF_VER)/patchelf-$(PATCHELF_VER).tar.bz2

$(SOURCES)/texinfo-$(TEXINFO_VER).tar.xz:
	wget -O $@ https://ftp.gnu.org/gnu/texinfo/texinfo-$(TEXINFO_VER).tar.xz

$(SOURCES)/aarch64-linux-musl-native.tgz:
	wget -O $@ https://musl.cc/aarch64-linux-musl-native.tgz

$(SOURCES)/x86_64-linux-musl-native.tgz:
	wget -O $@ https://musl.cc/x86_64-linux-musl-native.tgz

$(SOURCES)/toybox-$(TOYBOX_VER).tar.gz:
	wget -O $@ http://landley.net/toybox/downloads/toybox-$(TOYBOX_VER).tar.gz

$(SOURCES)/toybox-aarch64:
	wget -O $@ http://landley.net/toybox/downloads/binaries/$(TOYBOX_VER)/toybox-aarch64

$(SOURCES)/toybox-x86_64:
	wget -O $@ http://landley.net/toybox/downloads/binaries/$(TOYBOX_VER)/toybox-x86_64