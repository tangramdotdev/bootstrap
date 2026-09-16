## Definitions

# Platform detection
OS := $(shell uname -s)
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
ARCH := aarch64
else ifeq ($(ARCH),amd64)
ARCH := x86_64
endif

# Provided components
COMMON_COMPONENTS :=  dash toolchain utils
LINUX_COMPONENTS := env sandbox
ifeq ($(OS),Darwin)
MACOS_COMPONENTS := sdk
endif

# Source package metadata and hardcoded checksums
BUSYBOX_BASE_URL = https://busybox.net/downloads
BUSYBOX_VERSION = 1.38.0
BUSYBOX_SHA256 = 34f9ea6ff8636f2c9241153b9114eefa9e65674a45318ae1ef95bb5f31c53bb2

DASH_BASE_URL = http://gondor.apana.org.au/~herbert/dash/files
DASH_VERSION = 0.5.13.5
DASH_SHA512 = ae326c110713a9da6b7afb977ca6fd931793b03011f0a7aa2c42e873f116ed09448deea9ef5ca4515fe3afe24e210e0aaa580f7de89934edda9cf31ee44c94dd

GNU_BASE_URL = https://ftpmirror.gnu.org/gnu
COREUTILS_VERSION = 9.12
COREUTILS_SHA256 = a480198559733e9b3da999e90543ac6f888a2caa544d8d664c5a1f17e528e210

MUSL_CC_BASE_URL = https://musl.cc
MUSL_X86_64_SHA512 = 44d441ad9aa11a06feddf3daa4c9f53ad7d9ca37af1f5a61379aca07793703d179410cea723c1b7fca94c4de19a321228bdb3656bc5cbdb5e3bea8e2d6dac6c7
MUSL_AARCH64_SHA512 = 16d544e09845c9dbba50f29e0cb04dd661e17eb63c56acad6a67fd2a78aa7596b792477c7177d3cd56d408a27dc291a90507df882f2b099c0f25511ce08fd3b5

GLIBC_VERSION = 2.44
GLIBC_SHA256 = 37f600f2bef3c5e8300147059568b2a2e40a7ad6ccc65ce942556d49429cc667

GCC_VERSION = 16.2.0
GCC_SHA256 = e6738e29597f733270731aa90600f37ffdc045079dfc27ec7e8192cc81085c3e

CACERT_BASE_URL = https://curl.se/ca
CACERT_VERSION = 2026-08-13
CACERT_SHA256 = f66dff1bdf8f96060b8177976f8b7d9254bc89bc4db933d769f7384d28480bc9

ifeq ($(OS),Darwin)
GAWK_VERSION = 5.4.0
GAWK_SHA256 = 3dd430f0cd3b4428c6c3f6afc021b9cd3c1f8c93f7a688dc268ca428a90b4ac1

GREP_VERSION = 3.12
GREP_SHA256 = 2649b27c0e90e632eadcd757be06c6e9a4f48d941de51e7c0f83ff76408a07b9

TOYBOX_BASE_URL = http://landley.net/toybox/downloads
TOYBOX_VERSION = 0.8.14
TOYBOX_SHA256 = 827e4cdfd69f5da973e00e2a59b30b3c9857fb7fae74c362fd0b4f96be7929b0
endif

# Managed directories
ifeq ($(strip $(DESTDIR)),)
DESTDIR := dist
endif
ifeq ($(strip $(SOURCEDIR)),)
SOURCEDIR := sources
endif
ifeq ($(strip $(BUILDDIR)),)
BUILDDIR := build
endif

# Define the components and platforms this Makefile supports.
# On Linux, build all Linux platforms via Docker. On macOS, build all platforms.
ALL_ARCHES = aarch64 x86_64
LINUX_PLATFORMS := $(foreach ARCH,$(ALL_ARCHES),$(ARCH)_linux)

ifeq ($(OS),Darwin)
ALL_CROSS_COMPONENTS := $(sort $(COMMON_COMPONENTS) $(LINUX_COMPONENTS))
ALL_HOST_COMPONENTS := $(sort $(COMMON_COMPONENTS) $(MACOS_COMPONENTS))
MACOS_PLATFORMS := $(foreach ARCH,$(ALL_ARCHES),$(ARCH)_darwin)
SINGLE_TARGET_PLATFORMS := $(LINUX_PLATFORMS) $(MACOS_PLATFORMS)
HOST_PLATFORM := $(ARCH)_darwin
ALL_PLATFORMS := $(SINGLE_TARGET_PLATFORMS)
PHONY_TARGET_PLATFORMS := $(SINGLE_TARGET_PLATFORMS)
else ifeq ($(OS),Linux)
ALL_HOST_COMPONENTS := $(sort $(COMMON_COMPONENTS) $(LINUX_COMPONENTS))
HOST_PLATFORM := $(ARCH)_linux
ALL_PLATFORMS := $(LINUX_PLATFORMS)
SINGLE_TARGET_PLATFORMS := $(LINUX_PLATFORMS)
PHONY_TARGET_PLATFORMS := $(LINUX_PLATFORMS)
endif

# Component/platform validity matrix: Only generate targets for valid combinations.
# SDK is handled specially with per-version targets, not via this matrix.
DASH_PLATFORMS := $(LINUX_PLATFORMS) $(MACOS_PLATFORMS)
ENV_PLATFORMS := $(LINUX_PLATFORMS)
TOOLCHAIN_PLATFORMS := $(sort $(LINUX_PLATFORMS) $(HOST_PLATFORM))
UTILS_PLATFORMS := $(LINUX_PLATFORMS) $(MACOS_PLATFORMS)
SANDBOX_PLATFORMS := $(LINUX_PLATFORMS)

# macOS build inputs.
ifeq ($(OS),Darwin)
MACOS_COMMAND_LINE_TOOLS_PATH ?= /Library/Developer/CommandLineTools
MACOS_BUILD_TOOLCHAIN ?= $(patsubst %/bin/clang,%,$(shell xcrun --find clang))
MACOS_SDK_VERSIONS := 12.1 14.5 15.2 26.5 27.0
MACOS_BUILD_SDK ?= $(MACOS_COMMAND_LINE_TOOLS_PATH)/SDKs/MacOSX27.0.sdk
MACOS_DEPLOYMENT_TARGET ?= 14.0
BUILD_JOBS ?= 4
endif

## Top-level targets

# Preserve intermediate completion stamps without skipping missing new source versions.
.PRECIOUS: %/.unpacked %/.stamp
.DELETE_ON_ERROR:

# The default target builds all components and creates tarballs.
.PHONY: all
all: $(ALL_HOST_COMPONENTS)
	@$(MAKE) --no-print-directory tarballs

# Enumerate only supported completed components; stale universal bundles are excluded.
ALL_PACKAGE_NAMES := $(foreach COMPONENT,$(filter-out toolchain,$(COMMON_COMPONENTS)),$(foreach PLATFORM,$(ALL_PLATFORMS),$(COMPONENT)_$(PLATFORM))) $(addprefix toolchain_,$(TOOLCHAIN_PLATFORMS)) $(foreach COMPONENT,$(LINUX_COMPONENTS),$(foreach PLATFORM,$(LINUX_PLATFORMS),$(COMPONENT)_$(PLATFORM))) $(foreach VERSION,$(MACOS_SDK_VERSIONS),macos_sdk_$(VERSION))
ALL_PACKAGES := $(foreach NAME,$(ALL_PACKAGE_NAMES),$(if $(wildcard $(DESTDIR)/$(NAME)/.stamp),$(DESTDIR)/$(NAME)))
TARBALLS := $(addsuffix .tar.zst,$(ALL_PACKAGES))
SHASUMS := $(DESTDIR)/SHASUMS256.txt
.PHONY: tarballs shasums FORCE
FORCE:

tarballs: $(TARBALLS) $(SHASUMS)
shasums: $(SHASUMS)

