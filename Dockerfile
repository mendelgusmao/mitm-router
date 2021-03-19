FROM debian:buster
# replace ^ with below for raspberry pi
#FROM resin/rpi-raspbian:jessie

LABEL maintainer="brannon@brannondorsey.com"
LABEL license="MIT"

RUN apt-get update && \
    apt-get install --no-install-recommends -yy \
	cargo \
	dbus \
	dnsmasq \
	hostapd \
	iptables \
	libffi-dev \
	libssl-dev \
	macchanger \
	net-tools \
	python3-dev \
	python3-pip \
	python3-setuptools

RUN pip3 install mitmproxy

# mitmproxy requires this env
ENV LANG en_US.UTF-8

ADD hostapd.conf /etc/hostapd/hostapd.conf
ADD hostapd /etc/default/hostapd
ADD dnsmasq.conf /etc/dnsmasq.conf

ADD entrypoint.sh /root/entrypoint.sh
WORKDIR /root
ENTRYPOINT ["/root/entrypoint.sh"]
