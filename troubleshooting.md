Now startup mitmproxy:

```
# attach to the container
docker exec -it <CONTAINER_ID> bash

# add redirect rule 
iptables -t nat -A PREROUTING -i <AP_IFACE> -p tcp --dport 80 -j REDIRECT --to-port 1337

# and start mitmproxy
mitmproxy -T --host -p 1337
```

Reference: https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostapd/

## Troubleshooting

If hostapd fails to start:

```
[FAIL] Starting advanced IEEE 802.11 management: hostapd failed!
```

Get an error message by running hostapd manually:

```bash
$ hostapd /etc/hostapd/hostapd.conf 
Configuration file: /etc/hostapd/hostapd.conf
nl80211: Could not configure driver mode
nl80211 driver initialization failed.
hostapd_free_hapd_data: Interface wlan0 wasn't started
```

Then edit:

```
sudo nano /etc/NetworkManager/NetworkManager.conf
```

Adding...

```
[keyfile]
unmanaged-devices=mac:00:d0:8a:a0:e9:bd
```

Restart the network manager
```
sudo service NetworkManager restart
```

Re-run to see if it worked:

```
root@brannon:/# hostapd /etc/hostapd/hostapd.conf 
Configuration file: /etc/hostapd/hostapd.conf
Using interface wlxc4e984d7a5d2 with hwaddr 00:d0:8a:a0:e9:bd and ssid "Public"
wlxc4e984d7a5d2: interface state UNINITIALIZED->ENABLED
wlxc4e984d7a5d2: AP-ENABLED
```
