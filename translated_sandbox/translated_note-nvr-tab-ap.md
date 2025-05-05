## Connecting the tablet to the recorder via wifi through the tablet's AP

The scheme is simple: a [TL-725n](https://www.tp-link.com/ru/home-networking/adapter/tl-wn725n/) or a similar adapter on rtp8188eu, or an adapter for
which is the driver in the OpenIPC firmware; the tablet turns on the access point; the recorder connects to this access point; when restarting, the wfb service detects the specified wlan and
Sets up broadcasting and telemetry on the tablet.

### Let's raise the network
* Download the driver [8188eu](hi3536dv100/lib/modules/4.9.37/extra/8188eu.ko) to `/lib/modules/4.9.37/extra/`
* Let's set up network raising on the adapter in [`/etc/network/interfaces`](hi3536dv100/etc/network/interfaces), specifying your ssid and password:
```
      auto wlan1
      iface wlan1 inet dhcp
          pre-up if ! lsmod | grep 8188eu; then insmod /lib/modules/4.9.37/extra/8188eu.ko; fi
          pre-up sleep 1
          pre-up wpa_passphrase "ssid" "password" >/tmp/wpa_supplicant.conf
          pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
          pre-up sleep 3
          pre-up wpa_supplicant -B -D nl80211 -i wlan1 -c/tmp/wpa_supplicant.conf
          post-down killall wpa_supplicant
```
### We will correct the service configs
* Download updated [`/usr/bin/wifibroadcast`](hi3536dv100/usr/bin/wifibroadcast) and [`/usr/bin/telemetry`](hi3536dv100/usr/bin/telemetry) with connection detection in /usr/bin.
* Add a new line to [wfb.conf](hi3536dv100/etc/wfb.conf) with a parameter - the interface name for ap
```
tab_wlan=wlan1
```
* If we do not use sending a stream to a PC, we can comment out the `udp_addr` parameter, this will unload the registrar a little.
* Turn on the access point on the tablet and reboot the recorder, or press the button on the [front panel](nvr_gpio.md).