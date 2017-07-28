#!/bin/bash

AP_IFACE=wlx8416f9091905
INTERNET_IFACE=enp0s31f6

# SIGTERM-handler
term_handler() {
  echo "Get SIGTERM"
  iptables -t nat -D POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
  /etc/init.d/dnsmasq stop
  /etc/init.d/hostapd stop
  /etc/init.d/dbus stop

  # remove iptable entries
  iptables -t nat -D POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
  iptables -t nat -D POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
  iptables -D FORWARD -i "$AP_IFACE" -o "$INTERNET_IFACE" ACCEPT

  kill -TERM "$CHILD" 2> /dev/null
}

ifconfig "$AP_IFACE" 10.0.0.1/24

if [ -z "$SSID" -a -z "$PASSWORD" ]; then
  SSID="Public"
  PASSWORD="raspberry"
fi

sed -i "s/ssid=.*/ssid=$SSID/g" /etc/hostapd/hostapd.conf
sed -i "s/wpa_passphrase=.*/wpa_passphrase=$PASSWORD/g" /etc/hostapd/hostapd.conf
sed -i "s/interface=.*/interface=$AP_IFACE/g" /etc/hostapd/hostapd.conf
sed -i "s/interface=.*/interface=$AP_IFACE/g" /etc/dnsmasq.conf

/etc/init.d/dbus start
/etc/init.d/dnsmasq start
/etc/init.d/hostapd start

echo 1 > /proc/sys/net/ipv4/ip_forward

# iptables entries to setup AP network
# -C checks if rule exists, -A adds, and -D deletes
iptables -t nat -C POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
if [ ! $? -eq 0 ] ; then
    iptables -t nat -A POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
fi
iptables -t nat -C POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
if [ ! $? -eq 0 ] ; then
    iptables -t nat -A POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
fi
iptables -C FORWARD -i "$AP_IFACE" -o "$INTERNET_IFACE" -j ACCEPT
if [ ! $? -eq 0 ] ; then
    iptables -A FORWARD -i "$AP_IFACE" -o "$INTERNET_IFACE" -j ACCEPT
fi

# iptables rule to forward all traffic on router port 80 to 1337
# where mitmproxy will be listening for it
iptables -t nat -C PREROUTING -i "$AP_IFACE" -p tcp --dport 80 -j REDIRECT --to-port 1337
if [ ! $? -eq 0 ] ; then
  iptables -t nat -A PREROUTING -i "$AP_IFACE" -p tcp --dport 80 -j REDIRECT --to-port 1337
fi

# setup handlers
trap term_handler SIGTERM
trap term_handler SIGKILL

# wait forever
sleep infinity &
CHILD=$!
wait "$CHILD"
