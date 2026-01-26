FROM alpine:3.23.2
RUN apk update && apk add \
    alpine-sdk autoconf automake bash binutils bison build-base \
    file flex gawk gcc gcompat gettext-tiny git grep help2man \
    indent m4 libbz2 libgcc libtool linux-headers ncurses \
    ncurses-dev openssl-dev python3 wget xz zlib-dev zlib-static
