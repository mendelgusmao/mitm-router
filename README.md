# ☠ Man-in-the-middle Router 🌐

Turn any linux computer into a public Wi-Fi network that silently mitms all http traffic. Runs inside a Docker container using [hostapd](https://wiki.gentoo.org/wiki/Hostapd), [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html), and [mitmproxy](https://mitmproxy.org/) to create a open honeypot wireless network named "Public".

```
# clone the repo
git clone https://github.com/brannondorsey/mitm-router
cd mitm-router

# build the image this step can be omitted if you prefer to pull 
# the image from the docker hub repository
docker build . -t brannondorsey/mitm-router
```

```bash
# run the container
docker run -it --net host --privileged \
-e AP_IFACE="wlan0" \
-e INTERNET_IFACE="eth0" \
-e SSID="Public" \
-v "$(pwd)/data:/root/data" \
brannondorsey/mitm-router
```

We share the `mitm-router/data/` folder with the docker container so that we can view the capture files that it places there with on our host machine. By default, you will find the `mitmdump` capture file in `mitm-router/data/http-traffic.cap`.

`mitm-router` transparently captures all `HTTP` traffic sent to the router at `10.0.0.1:80`. It does **not** intercept HTTPS traffic (port `443`) as doing so would alert a user that a possible man-in-the-middle attack was taking place. Traffic between URLs that begin with `https://` will not be captured. 

## MAC Randomization

By default, `mitm-router` randomizes the MAC address of your `AP_IFACE` to anonymize your network device. This can be disabled with the `MAC="unchanged"` environment variable. You can also explicitly set the `AP_IFACE` MAC address with `MAC="XX:XX:XX:XX:XX:XX"`.  

## Configuring

Supported environment variables are listed below with their default values:

```bash
# wireless device name that will be used for the Access Point
AP_IFACE="wlan0"

# device name that is used for the router's internal internet connection
# packets from AP_IFACE will be forwarded to this device
INTERNET_IFACE="eth0"

# wireless network name
SSID="Public"

# optional WPA2 password; if left empty network will be public
PASSWORD=""

# optional randomization of AP_IFACE MAC address
# can be set to a specific value like "XX:XX:XX:XX:XX:XX"
# or "unchanged" to leave the device MAC alone
MAC="random"

# tcpdump output file location inside the container
CAPTURE_FILE="/root/data/http-traffic.cap"

# optional mitmproxy filter
# see http://docs.mitmproxy.org/en/stable/features/filters.html
FILTER=""
```

## Troubleshooting

See the [troubleshooting](troubleshooting.md) page for more info.

## Security

This access point runs inside of Docker for isolation, ensuring that any vulnerabilities that may be exploitable in the access point will not allow an adversary access to your computer or home network. That said, there are a few caveats to be aware of:

- `--net host` shares all of the network interfaces and `iptables` entries from the host machine with the docker container. Assume that a vulnerable docker container would have root access to these devices.
- Running in `--privileged` mode gives extended permissions to the docker container
- Your host machine (the one running docker) **will** be accessible on the "Public" network as a connected client. For this reason, please use a firewall (`ufw` on linux) to block incoming traffic on all ports so that computers on the "Public" network do not have access to exposed services your machine.
- All traffic on the honeypot network will be outbound from you home network's gateway. If someone on the "Public" network is torrenting or conducting illegal activity you will be held accountable and your ISP may cancel your service. <!--For this reason, I recommend you run a [VPN](https://airvpn.org/) on the host linux machine (the one that is running docker) to protect yourself. Doing so will cause all traffic from the host machine, and in turn the honeypot network, to be tunneled through the VPN. Also, be sure to pick a VPN that doesn't log your traffic ;)-->

For added security, I prefer to run this docker container on a dedicated computer, like a Raspberry Pi.

## Attribution

This code started as a hard fork of [simonschuang's rpi-hostapd](https://github.com/simonschuang/rpi-hostapd). The code has been heavily modified for mitm purposes.
