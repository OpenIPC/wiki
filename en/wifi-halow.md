# OpenIPC Wiki
[Table of Content](../README.md)

802.11ah HaLow Wi-Fi on OpenIPC
-------------------------------

This page explains what Wi-Fi HaLow is, when it makes sense for an IP camera,
and how to build and configure OpenIPC firmware with the Taixin TXW8301 HaLow
module — the first HaLow chip with a ready-made OpenIPC package
(`txw8301-openipc`).

### What is Wi-Fi HaLow (802.11ah)?

Wi-Fi HaLow is the IEEE 802.11ah standard: Wi-Fi moved down from 2.4/5 GHz
into the **sub-GHz** license-exempt bands (around 750–930 MHz depending on
the region), with narrow channels of 1–8 MHz.

Compared to regular camera Wi-Fi this trades throughput for reach:

| | Regular Wi-Fi (2.4 GHz) | Wi-Fi HaLow (sub-GHz) |
|---|---|---|
| Range, open air | ~50–100 m | hundreds of meters, up to ~1 km |
| Wall/foliage penetration | poor | good |
| Throughput (real world) | tens of Mbps | single-digit Mbps |
| Power consumption | higher | lower |
| Clients per AP | dozens | hundreds (up to 8191 by spec) |

**What this means for your camera:** a HaLow link comfortably carries a
low-bitrate H.264/H.265 stream (1–4 Mbps), snapshots, events, and ONVIF/RTSP
control traffic — over distances and through obstacles where 2.4 GHz gives up
entirely. It is *not* suitable for a high-bitrate 4K mainstream. Plan your
Majestic bitrate accordingly before blaming the link.

> [!IMPORTANT]
> Sub-GHz frequency allocations are **regional**. The USA uses 902–928 MHz,
> Europe 863–868 MHz, China 755–787 MHz, and so on. You must configure the
> module for the band that is legal in your country (see `freq_range` below).
> Defaults shipped in the package target the US 900 MHz band.

### Topology

A HaLow module does not talk to your regular Wi-Fi router. You need a HaLow
counterpart on the other side — an AP/gateway or a second module in AP mode:

```
+--------------------+          sub-GHz            +--------------------+
| IP camera          |   802.11ah, up to ~1 km     | HaLow AP / gateway |
| OpenIPC + TXW8301  |  ~~~~~~~~~~~~~~~~~~~~~~~~~  | (e.g. Taixin EVB,  |
| (STA mode, hg0)    |                             |  HaLow router)     |
+--------------------+                             +---------+----------+
                                                             | Ethernet /
                                                             | 2.4 GHz Wi-Fi
                                                        +----+-----+
                                                        | NVR / PC |
                                                        +----------+
```

The TXW8301 is an **FMAC** (full MAC) design: the whole 802.11ah stack runs
in the module firmware. The camera SoC just sees an ordinary network
interface named `hg0` — no `wpa_supplicant` is involved; association
parameters come from a config file read by the driver.

### Supported hardware

| Chip | Package | Interfaces | Status |
|---|---|---|---|
| Taixin TXW8301 | `txw8301-openipc` | SDIO, USB | Packaged, tested on GK7205V300 |
| Huge-IC | — (manual build) | SDIO | Legacy how-to: [Huge-IC AH drivers for Ingenic T31](hardware-wifi-ah-huge-ic.md) |

