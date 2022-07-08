# OpenIPC Wiki
[Table of Content](../index.md)

Wi-Fi for XM530 based devices
-----------------------------

Save this script as `/usr/sbin/wifi`

```
#!/bin/sh

WIFI=$1

if [ "$WIFI" = "xm711" ]; then
    insmod /lib/modules/3.10.103+/xiongmai/dwc_common_port_lib.ko
    insmod /lib/modules/3.10.103+/xiongmai/dwc_otg.ko
    insmod /lib/modules/3.10.103+/xiongmai/wifi_pdn.ko value=96
    insmod /lib/modules/3.10.103+/xiongmai/compat.ko
    insmod /lib/modules/3.10.103+/kernel/net/wireless/cfg80211.ko  # grab from original firmware
    insmod /lib/modules/3.10.103+/kernel/net/mac80211/mac80211.ko
    insmod /lib/modules/3.10.103+/xiongmai/xm711.ko
fi
```

Save these settings to `/etc/network/interfaces`

```
auto eth2
iface eth2 inet dhcp
    pre-up wifi xm711
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up (sleep 3; wpa_supplicant -B -Dnl80211 -ieth2 -c/tmp/wpa_supplicant.conf)
    post-down killall -q wpa_supplicant
```
