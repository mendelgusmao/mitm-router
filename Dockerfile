FROM debian:jessie

MAINTAINER Brannon Dorsey "brannon@brannondorsey.com"

RUN apt-get update --fix-missing && apt-get install -y \
    hostapd \
    dbus \
    net-tools \
    iptables \
    dnsmasq \
    net-tools \
    tmux \
    macchanger

# mitmproxy requires this env
ENV LANG en_US.UTF-8 

ADD mitmproxy/* /bin/
ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

ADD entrypoint.sh /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
