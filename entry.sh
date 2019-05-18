#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

if [ ! -f /root/ssh_host_keys/ssh_host_dsa_key ]; then
    ssh-keygen -A && mv /etc/ssh/ssh_host_* /root/ssh_host_keys/
fi

for i in $__USERS_LIST; do
    echo "$i" | \
	awk -F: '{printf "Adding user %s (uid=%d)\n",$1,$2; \
		system("adduser -D " $1 " -u " $2 " && \
		passwd -d " $1)}' -;
done

/usr/sbin/sshd -D
