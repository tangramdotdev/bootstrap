FROM alpine:3.23.3
RUN apk update && apk add \
    alpine-sdk autoconf automake bash binutils binutils-gold bison build-base \
    clang file flex gawk gcc gcompat gettext git glib-dev grep help2man \
    indent m4 libbz2 libgcc libtool linux-headers ncurses \
    ncurses-dev ninja openssl-dev pkgconf python3 wget xz zlib-dev zlib-static
RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN wget -qO /tmp/rustup.sh https://sh.rustup.rs && \
    sh /tmp/rustup.sh -y --default-toolchain stable && \
    rm /tmp/rustup.sh
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl
