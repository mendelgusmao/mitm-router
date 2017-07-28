# Man-in-the-middle Router

Work-in-progress hard-fork of [simonschuang/rpi-hostapd](https://github.com/simonschuang/rpi-hostapd) that turns it into a public wifi network that mitms all traffic to the router on port `80`.

```
# build the image
docker build . -t brannondorsey/mitm-router
```

```
# run the container
docker run -it --rm --net host --privileged brannondorsey/mitm-router bash

# launch the access point, for some reason hostapd doesn't come
# up correctly if this is run from the Dockerfile, so we run manually
root@host:/# /entrypoint.sh
```

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
