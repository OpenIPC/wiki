# OpenIPC Wiki
[Table of Content](../README.md)

Wireless settings
---

### Initial configuration

- The wireless settings are provided based on a uboot variable:

```diff
# HI3516EV300 CamHi
+if [ "$1" = "mt7601u-hi3516ev300-camhi" ]; then
	devmem 0x100C0080 32 0x530
```

> [!IMPORTANT]  
> Some drivers are not included in the premade OpenIPC firmware binaries, You may have to compile it yourself.

- The variables [are listed here][1] and be can set with:
```shell
fw_setenv wlandev mt7601u-hi3516ev300-camhi
```

### Enter wireless credentials

- Credentials can be added with:

```shell
fw_setenv wlanssid MySSID
fw_setenv wlanpass MyPassword
```

---

### Adopt custom settings

- It is possible to convert [existing wlan0 settings](../en/network-settings.md) to the [new configuration][1]:

```diff
auto wlan0
iface wlan0 inet dhcp
+	pre-up devmem 0x100C0080 32 0x530
+	pre-up echo 7 > /sys/class/gpio/export
+	pre-up echo out > /sys/class/gpio/gpio7/direction
+	pre-up echo 0 > /sys/class/gpio/gpio7/value
+	pre-up modprobe mt7601u
	pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
	pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
	pre-up sleep 3
	pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
	post-down killall -q wpa_supplicant
	post-down echo 1 > /sys/class/gpio/gpio7/value
	post-down echo 7 > /sys/class/gpio/unexport
```

```diff
# HI3516EV300 CamHi
if [ "$1" = "mt7601u-hi3516ev300-camhi" ]; then
+	devmem 0x100C0080 32 0x530
+	set_gpio 7 0
+	modprobe mt7601u
	exit 0
fi
```

[1]: https://github.com/OpenIPC/firmware/blob/master/general/overlay/etc/wireless
