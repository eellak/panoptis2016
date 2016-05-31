#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    printf "$(tput bold)$(tput setaf 3)[-]$(tput sgr0) Please run as root"
    exit
fi

#
# 1. Patch shellshock
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Patching bash for shellshock"
apt-get -y update &>/dev/null
apt-get install -y --only-upgrade bash &>/dev/null

#
# 2. Remove privilege escalation exploit binary
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Removing privilege escalation exploit binary (.test.txt)"
rm -f /home/lab/.test.txt

#
# 3. Deactivate and remove adore-ng rootkit
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) "
sed -i 's/ts_klp//' /etc/modules
rm -f /lib/modules/3.13.0-32-generic/kernel/lib/ts_klp.ko

#
# 4. Deactivate and remove reverse root shell
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Removing reverse root shell (dpkg, ufw)"
chattr -i /usr/bin/ufw /etc/cron.5min/dpkg
rm -f /usr/bin/ufw /etc/cron.5min/dpkg

printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Deactivating from profiles"
chattr -i /etc/profile /etc/skel/.profile
sed -i 's/\/usr\/bin\/ufw &//' /home/lab/.bashrc
sed -i 's/\/usr\/bin\/ufw &//' /etc/profile
sed -i 's/\/usr\/bin\/ufw &//' /etc/skel/.profile

#
# 5. Disable password-less root login
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Disabling password-less SSH root login"
sed -i 's/PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config
/etc/init.d/ssh stop &>/dev/null
/etc/init.d/ssh start &>/dev/null

#
# 6. Deactivate and remove trixd00r backdoor
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Removing trixd00r backdoor"
rm -f /usr/bin/sshd
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Removing from rc.local"
sed -i 's/\/usr\/bin\/sshd -i eth0 -d//' /etc/rc.local

#
# 7. Remove attacked added user `user`
#
printf "$(tput bold)$(tput setaf 3)[+]$(tput sgr0) Removing attacker account ('user')"
userdel user

#
# Suggest password change for all users
#
printf "$(tput bold)$(tput setaf 1)[+]$(tput sgr0) CHANGE ALL PASSWORDS..."
