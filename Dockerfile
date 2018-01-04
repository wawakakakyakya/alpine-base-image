FROM alpine:edge
MAINTAINER wawakakakyakya@yahoo.co.jp

USER root

# update package
RUN echo -e "http://dl-4.alpinelinux.org/alpine/v3.5/community\nhttp://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
# echo "http://alpine.gliderlabs.com/alpine/edge/main"
RUN apk update
RUN apk upgrade
RUN apk --no-cache add --virtual=bash-dependencies bash bash-doc bash-completion
RUN apk --no-cache add vim net-tools

# https://blog.adachin.me/wordpress/archives/4177
# https://github.com/gliderlabs/docker-alpine/issues/183
# Install openrc, openrc is service manager.

RUN apk add openrc \
# Tell openrc its running inside a container, till now that has meant LXC
    && sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf \
# Tell openrc loopback and net are already there, since docker handles the networking
    && echo 'rc_provide="loopback net"' >> /etc/rc.conf \
# no need for loggers
    && sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf \
# can't get ttys unless you run the container in privileged mode
    && sed -i '/tty/d' /etc/inittab \
# can't set hostname since docker sets it
    && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
# can't mount tmpfs since not privileged
    && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh \
# can't do cgroups
    && sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
    && rc-status \
    && touch /run/openrc/softlevel

# clean apk cache
RUN rm -rf /var/cache/apk/*

# change login shell
# Todo: It does not work
RUN sed -e 's/ash/bash/' /etc/passwd

# change TimeZone JST
RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata

# set environment
ENV LANG="ja_JP.UTF-8"
