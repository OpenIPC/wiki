# OpenIPC Wiki
[Table of Content](../README.md)

Wi-Fi for XM530 based devices
-----------------------------

This page is for the first-generation XM530 and XM550 (`ipcinfo -c` says
`xm530` or `xm550`; the image is `xm530_lite`). XM530V200, XM533 and XM535
boards use a different image and their own profiles in `/etc/wireless/usb`.

The Wi-Fi on these boards is a USB module behind the SoC's USB host
(`dwc_otg`), powered through a GPIO by `wifi_pdn`. Find out which chip
yours is before following anything below. With the module powered, the
USB ID tells you:

```sh
insmod /lib/modules/3.10.103+/xiongmai/dwc_common_port_lib.ko
insmod /lib/modules/3.10.103+/xiongmai/dwc_otg.ko
insmod /lib/modules/3.10.103+/xiongmai/wifi_pdn.ko value=96
sleep 3
cat /sys/bus/usb/devices/*/idVendor /sys/bus/usb/devices/*/idProduct
```

`value=` is the power GPIO. 96 is what the boards seen so far use; the
factory firmware's own `wifi_pdn` line shows yours.

### XM711

The `xm530_lite` image ships everything this module needs: the vendor
driver (`xm711.ko`, `compat.ko`), the vendor's backported `cfg80211.ko`
at `/lib/modules/3.10.103+/kernel/net/wireless/`, and the script that
loads them in order, `/usr/bin/wifi`. Nothing has to be copied from the
factory firmware.

```sh
wifi xm711
```

Do not load `mac80211.ko` as well. The XM711 driver does not use it, and
the kernel's `mac80211` cannot load against the backported `cfg80211`:
it fails with `Unknown symbol __cfg80211_send_disassoc`,
`cfg80211_send_rx_auth` and so on. Earlier versions of this page loaded
it.

Then, in `/etc/network/interfaces`:

```
auto eth2
iface eth2 inet dhcp
    pre-up wifi xm711
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up (sleep 3; wpa_supplicant -B -Dnl80211 -ieth2 -c/tmp/wpa_supplicant.conf)
    post-down killall -q wpa_supplicant
```

### AltoBeam ATBM6032 (`007a:8888`, sold as XM713G)

None of the above applies: this is a different chip, and `xm711.ko`
does not drive it. The stock `xm530_lite` image has no driver for it and
no profile in `/etc/wireless/usb`, so setting `wlandev` to a module name
such as `atbm603x_wifi_usb` loads nothing (`wlandev` takes a profile
name).

The factory `xm713g.ko` is built against the stock kernel's `cfg80211`
with wireless extensions (`CONFIG_CFG80211_WEXT`), which is why it also
needs the factory `cfg80211.ko`. OpenIPC does not ship either.

Support with OpenIPC's own driver is in progress:
[OpenIPC/firmware#2316](https://github.com/OpenIPC/firmware/pull/2316)
adds the `atbm603x-xm530` profile (USB host, then `wifi_pdn` from the
`wifipdn` variable, then the driver), and
[OpenIPC/builder#130](https://github.com/OpenIPC/builder/pull/130) is a
device image that sets it up. Builds made before
[OpenIPC/firmware#2854](https://github.com/OpenIPC/firmware/pull/2854)
could not load that driver at all: its build left it out of `modules.dep`.
See [OpenIPC/firmware#2853](https://github.com/OpenIPC/firmware/issues/2853)
for a board with this chip.
