# OpenIPC Wiki
[Table of Content](../README.md)

TP-Link Tapo C120
---

SoC SSC377, sensor SC430AI (4 MP), 16 MB NOR (XM25QH128C), Wi-Fi RTL8188FTV on USB.
Firmware: the `ssc377_lite_tp-link-tapo-c120` device in
[OpenIPC/builder](https://github.com/OpenIPC/builder/pull/162) (16 MB layout, `rtl8188fu` driver, WPA3-capable
`wpa_supplicant`, IQ file, IR-cut and LED pins). The SC430AI driver is in
[OpenIPC/sensors](https://github.com/OpenIPC/sensors/tree/master/sigmastar/infinity6c) (PR #7) and the
loader entry in OpenIPC/firmware#2445; until those and the builder device are merged, build the device
yourself with `./builder.sh ssc377_lite_tp-link-tapo-c120`. The generic `ssc377_lite` image is an 8 MB
layout with no Wi-Fi driver and does not fit this camera.

![Bottom side](../images/device-tapo-c120-bottom.jpg)

### UART
Five pads next to the flash chip on the top side: `VCC TP1 TP2 TP3 TP4`

VCC | TP2 | TP3 | TP4
-|-|-|-
3.3V (do not feed) | TX | RX | GND

115200 8N1. Connect RX (TP3) only after the camera is powered, otherwise it does not boot.

Stock U-Boot stop string is `slp` (prompt `SigmaStar #`). It has `sf`, `md`, `mw`, `go` but no `mmc`/`fatload`.

### Flash
Dump the whole chip before writing anything. The OpenIPC bootloader image overwrites data the stock
firmware needs to work, so only a complete backup lets you go back to Tapo.

The builder image uses the standard OpenIPC 16 MB layout (`kernsize 0x300000`, `rootsize 0xa00000`):
```
mtdparts=NOR_FLASH:256k(boot),64k(env),3072k(kernel),10240k(rootfs),-(rootfs_data)
```

### Sensor
Detection works by itself: `ipcinfo -s` prints `sc430ai`, and after start `logread | grep "Sensor index"`
shows `2688x1520@30fps`. The builder device ships the IQ file as `/etc/sensors/sc430ai.bin`; on any
other image take it out of your own stock firmware dump (`binwalk` finds the squashfs).

### GPIO
IRCut | IRLed | WhiteLed | RedLed | GreenLed | WiFi power
-|-|-|-|-|-
GPIO81 | GPIO12 GPIO13 | GPIO14 | GPIO10 | GPIO11 | GPIO42

IR cut: high = day. LEDs: high = on. Speaker amplifier (GPIO48) is handled by the audio driver.

```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "nightMode": {
    "irCutPin1": 81,
    "irCutSingleInvert": true,
    "backlightPin": 14
  }
}
EOF
```

---

### Wireless
The RTL8188FTV is powered through GPIO42; the builder device's `/etc/wireless/usb` has the entry:
```
if [ "$1" = "rtl8188fu-tapo-c120" ]; then
	set_gpio 42 1
	sleep 2
	modprobe 8188fu
	exit 0
fi
```

```
fw_setenv wlandev rtl8188fu-tapo-c120
fw_setenv wlanssid Router
fw_setenv wlanpass 12345678
```

Driver: `BR2_PACKAGE_RTL8188FU_OPENIPC=y` (`8188fu` from openipc/realtek-wlan, branch `rtl8188fu`).
The device selects `BR2_PACKAGE_WPA_SUPPLICANT_OPENIPC=y`, a wpa_supplicant with SAE, but the stock
`wlan0` script still writes a WPA2-PSK config: a WPA3-only network needs `key_mgmt=SAE` in
`/tmp/wpa_supplicant.conf` until that script learns it.

### Ethernet
`J2` (marked ETH) on the bottom side has TX/RX from the internal PHY, no connector fitted.
