# Troubleshooting

There are a variety of things that can go wrong with this setup setup. Google around for solutions, and if you can't find anything please create an issue, specifying 

## Hostapd Failed to Launch

```
[FAIL] Starting advanced IEEE 802.11 management: hostapd failed!
```

If you find yourself seeing the above error when you run the docker container, login to your running container and launch `hostapd` manually to get a more descriptive error.

```bash
# get the name of your container
docker ps

# attach to the container
docker exec -it <CONTAINER_NAME> bash

# run hostapd manually
hostapd /etc/hostapd/hostapd.conf
```

Google around for an answer to whatever you see there.

### nl80211: Could not configure driver mode

I've encountered a driver error like this multiple times on different machines:

```
Configuration file: /etc/hostapd/hostapd.conf
nl80211: Could not configure driver mode
nl80211 driver initialization failed.
hostapd_free_hapd_data: Interface wlan0 wasn't started
```

If this is the case, and you are running this from an Ubuntu host machine, here is a solution. You need to tell the NetworkManager to leave your `AP_IFACE` unmanaged. Edit the `NetworkManager.con` file on your host machine with:

```
sudo nano /etc/NetworkManager/NetworkManager.conf
```
And add the following lines, substituting the MAC address of your Wi-Fi card.

```
[keyfile]
unmanaged-devices=mac:00:d0:8a:a0:e9:bd
```

Now restart the network manager so that the changes to effect:

```
sudo service NetworkManager restart
```

Re-run hostapd manually to see if it worked:

```bash
hostapd /etc/hostapd/hostapd.conf 
```

```
Configuration file: /etc/hostapd/hostapd.conf
Using interface wlxc4e984d7a5d2 with hwaddr 00:d0:8a:a0:e9:bd and ssid "Public"
wlxc4e984d7a5d2: interface state UNINITIALIZED->ENABLED
wlxc4e984d7a5d2: AP-ENABLED
```

You must now be sure to specify that `mitm-router` does *not* randomize the MAC address you've whitelisted. When running the docker container, use the `-e MAC="unchanged"` to disable MAC randomization. If you would still like the effects of MAC spoofing, set the value of `unmanaged-devices` in `NetworkManager.conf` to a MAC of your choice, and pass this MAC in the docker `run` command explicitly with `-e MAC="XX:XX:XX:XX:XX:XX"`. 

On certain machines, I've had issues getting hostapd to work with spoofed MAC addresses at all. So for a surefire (albeit sketchy) method, don't spoof the MAC of you `AP_IFACE`.

## Dnsmasq Failed to Launch

Login to the docker container using the same instructions from the [Hostapd Failed to Launch](#hostapd-failed-to-launch) section. Once inside the container, run `dnsmasq` as a non-daemon process to get an error message.

```
dnsmasq --no-daemon
```

### dnsmasq: failed to create listening socket for 10.0.0.1: Cannot assign requested address

This error occurs when the `$AP_IFACE` wireless interface hasn't been assigned a static IP address. The IP address `10.0.0.1` should be assigned to the wireless interface in `entrypoint.sh`, however, due to certain circumstances I've experienced this to occasionally fail. You can set the static IP address manually with:

```
# assumes AP_IFACE is already set (e.g. AP_IFACE=wlan0
ifconfig $AP_IFACE up 10.0.0.1 netmask 255.255.255.0

# check to make sure the IP address was correctly assigned
ifconfig
```

Once the interface IP address has been assigned, relaunch the `dnsmasq` process manually to make sure that it worked correctly. The wireless interface's IP should remain assigned until the device is unplugged.
