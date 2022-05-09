# Build You A Bootstrap

We think a lot about build systems at [Tangram](https://tangram.dev). One tool we discuss a lot is called [Nix](https://nixos.org/). Nix allows declaratively defining system configurations and build instructions for software and collecting groups of software into convenient, isolated, and reproducible development environments. You can define a Nix "expression" for any software, but the [`nixpkgs`](https://github.com/NixOS/nixpkgs) repository rivals or surpasses major Linux distributions in the number of available packages.

You can define an entire operating system this way, with each component defined in a build, from user software like [LibreOffice](https://www.libreoffice.org/) down to the core, like the [Linux kernel](https://kernel.org/) or [`bash`](https://www.gnu.org/software/bash/).

However, it can't be [turtles all the way down](https://en.wikipedia.org/wiki/Turtles_all_the_way_down). You will necessarily reach a "bottom turtle" at some point because the Nix system itself doesn't exist yet. What if you - right now, today - wanted to use this system? Somehow, you need a build of nix on your computer. The Nix developers are in the same boat. Therefore, this fantastic composable system needs things like a C compiler and shell before it can provide a C compiler and a shell. In this post, we'll talk through how to get that original hosting compiler & OS - how to _bootstrap_!

- [Concepts](#concepts)
  - [Native Compilers 101](#native-compilers-101)
  - [Static vs dynamic linking](#static-vs-dynamic-linking)
  - [Interpreter/rpath](#interpreterrpath)
  - [Chroot](#chroot)
- [The Thing](#the-thing)
  - [How we get there](#how-we-get-there)
    - [The Container](#the-container)
    - [The Build](#the-build)
      - [Creating the Cross-Toolchain](#creating-the-cross-toolchain)
      - [Populating the Chroot](#populating-the-chroot)
      - [Finalizing the Chroot](#finalizing-the-chroot)
      - [Building the Bootstrap](#building-the-bootstrap)
      - [Patching and Usage](#patching-and-usage)
    - [And Beyond?](#and-beyond)

## Concepts

There are some fundamental ideas you'll need to understand to follow along. I'll make it snappy.

### Native Compilers 101

> The bootstrap directory we're building consists of programs and libraries built in either C or C++. C and C++ are pretty distinct programming environments, but their compilation processes share a lot in common, so _for this post_, I will be referring to both as a group.

To turn source code into an executable file your operating system can execute, the user must perform Ahead-Of-Time (AOT) compilation. You feed the source files into a compiler, which creates a corresponding _object file_ for each source code unit. Then, all those object files are collected and processed by a program called the _linker_, which knows how to make the requisite connections between the sources. When your program reaches a call, like a `create_hash_map()` function you've made available in a different compilation unit or `printf()` from the standard C library, it needs to know where to look. . The linker is responsible for resolving all of these connections and producing a single executable that understands exactly where to look for each requested bit of machine code.

### Static vs. dynamic linking

There are two different strategies for linking: dynamic and static. Static linking is the more straightforward case: the compiler copies any required code into the final binary at build time. This strategy means the running executable doesn't have to do much work to locate all required code paths; they're already included. The linking is finished at build time, so there is no dynamic lookup process to complete at runtime at all.

The issue with this strategy is that your computer will have multiple redundant copies of commonly used code. The C library is a prime example - a considerable amount of programs depend on the same set of core functionality, like printing text. You don't want to copy identical versions of these functions into every single binary that uses them.

The solution is dynamic linking. Instead of copying the code, the final binary stores a list of required libraries, known as "shared object files." Our friend `printf()` is provided by the `libc.so.6` shared object file, so at runtime, it's sufficient to give the name of this object file and a path to find it in. Now all programs requiring this functionality can share the same code on disk.

### Interpreter/rpath

There are a few different pieces that need to come together to make this work:

1. The needed shared object files
1. The runpath, also called the `rpath`, for locating these objects as the program is running
1. The interpreter, also known as the dynamic linker.

Users can use the `ldd` program to inspect this resolution process. Here's an example output in an Ubuntu environment for the `cp` file copying utility:

```shell
$ ldd $(which cp)
        linux-vdso.so.1 (0x00007ffc20166000)
        libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007fc61acc2000)
        libacl.so.1 => /lib/x86_64-linux-gnu/libacl.so.1 (0x00007fc61acb7000)
        libattr.so.1 => /lib/x86_64-linux-gnu/libattr.so.1 (0x00007fc61acaf000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fc61aabd000)
        libpcre2-8.so.0 => /lib/x86_64-linux-gnu/libpcre2-8.so.0 (0x00007fc61aa2d000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fc61aa27000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fc61ad18000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fc61aa02000)
```

On the left-hand side, we see the requested object, and on the right, we see a fully resolved path pointing to where that object resides on your filesystem.

This output has two unusual items, which only provide a left-hand side without a corresponding lookup location: `linux-vdso.so.1` and `/lib64/ld-linux-x86-64.so.2`.

The first, `linux-vdso.so.1`, isn't relevant for us. This object is a "virtual" shared object file provided by the Linux kernel, so it doesn't have a physical location on the disk. The kernel provides this to userspace programs to avoid some of the overhead of making certain syscalls. Generally, the C library handles this interaction, and we can forget about it for this discussion. Check out the [`vdso` man page](https://man7.org/linux/man-pages/man7/vdso.7.html) for more detail.

The other, `/lib64/ld-linux-x86-64.so.2`, is extremely relevant. This object is the interpreter. While confusingly named like a shared object file, it's a program that gets executed. This program is what reads your filesystem and loads the required shared object files before execution, preparing them for use by the main binary.

The `ldd` program helps inspect how dynamic linking resolution occurs on your system. Still, when putting together a toolchain manually, it's helpful to see the building blocks before attempting any resolution process. The information needed to complete this step is stored directly in the binary itself, and we can use the `readelf` utility to read it.

To inspect the interpreter's path, you can use `readelf -x .interp /path/to/binary`. On Ubuntu, you'll need to install the `binutils` package if not already present. Here's the output for `cp`:

```shell
$ readelf -x .interp $(which cp)

Hex dump of section '.interp':
  0x00000318 2f6c6962 36342f6c 642d6c69 6e75782d /lib64/ld-linux-
  0x00000328 7838362d 36342e73 6f2e3200          x86-64.so.2.
```

The `.interp` section is a specific area of the compiled binary, and this command helpfully interprets the bytes given in hexadecimal as ASCII characters. We can see the full path of the dynamic linker on the right. For a more human-friendly readout, you can alternatively use `-l` and `grep` to find this information:

```
$ readelf -l $(which cp) | grep interpreter
  [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
```

To inspect the dynamic dependencies, you can use `readelf -d':

```shell
$ readelf -d hello

Dynamic section at offset 0x3e00 contains 26 entries:
Tag Type Name/Value
0x0000000000000001 (NEEDED) Shared library: [libc.so.6]
0x000000000000001d (RUNPATH) Library runpath: [/home/cool_person/bootstrap/usr/lib:/usr/lib]
0x000000000000000c (INIT) 0x401000
0x000000000000000d (FINI) 0x40114c

# lots of other stuff elided

```

The salient part for us is at the top. First, we see one or more entries marked `NEEDED`. These are the libraries this program will need to access at runtime to work. Then, if present, there is a `RUNPATH`, which contains one or more directories to look for the `NEEDED` shared object files.

Consult the [`ld-linux` man page](https://linux.die.net/man/8/ld-linux) for a more in-depth explanation.

### Chroot

Our eventual goal is a system wholly divorced from any specific host. One tool used to meet this requirement is called a [`chroot`](https://en.wikipedia.org/wiki/Chroot). We begin the build process in a host environment and populate a directory somewhere on the filesystem. However, we want that filesystem to _be_ the whole universe as far as anything inside it is concerned. Using `chroot`, we can ensure this property holds. If our directory is built at `/mnt/my-chroot`, entering a chroot at this location will map that path to `/`. Suddenly, anything outside of this directory is entirely invisible and inaccessible. We use this property to ensure that our resulting bootstrap folder is self-contained and has no lingering connection to any detail about the host that built it.

## The Thing

We need to create a directory that we can `chroot` into and use to compile arbitrary software. Building "the universe" should be possible using only these building blocks. Any software built in this manner has no dependencies on anything outside this core directory, completely divorcing us from any specific environment like a Linux distribution. While the initial setup needs to occur in an environment with an existing development setup, when completed, it shouldn't matter at all what environment that was or even be apparent to software using our bootstrap. Thus, we can break the process into two distinct phases: "before `chroot`" and "inside `chroot`."

The final bootstrap folder will need a C and C++ compiler, some essential utilities like `ls`, `grep`, and `tar`, and a utility called [`patchelf`](https://github.com/NixOS/patchelf) used to edit the interpreter and rpath values of compiled objects manually.

### How we get there.

To start, you need a working development environment. Our final product is isolated from the host, so we can use something premade and ready to go, and it doesn't much matter what we choose.

While you can adapt the following setup to many different environments, we perform our build in a fresh [Debian 11](https://www.debian.org/) installation. Our specific process uses a [Podman](https://podman.io/) container to ensure a new, sandboxed build environment. This tool is compatible with [Docker](https://www.docker.com/) as an alternative [OCI runtime](https://opencontainers.org/), so if you've got Docker installed, you're good to go.

Luckily, the process of building such an environment is already well-documented by the [Linux From Scratch](https://www.linuxfromscratch.org/) project. While the end goal of their book is a fully bootable and usable Linux operating system, we can use a subset of their walkthrough to produce a viable bootstrap. We based our process on [LFS 11.1](https://www.linuxfromscratch.org/lfs/view/11.1/) specifically.

#### The Container

Before kicking off the actual build, we use a Dockerfile to set up our new Debian environment. Setting up some environment variables helps coordinate the work as the build progresses:

```Dockerfile
ENV LFS=/mnt/lfs

ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin

WORKDIR /bin
RUN rm sh && ln -s bash sh
```

We will build the bootstrap inside `/mnt/lfs`, and we want to be sure all build steps use the exact location now marked `$LFS`. We also configure the `$PATH` to look inside `/tools/bin`, a directory we will incrementally populate before it goes looking in the typical Debian search paths. This will allow us to use tools immediately as we build them. Next, we ensure that `/bin/sh` runs the `bash` shell.

We also need a set of Debian software to get the process started:

```Dockerfile
RUN apt-get update && apt-get install -y   \
  bc                                       \
  bison                                    \
  build-essential                          \
  gawk                                     \
  libelf-dev                               \
  libssl-dev                               \
  python3                                  \
  sudo                                     \
  texinfo                                  \
  wget
```

This set of tools will let us download and compile software inside the container. Our first order of business will be setting up our compilation toolchain, but we need to build using existing tools first.

It's also helpful to establish the basic directory hierarchy:

```Dockerfile
RUN mkdir -pv            "$LFS"/sources  \
  && chmod -v a+wt       "$LFS"/sources

RUN mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}         \
  && for i in bin lib sbin; do ln -sv usr/$i $LFS/$i; done   \
  && mkdir -pv $LFS/lib64

RUN mkdir -pv $LFS/tools   \
  && ln   -sv $LFS/tools /
```

We also need a non-root user to build the initial set of tools:

```Dockerfile
RUN groupadd lfs \
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd
RUN adduser lfs sudo

RUN chown -v lfs $LFS/{usr{,/\*},lib,lib64,var,etc,bin,sbin,tools,logs}

RUN echo "lfs ALL = NOPASSWD : ALL" > /etc/sudoers

```

This user gets ownership over the `$LFS` directory tree and can use `sudo` without entering a password.

We also provide a `.bashrc` with the following contents:

```sh
set +h
umask 022
```

Setting `+h` is critical. This setting disables `bash` 's hashing feature. The first time you execute a command, the shell has to look up the location of the executable and run it from there. By default, this location gets hashed, so the next time you run the same command, the shell can skip the lookup process - we already know where it is. However, we will actively be building _new_ executables that we may need in the next step. With hashing enabled, `bash` won't know to use our new artifact and will continue to point to the old file on disk, even if the location comes earlier in the `$PATH`. That's no good. Turning this off forces the shell to perform the full lookup resolution each time you call a command, giving us our desired behavior.

Setting `umask 022` sets the default permissions for new files created in this shell environment. The owner can write, and anyone else can read and execute: `rwxr-xr-x`.

Once all this is in place, we switch to the new `lfs` user and finish off the Dockerfile with `ENTRYPOINT ["/tools/run-all.sh"]`, indicating that `docker run` will cause our build script to execute.

#### The Build

With the container fully configured, the build itself can begin. The first step is acquiring the sources. The LFS project maintains a handy list of URLs for source tarballs that work together. The only omission is the `patchelf` utility. This tool manually edits the interpreter path and rpath values of already-compiled ELF executables. This functionality enables us to use our bootstrap from anywhere on a host.

We place all the compressed tarballs in `"$LFS"/sources`. As they're needed, each step will extract the specific source and remove the uncompressed folder after installing the result.

The builds themselves are as described in Linux From Scratch from this point forward. What follows is a high-level overview of each phase.

##### Creating The Cross-Toolchain

We want to build the final bootstrap artifacts inside an isolated chroot without depending on any of the tools we installed using the Debian package manager.

The most important part of this is a cross-toolchain. This toolchain consists of 5 essential components:

- `binutils`
- `gcc`
- Linux API headers
- `glibc`
- `libstdc++`

We'll be installing this into the `$LFS/tools directory, which will not make its way into the final bootstrap.

We first have to install `binutils`, providing tools like the assembler and linker, because the configuration steps for `gcc` and `glibc` include running a series of tests on the assembler and linker determine the correct environment configuration. With those in place, we can build GCC, but only a very minimal version. Most C programs depend on the standard C library, including the fully-featured GCC installation, but we're making everything from scratch. While it's true that our Debian container provides one, we need to pretend that it doesn't exist and build it ourselves. However, this leads to a chicken-and-egg problem: we need a C compiler to build the standard C library, but we need the standard C library to build the C compiler!

Luckily, we can circumvent this problem by building our toolchain in stages. The `gcc` we build in this phase is exceptionally minimal. By turning off most functionality, we can produce just the core compiler required to build `glibc`. The configure flags look like this:

```shell
../configure                  \
  --target="$LFS_TGT"           \
  --prefix="$LFS"/tools         \
  --with-glibc-version=2.35   \
  --with-sysroot="$LFS"         \
  --with-newlib               \
  --without-headers           \
  --enable-initfini-array     \
  --disable-nls               \
  --disable-shared            \
  --disable-multilib          \
  --disable-decimal-float     \
  --disable-threads           \
  --disable-libatomic         \
  --disable-libgomp           \
  --disable-libquadmath       \
  --disable-libssp            \
  --disable-libvtv            \
  --disable-libstdcxx         \
  --enable-languages=c,c++
```

We can't even build `libstdc++` without a C library in place, but this very basic compiler is sufficient for our immediate purpose.

Building `glibc` also requires some userspace headers from the Linux kernel, which do not require compilation. We need a copy of the Linux source code. The `make headers` build target prepares the headers we need, which we can copy into our budding `$LFS` directory.

After successfully building `glibc`, we have all we need to finish our toolchain by building `libstdc++`, which the GCC source code includes. Now, our toolchain is ready to build external software written in C or C++.

This section glosses over many of the details required to make this work. For further information, consult [Chapter 5](https://www.linuxfromscratch.org/lfs/view/11.1/chapter05/introduction.html) of Linux from Scratch.

##### Populating The Chroot

Having a functional self-contained toolchain is excellent, but for `$LFS` to function as a chroot, we need additional tools to break free from the host system completely. The most important of these is a shell, specifically `bash`. When you enter a chroot, you must provide an executable that resides inside the tree as an entry point. We've been using the `bash` supplied by Debian until this point. We need to compile our version using our new toolchain and install it to `$LFS`. Similarly, once a shell exists for us to use, we're going to need utilities like `ls` and `cd` to navigate our new isolated environment, so we need to build GNU `coreutils`. Some builds require tools like `sed` and `awk` and `tar`, so we'll build those too.

To cap this off, we _rebuild_ `binutils` and `gcc` using the temporary cross-toolchain we built previously. The initial versions were still intrinsically tied to the host environment. By producing them again using our fresh copy of GCC, we ensure that our resulting tooling is only aware of the environment we've built inside the `$LFS` directory tree and nothing from outside. However, we can't build `libstdc++` again quite yet, because that part of the process will still pollute the resulting objects with artifacts from the host environment. To avoid this, we need to build `libstdc++` inside a chroot, making such pollution impossible.

Once these builds are complete, we're ready to step into the chroot for the first time, leaving Debian behind for the remainder of the process. For more details about this portion of the build, see [Chapter 6](https://www.linuxfromscratch.org/lfs/view/11.1/chapter06/introduction.html) of Linux From Scratch.

##### Finalizing The Chroot

Up until this point, all of our software has been built in a full-fledged Debian environment, using our purpose-built `lfs` non-root user. We've produced a directory at `/mnt/lfs` containing a shell, essential utilities, and a compiler toolchain, so we're ready to isolate ourselves fully.

When we enter the chroot, this `/mnt/lfs` directory will become `/` as far as anything inside is concerned. However, a working Linux environment also depends on interaction with the kernel via special filesystems exposed in the `/dev`, `/proc`, `/run`, and `/sys` directories, collectively known as the Virtual Kernel File System, or `vkfs`. These locations don't represent files on storage media like the rest of the hierarchy but rather interfaces to your actual running hardware. Running our Debian container in Docker took care of this mapping for us, and likewise, we can do the same for our chroot. Before moving on, we can mount these systems as they've been exposed to the Debian container directly to, for example, `/mnt/lfs/dev`, so inside, we can access `/dev` as usual. The steps look like this:

```sh
mkdir -pv $LFS/{dev,proc,sys,run}
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3
mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
```

Finally, the moment of truth. To enter the chroot, we use the (aptly named) `chroot` command, now as the root Debian user:

```sh
chroot "$LFS" /usr/bin/env -i     \
    HOME=/root                    \
    TERM="$TERM"                  \
    PS1='(lfs chroot) \u:\w\$ '   \
    PATH=/usr/bin:/usr/sbin       \
    /bin/bash --login +h          \
    -c "sh /tools/chroot-with-tools.sh"
```

We provide the target filesystem and pass `-i` to `env`, which explicitly ignores any environment configuration in our Debian container. We want to start with a clean slate. While you could end this invocation with `/bin/bash --login` and drop it into an interactive shell session, we use`-c`to point to a script that will carry us through the remainder of the build. After this script, we'll exit the`chroot` back into Debian to finish things up. Notably,`/bin/bash` here is actually `/mnt/lfs/bin/bash`. Henceforth, `/mnt/lfs` is `/`, and there is no wider universe.

Once inside, the first order of business is to establish a fully FHS-compliant directory tree and then finally build the missing `libstdc++` we've been waiting on, alongside a few extra tools we'll need to create the final system. For the rest of the details, refer to [Chapter 7](https://www.linuxfromscratch.org/lfs/view/11.1/chapter07/chapter07.html) of Linux From Scratch.

##### Building The Bootstrap

Whew! It was quite a process, but finally, our `chroot` contains all the pieces necessary to build our final self-contained bootstrap from the ground up. We've resolved all circular dependencies, and we no longer have any tools with any memory of the original Debian container that built them. Starting with `glibc`, we can build up all the tools we'll finally need. Up to this point, most compilation phases have required unique configuration and cross-compilation, but we're now in a "standard" environment, and we can use generally use the usual `./configure && make && make install` pattern without modification. For specifics about individual packages, refer to [Chapter 8](https://www.linuxfromscratch.org/lfs/view/11.1/chapter08/introduction.html) of Linux From Scratch.

We only need a subset of the packages described there for our bootstrap, but make sure to include all the hits like `gcc`, `make`, `coreutils`, `patch`, and the like. We also include `patchelf`, not included in the documented Linux From Scratch system, compiled with static linking so that we can manually adjust the interpreter and rpaths of any artifacts we produce later on.

After all the packages have finished building, it's essential to strip out the debug symbols, which significantly bloat the final bundle size. They won't be necessary. We can also eliminate the source tarballs, the `/tools` directory, and anything referring to our intermediate `x86_64-lfs-linux-gnu` cross-toolchain. The toolchain built in the final phase is entirely native.

##### Patching And Usage

Once this whole process completes, we've produced a container with a directory at `/mnt/lfs`, and using `docker cp`, we can grab the contents and work with them in our real host environment. However, we don't want to have to `chroot` into this location to use the tools inside. This is when the `patchelf` utility comes in handy. By running a script, we can patch all the produced binaries in this folder to point to `$BOOTSTRAP/usr/lib/ld-linux-x86-64.so.2` and set their rpaths to `$BOOTSTRAP/usr/lib`. You can execute them like usual on your computer, whatever environment you're running, and any applications and libraries you use from the bootstrap will confine their resolution paths to within the bootstrap itself. Just what we intended!

To avoid needing to run `patchelf` on any artifacts you compile using the bootstrap toolchain, you can use these `CFLAGS`: `--sysroot=$BOOTSTRAP -Wl,-dynamic-linker=$BOOTSTRAP/usr/lib/ld-linux-x86-64.so.2 -Wl,-rpath,$BOOTSTRAP/usr/lib`. The first flag directs GCC to use the bootstrap as the system root instead of its usual lookup path on your host - this is fine because we've ensured every library it needs exists in the right place within this directory. We're confident about this because that directory actually _was_ `/` at compile time! The final two options are linker flags, which tell the linker to set the interpreter and rpath properly at compile-time; no `patchelf` is needed. With all these pieces in place, our bootstrap is ready to roll.

#### And Beyond?

TODO - Talk about how we integrate with the Tangram store!
