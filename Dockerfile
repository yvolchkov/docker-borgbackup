# SPDX-License-Identifier: GPL-3.0-or-later

FROM alpine:latest as builder
MAINTAINER yvolchkov
ARG BORGMATIC_VERSION=1.2.15
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    alpine-sdk \
    python3-dev \
    openssl-dev \
    lz4-dev \
    acl-dev \
    linux-headers \
    attr-dev \
    && pip3 install --upgrade pip \
    && pip3 install --upgrade borgbackup

FROM alpine

RUN apk --no-cache add openssh python3 openssl libacl lz4-libs tini && \
    adduser -D bkp && passwd -d bkp
COPY --from=builder /usr/lib/python3.6/site-packages /usr/lib/python3.6/
COPY --from=builder /usr/bin/borg /usr/bin/
COPY --from=builder /usr/bin/borgfs /usr/bin/

RUN sed -i -e 's/#\?.PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
    sed -i -e 's/#\?.PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config && \
    sed -i -e 's/#\?.PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config && \
    sed -i -e 's/#\?HostKey \/etc\/ssh/HostKey \/root\/ssh_host_keys/g' /etc/ssh/sshd_config

copy entry.sh /root/entry.sh
copy --chown=bkp:bkp authorized_keys /home/bkp/.ssh/authorized_keys
ENTRYPOINT ["/sbin/tini",  "--", "/root/entry.sh"]
