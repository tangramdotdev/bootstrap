# Tangram Bootstrap

This repository creates the bootstrap for the Tangram package manager using Linux From Scratch 11.1 as a base.

## Usage

Requires root to run with podman. Run `./build.sh`. On Linux, you may need to use `sudo` to run Podman in privileged mode. On MacOS, your podman machine needs to be configured with root instead of the default rootless mode, but the script can be run without privilege escalation. The output directory will be copied to `$PWD/lfs` upon completion. A build log will be created at `$PWD/lfs/logs/build-lfs.log`, along with a separate log file containing full build output for each step.

### Source Downloads

To prompt the build process to download the sources from the internet, edit line 18 of the Dockerfile to read `ENV FETCH_TOOLCHAIN_MODE=0`.

Otherwise, download the [prepared tarball using this link](https://github.com/tangramdotdev/bootstrap/releases/download/v0.0.0/lfs-sources.tar.xz). Extract this to the `toolchain` directory and leave the `FETCH_TOOLCHAIN_MODE` variable as `1`.

## Acknowledgements

- [LFS 11.1](https://www.linuxfromscratch.org/lfs/downloads/stable/LFS-BOOK-11.1-NOCHUNKS.html)
- [reinterpretcat/lfs](https://github.com/reinterpretcat/lfs)