$(SHASUMS): $(TARBALLS) FORCE
	@mkdir -p $(@D)
	@$(if $(strip $(TARBALLS)),$(sha256) $(TARBALLS),:) > $@

# On MacOS, additionally build all components for all other platforms.
ifeq ($(OS),Darwin)
ALL_PLATFORM_TARGETS := $(sort $(foreach TARGET,$(ALL_CROSS_COMPONENTS),$(foreach PLATFORM,$(LINUX_PLATFORMS),$(TARGET)_$(PLATFORM))) $(foreach TARGET,$(filter-out toolchain,$(COMMON_COMPONENTS)),$(foreach PLATFORM,$(filter-out $(HOST_PLATFORM),$(MACOS_PLATFORMS)),$(TARGET)_$(PLATFORM))))

.PHONY: all_darwin
all_darwin: sdk toolchain $(foreach COMPONENT,$(filter-out toolchain,$(COMMON_COMPONENTS)),$(foreach PLATFORM,$(MACOS_PLATFORMS),$(COMPONENT)_$(PLATFORM)))
	@$(MAKE) --no-print-directory tarballs

.PHONY: check_darwin
check_darwin: sdk toolchain $(foreach COMPONENT,$(filter-out toolchain,$(COMMON_COMPONENTS)),$(foreach PLATFORM,$(MACOS_PLATFORMS),$(COMPONENT)_$(PLATFORM)))
	@$(check_darwin_bundles)

.PHONY: all_platforms
all_platforms: $(ALL_HOST_COMPONENTS) $(ALL_PLATFORM_TARGETS)
	@$(MAKE) --no-print-directory tarballs
endif

# Top-level clean targets, which blow away whole directories.  Use the component-specific clean targets for more fine-grained control.
.PHONY: clean
clean: clean_dist
	@rm -rfv $(BUILDDIR)

.PHONY: clean_all
clean_all: clean clean_sources

.PHONY: clean_dist
clean_dist:
	@rm -rf $(DESTDIR)

.PHONY: clean_sources
clean_sources:
	@rm -rfv $(SOURCEDIR)

## Create phony targets for all enabled components.

# Each component gets an entrypoint phony target for the host platform.
define component_entrypoint
.PHONY: $(1)
$(1): $(1)_$(HOST_PLATFORM)
endef

# SDK is handled specially (per-version targets), exclude from standard entrypoints
$(foreach COMPONENT,$(filter-out sdk,$(ALL_HOST_COMPONENTS)),$(eval $(call component_entrypoint,$(COMPONENT))))

# Additionally, each component gets a set phony target for each valid platform.
# Uses .stamp files for reliable dependency tracking instead of directory timestamps.
define component_platform_entrypoints
.PHONY: $(1)_$(2)
$(1)_$(2): $(DESTDIR)/$(1)_$(2)/.stamp

.PHONY: clean_$(1)
clean_$(1): clean_$(1)_$(2)

.PHONY: clean_$(1)_dist
clean_$(1)_dist: clean_$(1)_$(2)_dist

.PHONY: clean_$(1)_all
clean_$(1)_all: clean_$(1)_$(2)_all

.PHONY: clean_$(1)_sources
clean_$(1)_sources: clean_$(1)_$(2)_sources
endef

# Generate targets only for valid component/platform combinations
$(foreach PLATFORM,$(filter $(PHONY_TARGET_PLATFORMS),$(DASH_PLATFORMS)),$(eval $(call component_platform_entrypoints,dash,$(PLATFORM))))
$(foreach PLATFORM,$(filter $(PHONY_TARGET_PLATFORMS),$(ENV_PLATFORMS)),$(eval $(call component_platform_entrypoints,env,$(PLATFORM))))
$(foreach PLATFORM,$(filter $(PHONY_TARGET_PLATFORMS),$(TOOLCHAIN_PLATFORMS)),$(eval $(call component_platform_entrypoints,toolchain,$(PLATFORM))))
$(foreach PLATFORM,$(filter $(PHONY_TARGET_PLATFORMS),$(UTILS_PLATFORMS)),$(eval $(call component_platform_entrypoints,utils,$(PLATFORM))))
$(foreach PLATFORM,$(filter $(PHONY_TARGET_PLATFORMS),$(SANDBOX_PLATFORMS)),$(eval $(call component_platform_entrypoints,sandbox,$(PLATFORM))))

## Validate build environment.

define ensure_command
if ! command -v $(1) >/dev/null 2>&1; then \
	echo $(2); \
	exit 1; \
fi
endef

TOOLCHAIN := $(BUILDDIR)/$(HOST_PLATFORM)/toolchain.stamp

ifeq ($(OS),Linux)
# On Linux, Docker is used for builds (same as macOS cross-compilation)
OS_COMMANDS := docker sha256sum sha512sum sed
$(TOOLCHAIN):
	@$(call ensure_command,docker,"Error: Docker is required for Linux builds. Install Docker and ensure the daemon is running.")
	@mkdir -p $(@D)
	@touch $@
else ifeq ($(OS),Darwin)
# On macOS, use the system toolchain for Darwin builds, Docker for Linux builds
OS_COMMANDS := cc c++ gsed ld shasum xcrun
$(TOOLCHAIN):
	@$(call ensure_command,cc,"Error: Xcode Command Line Tools are not installed! Run xcode-select --install.")
	@mkdir -p $(@D)
	@touch $@
endif

COMMANDS := $(OS_COMMANDS) ar awk bash bzip2 cd chmod cp curl find gzip install ln make mkdir rm strip tar touch xz zstd
ENVIRONMENT := $(BUILDDIR)/$(HOST_PLATFORM)/environment.stamp
$(ENVIRONMENT): $(TOOLCHAIN)
	@for cmd in $(COMMANDS); do \
		$(call ensure_command,$$cmd,"Error: $$cmd not found in \$$PATH!"); \
	done
	@mkdir -p $(@D)
	@touch $@

.PHONY: list_needed_commands
list_needed_commands:
	@echo $(sort $(COMMANDS))

.PHONY: validate_environment
validate_environment: $(ENVIRONMENT)

## Dash

# Create a distribution artifact including an `sh` symlink.
define dash_dist_target
$(DESTDIR)/dash_$(1)/.stamp: $(BUILDDIR)/$(1)/dash
	@mkdir -p $(DESTDIR)/dash_$(1)/bin
	@cp $$< $(DESTDIR)/dash_$(1)/bin/
	@cd $(DESTDIR)/dash_$(1)/bin && ln -sf ./dash ./sh
	@touch $$@
endef
$(foreach PLATFORM,$(PHONY_TARGET_PLATFORMS),$(eval $(call dash_dist_target,$(PLATFORM))))

# These targets are defined for the single-target platforms: x86_64_linux, aarch64_linux, x86_64_darwin, aarch64_darwin.
define dash_targets
$(BUILDDIR)/$(1)/dash: $(SOURCEDIR)/dash-$(DASH_VERSION)/.unpacked $(if $(filter %_linux,$(1)),$(BUILDDIR)/docker_images.stamp) $(ENVIRONMENT)
	@$$(call build_$$(call get_os,$(1)),$(SOURCEDIR)/dash-$(DASH_VERSION),$$(call get_arch,$(1)),src/dash,$$@)

.PHONY: clean_dash_$(1)
clean_dash_$(1): clean_dash_$(1)_dist
	@rm -rfv $(BUILDDIR)/$(1)/dash*

.PHONY: clean_dash_$(1)_dist
clean_dash_$(1)_dist:
	@rm -rfv $(DESTDIR)/dash_$(1)

.PHONY: clean_dash_$(1)_all
clean_dash_$(1)_all: clean_dash_$(1) clean_dash_$(1)_sources

.PHONY: clean_dash_$(1)_sources
clean_dash_$(1)_sources: clean_dash_source
endef

$(foreach PLATFORM,$(SINGLE_TARGET_PLATFORMS),$(eval $(call dash_targets,$(PLATFORM))))

