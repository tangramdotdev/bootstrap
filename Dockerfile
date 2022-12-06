# Run `. /envfile` upon entering.
FROM alpine:3.16.2
RUN apk update
RUN apk add alpine-sdk autoconf automake bash binutils bison build-base file flex gawk gcc gcompat gettext-tiny git grep indent m4 libbz2 libgcc libtool linux-headers ncurses ncurses-dev openssl-dev python3 wget xz zlib-dev zlib-static
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
COPY scripts/create_wrapper /create_wrapper
RUN source /root/.cargo/env && cd /create_wrapper && cargo install --path .
RUN echo 'export NPROC=$(nproc)' >> /envfile
RUN echo 'export ARCH=$(uname -m)' >> /envfile
RUN echo 'export VOLMOUNT=/bootstrap' >> /envfile
RUN echo 'export WORK=$VOLMOUNT/work' >> /envfile
RUN echo 'export TOP="$WORK/$ARCH"' >> /envfile
RUN echo 'export SCRIPTS=$VOLMOUNT/scripts' >> /envfile
RUN echo 'export SOURCES="$VOLMOUNT/sources"' >> /envfile
RUN echo 'export PATCHES=$VOLMOUNT/patches' >> /envfile
RUN echo 'export BUILDS="$TOP/builds"' >> /envfile
RUN echo 'export ROOTFS="$TOP/rootfs"' >> /envfile
RUN echo 'export PATH="$PATH:/root/.cargo/bin"' >> /envfile
CMD ["/bin/bash"]