FROM debian:11

LABEL description="Automated build of LFS 11.1 for Tangram bootstrap"
LABEL version="11.1"
LABEL maintainer="root@tangram.dev"

# LFS build location (2.6)
ENV LFS=/mnt/lfs

# LFS build parameters
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV CONFIG_SITE=$LFS/usr/share/config.site
# Defines how toolchain is fetched
# 0 use LFS wget file
# 1 use binaries from toolchain folder
ENV FETCH_TOOLCHAIN_MODE=1

# Set bash as default shell (2.2)
WORKDIR /bin
RUN rm sh && ln -s bash sh

# Install host prerequisite (2.2)
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
  wget                                     \
&& apt-get -q -y autoremove                \
&& rm -rf /var/lib/apt/lists/*

# create "sticky" sources dir (3.1)
RUN mkdir -pv            $LFS/sources  \
  && chmod -v a+wt       $LFS/sources

# Create limited directory hierarchy (4.2)
RUN mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}         \
  && for i in bin lib sbin; do ln -sv usr/$i $LFS/$i; done   \
  && mkdir -pv $LFS/lib64

# create tools dir and symlink to root (4.2)
RUN mkdir -pv $LFS/tools   \
  && ln   -sv $LFS/tools /

# copy local toolchain archives if present
COPY [ "toolchain/", "$LFS/sources" ]

# copy existing cross-toolchain, if present
# NOTE - this overwrites sources already copied above - wasteful, but not harmful.
# Best to not populate toolchain/ if using the existing cross toolchain tarball.
COPY [ "lfs/", "$LFS" ]

# copy scripts
COPY [ "scripts/run-all.sh",           \
       "scripts/version-check.sh",     \
       "scripts/prepare/",             \
       "scripts/build/",               \
       "md5sums",                      \
       "wget-list",                    \
       "$LFS/tools/" ]

# Create `lfs` user (4.3)
RUN groupadd lfs                                        \
  && useradd -s /bin/bash -g lfs -m -k /dev/null lfs    \
  && echo "lfs:lfs" | chpasswd
RUN adduser lfs sudo

# set log location vars
RUN mkdir -pv $LFS/logs
ENV LOGDIR=$LFS/logs
ENV LOGFILE=$LOGDIR/build-lfs.log

# The lfs user should own the working dirs (4.3)
RUN chown -v lfs $LFS/{usr{,/*},lib,lib64,var,etc,bin,sbin,tools,logs}

# No password for sudo
RUN echo "lfs ALL = NOPASSWD : ALL" > /etc/sudoers
# Carry important env vars across sudo invocation
RUN echo 'Defaults env_keep += "CONFIG_SITE LFS LC_ALL LFS_TGT PATH LOGDIR LOGFILE FETCH_TOOLCHAIN_MODE"' >> /etc/sudoers

# Run environment checks (2.2)
RUN chmod +x $LFS/tools/*.sh       \
  && sync                          \
  && $LFS/tools/version-check.sh

# Ensure there's no /etc/bash.bashrc extra initialization (4.4)
RUN [ ! -e /etc/bash/bashrc ] || mv -v /etc/bash.bashrc /etc/bash/bashrc.NOUSE

# Enter container as lfs user (4.3)
USER lfs
COPY [ "config/.bash_profile", "config/.bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# Fire away
ENTRYPOINT [ "/tools/run-all.sh" ]
