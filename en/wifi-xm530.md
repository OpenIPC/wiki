# OpenIPC Wiki
[Table of Content](../README.md)

Wi-Fi for XM530 based devices
-----------------------------

This page is for the first-generation XM530 and XM550 (`ipcinfo -c` says
`xm530` or `xm550`; the image is `xm530_lite`). XM530V200, XM533 and XM535
boards use a different image and their own profiles in `/etc/wireless/usb`.

The Wi-Fi on these boards is a USB module behind the SoC's USB host
(`dwc_otg`), powered through a GPIO by `wifi_pdn`. Find out which chip
yours is before following anything below.

First the power GPIO: it is `wifi_pdn`'s `value=`, and the factory
firmware's own `insmod wifi_pdn.ko value=…` line shows it for your board.
96 is what the boards seen so far use; put yours in place of `$PDN` if it
differs. With the module powered, its USB ID tells you the chip:

```sh
PDN=96
insmod /lib/modules/3.10.103+/xiongmai/dwc_common_port_lib.ko
insmod /lib/modules/3.10.103+/xiongmai/dwc_otg.ko
insmod /lib/modules/3.10.103+/xiongmai/wifi_pdn.ko value=$PDN
sleep 3
for d in /sys/bus/usb/devices/*; do
    [ -f "$d/idVendor" ] && echo "$(cat "$d/idVendor"):$(cat "$d/idProduct")"
done
```

`1d6b:0002` is the USB host itself; the other line is the Wi-Fi module.
No second line means the module is not powered: check `$PDN`.

### XM711

The `xm530_lite` image ships everything this module needs: the vendor
driver (`xm711.ko`, `compat.ko`), the vendor's backported `cfg80211.ko`
at `/usr/lib/xiongmai/cfg80211.ko` (in
`/lib/modules/3.10.103+/kernel/net/wireless/` on images built before
firmware#2316), and the script that
loads them in order, `/usr/bin/wifi`. Nothing has to be copied from the
factory firmware.

```sh
wifi xm711
```

The script powers the module with `wifi_pdn value=96`. On a board whose
factory firmware uses another value, edit `value=` in `/usr/bin/wifi`; the
edit lands in the overlay, so `sysupgrade -n` (or `firstboot`) undoes it.

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
does not drive it. The factory `xm713g.ko` is built against the stock
kernel's `cfg80211` with wireless extensions (`CONFIG_CFG80211_WEXT`),
which is why it also needs the factory `cfg80211.ko`. OpenIPC ships
neither, and uses its own driver (`atbm60xx`) instead.

The generic `xm530_lite` image has the `atbm603x-xm530` profile in
`/etc/wireless/usb` but not the driver, which is too large for it. Use an
image built with:

```
BR2_PACKAGE_ATBM60XX=y
BR2_PACKAGE_ATBM60XX_MODEL_603X=y
BR2_PACKAGE_ATBM60XX_INTERFACE_USB=y
```

such as the `xm530_lite_anbiux-a8b-3mp` device in
[OpenIPC/builder](https://github.com/OpenIPC/builder), or your own build.
Then name the profile, the power GPIO and the network in the U-Boot
environment:

```sh
fw_setenv wlandev atbm603x-xm530
fw_setenv wifipdn 96
fw_setenv wlanssid 'YourSSID'
fw_setenv wlanpass 'YourPassword'
reboot
```

`wlandev` takes a profile name, not a module name. If `wifipdn` is unset,
or `wlan0` does not appear, the profile fails and the camera comes up on
the wired port.

Added in [OpenIPC/firmware#2316](https://github.com/OpenIPC/firmware/pull/2316)
and [OpenIPC/builder#130](https://github.com/OpenIPC/builder/pull/130).
Builds made before
[OpenIPC/firmware#2854](https://github.com/OpenIPC/firmware/pull/2854)
could not load the driver at all: it was missing from `modules.dep`.
