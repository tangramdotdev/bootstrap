# Tangram Bootstrap

This repository creates the bootstrap for the Tangram package manager using Linux From Scratch 11.1 as a base.

## Usage

Requires root to run with podman. Run `sudo ./build.sh`. The output directory will be copied to `$PWD/lfs` upon completion. A build log will be created at `$PWD/logs/build-lfs.log`, along with a separate log file containing full build output for each step. This is volume mapped, so can be inspected while the script runs. This directory is cleared at the start of each run, so copy elsewhere if you'd like to preserve the contents.

### Source Downloads

To prompt the build process to download the sources from the internet, edit line 22 of the Dockerfile to read `ENV FETCH_TOOLCHAIN_MODE=0`.

Otherwise, ask Ben for the link to the prepared tarball. Extract this to the `toolchain` directoy and leave the `FETCH_TOOLCHAIN_MODE` variable as `1`.

Eventually, this will be hosted in a nice place, and a `2` mode will take care of that for you.

## Acknowledgements

- [LFS 11.1](https://www.linuxfromscratch.org/lfs/downloads/stable/LFS-BOOK-11.1-NOCHUNKS.html)
- [reinterpretcat/lfs](https://github.com/reinterpretcat/lfs)