.PHONY: clean_dash_source
clean_dash_source:
	@rm -rfv $(SOURCEDIR)/dash*

$(SOURCEDIR)/dash-$(DASH_VERSION).tar.gz.stamp: $(SOURCEDIR)/dash-$(DASH_VERSION).tar.gz
	@$(call verify_sha512,$<,$(DASH_SHA512),$@)

$(SOURCEDIR)/dash-$(DASH_VERSION).tar.gz:
	@$(call download,$(DASH_BASE_URL)/$(@F),$@)

## env

.PHONY: clean_env_source
clean_env_source: clean_coreutils_source

define env_targets
.PHONY: clean_env_$(1)
clean_env_$(1): clean_env_$(1)_dist
	@rm -rfv $(BUILDDIR)/$(1)/env

.PHONY: clean_env_$(1)_dist
clean_env_$(1)_dist:
	@rm -rfv $(DESTDIR)/env_$(1)

.PHONY: clean_env_$(1)_all
clean_env_$(1)_all: clean_env_$(1) clean_env_$(1)_sources

.PHONY: clean_env_$(1)_sources
clean_env_$(1)_sources: clean_env_source

$(DESTDIR)/env_$(1)/.stamp: $(BUILDDIR)/$(1)/env
	@mkdir -p $(DESTDIR)/env_$(1)/bin
	@cp $$< $(DESTDIR)/env_$(1)/bin/
	@touch $$@
endef

$(foreach PLATFORM,$(LINUX_PLATFORMS),$(eval $(call env_targets,$(PLATFORM))))

define build_env_target
$(BUILDDIR)/$(1)/env: $(SOURCEDIR)/coreutils-$(COREUTILS_VERSION)/.unpacked $(BUILDDIR)/docker_images.stamp $(ENVIRONMENT)
	@$$(call build_linux,$(SOURCEDIR)/coreutils-$(COREUTILS_VERSION),$$(call get_arch,$(1)),src/env,$$@)
endef

$(foreach arch,$(ALL_ARCHES),$(eval $(call build_env_target,$(arch)_linux)))

## sandbox (glibc, libgcc_s, dash, env)

.PHONY: clean_glibc_source
clean_glibc_source:
	@rm -rfv $(SOURCEDIR)/glibc-$(GLIBC_VERSION)* $(SOURCEDIR)/glibc-$(GLIBC_VERSION).tar.xz

.PHONY: clean_gcc_source
clean_gcc_source:
	@rm -rfv $(SOURCEDIR)/gcc-$(GCC_VERSION)* $(SOURCEDIR)/gcc-$(GCC_VERSION).tar.xz

.PHONY: clean_cacert_source
clean_cacert_source:
	@rm -rfv $(SOURCEDIR)/cacert*

.PHONY: clean_sandbox_source
clean_sandbox_source: clean_glibc_source clean_gcc_source clean_cacert_source

