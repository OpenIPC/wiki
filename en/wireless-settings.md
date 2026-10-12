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

### Or show the camera a QR code

Firmware that includes the QR scanner (the `quirc-openipc` package) looks for a code
after boot on any camera with `wlandev` set: 30 attempts, one snapshot each, so at
least half a minute and longer on slower cameras. Two kinds of code work:

- the one [OpenIPC's generator](https://openipc.org/tools/qr-code-generator) makes,
  which holds two lines, `wlanssid=...` and `wlanpass=...`;
- the one a phone shows when it shares its Wi-Fi network (`WIFI:S:...;P:...;;`).

Spaces and non-Latin characters in the network name or password are fine.

The camera joins the network before it saves anything, and reports what happened by
clicking its IR-cut filter, which you hear as short buzzing tunes:

| you hear | meaning |
|---|---|
| two quick rising notes | the code was read |
| a rising four-note run | joined and got an address; the settings are saved and the camera reboots |
| three low buzzes | the network refused the password |
| high-low, twice | no network by that name answered |
| a long tone, then a low one | joined, but nothing handed out an address |
| one low blip | that code is not a Wi-Fi code |
| three falling notes | no code was seen; scanning has stopped (power-cycle to try again) |

After a failed attempt (wrong password, no such network, no address, or a code that is
not a Wi-Fi one) the camera reconnects to any network it already had and keeps looking,
so you can fix the code on your phone and show it again. It tries the same code a
second time only after 15 seconds. After the three falling notes it has stopped looking;
power-cycle it to scan again.

These sounds come with firmware built after
[OpenIPC/firmware#2496](https://github.com/OpenIPC/firmware/pull/2496). Older firmware
saves whatever code it reads and reboots, with no sound unless the camera has a
speaker.

### Cable and Wi-Fi together

On a camera with an Ethernet port, setting up Wi-Fi does not take the cable away.
With `wlandev` set and a network saved in `wlanssid`, both come up and the cable is
preferred:

- The cable gets an address by DHCP whenever it is plugged in. Wi-Fi joins too, with
  its routes ranked behind the cable's, so traffic and DNS go over the cable.
- Pull the cable and traffic moves to Wi-Fi within a few seconds (about 4 s on a
  Hi3516EV300). Plug it back in and traffic moves back to the cable with nothing lost.
- A camera that boots with no cable runs on Wi-Fi alone, with no wait. Plugging a
  cable in later works the same as at boot.
- Plugged straight into a laptop with no DHCP server, the cable falls back to
  `netaddr_fallback` (192.168.2.10 unless you set another).
- With `wlandev` set but no network saved yet, the cable has DHCP, and the camera
  waits for a [QR code](#or-show-the-camera-a-qr-code).

To keep the older layout, where Wi-Fi is the only network path and the cable stays on
a fixed service address, set:

```shell
fw_setenv netmode wifi
```

Each interface's route priority can be changed with a `metric N` line in its stanza
under `/etc/network/interfaces.d/`. The lower the metric, the more preferred the
interface.

Two things it does not do yet. It switches when the cable's *link* goes, not when the
cable is still connected but the network behind it stops working. And while the cable
is up, the camera's Wi-Fi address answers reliably only from the Wi-Fi network itself.

This needs firmware built after
[OpenIPC/firmware#2573](https://github.com/OpenIPC/firmware/pull/2573). Older
firmware puts the cable on the static `netaddr_fallback` address as soon as a Wi-Fi
network is saved, and leaves it there.

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
