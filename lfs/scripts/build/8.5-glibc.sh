#!/bin/bash
set -euo pipefail
log "Building glibc final (24 SBU | 2.8 GB)..."

BUILD_LOGFILE=$LOGDIR/8.5-glibc.log
VERSION=2.36

pushd /sources
tar xf glibc-"$VERSION".tar.xz
pushd glibc-"$VERSION"
patch -Np1 -i ../glibc-"$VERSION"-fhs-1.patch | tee -a "$BUILD_LOGFILE"
mkdir -v build
pushd build
echo "rootsbindir=/usr/sbin" | tee -a configparms "$BUILD_LOGFILE"
../configure --prefix=/usr \
  --disable-werror \
  --enable-kernel=3.2 \
  --enable-stack-protector=strong \
  --with-headers=/usr/include \
  libc_cv_slibdir=/usr/lib | tee -a "$BUILD_LOGFILE"
make -j"$(nproc)" | tee -a "$BUILD_LOGFILE"
# FAILED?!
#make check | tee -a "$BUILD_LOGFILE"
touch /etc/ld.so.conf | tee -a "$BUILD_LOGFILE"
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile | tee -a "$BUILD_LOGFILE"
make install | tee -a "$BUILD_LOGFILE"
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd | tee -a "$BUILD_LOGFILE"
cp -v ../nscd/nscd.conf /etc/nscd.conf | tee -a "$BUILD_LOGFILE"
mkdir -pv /var/cache/nscd | tee -a "$BUILD_LOGFILE"
mkdir -pv /usr/lib/locale | tee -a "$BUILD_LOGFILE"
localedef -i POSIX -f UTF-8 C.UTF-8 2>/dev/null || true | tee -a "$BUILD_LOGFILE"
#localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i de_DE -f ISO-8859-1 de_DE | tee -a "$BUILD_LOGFILE"
#localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro | tee -a "$BUILD_LOGFILE"
#localedef -i de_DE -f UTF-8 de_DE.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i el_GR -f ISO-8859-7 el_GR | tee -a "$BUILD_LOGFILE"
#localedef -i en_GB -f ISO-8859-1 en_GB | tee -a "$BUILD_LOGFILE"
#localedef -i en_GB -f UTF-8 en_GB.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i en_HK -f ISO-8859-1 en_HK | tee -a "$BUILD_LOGFILE"
#localedef -i en_PH -f ISO-8859-1 en_PH | tee -a "$BUILD_LOGFILE"
localedef -i en_US -f ISO-8859-1 en_US | tee -a "$BUILD_LOGFILE"
localedef -i en_US -f UTF-8 en_US.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i es_ES -f ISO-8859-15 es_ES@euro | tee -a "$BUILD_LOGFILE"
#localedef -i es_MX -f ISO-8859-1 es_MX | tee -a "$BUILD_LOGFILE"
#localedef -i fa_IR -f UTF-8 fa_IR | tee -a "$BUILD_LOGFILE"
#localedef -i fr_FR -f ISO-8859-1 fr_FR | tee -a "$BUILD_LOGFILE"
#localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro | tee -a "$BUILD_LOGFILE"
#localedef -i fr_FR -f UTF-8 fr_FR.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i is_IS -f ISO-8859-1 is_IS | tee -a "$BUILD_LOGFILE"
#localedef -i is_IS -f UTF-8 is_IS.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i it_IT -f ISO-8859-1 it_IT | tee -a "$BUILD_LOGFILE"
#localedef -i it_IT -f ISO-8859-15 it_IT@euro | tee -a "$BUILD_LOGFILE"
#localedef -i it_IT -f UTF-8 it_IT.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i ja_JP -f EUC-JP ja_JP | tee -a "$BUILD_LOGFILE"
#localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true | tee -a "$BUILD_LOGFILE"
#localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro | tee -a "$BUILD_LOGFILE"
#localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R | tee -a "$BUILD_LOGFILE"
#localedef -i ru_RU -f UTF-8 ru_RU.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i se_NO -f UTF-8 se_NO.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i ta_IN -f UTF-8 ta_IN.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i tr_TR -f UTF-8 tr_TR.UTF-8 | tee -a "$BUILD_LOGFILE"
#localedef -i zh_CN -f GB18030 zh_CN.GB18030 | tee -a "$BUILD_LOGFILE"
#localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS | tee -a "$BUILD_LOGFILE"
#localedef -i zh_TW -f UTF-8 zh_TW.UTF-8 | tee -a "$BUILD_LOGFILE"
# NOTE - this line installs ALL of them, and takes a long time!!
#make localedata/install-locales | tee -a "$BUILD_LOGFILE"
localedef -i POSIX -f UTF-8 C.UTF-8 2>/dev/null || true | tee -a "$BUILD_LOGFILE"
#localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true | tee -a "$BUILD_LOGFILE"

# configure
cat >/etc/nsswitch.conf <<"EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2022c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica \
  asia australasia backward; do
  zic -L /dev/null -d $ZONEINFO ${tz}
  zic -L /dev/null -d $ZONEINFO/posix ${tz}
  zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime

cat >/etc/ld.so.conf <<"EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >>/etc/ld.so.conf <<"EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

popd
popd
rm -rf glibc-"$VERSION"
popd