define build_glibc_script
$(call build_in_temp,$(1),$(2),\
set -e && \
mkdir -p $$TARGET && \
$$SOURCE/configure \
    --prefix=/usr \
    --with-headers=/usr/include \
    --enable-kernel=4.19 \
    --disable-werror \
    --disable-nscd \
    --disable-timezone-tools \
    libc_cv_slibdir=/usr/lib && \
make -j$$(nproc) && \
make install DESTDIR=$$TARGET && \
rm -rf $$TARGET/usr/share $$TARGET/usr/bin $$TARGET/usr/sbin $$TARGET/var $$TARGET/etc \
       $$TARGET/usr/include $$TARGET/usr/libexec $$TARGET/sbin \
       $$TARGET/usr/lib/gconv $$TARGET/usr/lib/audit && \
find $$TARGET/usr/lib -maxdepth 1 \( -name "*.a" -o -name "*.la" -o -name "*.o" \) -delete && \
find $$TARGET/usr/lib -maxdepth 1 -name "*.so" ! -name "*.so.*" -delete && \
cd $$TARGET/usr/lib && find . -maxdepth 1 -name "*.so.*" \
    ! -name "ld-linux-*" \
    ! -name "libc.so.*" \
    ! -name "libdl.so.*" \
    ! -name "libm.so.*" \
    ! -name "libnss_dns.so.*" \
    ! -name "libnss_files.so.*" \
    ! -name "libpthread.so.*" \
    ! -name "libresolv.so.*" \
    ! -name "librt.so.*" \
    -delete && \
mv $$TARGET/usr/lib/* $$TARGET/ && rm -rf $$TARGET/usr && \
touch $$TARGET/.stamp)
endef

define build_libgcc_script
$(call build_in_temp,$(1),$(2),\
set -e && \
mkdir -p $$TARGET && \
$$SOURCE/configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-languages=c \
    --disable-bootstrap \
    --disable-multilib \
    --disable-libsanitizer \
    --disable-libvtv \
    --disable-libquadmath \
    --disable-libgomp \
    --disable-libssp \
    --disable-libatomic \
    --disable-libstdcxx \
    --enable-shared \
    --disable-static && \
make -j$$(nproc) all-target-libgcc && \
make install-target-libgcc DESTDIR=$$TARGET && \
mkdir -p $$TARGET/usr/lib && \
if [ ! -f $$TARGET/usr/lib/libgcc_s.so.1 ]; then \
    cp $$(find $$TARGET -name "libgcc_s.so.1" -print -quit) $$TARGET/usr/lib/libgcc_s.so.1; \
fi && \
rm -rf $$TARGET/usr/lib/gcc $$TARGET/usr/share && \
find $$TARGET/usr/lib -maxdepth 1 \( -name "*.a" -o -name "*.la" -o -name "*.o" \) -delete && \
find $$TARGET/usr/lib -maxdepth 1 -name "*.so" ! -name "*.so.*" -delete && \
strip --strip-unneeded $$TARGET/usr/lib/libgcc_s.so.1 && \
mv $$TARGET/usr/lib/* $$TARGET/ && rm -rf $$TARGET/usr && \
touch $$TARGET/.stamp)
endef

# Custom unpack rule for GCC: also download prerequisites (GMP, MPFR, MPC, ISL)
$(SOURCEDIR)/gcc-$(GCC_VERSION)/.unpacked: $(SOURCEDIR)/gcc-$(GCC_VERSION).tar.xz.stamp
	@mkdir -p $(@D)
	@tar -xf $(basename $<) -C $(SOURCEDIR)
	@cd $(SOURCEDIR)/gcc-$(GCC_VERSION) && contrib/download_prerequisites
	@touch $@

define build_sandbox_targets
.PHONY: clean_sandbox_$(1)
clean_sandbox_$(1): clean_sandbox_$(1)_dist
	@rm -rfv $(BUILDDIR)/$(1)/glibc $(BUILDDIR)/$(1)/libgcc

.PHONY: clean_sandbox_$(1)_dist
clean_sandbox_$(1)_dist:
	@rm -rfv $(DESTDIR)/sandbox_$(1)

.PHONY: clean_sandbox_$(1)_all
clean_sandbox_$(1)_all: clean_sandbox_$(1) clean_sandbox_$(1)_sources

.PHONY: clean_sandbox_$(1)_sources
clean_sandbox_$(1)_sources: clean_sandbox_source

$(BUILDDIR)/$(1)/glibc/.stamp: $(SOURCEDIR)/glibc-$(GLIBC_VERSION)/.unpacked $(BUILDDIR)/docker_glibc_images.stamp $(ENVIRONMENT)
	@$$(call run_glibc_docker_build,$$(call build_glibc_script,$(SOURCEDIR)/glibc-$(GLIBC_VERSION),$(BUILDDIR)/$(1)/glibc),$$(call get_arch,$(1)))

$(BUILDDIR)/$(1)/libgcc/.stamp: $(SOURCEDIR)/gcc-$(GCC_VERSION)/.unpacked $(BUILDDIR)/docker_glibc_images.stamp $(ENVIRONMENT)
	@$$(call run_glibc_docker_build,$$(call build_libgcc_script,$(SOURCEDIR)/gcc-$(GCC_VERSION),$(BUILDDIR)/$(1)/libgcc),$$(call get_arch,$(1)))

$(DESTDIR)/sandbox_$(1)/.stamp: $(BUILDDIR)/$(1)/glibc/.stamp $(BUILDDIR)/$(1)/libgcc/.stamp $(BUILDDIR)/$(1)/dash $(BUILDDIR)/$(1)/env $(SOURCEDIR)/cacert-$(CACERT_VERSION).pem.stamp
	@mkdir -p $(DESTDIR)/sandbox_$(1)/opt/tangram/lib
	@mkdir -p $(DESTDIR)/sandbox_$(1)/opt/tangram/bin
	@mkdir -p $(DESTDIR)/sandbox_$(1)/bin
	@mkdir -p $(DESTDIR)/sandbox_$(1)/usr/bin
	@mkdir -p $(DESTDIR)/sandbox_$(1)/opt/tangram/etc/ssl/certs
	@cp -R $(BUILDDIR)/$(1)/glibc/*.so* $(DESTDIR)/sandbox_$(1)/opt/tangram/lib/
	@cp -R $(BUILDDIR)/$(1)/libgcc/*.so* $(DESTDIR)/sandbox_$(1)/opt/tangram/lib/
	@cp $(BUILDDIR)/$(1)/dash $(DESTDIR)/sandbox_$(1)/bin/sh
	@cp $(BUILDDIR)/$(1)/env $(DESTDIR)/sandbox_$(1)/usr/bin/env
	@cp $(SOURCEDIR)/cacert-$(CACERT_VERSION).pem $(DESTDIR)/sandbox_$(1)/opt/tangram/etc/ssl/certs/ca-certificates.crt
	@printf '#!/bin/sh\nexec /opt/tangram/lib/$$(call get_ld_linux,$(1)) --inhibit-cache --library-path /opt/tangram/lib /opt/tangram/libexec/tangram "$$$$@"\n' > $(DESTDIR)/sandbox_$(1)/opt/tangram/bin/tangram
	@chmod +x $(DESTDIR)/sandbox_$(1)/opt/tangram/bin/tangram
	@touch $$@
endef
$(foreach platform,$(LINUX_PLATFORMS),$(eval $(call build_sandbox_targets,$(platform))))

# Source download and verify rules
$(SOURCEDIR)/glibc-$(GLIBC_VERSION).tar.xz.stamp: $(SOURCEDIR)/glibc-$(GLIBC_VERSION).tar.xz
	@$(call verify_sha256,$<,$(GLIBC_SHA256),$@)

$(SOURCEDIR)/glibc-$(GLIBC_VERSION).tar.xz:
	@$(call download,$(GNU_BASE_URL)/glibc/$(@F),$@)

$(SOURCEDIR)/gcc-$(GCC_VERSION).tar.xz.stamp: $(SOURCEDIR)/gcc-$(GCC_VERSION).tar.xz
	@$(call verify_sha256,$<,$(GCC_SHA256),$@)

$(SOURCEDIR)/gcc-$(GCC_VERSION).tar.xz:
	@$(call download,$(GNU_BASE_URL)/gcc/gcc-$(GCC_VERSION)/$(@F),$@)

$(SOURCEDIR)/cacert-$(CACERT_VERSION).pem.stamp: $(SOURCEDIR)/cacert-$(CACERT_VERSION).pem
	@$(call verify_sha256,$<,$(CACERT_SHA256),$@)

$(SOURCEDIR)/cacert-$(CACERT_VERSION).pem:
	@$(call download,$(CACERT_BASE_URL)/$(@F),$@)

## Linux toolchain (musl.cc)

.PHONY: clean_musl_cc_source
clean_musl_cc_source:
	@rm -rfv $(SOURCEDIR)/*-linux-musl-native.tgz*

define toolchain_linux_targets
.PHONY: clean_toolchain_$(1)
clean_toolchain_$(1): clean_toolchain_$(1)_dist

.PHONY: clean_toolchain_$(1)_dist
clean_toolchain_$(1)_dist:
	@rm -rfv $(DESTDIR)/toolchain_$(1)

.PHONY: clean_toolchain_$(1)_all
clean_toolchain_$(1)_all: clean_toolchain_$(1) clean_toolchain_$(1)_sources

.PHONY: clean_toolchain_$(1)_sources
clean_toolchain_$(1)_sources: clean_musl_cc_source
endef

$(foreach PLATFORM,$(LINUX_PLATFORMS),$(eval $(call toolchain_linux_targets,$(PLATFORM))))

# Extract musl.cc toolchain, fix interpreter symlink, add cc->gcc symlink
# $(1)=arch, $(2)=destdir
define fixup_musl_cc_directory
$(eval TARBALL := $(subst .stamp,,$<))
mkdir -p $(2)
tar -xf $(TARBALL) --strip-components=1 -C $(2)
$(call set_arch,$(1)) && \
INTERP=ld-musl-$$ARCH.so.1 && \
cd $(2)/lib && \
rm $$INTERP && \
ln -s libc.so $$INTERP
cd $(2)/bin && \
ln -s gcc cc
touch $(2)/.stamp
endef

$(DESTDIR)/toolchain_x86_64_linux/.stamp: $(SOURCEDIR)/x86_64-linux-musl-native.tgz.stamp
	@$(call fixup_musl_cc_directory,x86_64,$(DESTDIR)/toolchain_x86_64_linux)

$(DESTDIR)/toolchain_aarch64_linux/.stamp: $(SOURCEDIR)/aarch64-linux-musl-native.tgz.stamp
	@$(call fixup_musl_cc_directory,aarch64,$(DESTDIR)/toolchain_aarch64_linux)

$(SOURCEDIR)/x86_64-linux-musl-native.tgz.stamp: $(SOURCEDIR)/x86_64-linux-musl-native.tgz
	@$(call verify_sha512,$<,$(MUSL_X86_64_SHA512),$@)

$(SOURCEDIR)/aarch64-linux-musl-native.tgz.stamp: $(SOURCEDIR)/aarch64-linux-musl-native.tgz
	@$(call verify_sha512,$<,$(MUSL_AARCH64_SHA512),$@)

$(foreach ARCH,aarch64 x86_64,$(eval .PRECIOUS: $(SOURCEDIR)/$(ARCH)-linux-musl-native.tgz))

$(SOURCEDIR)/%-linux-musl-native.tgz:
	@$(call download,$(MUSL_CC_BASE_URL)/$(@F),$@)

## Linux utils (busybox)

.PHONY: clean_busybox_source
clean_busybox_source:
	@rm -rfv $(SOURCEDIR)/busybox*

define build_busybox_script
$(call build_in_temp,$(1),$(2),make KBUILD_SRC="$$SOURCE" -f "$$SOURCE"/Makefile defconfig && \
sed -i "s/^# CONFIG_STATIC is not set$$/CONFIG_STATIC=y/" .config && \
sed -i "s/^CONFIG_TC=y$$/# CONFIG_TC is not set/" .config && \
if [ "$$(uname -m)" = "aarch64" ]; then \
	sed -i "s/^CONFIG_SHA1_HWACCEL=y$$/# CONFIG_SHA1_HWACCEL is not set/" .config; \
	sed -i "s/^CONFIG_SHA256_HWACCEL=y$$/# CONFIG_SHA256_HWACCEL is not set/" .config; \
fi && \
export CC="gcc -static" && \
make -j$$(nproc) && \
strip --strip-unneeded busybox && \
mkdir -p $$TARGET/bin && \
rm -rf $$TARGET/bin/* && \
cp busybox "$$TARGET"/bin && \
cd "$$TARGET"/bin && \
for cmd in $$(./busybox --list); do \
	if [ "$$cmd" = "busybox" ]; then \
		continue; \
	fi && \
	ln -s ./busybox "$$cmd"; \
done)
endef

# Pattern rule for Linux utils distribution (busybox)
$(DESTDIR)/utils_%/.stamp: $(BUILDDIR)/%/utils/.stamp
	@mkdir -p $(DESTDIR)/utils_$*
	@cp -R $(BUILDDIR)/$*/utils/* $(DESTDIR)/utils_$*/
	@touch $@

# Linux utils (busybox) build targets - always use Docker for reproducibility
define build_linux_utils_targets
.PHONY: clean_utils_$(1)
clean_utils_$(1): clean_utils_$(1)_dist
	@rm -rfv $(BUILDDIR)/$(1)/utils

.PHONY: clean_utils_$(1)_dist
clean_utils_$(1)_dist:
	@rm -rfv $(DESTDIR)/utils_$(1)

.PHONY: clean_utils_$(1)_all
clean_utils_$(1)_all: clean_utils_$(1) clean_utils_$(1)_sources

.PHONY: clean_utils_$(1)_sources
clean_utils_$(1)_sources: clean_busybox_source

$(BUILDDIR)/$(1)/utils/.stamp: $(SOURCEDIR)/busybox-$(BUSYBOX_VERSION)/.unpacked $(BUILDDIR)/docker_images.stamp $(ENVIRONMENT)
	@$$(call run_linux_docker_build,$$(call build_busybox_script,$(SOURCEDIR)/busybox-$(BUSYBOX_VERSION),$(BUILDDIR)/$(1)/utils),$$(call get_arch,$(1)))
	@touch $$@
endef
$(foreach platform,$(LINUX_PLATFORMS),$(eval $(call build_linux_utils_targets,$(platform))))

$(SOURCEDIR)/busybox-$(BUSYBOX_VERSION).tar.bz2.stamp: $(SOURCEDIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	@$(call verify_sha256,$<,$(BUSYBOX_SHA256),$@)

$(SOURCEDIR)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	@$(call download,$(BUSYBOX_BASE_URL)/$(@F),$@)

## macOS toolchain, sdk

ifeq ($(OS),Darwin)
$(foreach PLATFORM,$(MACOS_PLATFORMS),$(BUILDDIR)/$(PLATFORM)/dash): Makefile

# SDK: each version is a separate, architecture-independent archive.
.PHONY: sdk
sdk: $(foreach VERSION,$(MACOS_SDK_VERSIONS),$(DESTDIR)/macos_sdk_$(VERSION)/.stamp)

.PHONY: clean_sdk clean_sdk_dist
clean_sdk: $(foreach VERSION,$(MACOS_SDK_VERSIONS),clean_sdk_$(VERSION))

clean_sdk_dist: $(foreach VERSION,$(MACOS_SDK_VERSIONS),clean_sdk_$(VERSION)_dist)

define build_darwin_sdk_target

.PHONY: sdk_$(1)
sdk_$(1): $$(DESTDIR)/macos_sdk_$(1)/.stamp

.PHONY: clean_sdk_$(1)
clean_sdk_$(1): clean_sdk_$(1)_dist

.PHONY: clean_sdk_$(1)_dist
clean_sdk_$(1)_dist:
	@rm -rfv $$(DESTDIR)/macos_sdk_$(1)

$(DESTDIR)/macos_sdk_$(1)/.stamp: | $(ENVIRONMENT)
	@if [ ! -d "$(MACOS_COMMAND_LINE_TOOLS_PATH)/SDKs/MacOSX$(1).sdk" ]; then \
		echo "Error: macOS SDK $(1) not found at $(MACOS_COMMAND_LINE_TOOLS_PATH)/SDKs/MacOSX$(1).sdk"; \
		exit 1; \
	fi
	@rm -rf $$(@D)
	@mkdir -p $$(@D)
	@cp -R "$(MACOS_COMMAND_LINE_TOOLS_PATH)/SDKs/MacOSX$(1).sdk/." $$(@D)/
	@touch $$@
endef

$(foreach VERSION,$(MACOS_SDK_VERSIONS),$(eval $(call build_darwin_sdk_target,$(VERSION))))

$(DESTDIR)/toolchain_$(HOST_PLATFORM)/.stamp: Makefile | $(ENVIRONMENT)
	@rm -rf $(@D)
	@mkdir -p $(@D)
	@cp -R "$(MACOS_BUILD_TOOLCHAIN)/." $(@D)/
	@touch $@

# $(1)=platform.
define toolchain_darwin_clean_targets
.PHONY: clean_toolchain_$(1) clean_toolchain_$(1)_dist clean_toolchain_$(1)_all clean_toolchain_$(1)_sources
clean_toolchain_$(1): clean_toolchain_$(1)_dist
clean_toolchain_$(1)_dist:
	@rm -rfv $(DESTDIR)/toolchain_$(1) $(DESTDIR)/toolchain_$(1).tar.zst
clean_toolchain_$(1)_all: clean_toolchain_$(1)
clean_toolchain_$(1)_sources:
	@:
endef
$(eval $(call toolchain_darwin_clean_targets,$(HOST_PLATFORM)))
endif

## macOS utils

ifeq ($(OS),Darwin)
MACOS_BOOTSTRAP_UTILS_BUILD_PATH := $(BUILDDIR)/$(HOST_PLATFORM)/utils

# Package the existing per-architecture builds directly, without a lipo assembly step.
define utils_darwin_target
$(DESTDIR)/utils_$(1)/.stamp: $(BUILDDIR)/$(1)/utils/bin/toybox.stamp $(BUILDDIR)/$(1)/gawk/.stamp $(BUILDDIR)/$(1)/grep/.stamp $(BUILDDIR)/$(1)/expr $(BUILDDIR)/$(1)/tr
	@rm -rf $(DESTDIR)/utils_$(1)
	@mkdir -p $(DESTDIR)/utils_$(1)/bin
	@cp -R $(BUILDDIR)/$(1)/utils/bin/. $(DESTDIR)/utils_$(1)/bin/
	@cd $(DESTDIR)/utils_$(1)/bin && rm -f toybox.stamp awk expr grep tr egrep fgrep
	@cp $(BUILDDIR)/$(1)/gawk/bin/gawk $(BUILDDIR)/$(1)/grep/bin/grep $(BUILDDIR)/$(1)/expr $(BUILDDIR)/$(1)/tr $(DESTDIR)/utils_$(1)/bin/
	@cd $(DESTDIR)/utils_$(1)/bin && ln -sf ./gawk ./awk
	@touch $$@

.PHONY: clean_utils_$(1) clean_utils_$(1)_dist clean_utils_$(1)_all clean_utils_$(1)_sources
clean_utils_$(1): clean_utils_$(1)_dist
	@rm -rfv $(BUILDDIR)/$(1)/utils $(BUILDDIR)/$(1)/coreutils $(BUILDDIR)/$(1)/gawk $(BUILDDIR)/$(1)/grep $(BUILDDIR)/$(1)/expr $(BUILDDIR)/$(1)/tr
clean_utils_$(1)_dist:
	@rm -rfv $(DESTDIR)/utils_$(1) $(DESTDIR)/utils_$(1).tar.zst
clean_utils_$(1)_all: clean_utils_$(1) clean_utils_$(1)_sources
clean_utils_$(1)_sources: clean_coreutils_source clean_gawk_source clean_grep_source clean_toybox_source
endef
$(foreach PLATFORM,$(MACOS_PLATFORMS),$(eval $(call utils_darwin_target,$(PLATFORM))))
endif

# GNU coreutils and other GNU common rules
# NOTE - the `env`, `expr`, and `tr` targets all share this source.  There is no target to obtain a complete coreutils installation, just the individual tools required.

.PHONY: clean_coreutils_source
clean_coreutils_source:
	@rm -rfv $(SOURCEDIR)/coreutils-$(COREUTILS_VERSION)* $(SOURCEDIR)/coreutils-$(COREUTILS_VERSION).tar.xz

ifeq ($(OS),Linux)
$(SOURCEDIR)/coreutils-$(COREUTILS_VERSION).tar.xz.stamp: $(SOURCEDIR)/coreutils-$(COREUTILS_VERSION).tar.xz
	@$(call verify_sha256,$<,$(COREUTILS_SHA256),$@)

$(SOURCEDIR)/coreutils-$(COREUTILS_VERSION).tar.xz:
	@$(call download,$(GNU_BASE_URL)/coreutils/$(@F),$@)
endif

ifeq ($(OS),Darwin)
# $(1) = package name, $(2) = version, $(3) = sha256 checksum
define both_darwin_architectures_from_gnu_targets
$$(foreach ARCH,$(ALL_ARCHES),$(BUILDDIR)/$$(ARCH)_darwin/$(1)/.stamp): $(SOURCEDIR)/$(1)-$(2)/.unpacked Makefile $(ENVIRONMENT)
	@$$(call build_darwin_and_install,$(SOURCEDIR)/$(1)-$(2),$$(call get_arch,$$(notdir $$(abspath $$(@D)/..))),$$(@D))

$(SOURCEDIR)/$(1)-$(2).tar.xz.stamp: $(SOURCEDIR)/$(1)-$(2).tar.xz
	@$$(call verify_sha256,$$<,$(3),$$@)

$(SOURCEDIR)/$(1)-$(2).tar.xz:
	@$$(call download,$$(GNU_BASE_URL)/$(1)/$$(notdir $$@),$$@)
endef

$(eval $(call both_darwin_architectures_from_gnu_targets,coreutils,$(COREUTILS_VERSION),$(COREUTILS_SHA256)))

## MacOS utils

# expr and tr from GNU coreutils
define darwin_single_coreutils_targets
.PHONY: $(1)_darwin
$(1)_darwin: $(BUILDDIR)/$(HOST_PLATFORM)/$(1)

.PHONY: clean_$(1)_darwin
clean_$(1)_darwin:
	@rm -rfv $(BUILDDIR)/$(HOST_PLATFORM)/$(1)

.PHONY: clean_$(1)_darwin_all
clean_$(1)_darwin_all: clean_$(1)_darwin clean_coreutils_source

$(foreach ARCH,$(ALL_ARCHES),$(eval $(BUILDDIR)/$(ARCH)_darwin/$(1): $(BUILDDIR)/$(ARCH)_darwin/coreutils/.stamp ; \
	@cp $$(@D)/coreutils/bin/$$(@F) $$@))
endef

$(foreach TOOL,expr tr,$(eval $(call darwin_single_coreutils_targets,$(TOOL))))

# gawk and grep from individual GNU packages
# $(1) = package name, $(2) = version, $(3) = sha256 checksum
define darwin_single_gnu_targets
.PHONY: $(1)_darwin
$(1)_darwin: $(BUILDDIR)/$(HOST_PLATFORM)/$(1)/.stamp

.PHONY: clean_$(1)_darwin
clean_$(1)_darwin:
	@rm -rfv $(BUILDDIR)/$(HOST_PLATFORM)/$(1) $$(foreach PLATFORM,$$(MACOS_PLATFORMS) $$(HOST_PLATFORM),$(BUILDDIR)/$$(PLATFORM)/$(1)*)

.PHONY: clean_$(1)_darwin_all
clean_$(1)_darwin_all: clean_$(1)_darwin clean_$(1)_source

.PHONY: clean_$(1)_source
clean_$(1)_source:
	@rm -rfv $(SOURCEDIR)/$(1)-$(2)*

$$(eval $$(call both_darwin_architectures_from_gnu_targets,$(1),$(2),$(3)))
endef

$(eval $(call darwin_single_gnu_targets,gawk,$(GAWK_VERSION),$(GAWK_SHA256)))

$(eval $(call darwin_single_gnu_targets,grep,$(GREP_VERSION),$(GREP_SHA256)))

## Toybox (macOS utils)

.PHONY: toybox_darwin
toybox_darwin: $(MACOS_BOOTSTRAP_UTILS_BUILD_PATH)/bin/toybox.stamp

.PHONY: clean_toybox_darwin
clean_toybox_darwin:
	@rm -rfv $(foreach PLATFORM,$(MACOS_PLATFORMS),$(BUILDDIR)/$(PLATFORM)/utils)

.PHONY: clean_toybox_darwin_all
clean_toybox_darwin_all: clean_toybox_darwin clean_toybox_source

.PHONY: clean_toybox_source
clean_toybox_source:
	@rm -rfv $(SOURCEDIR)/toybox-$(TOYBOX_VERSION)*

# Build toybox for Darwin
# $(1)=source dir, $(2)=arch, $(3)=destination
# Note: +$(MAKE) is used to properly inherit jobserver; MAKEFLAGS= clears parallel flags
# to avoid race conditions in toybox's genconfig.sh which creates files Make expects
define build_toybox_darwin
set -e; \
$(call set_arch_darwin,$(2)) && \
mkdir -p $$(dirname $(CURDIR)/$(3)) && \
WORK=$$(mktemp -d) && \
trap "rm -rf $$WORK" EXIT && \
cp -R $(CURDIR)/$(1)/* $$WORK && \
cd $$WORK && \
$(call darwin_compiler) && \
MAKEFLAGS= $(MAKE) macos_defconfig && \
$(MAKE) -j$(BUILD_JOBS) && \
chmod +w toybox && \
"$(MACOS_BUILD_TOOLCHAIN)/bin/strip" -S toybox && \
PREFIX="$(abspath $(3))" scripts/install.sh --symlink --force && \
touch "$(abspath $(3))/toybox.stamp"
endef

$(BUILDDIR)/aarch64_darwin/utils/bin/toybox.stamp: $(SOURCEDIR)/toybox-$(TOYBOX_VERSION)/.unpacked Makefile $(ENVIRONMENT)
	@$(call build_toybox_darwin,$(SOURCEDIR)/toybox-$(TOYBOX_VERSION),aarch64,$(@D))

$(BUILDDIR)/x86_64_darwin/utils/bin/toybox.stamp: $(SOURCEDIR)/toybox-$(TOYBOX_VERSION)/.unpacked Makefile $(ENVIRONMENT)
	@$(call build_toybox_darwin,$(SOURCEDIR)/toybox-$(TOYBOX_VERSION),x86_64,$(@D))

$(SOURCEDIR)/toybox-$(TOYBOX_VERSION).tar.gz.stamp: $(SOURCEDIR)/toybox-$(TOYBOX_VERSION).tar.gz
	@$(call verify_sha256,$<,$(TOYBOX_SHA256),$@)

$(SOURCEDIR)/toybox-$(TOYBOX_VERSION).tar.gz:
	@$(call download,$(TOYBOX_BASE_URL)/$(@F),$@)
endif

## Common rules and definitions

# Unpack a source tarball into the source directory.
# Creates a .unpacked stamp file inside the extracted directory for reliable dependency tracking.
define unpack_tarball
$(SOURCEDIR)/%/.unpacked: $(SOURCEDIR)/%$(1).stamp
	@mkdir -p $$(@D)
	@tar -xf $$(basename $$<) -C $(SOURCEDIR)
	@touch $$@
endef

SUPPORTED_EXTENSIONS = .tar.bz2 .tar.gz .tgz .tar.xz
$(foreach EXT,$(SUPPORTED_EXTENSIONS),$(eval $(call unpack_tarball,$(EXT))))

# Create tarballs from output directories
$(DESTDIR)/%.tar.zst: $(DESTDIR)/%/.stamp
	@bash -o pipefail -c 'tar -cf - --exclude=".stamp" -C "$$1" . | zstd -z -19 -T0 -f -o "$$2" -' -- "$(DESTDIR)/$*" "$@"

$(DESTDIR)/%.tar.zst.sha256sum: $(DESTDIR)/%.tar.zst
	@$(sha256) $< > $@

# Set ARCH with the corresponding string for the target arch.
define set_arch_darwin
if [ $(1) = "aarch64" ]; then \
	ARCH="arm64"; \
elif [ $(1) = "x86_64" ]; then \
	ARCH="x86_64"; \
else \
	echo "Unknown arch $(1)"; \
	exit 1; \
fi
endef
define set_arch
if [ $(1) = "aarch64" ]; then \
	ARCH="aarch64"; \
elif [ $(1) = "x86_64" ]; then \
	ARCH="x86_64"; \
else \
	echo "Unknown arch $(1)"; \
	exit 1; \
fi
endef

ifeq ($(OS),Darwin)
# Inspect both bundles and execute only tools built for this host.
define check_darwin_bundles
set -e -o pipefail; \
for ARCH in $(ALL_ARCHES); do \
    APPLE_ARCH=$$ARCH; [ "$$ARCH" != aarch64 ] || APPLE_ARCH=arm64; \
    for COMPONENT in dash utils toolchain; do \
        [ "$$COMPONENT" != toolchain ] || [ "$$ARCH" = "$(ARCH)" ] || continue; \
        BIN="$(DESTDIR)/$${COMPONENT}_$${ARCH}_darwin/bin"; \
        case $$COMPONENT in dash) TOOLS="dash sh";; utils) TOOLS="toybox awk gawk expr grep tr";; toolchain) TOOLS="clang clang++ ld ar nm ranlib strip";; esac; \
        for TOOL in $$TOOLS; do test "$$(lipo -archs "$$BIN/$$TOOL")" = "$$APPLE_ARCH"; done; \
    done; \
    for FILE in $(DESTDIR)/dash_$${ARCH}_darwin/bin/dash $(addprefix $(DESTDIR)/utils_$${ARCH}_darwin/bin/,gawk grep expr tr toybox); do \
        test "$$(otool -l "$$FILE" | awk '/^[[:space:]]*minos / { print $$2 }')" = "$(MACOS_DEPLOYMENT_TARGET)"; \
        if otool -L "$$FILE" | sed 1d | grep -vE '^[[:space:]]+(/usr/lib/|/System/Library/)'; then echo "Unexpected dependency: $$FILE"; exit 1; fi; \
    done; \
done; \
WORK=$$(mktemp -d) && trap 'rm -rf "$$WORK"' EXIT; \
printf '#include <stdio.h>\nint main(void) { puts("ok"); return 0; }\n' > "$$WORK/main.c"; \
printf '#include <iostream>\nint main() { std::cout << "ok" << std::endl; }\n' > "$$WORK/main.cpp"; \
for LANGUAGE in c cpp; do \
    COMPILER=clang; [ "$$LANGUAGE" = c ] || COMPILER=clang++; \
    for ARCH in $(ALL_ARCHES); do \
        APPLE_ARCH=$$ARCH; [ "$$ARCH" != aarch64 ] || APPLE_ARCH=arm64; \
        $(DESTDIR)/toolchain_$(HOST_PLATFORM)/bin/$$COMPILER -target "$$APPLE_ARCH-apple-macos$(MACOS_DEPLOYMENT_TARGET)" \
            -isysroot "$(MACOS_BUILD_SDK)" "$$WORK/main.$$LANGUAGE" -o "$$WORK/program"; \
        test "$$(lipo -archs "$$WORK/program")" = "$$APPLE_ARCH"; \
        if [ "$$ARCH" = "$(ARCH)" ]; then test "$$("$$WORK/program")" = ok; fi; \
    done; \
done; \
echo "Darwin architecture, deployment, dependency, and C/C++ checks passed."; \
echo "Foreign-architecture executables were inspected but not run."
endef

# Target flags must also reach generators that invoke CC without CFLAGS.
# WORK and ARCH are set by the existing Darwin build recipes.
define darwin_compiler
for COMPILER in clang clang++; do \
	printf '#!/bin/sh\nexec "%s" -target "%s" -isysroot "%s" "$$@"\n' "$(MACOS_BUILD_TOOLCHAIN)/bin/$$COMPILER" "$$ARCH-apple-macos$(MACOS_DEPLOYMENT_TARGET)" "$(MACOS_BUILD_SDK)" > "$$WORK/$$COMPILER" || exit 1; \
	chmod +x "$$WORK/$$COMPILER" || exit 1; \
done && \
export CC="$$WORK/clang" CXX="$$WORK/clang++" CFLAGS=-Os CXXFLAGS=-Os && \
export HOSTCC="$(MACOS_BUILD_TOOLCHAIN)/bin/clang" CC_FOR_BUILD="$(MACOS_BUILD_TOOLCHAIN)/bin/clang" && \
export AR="$(MACOS_BUILD_TOOLCHAIN)/bin/ar" RANLIB="$(MACOS_BUILD_TOOLCHAIN)/bin/ranlib" && \
export SDKROOT="$(MACOS_BUILD_SDK)" MACOSX_DEPLOYMENT_TARGET="$(MACOS_DEPLOYMENT_TARGET)"
endef

# Build a Darwin binary for a single target
# $(1)=source dir, $(2)=arch, $(3)=binary path in build, $(4)=destination
define build_darwin
$(info Building $(4) for $(2)_darwin)
set -e; \
$(call set_arch_darwin,$(2)) && \
WORK=$$(mktemp -d) && \
trap "rm -rf $$WORK" EXIT && \
cd $$WORK && \
$(call darwin_compiler) && \
$(CURDIR)/$(1)/configure --build=$$(uname -m)-apple-darwin --host=$$ARCH-apple-darwin --disable-nls && \
$(MAKE) -j$(BUILD_JOBS) && \
mkdir -p $$(dirname $(CURDIR)/$(4)) && \
cp $$WORK/$(3) $(CURDIR)/$(4)
endef

# Build and install a Darwin binary for a single target (for packages using make install)
# $(1)=source dir, $(2)=arch, $(3)=destination prefix
define build_darwin_and_install
$(info Building $(3) for $(2)_darwin)
set -e; \
$(call set_arch_darwin,$(2)) && \
WORK=$$(mktemp -d) && \
trap "rm -rf $$WORK" EXIT && \
cd $$WORK && \
$(call darwin_compiler) && \
$(CURDIR)/$(1)/configure --prefix=$(CURDIR)/$(3) --build=$$(uname -m)-apple-darwin --host=$$ARCH-apple-darwin \
	--disable-nls $(if $(filter grep-%,$(notdir $(1))),--disable-perl-regexp) $(if $(filter gawk-%,$(notdir $(1))),--without-readline --without-mpfr) && \
$(MAKE) -j$(BUILD_JOBS) && \
$(MAKE) install && \
touch $(CURDIR)/$(3)/.stamp
endef
endif

# Build a static Linux binary using the Alpine system toolchain
# $(1)=source dir, $(2)=output path, $(3)=binary name in build dir
# NOTE: FORCE_UNSAFE_CONFIGURE for coreutils, --enable-static for dash
define single_target_linux_script
$(call build_in_temp,$(1),$(2),\
set -e && \
export FORCE_UNSAFE_CONFIGURE=1 && \
export CC="gcc -static" && \
export CFLAGS="-Os -fPIE -fPIC" && \
export LDFLAGS="-s" && \
$$SOURCE/configure --enable-static && \
make -j$$(nproc) && \
mkdir -p $$(dirname $$TARGET) && \
cp $(3) $$TARGET)
endef

# Build in a temp directory inside Docker container
# $(1)=source, $(2)=target, $(3)=build script
define build_in_temp
SOURCE=/bootstrap/$(1) && \
TARGET=/bootstrap/$(2) && \
WORK=$$(mktemp -d) && \
trap "rm -rf $$WORK" EXIT && \
cd $$WORK && \
$(3)
endef

# Build a Linux binary in Docker (used on both macOS and Linux for reproducibility)
# $(1)=source dir, $(2)=arch, $(3)=binary name, $(4)=output path
define build_linux
$(call run_linux_docker_build,$(call single_target_linux_script,$(1),$(4),$(3)),$(2))
endef

# Run the correct shasum command for the current OS.
ifeq ($(OS),Darwin)
sha256 = shasum -a 256
sha512 = shasum -a 512
else ifeq ($(OS),Linux)
sha256 = sha256sum
sha512 = sha512sum
endif

# Verify SHA256 checksum: $(1)=file, $(2)=expected, $(3)=stamp
define verify_sha256
ACTUAL=$$($(sha256) $(1) | cut -d' ' -f1) && \
if [ "$$ACTUAL" = "$(2)" ]; then \
	echo "SHA256 verified: $(1)"; \
	touch $(3); \
else \
	echo "SHA256 mismatch for $(1)"; \
	echo "  expected: $(2)"; \
	echo "  actual:   $$ACTUAL"; \
	exit 1; \
fi
endef

# Verify SHA512 checksum: $(1)=file, $(2)=expected, $(3)=stamp
define verify_sha512
ACTUAL=$$($(sha512) $(1) | cut -d' ' -f1) && \
if [ "$$ACTUAL" = "$(2)" ]; then \
	echo "SHA512 verified: $(1)"; \
	touch $(3); \
else \
	echo "SHA512 mismatch for $(1)"; \
	echo "  expected: $(2)"; \
	echo "  actual:   $$ACTUAL"; \
	exit 1; \
fi
endef

# Download a file, ensuring the destination directory exists.
define download
@mkdir -p $(dir $(2))
@curl -fsSLo $(2) $(1)
endef

# Obtain the OS from a system string, e.g. "linux" from "aarch64_linux".
define get_os
$(lastword $(subst _, ,$(1)))
endef

# Obtain the arch from a system string, e.g. "aarch64" from "aarch64_linux".
# Must handle x86_64 specially since it contains an underscore.
define get_arch
$(if $(findstring x86_64,$(1)),x86_64,$(if $(findstring aarch64,$(1)),aarch64,$(word 1,$(subst _, ,$(1)))))
endef

# Map platform to ld-linux dynamic linker filename.
get_ld_linux = $(if $(findstring x86_64,$(1)),ld-linux-x86-64.so.2,ld-linux-aarch64.so.1)

# Targets that just list other targets.
NULL :=
SPACE := $(NULL) $(NULL)
define \n


endef
define spaces_to_lines
$(subst $(SPACE),$(\n),$(1))
endef

.PHONY: list list_all
list list_all:
	$(info $(call spaces_to_lines,$(ALL_HOST_COMPONENTS)))
	@:

ifeq ($(OS),Darwin)
.PHONY: list_cross_targets
list_cross_targets:
	$(info $(call spaces_to_lines,$(ALL_PLATFORM_TARGETS)))
	@:

.PHONY: list_all_platforms
list_all_platforms:
	$(info $(call spaces_to_lines,$(sort $(ALL_HOST_COMPONENTS) $(ALL_PLATFORM_TARGETS))))
	@:
endif

# https://stackoverflow.com/a/26339924/7163088
.PHONY: list_all_targets
list_all_targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
# Docker infrastructure for building Linux targets (used on both macOS and Linux)

.PHONY: docker_images
docker_images: $(BUILDDIR)/docker_images.stamp

.PHONY: docker_stopall
docker_stopall:
	@docker container stop $$(docker container ls -q --filter name=tangram-bootstrap) 2>/dev/null || true
	@docker buildx stop tangram_bootstrap_builder 2>/dev/null || true
	@docker buildx stop tangram_bootstrap_glibc_builder 2>/dev/null || true

.PHONY: clean_docker
clean_docker: docker_stopall clean_docker_glibc
	@docker rmi tangram_bootstrap_x86_64 2>/dev/null || true
	@docker rmi tangram_bootstrap_aarch64 2>/dev/null || true
	$(stop_builder)
	@rm -rfv $(BUILDDIR)/docker_images.stamp

# Rebuild Docker images only when Dockerfile changes
$(BUILDDIR)/docker_images.stamp: Dockerfile
	$(stop_builder)
	@docker buildx create --platform linux/amd64,linux/arm64 --name tangram_bootstrap_builder
	@docker buildx inspect tangram_bootstrap_builder --bootstrap
	@docker buildx build --builder tangram_bootstrap_builder --platform linux/amd64 --load -t tangram_bootstrap_x86_64 -f Dockerfile .
	@docker buildx build --builder tangram_bootstrap_builder --platform linux/arm64 --load -t tangram_bootstrap_aarch64 -f Dockerfile .
	$(stop_builder)
	@mkdir -p $(@D) && touch $@

define stop_builder
@docker buildx stop tangram_bootstrap_builder 2>/dev/null || true
@docker buildx rm tangram_bootstrap_builder 2>/dev/null || true
endef

# Verify Docker image exists before running
define verify_docker_image
@if ! docker image inspect tangram_bootstrap_$(1) >/dev/null 2>&1; then \
	echo "Error: Docker image tangram_bootstrap_$(1) not found. Run 'make docker_images' first."; \
	exit 1; \
fi
endef

# Map arch name to Docker platform format
docker_platform = $(if $(filter x86_64,$(1)),amd64,$(if $(filter aarch64,$(1)),arm64,$(1)))

# Run a script in a Docker container.
define run_linux_docker_build
$(call verify_docker_image,$(2))
docker run \
	--rm \
	--platform linux/$(call docker_platform,$(2)) \
	--name "tangram-bootstrap-$(2)-$(@F)-$(notdir $(@D))" \
	-v "$$PWD:/bootstrap" \
	tangram_bootstrap_$(2) \
	bash -eu -o pipefail -c \
	'$(1)'
endef

# Docker infrastructure for glibc builds (Fedora-based)

.PHONY: docker_glibc_images
docker_glibc_images: $(BUILDDIR)/docker_glibc_images.stamp

.PHONY: clean_docker_glibc
clean_docker_glibc:
	$(stop_glibc_builder)
	@docker rmi tangram_bootstrap_glibc_x86_64 2>/dev/null || true
	@docker rmi tangram_bootstrap_glibc_aarch64 2>/dev/null || true
	@rm -rfv $(BUILDDIR)/docker_glibc_images.stamp

$(BUILDDIR)/docker_glibc_images.stamp: Dockerfile.glibc
	$(stop_glibc_builder)
	@docker buildx create --platform linux/amd64,linux/arm64 --name tangram_bootstrap_glibc_builder
	@docker buildx inspect tangram_bootstrap_glibc_builder --bootstrap
	@docker buildx build --builder tangram_bootstrap_glibc_builder --platform linux/amd64 --load -t tangram_bootstrap_glibc_x86_64 -f Dockerfile.glibc .
	@docker buildx build --builder tangram_bootstrap_glibc_builder --platform linux/arm64 --load -t tangram_bootstrap_glibc_aarch64 -f Dockerfile.glibc .
	$(stop_glibc_builder)
	@mkdir -p $(@D) && touch $@

define stop_glibc_builder
@docker buildx stop tangram_bootstrap_glibc_builder 2>/dev/null || true
@docker buildx rm tangram_bootstrap_glibc_builder 2>/dev/null || true
endef

define verify_glibc_docker_image
@if ! docker image inspect tangram_bootstrap_glibc_$(1) >/dev/null 2>&1; then \
	echo "Error: Docker image tangram_bootstrap_glibc_$(1) not found. Run 'make docker_glibc_images' first."; \
	exit 1; \
fi
endef

define run_glibc_docker_build
$(call verify_glibc_docker_image,$(2))
docker run \
	--rm \
	--platform linux/$(call docker_platform,$(2)) \
	--user $$(id -u):$$(id -g) \
	--name "tangram-bootstrap-$(2)-$(@F)-$(notdir $(@D))" \
	-v "$$PWD:/bootstrap" \
	tangram_bootstrap_glibc_$(2) \
	bash -eu -o pipefail -c \
	'$(1)'
endef
