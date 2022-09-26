#!/bin/bash
set -euo pipefail
log "Creating essential files and symlinks..."

BUILD_LOGFILE=$LOGDIR/7.6-create-essential-files.log

# /etc/mtab
ln -sv /proc/self/mounts /etc/mtab | tee -a "$BUILD_LOGFILE"
log "Creating /etc/hosts"
cat >/etc/hosts <<EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF
log "Creating /etc/passwd"
cat >/etc/passwd <<"EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF
log "Creating /etc/group"
cat >/etc/group <<"EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF
# Temporary user for testing in ch8
log "Creating temporary non-root testing user."
echo "tester:x:101:101::/home/tester:/bin/bash" | tee -a /etc/passwd "$BUILD_LOGFILE"
echo "tester:x:101:" | tee -a /etc/group "$BUILD_LOGFILE"
install -o tester -d /home/tester | tee -a "$BUILD_LOGFILE"
# This would remove the "I have no name!" prompt during ch7, but we don't care.
# exec /usr/bin/bash --login
# Set up log files
log "Creating log files."
touch /var/log/{btmp,lastlog,faillog,wtmp} | tee -a "$BUILD_LOGFILE"
chgrp -v utmp /var/log/lastlog | tee -a "$BUILD_LOGFILE"
chmod -v 664 /var/log/lastlog | tee -a "$BUILD_LOGFILE"
chmod -v 600 /var/log/btmp | tee -a "$BUILD_LOGFILE"
