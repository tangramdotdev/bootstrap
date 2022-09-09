#!/bin/sh
#! This script builds a fully static Perl in a Alpine Docker container
# docker run -it --platform linux/arm64/v8 --name "aarch64-bootstrap-alpine" -v "$PWD":/bootstrap alpine /bin/bash /bootstrap/build_linux_static_perl.sh

NPROC=$(nproc)
ARCH=$(uname -m)
TOP="/bootstrap/$ARCH"
SOURCES="/bootstrap/sources"
BUILDS="$TOP/builds"
ROOTFS="$TOP/rootfs"

apk add alpine-sdk nano perl perl-utils

# copy stuff
cp -r /usr/bin/perl* $ROOTFS/bin
cp -r /usr/lib/perl* $ROOTFS/lib
cp -r /usr/share/perl* $ROOTFS/share

# wrap stuff
cd $ROOTFS/bin
mv perl .perl_unwrapped
cat > ./perl << EOF
#!/bin/sh
DIR=\$(cd -- "\${0%/*}" && pwd)
LIB_DIR=\${DIR}/../toolchain/lib
PERL5_LIB_DIR=\${DIR}/lib/perl5/core_perl/CORE
INTERPRETER=\${LIB_DIR}/ld-musl-$ARCH.so.1
\${INTERPRETER} --preload \${LIB_DIR}/libc.so --preload \${PERL5_LIB_DIR}/libperl.so -- \${DIR}/.perl_unwrapped "\$@"
EOF
chmod +x perl
cd -


# cpan -I App::Staticperl

# PERL_VER="perl-5.36.0"
# PERL_PKG="$PERL_PKG.tar.gz"
# PERL_URL="https://www.cpan.org/src/5.0/$PERL_PKG"
# preparePerl() {
#     fetchSource "$PERL_URL" "$PERL_PKG"
#     unpackSource "$PERL_PKG"
#     export EMAIL="root@tangram.dev"
#     export PERL_CC="cc"
#     export PERL_CCFLAGS="-fPIC"
#     export PERL_OPTIMIZE="-Os"
#     export PERL_LD_FLAGS="-static"
#     export PERL_LIBS="-lm -lcrypt"
#     export PERL_CONFIGURE=""
#     cd "$BUILDS"/"$PERL_VER"
#     rm -f config.sh Policy.sh
#    sh Configure -des
#                 -A ccflags="$PERL_CCFLAGS" \
#                 -Dcc="$PERL_CC" \
#                 -Doptimize="$PERL_OPTIMIZE" \
#                 -Uldflags="$PERL_LDFLAGS" \
#                 -Dlibs="$PERL_LIBS" \
#                 -Dprefix="$ROOTFS" \
#                 -Dbin="$ROOTFS/bin" \
#                 -Dprivlib="$ROOTFS/lib" \
#                 -Darchlib="$ROOTFS/lib" \
#                 -Uusevendorprefix \
#                 -Dsitelib="$ROOTFS/lib" \
#                 -Dsitearch="$ROOTFS/lib" \
#                 -Uman1dir \
#                 -Uman3dir \
#                 -Usiteman1dir \
#                 -Usiteman3dir \
#                 -Dpager=/usr/bin/less \
#                 -Demail="$EMAIL" \
#                 -Dcf_email="$EMAIL" \
#                 -Dcf_by="$EMAIL" \
#         make libperl.so && make
#     cd -
# }

# # staticperl
# # FIXME - find a stable URL
# STATICPERL_URL="http://cvs.schmorp.de/App-Staticperl/bin/staticperl" 
# preparePerl() {
#     cpan -I App::Staticperl
#     cat << EOF > ./staticperlrc
# DLCACHE="$SOURCES"
# EMAIL="root@tangram.dev"
# CPAN="ftp://mirror.cogentco.com/pub/CPAN/"
# EOF
#     cat << EOF > ./big.bundle
# static
# usepacklists
# strip ppi
# incglob *
# exclude /Devel/**
# exclude /ExtUtils/**
# exclude /Encode/??.*
# exclude /Encode/??/**
# exclude /PPI.pm
# exclude /PPI/**
# exclude /CPAN**
# exclude /Compress**
# exclude /TAP**
# exclude /Test/**
# exclude /Module/Build**
# exclude /Module/CoreList.pm
# exclude /unicore/Name.pl
# exclude /unicore/To/NFKCCF.pl
# exclude /unicore/Decomposition.pl
# EOF
#     cat > ./tiny.bundle <<EOF
# static
# strip ppi
# use utf8
# use POSIX
# use Socket
# EOF
#     cat > ./small.bundle <<EOF
# static
# strip ppi

# use utf8
# use Config
# use Errno
# use Fcntl
# use POSIX
# use Socket
# use Encode
# use Digest::MD5
# #use Encode::Byte
# use Encode::Unicode
# use Scalar::Util
# use Benchmark

# use Data::Dump

# use EV
# use EV::Loop::Async
# use Crypt::Twofish2
# use Array::Heap
# use Convert::Scalar
# use Compress::LZF
# use JSON::XS
# use Linux::Inotify2
# use common::sense
# use Guard
# use Async::Interrupt
# use AnyEvent
# use AnyEvent::AIO
# use AnyEvent::DNS
# use AnyEvent::Debug
# use AnyEvent::HTTP
# use AnyEvent::Handle
# use AnyEvent::Impl::EV
# use AnyEvent::Impl::Perl
# use AnyEvent::Socket
# use AnyEvent::Util
# use IO::AIO
# use List::Util
# use Coro
# use Coro::AIO
# use Coro::AnyEvent
# use Coro::Channel
# use Coro::Debug
# use Coro::EV
# use Coro::Handle
# use Coro::RWLock
# use Coro::Select
# use Coro::Semaphore
# use Coro::SemaphoreSet
# use Coro::Signal
# use Coro::Socket
# use Coro::Specific
# use Coro::State
# use Coro::Storable
# use Coro::Timer
# use Coro::Util

# use AnyEvent::HTTPD
# use URI::_generic
# use URI::http
# EOF
#     export STATICPERLRC="$BUILDS"/staticperl/staticperlrc
#     ./staticperl install
#     ./staticperl mkperl big.bundle
#     cd -
#     # cd "$BUILDS"
#     # wget "$BIGPERL_URL"
#     # chmod u+x bigperl.bin
# }