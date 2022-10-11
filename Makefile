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

# Package versions
BASH_VER=5.1.16
TOYBOX_VER=0.8.8

# Interface targets

.PHONY: all
all: dist

.PHONY: clean
clean: clean_dist clean_bash clean_toybox

.PHONY: deps
deps: dirs images

.PHONY: dirs
dirs:
	mkdir -p $(DIST) $(SOURCES) $(WORK)

.PHONY: dist
dist: bash_dist musl_toolchain_dist toybox_dist
 #copy all bundles to dist, do some sort of sed thing to append a date to each

.PHONY: images
images: image_amd64 image_arm64

# https://stackoverflow.com/a/26339924/7163088
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

# Docker build environment

.PHONY: image_amd64
image_amd64:
	$(OCI) build --platform linux/amd64 -t $(IMAGE_AMD64) -f $(IMAGE_FILE) .

.PHONY: image_arm64
image_arm64:
	$(OCI) build --platform linux/arm64/v8 -t $(IMAGE_ARM64) -f $(IMAGE_FILE) .

# Statically-linked bash

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
	rm -rfv $(WORK)/bash*

# Toybox

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

.PHONY: toybox_dist
toybox_dist: $(DIST)/toybox_linux_aarch64_$(DATE).tar.xz $(DIST)/toybox_linux_x86_64_$(DATE).tar.xz $(DIST)/toybox_macos_universal_$(DATE).tar.xz

.PHONY: clean_dist
clean_dist:
	rm -rfv $(DIST)/*

# Work targets

## Bash

$(DIST)/bash_linux_aarch64_$(DATE).tar.xz: $(WORK)/bash_linux_aarch64
	$(SCRIPTS)/build_binary_artifact.sh $< $@ bash

$(DIST)/bash_linux_x86_64_$(DATE).tar.xz: $(WORK)/bash_linux_x86_64
	$(SCRIPTS)/build_binary_artifact.sh $< $@ bash

$(DIST)/bash_macos_universal_$(DATE).tar.xz: $(WORK)/bash_macos_universal
	$(SCRIPTS)/build_binary_artifact.sh $< $@ bash

$(WORK)/bash_linux_aarch64: $(WORK)/bash-$(BASH_VER)
	$(OCI) run \
		--rm \
		--platform linux/arm64/v8 \
		--name "aarch64-static-bash" \
		-v $(PWD):$(VOLMOUNT) \
		$(IMAGE_ARM64) \
		/bin/bash $(VOLMOUNT)/scripts/build_linux_static_bash.sh $(BASH_VER)

$(WORK)/bash_linux_x86_64: $(WORK)/bash-$(BASH_VER)
	$(OCI) run \
		--rm \
		--platform linux/amd64 \
		--name "x86-64-static-bash" \
		-v $(PWD):$(VOLMOUNT) \
		$(IMAGE_AMD64) \
		/bin/bash $(VOLMOUNT)/scripts/build_linux_static_bash.sh $(BASH_VER)

$(WORK)/bash_macos_universal: $(WORK)/bash_macos_arm $(WORK)/bash_macos_x86
	lipo -create -output $@ $^

$(WORK)/bash_macos_arm: $(WORK)/bash-$(BASH_VER)
	$(SCRIPTS)/build_macos_bash.sh $< $@ arm64-apple-macos12.3

$(WORK)/bash_macos_x86: $(WORK)/bash-$(BASH_VER)
	$(SCRIPTS)/build_macos_bash.sh $< $@ x86_64-apple-macos12.3

## Musl toolchain

$(DIST)/musl_toolchain_linux_aarch64_$(DATE).tar.xz: $(WORK)/musl_toolchain_linux_aarch64.tar.xz
	cp $< $@ 

$(DIST)/musl_toolchain_linux_x86_64_$(DATE).tar.xz: $(WORK)/musl_toolchain_linux_x86_64.tar.xz
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

$(WORK)/toybox_linux_aarch64: $(SOURCES)/toybox-aarch64
	cp $< $@ && \
	chmod +x $@

$(WORK)/toybox_linux_x86_64: $(SOURCES)/toybox-x86_64
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

# Sources

$(SOURCES)/bash-$(BASH_VER).tar.gz:
	wget -O $@ https://ftp.gnu.org/gnu/bash/bash-$(BASH_VER).tar.gz
	
$(WORK)/bash-$(BASH_VER): $(SOURCES)/bash-$(BASH_VER).tar.gz
	cd $(WORK) && \
	tar -xf $<

$(SOURCES)/aarch64-linux-musl-native.tgz:
	wget -O $@ https://musl.cc/aarch64-linux-musl-native.tgz

$(SOURCES)/x86_64-linux-musl-native.tgz:
	wget -O $@ https://musl.cc/x86_64-linux-musl-native.tgz

$(SOURCES)/toybox-$(TOYBOX_VER).tar.gz:
	wget -O $@ http://landley.net/toybox/downloads/toybox-$(TOYBOX_VER).tar.gz

$(WORK)/toybox-$(TOYBOX_VER): $(SOURCES)/toybox-$(TOYBOX_VER).tar.gz
	cd $(WORK) && \
	tar -xf $<

$(SOURCES)/toybox-aarch64:
	wget -O $@ http://landley.net/toybox/downloads/binaries/$(TOYBOX_VER)/toybox-aarch64

$(SOURCES)/toybox-x86_64:
	wget -O $@ http://landley.net/toybox/downloads/binaries/$(TOYBOX_VER)/toybox-x86_64