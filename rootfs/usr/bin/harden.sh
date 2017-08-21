#!/bin/sh
set -x
set -e

# Remove existing crontabs, if any.
rm -fr /var/spool/cron
rm -fr /etc/crontabs
rm -fr /etc/periodic

# Remove all but a handful of admin commands.
find /sbin /usr/sbin ! -type d \
  -a ! -name sshd \
  -a ! -name nologin \
  -delete

sysdirs="
  /bin
  /etc
  /lib
  /sbin
  /usr
"

# Ensure system dirs are owned by root and not writable by anybody else.
find $sysdirs -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Remove unnecessary user accounts, including root.
sed -i -r '/^(bastion|sshd)/!d' /etc/group
sed -i -r '/^(bastion|sshd)/!d' /etc/passwd

# Remove apk configs.
find $sysdirs -xdev -regex '.*apk.*' -exec rm -fr {} +

# Remove crufty...
#   /etc/shadow-
#   /etc/passwd-
#   /etc/group-
find $sysdirs -xdev -type f -regex '.*-$' -exec rm -f {} +

# give read permission to ssh key files
chmod a+r /etc/ssh/ssh_*

# Remove all suid files.
find $sysdirs -xdev -type f \
  -a -perm +4000 \
  -delete

# Remove other programs that could be dangerous.
find $sysdirs -xdev \( \
  -name hexdump -o \
  -name chgrp -o \
  -name chmod -o \
  -name chown -o \
  -name ln -o \
  -name od -o \
  -name strings -o \
  -name su \
  \) -delete

# Remove init scripts since we do not use them.
rm -fr /etc/init.d
rm -fr /lib/rc
rm -fr /etc/conf.d
rm -fr /etc/inittab
rm -fr /etc/runlevels
rm -fr /etc/rc.conf

# Remove kernel tunables since we do not need them.
rm -fr /etc/sysctl*
rm -fr /etc/modprobe.d
rm -fr /etc/modules
rm -fr /etc/mdev.conf
rm -fr /etc/acpi

# Remove root homedir since we do not need it.
rm -fr /root

# Remove fstab since we do not need it.
rm -f /etc/fstab

# Remove broken symlinks (because we removed the targets above).
find $sysdirs -xdev -type l -exec test ! -e {} \; -delete

# Remove all but a handful of admin commands.
find /usr/bin /bin ! -type d \
  -a ! -name bash \
  -a ! -name ssh \
  -a ! -name dumb-init \
  -delete
