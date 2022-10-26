# Tangram Bootstrap

This repository contains scripts to generate the bootstrap for [Tangram](https://www.tangram.dev).

## Usage

This makefile produces a set of ready-made Tangram artifacts containing statically-linked utilities.

### Prerequisities

macOS 13.0 or higher with a container runtime such as [Colima](https://github.com/abiosoft/colima) or [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed.

### Setup

If it's your first time building the tools, run `make deps` to set up the folder structure and build the Linux `arm64` and `amd64` container images. This only needs to run once.

### Targets

To build everything, run `make`. This will produce a set of compressed tarballs at `./dist`, keeping build artifacts at `./work`. Sources are downloaded to `./sources`, and not cleaned up by `make clean`. Run `make clean_sources` to explicitly clear this directory.

Other usage options include:

- Enumerate all available targets: `make list`. Use `make list | xargs` to see on a single line.
- Build the static tools bundle for both architectures: `make static_tools`.
- Build the static tools bundle for `amd64`: `make static_tools_amd64`.
- Build a package: `make bison_linux_arm64`.
- Clean a package: `make clean_bison`.

Builds can be parallelized, e.g. `make -j$(nproc)`.

This Makefile also produces these ready-made pre-processed Tangram artifacts:

- [`bash_static`](https://www.gnu.org/software/bash/)
- [`linux_headers`](https://www.kernel.org)
- [`musl.cc`](https://musl.cc)
- [`toybox`](http://landley.net/toybox/)

Eventually, these artifacts will be expressed within Tangram instead.
