# OpenIPC Wiki
[Table of Content](../README.md)

VStarcam pan/tilt cameras (Hi3518EV200 + GC2023 + MT7601U)
---

Notes from a full conversion of a VStarcam indoor pan/tilt camera (P2P UID
prefix `VSTA...`, close sibling of the C8892WIP in the builder device list).
Everything below was verified on real hardware.

### Hardware

| Component | Detail |
|-----------|--------|
| SoC       | HiSilicon Hi3518EV200 |
| Sensor    | GalaxyCore GC2023, 1080p, wired to **MIPI** (2-lane RAW10), SDK I2C address `0x6e` |
| Flash     | 16 MB SPI NOR (GD25Q128, `0xc8 0x40 0x18`) |
| Wi-Fi     | MediaTek MT7601U on USB (`148f:7601`) |
| PTZ       | Two 28BYJ-48-style steppers on GPIOs, pan `31 32 33 34`, tilt `58 59 60 61` |
| Serial    | ttyAMA0 at 115200 8N1; U-Boot 2010.06, prompt `hisilicon #`, `bootdelay=1` |

Vendor firmware serial login is `vstarcam2017` / `20170912` (uid 0) — the
username is not `root`; `root` is always rejected.

### Installing while keeping the vendor U-Boot

The vendor U-Boot stores its environment at offset `0x80000`, which sits inside
the kernel region of OpenIPC's standard 16 MB layout — with standard offsets a
later `saveenv` would write the environment straight through the kernel. Keeping
the vendor U-Boot (and therefore the vendor recovery path) works fine with a
shifted layout:

```
setenv bootargs 'mem=32M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock2 rootfstype=squashfs init=/init mtdparts=hi_sfc:1024k(boot),3072k(kernel),8192k(rootfs),-(rootfs_data)'
```

- Kernel at `0x100000`, rootfs at `0x400000`. The vendor `bootcmd`
  (`sf read 0x82000000 0x100000 0x300000; bootm`) needs no change at all —
  OpenIPC's uImage uses the same `0x80008000` load address as the vendor kernel.
- `root=/dev/mtdblock2`, not the `mtdblock3` from the upstream install guide —
  this layout has no separate `env` partition, so every index shifts down one.
- The overlay partition must be named exactly `rootfs_data` and boot needs
  `init=/init`, or you get a read-only system with no persistent config.

Two U-Boot traps worth knowing before you flash:

- **This U-Boot has no `tftpdstp`** (`strings` on the boot partition shows only
  `tftpblocksize`/`tftptimeout`), so it silently retries against anything that
  is not port 69. Run the TFTP server on the standard port.
- The stripped build has no `boot` or `run` commands — invoke the `bootcmd`
  steps by hand.

### Sensor: GC2023 over MIPI

Use the `gc2023_mipi` sensor identity and `gc2023_mipi_1080p.ini` (2-lane
RAW10, `Isp_Bayer=0`/RGGB). The plain `gc2023` entry in `load_hisilicon` muxes
the parallel VI pads, which disables the MIPI PHY on this board — the tell is
`/proc/umap/vi` showing `IntCnt=0` with `TmgErr=0` and `ccErrN=0` (no VSYNC at
all; bad ini timings would raise the error counters instead).

Caveat: on the tested unit the closed `libsns_gc2023.so` shipped with the
firmware did not produce frames (VENC timeout — it appears to program the
sensor for DVP output). The working setup used the *vendor's* MIPI sensor
library plus a replay of its 123-write init table, because that library leaves
digital gain (page 0 register `0xb1`) at 0 — which multiplies every pixel to
zero: perfectly valid MIPI framing carrying an all-black raster. If you see
valid framing but black frames, check `0xb1` before suspecting optics or IQ.

The sensor answers only on the SDK's own I2C (via `ipctool i2cget`, 8-bit
address `0x6e`) — sweeping `/dev/i2c-*` finds nothing and proves nothing.

### Wi-Fi

Build with `BR2_PACKAGE_MT7601U_OPENIPC=y` and load `mt7601sta`, not the
mainline `mt7601u` — see the driver note in
[Adding a wifi driver](adding-wifi-driver.md): mainline managed 0.4–1.0 Mbps
transmit on this hardware, the STA driver 15–17 Mbps on the same dongle and AP.

If both eth0 and wlan0 are up, make sure they do not share a DHCP hostname:
busybox `ifup` sends the same hostname on every interface, and a DHCP server
that keys reservations on hostname will hand both interfaces the same address,
which blackholes the camera (ARP answered by the wrong interface).

### PTZ

`fw_setenv gpio_motors "31 32 33 34 58 59 60 61"` drives the head with the
`gpio-motors` package. The pins came from the vendor's `motogpio.ko`: it never
calls `ioremap` and uses static-mapping virtual addresses, so subtracting the
fixed `phys 0x20000000 → virt 0xFE100000` offset turns its literal pool back
into real GPIO banks. There are no working limit switches — the vendor homes by
driving into the mechanical stop and counting steps back out.

### IR-cut and IR LED

The IR-cut solenoid is bi-stable: pulse sysfs GPIO **64** for ~200 ms to switch
to day (filter in), pulse GPIO **65** for night (filter out). The IR illuminator
is a plain level on sysfs GPIO **1**. Both filter pins power up muxed as
`SAR_ADC` channels, so nothing responds until the pinmux is set:

```
devmem 0x200F0100 32 1   # MUXCTRL_REG64 -> GPIO8_0
devmem 0x200F0104 32 1   # MUXCTRL_REG65 -> GPIO8_1
```

Do not brute-force sweep GPIOs looking for pins on this board — some lines are
sensor power/reset, and a sweep that leaves one asserted breaks sensor I2C until
a power cycle.
