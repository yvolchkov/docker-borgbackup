#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

if [ ! -f /root/ssh_host_keys/ssh_host_dsa_key ]; then
    ssh-keygen -A && mv /etc/ssh/ssh_host_* /root/ssh_host_keys/
fi

chown bkp:bkp /data/
/usr/sbin/sshd -D