The TXW8301 package was contributed and hardware-validated in
[firmware PR #2043](https://github.com/OpenIPC/firmware/pull/2043) on an
`XM IVG-G5F` (GK7205V300) camera board, using its J3 extension header for
both SDIO and USB, connected to a `TAIXIN-AH-RX00P_EVB_V1.7` evaluation
board.

Useful upstream references:

- Driver source: <https://github.com/TXW8301/TXW8301-FMAC-linux-driver>
- Firmware SDK: <https://github.com/TXW8301/TXW8301-FMAC-SDK>

### Building firmware with TXW8301 support

The driver is **not** included in stock OpenIPC images (lite or ultimate) —
flash space is precious and most users will never need it. You build your
own image with the package enabled, the same way as for any
[additional wifi driver](adding-wifi-driver.md):

```
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
sudo make deps
```

Add to your board defconfig (e.g.
`br-ext-chip-goke/configs/gk7205v300_ultimate_defconfig`):

```
# SDIO-connected module (default)
BR2_PACKAGE_TXW8301_OPENIPC=y
BR2_PACKAGE_TXW8301_OPENIPC_SDIO=y
```

or, for a USB-connected module:

```
BR2_PACKAGE_TXW8301_OPENIPC=y
BR2_PACKAGE_TXW8301_OPENIPC_USB=y
```

Then build:

```
make BOARD=gk7205v300_ultimate
```

The package installs:

| File | Purpose |
|---|---|
| `/lib/modules/<kver>/extra/hgicf.ko` | FMAC driver kernel module |
| `/lib/firmware/taixin/hgicf.bin` | Module firmware blob (SDIO or USB build) |
| `/etc/hgicf.conf` | Association / radio configuration |
| `/etc/modprobe.d/txw8301.conf` | Points the driver at firmware and config paths |
| `/etc/init.d/S35txw8301` | Init script: loads module, brings up `hg0`, runs DHCP |
| `/usr/bin/hgicf`, `/usr/bin/hgpriv` | Vendor diagnostic / control tools |

### Hardware hookup

- **SDIO**: wire the module to an SDIO-capable extension header (on the
  tested XM IVG-G5F board this is the J3 header). Keep the wires short —
  SDIO is picky about signal integrity. Check your SoC pinmux: the SDIO
  pins may be shared with other functions.
- **USB**: any free USB host port works; this is the easier option if your
  board exposes USB on a header or pads.
- Power the module from a rail that can handle its TX bursts; sub-GHz PAs
  can draw noticeable current spikes.

Verify the module enumerated after boot:

```shell
# USB variant
lsusb

# SDIO variant — look for the SDIO card in the kernel log
dmesg | grep -i -E "mmc|sdio|hgic"

# In both cases the driver should create the interface
ip link show hg0
```

### Configuration: /etc/hgicf.conf

The driver reads `/etc/hgicf.conf` when the module is loaded (the path is
set via the `conf_file=` module parameter in `/etc/modprobe.d/txw8301.conf`).
The default file:

```
freq_range=9080,9240,8
bss_bw=8
tx_mcs=255
chan_list=9080,9160,9240
key_mgmt=WPA-PSK
wpa_psk=
ssid=HALOW_XXXXXX
mode=sta
dhcpc=1
```

| Key | Meaning |
|---|---|
| `freq_range` | Start, end, step of the allowed band, in units of 0.1 MHz. `9080,9240,8` = 908.0–924.0 MHz (US band). **Change this to match your region.** |
| `bss_bw` | Channel bandwidth in MHz (1/2/4/8). Wider = faster, narrower = longer reach. Must match the AP. |
| `tx_mcs` | Fixed MCS index; `255` = automatic rate selection (leave it). |
| `chan_list` | Channel center frequencies to scan/use, in 0.1 MHz units. |
| `key_mgmt` | `WPA-PSK` or `NONE`. |
| `wpa_psk` | The pre-shared key of your HaLow network. |
| `ssid` | The HaLow network name. |
| `mode` | `sta` (camera joins an AP, the usual case) or `ap`. |
| `dhcpc` | `1` = init script runs `udhcpc` on `hg0`; `0` = configure the address yourself. |

After editing, restart the link:

```shell
/etc/init.d/S35txw8301 restart
```

The init script reloads the module (which re-reads the config), waits for
`hg0` to appear, brings it up, and starts a DHCP client if `dhcpc=1`.

For a static address instead of DHCP, set `dhcpc=0` and configure `hg0` in
`/etc/network/interfaces.d/` as described in
[Network settings](network-settings.md).

### Bring-up and verification

1. Boot the camera and watch the console/`dmesg` for the driver loading its
   firmware blob and creating `hg0`.
2. `ip link show hg0` — the interface exists and is `UP`.
3. `ip addr show hg0` — an address appeared (DHCP) or is set (static).
4. `hgpriv` can query module status, RSSI and negotiated rate — run it
   without arguments to see available commands.
5. Test the pipe: ping the gateway, then pull an RTSP stream through the
   link. With an 8 MHz channel expect a few Mbps of useful throughput;
   with 1–2 MHz channels expect proportionally less. Set the Majestic
   bitrate below what the link sustains, or the stream will stutter.

### Troubleshooting

| Symptom | Things to check |
|---|---|
| No `hg0` after boot | Did the module enumerate at all? (`lsusb`, check `dmesg` for SDIO). Wrong interface variant selected at build time (SDIO package on a USB-wired module or vice versa)? |
| Driver loads, firmware error in dmesg | `/lib/firmware/taixin/hgicf.bin` present? It is interface-specific — an SDIO blob won't run on a USB module. |
| `hg0` up but never associates | `ssid`/`wpa_psk` correct? `freq_range`/`chan_list`/`bss_bw` must be compatible with the AP — a region mismatch means the camera scans frequencies the AP never uses. |
| Associates, no IP address | Is a DHCP server reachable over the HaLow link? Try a static address to isolate the problem. |
| Link works but video stutters | Normal for HaLow if the bitrate is too high — lower the Majestic bitrate, prefer H.265, or widen `bss_bw` if regulations allow. |
| SDIO module randomly disappears | Wiring/signal integrity: shorten leads, lower SDIO bus speed, check power supply sag under TX load. |

### See also

- [Adding a wifi driver to your firmware](adding-wifi-driver.md)
- [Wireless settings](wireless-settings.md)
- [Network settings](network-settings.md)
- [Adding Huge-IC AH WiFi HaLow drivers for Ingenic T31](hardware-wifi-ah-huge-ic.md) (legacy manual method)
- [TXW8301 FMAC Linux driver](https://github.com/TXW8301/TXW8301-FMAC-linux-driver)
- [OpenIPC firmware PR #2043](https://github.com/OpenIPC/firmware/pull/2043) — package integration and test setup photos
