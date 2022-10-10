# Tangram Bootstrap

This repository contains scripts to generate the bootstrap for [Tangram](https://www.tangram.dev).

## Usage

There are two alternate bootstrap strategies in development.

### Musl

This bootstrap contains a `musl-gcc` toolchain and statically-linked utilities. It is intended to execute on an Apple computer with macOS 12.3 or higher with a container runtime such as [Colima](https://github.com/abiosoft/colima) or [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed.

If it's your first time building the tools, run `make deps` to set up the folder structure and build the Linux arm64 and amd64 container images. This only needs to run once.

To build everything, run `make`. This will produce a set of compressed tarballs at `./dist`, keeping build artifacts at `./work`. Sources are downloaded to `./sources`, and not cleaned up by `make clean`.

Each package can be built or cleaned up in isolation if needed. Use `make list` to see a full list of all available targets.

This Makefile also produces ready-made Tangram artifacts for statically-linked [`bash`](https://www.gnu.org/software/bash/), [`toybox`](http://landley.net/toybox/), and a self-contained toolchain from [`musl.cc`](https://musl.cc) until these packages can be expressed fully in Tangram.

### LFS

This bootstrap contains a `glibc` toolchain and a subset of the system described by [LFS 11.2](https://www.linuxfromscratch.org/lfs/view/11.2/index.html). Run `./lfs/build.sh` on an Apple computer with macOS 12.3 or higher and [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed.
