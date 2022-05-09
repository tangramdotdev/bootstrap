#!/bin/bash
# NOTE - you will see many "file format not recognized" errors.  Safe to ignore.

BUILD_LOGFILE=$LOGDIR/8.77-strip.sh

save_usrlib="$(cd /usr/lib || exit; ls ld-linux*)
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0
             libstdc++.so.6.0.29
             libitm.so.1.0.0
             libatomic.so.1.2.0"

cd /usr/lib || exit

for LIB in $save_usrlib; do
    objcopy --only-keep-debug "$LIB" "$LIB".dbg | tee -a "$BUILD_LOGFILE"
    cp "$LIB" /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
    strip --strip-unneeded /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
    objcopy --add-gnu-debuglink="$LIB".dbg /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
    install -vm755 /tmp/"$LIB" /usr/lib | tee -a "$BUILD_LOGFILE"
    rm -v /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
done

online_usrbin="bash find strip"
online_usrlib="libbfd-2.38.so
               libhistory.so.8.1
               libncursesw.so.6.3
               libm.so.6
               libreadline.so.8.1
               libz.so.1.2.12
               $(cd /usr/lib || exit; find libnss*.so* -type f)"

for BIN in $online_usrbin; do
    cp /usr/bin/"$BIN" /tmp/"$BIN" | tee -a "$BUILD_LOGFILE"
    strip --strip-unneeded /tmp/"$BIN" | tee -a "$BUILD_LOGFILE"
    install -vm755 /tmp/"$BIN" /usr/bin | tee -a "$BUILD_LOGFILE"
    rm -v /tmp/"$BIN" | tee -a "$BUILD_LOGFILE"
done

for LIB in $online_usrlib; do
    cp /usr/lib/"$LIB" /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
    strip --strip-unneeded /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
    install -vm755 /tmp/"$LIB" /usr/lib | tee -a "$BUILD_LOGFILE"
    rm -v /tmp/"$LIB" | tee -a "$BUILD_LOGFILE"
done

for i in $(find /usr/lib -type f -name "\*.so*" ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename "$i")* )
            ;;
        * ) strip --strip-unneeded "$i" | tee -a "$BUILD_LOGFILE"
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib
