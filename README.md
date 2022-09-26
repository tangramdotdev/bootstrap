# Tangram Bootstrap

This repository contains scripts to generate the bootstrap for [Tangram](https://www.tangram.dev).

## Usage

There are three alternate bootstrap strategies in development.

### Musl

This bootstrap contains a `musl-gcc` toolchain and statically-linked utilities. Run `./build.sh` on an Apple computer with macOS 12.3 or higher and [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed.

### LFS

This bootstrap contains a `glibc` toolchain and a subset of the system described by [LFS 11.2](https://www.linuxfromscratch.org/lfs/view/11.2/index.html). Run `./lfs/build.sh` on an Apple computer with macOS 12.3 or higher and [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed.

### Crosstools (WIP)

This bootstrap will contain a dynamically linked `glibc` toolchain that is buildable using a minimal `musl`-based build system. Run `docker build -t alpine-crosstools - <./alpine-crosstools-dockerfile` to build a suitable image, then run the `build-crosstools.sh` script inside a container with this directory mounted in: `docker run --rm --name "build-crosstols" -v "$PWD":/bootstrap /bin/sh /bootstrap/build-crosstools.sh`.
