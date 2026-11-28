# OpenIPC Wiki
[Table of Content](../README.md)

For NT98562 and NT98566 SoC boards (NOR and SPI NAND)
-----------------------------------------------------

### What is supported

- **SPI NOR boards** (XM vendor boards whose U-Boot prompt is `nvt@na51089:`):
  the vendor U-Boot stays on flash; only the kernel and the root filesystem are
  replaced. NOR flash of 8 MB or more (anything past 8 MB goes to the settings
  partition).
- **SPI NAND boards** (NT98566, 128 MB RAM): uses OpenIPC U-Boot
  (`u-boot-nt98566-nand.bin`) and the UBI image
  `openipc.nt98566-nand-ultimate.tgz`, verified on hardware (see
  [Dahua DH-IPC-HFW2449SP-S-IL](device-dahua-dh-ipc-hfw2449sp-s-il.md)).
- Sensors with video: SC401AI, SC430AI, SC500AI, SC501AI and IMX415. With any
  other sensor the camera boots and is reachable on the network, but has no
  video.
- IMX415 (for example the XM IVG-N8S, NT98566) is in images built from
  2026-11-10 on, and is not detected on its own: set it once from Linux and
  reboot, see [Setting the sensor](#setting-the-sensor).
- Images: `openipc.nt98562-nor-lite.tgz`, `openipc.nt98566-nor-lite.tgz`, and
  `openipc.nt98566-nand-ultimate.tgz`. The NT98566 NOR and SPI NAND images have
  been checked on hardware; the NT98562 NOR image is built from the same tree
  but has not been tested on a camera yet. Reports are welcome.
- OpenIPC U-Boot builds for these SoCs (`u-boot-nt98562-nor.bin`,
  `u-boot-nt98566-nor.bin`, `u-boot-nt98566-nand.bin`) are in the
  [firmware release](https://github.com/OpenIPC/firmware/releases/tag/latest),
  built from OpenIPC/u-boot. The NOR instructions below keep the vendor U-Boot;
  the SPI NAND instructions use OpenIPC U-Boot.

If the camera no longer boots, see [Novatek unbrick](novatek-unbrick.md).

### Initial device firmware update (SPI NOR)

You need a UART console and a TFTP server on the camera's network.

1. Back up the whole flash first and keep the copy off the camera, as described
   in [Backing up stock firmware](backup-stock-firmware.md). U-Boot on these
   boards cannot send a backup over the network, so use a programmer or the
   stock firmware's shell.
2. Download the archive for your SoC, for example
   https://github.com/OpenIPC/firmware/releases/download/latest/openipc.nt98562-nor-lite.tgz,
   and put the `uImage.<soc>` and `rootfs.squashfs.<soc>` files from it in the
   TFTP root.
3. Power the camera on while pressing Ctrl-C on the console until the
   `nvt@na51089:` prompt appears; the boot delay is zero, so a single key press
   is usually too late. Some vendor U-Boots print `Hit X to stop autoboot`, but
   X does nothing there; Ctrl-C is the key. Then enter, with your own addresses
   and SoC:

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
setenv soc nt98562
setenv osmem 32M
setenv bootargs 'earlyprintk console=ttyS0,115200 mem=${osmem} panic=20 nprofile_irq_duration=on root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=spi_nor.0:64k(loader),256k(boot),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x03100000 0x50000 0x200000;nvt_boot'
setenv uk 'mw.b 0x01000000 ff 1000000;tftp 0x01000000 uImage.${soc} && sf probe 0 && sf erase 0x50000 0x200000 && sf write 0x01000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x01000000 ff 1000000;tftp 0x01000000 rootfs.squashfs.${soc} && sf probe 0 && sf erase 0x250000 0x500000 && sf write 0x01000000 0x250000 ${filesize}'
saveenv
run uk && run ur && reset
```

   Each `run` must end with `Written: OK`. If a download or a write fails, the
   line stops there: nothing more is erased and the camera does not reset. Fix
   the TFTP side and run the line again.
4. The settings partition still holds what the stock firmware left there and
   has to be formatted once. A freshly flashed camera is unclaimed and has no
   shell, so log in as `root` on the console or over SSH with no password,
   answer the one-time setup prompt, and run `firstboot`. It formats the
   partition and reboots.
5. `firstboot` also erases the password you just set, so the camera comes back
   unclaimed. Claim it for good: open its web page to set the root password and
   accept the licence, or log in over SSH or the console again. See
   [Factory reset and the unclaimed camera](first-boot.md).

### Setting the sensor

At first boot the camera looks for the sensor and stores what it finds in the
U-Boot variable `sensor`. An IMX415 is not found that way, and the camera comes
up with no video. Set it from Linux, then reboot:

```
fw_setenv sensor imx415
reboot
```

After the reboot, `lsmod | grep nvt_sen` shows `nvt_sen_imx415` and the stream
is 2560x1440. The same command names any other supported sensor if detection
picks the wrong one.

### Follow-up quick updates (SPI NOR)

From the U-Boot prompt, with the new files in the TFTP root:

```
run uk && run ur && reset
```

Or run `sysupgrade` on a running camera.

### SPI NAND boards (NT98566)

This section has been verified on the
[Dahua DH-IPC-HFW2449SP-S-IL](device-dahua-dh-ipc-hfw2449sp-s-il.md) only.
`u-boot-nt98566-nand.bin` replaces the vendor first-stage loader (which
initializes DDR) and its device tree, so another SPI NAND board with a
different RAM configuration may fail to boot and require an external flash
programmer to recover.

OpenIPC SPI NAND builds use OpenIPC U-Boot (`u-boot-nt98566-nand.bin`) and a
three-partition layout where the kernel (`/boot/uImage`) lives inside the
`ubi0:rootfs` UBIFS volume:

```
mtdparts=spi_nand.0:2816k(boot),256k(env),-(ubi)
```

1. **Back up the entire stock SPI NAND flash first** following the NAND routes
   in [Backing up stock firmware](backup-stock-firmware.md) (do not use SPI NOR
   `sf` commands, and see [NAND rootfs layouts](nand-rootfs-layouts.md) before
   restoring bootloader-dumped pieces across bad blocks). Store the backup off
   the camera: replacing the bootloader with `u-boot-nt98566-nand.bin`
   overwrites the vendor boot area (`0x0..0x2c0000`).
2. Download `u-boot-nt98566-nand.bin` and `openipc.nt98566-nand-ultimate.tgz`
   from the
   [latest release](https://github.com/OpenIPC/firmware/releases/tag/latest),
   and place `u-boot-nt98566-nand.bin` and `rootfs.ubifs.nt98566` (extracted
   from the `.tgz`) in your TFTP root.
3. Flash `u-boot-nt98566-nand.bin` to offset `0x0` (via an external flash
   programmer, or from a RAM-booted OpenIPC U-Boot using `run ub` - see
   [Novatek unbrick](novatek-unbrick.md) for Ethernet RAM boot with `defib`,
   noting that `defib` on `nt98566` has not been confirmed on hardware yet),
   then power-cycle and stop at the `OpenIPC #` prompt.
4. Configure networking, set your board's MAC address, erase the `ubi`
   partition once to create a clean UBI volume, and flash the rootfs (which
   also carries `/boot/uImage`):

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
setenv ethaddr 00:11:22:33:44:55
setenv osmem 48M
saveenv
nand erase.part ubi
run ur && reset
```

   Using `run ur && reset` keeps the board at the `OpenIPC #` prompt if the
   TFTP transfer or UBI write fails, so you can retry without rebooting into an
   empty `ubi` partition.

5. Follow-up updates:
   - From Linux: run `sysupgrade` (or
     `sysupgrade --rootfs=/tmp/rootfs.ubifs.nt98566`). Because the kernel lives
     inside `ubi0:rootfs`, pass `--rootfs=` rather than `--kernel=`.
   - From OpenIPC U-Boot: `run ur && reset` (updates `ubi0:rootfs` while
     keeping `ubi0:rootfs_data`).

On 128 MB NT98566 boards, `osmem=48M` is recommended for 4 MP streams (leaves
around 40 MiB of free DDR1 for the video pipeline).

### Memory split: `osmem` and `mem=`

On these boards U-Boot divides the RAM using the `osmem` variable: Linux gets
the first `osmem`, and the video pipeline gets the rest. The kernel, however,
takes its own size from the `mem=` argument in `bootargs`. The two must always
be equal:

- `osmem` larger than `mem=` — the camera stops right after the kernel is
  decompressed and prints nothing more.
- `mem=` larger than `osmem` — Linux and the video pipeline end up using the
  same memory; the camera crashes and reboots as soon as the video drivers
  load, on every boot.

Keep a literal `${osmem}` in `bootargs` instead of a number. The `bootcmd`
these boards use (`setenv setargs setenv bootargs ${bootargs};run setargs;...`)
expands it at every boot, so `osmem` becomes the only value you change. From
Linux, replace just the `mem=` value and leave the rest of your `bootargs`,
partition layout included, exactly as it is:

```
fw_printenv -n bootargs > /root/bootargs.orig
fw_setenv bootargs "$(fw_printenv -n bootargs | sed 's/mem=[0-9]*M/mem=${osmem}/')"
fw_printenv bootargs
```

The last command must now show `mem=${osmem}`. Copy `/root/bootargs.orig` off
the camera as well: `firstboot` wipes `/root`, while the U-Boot environment
survives. To undo: `fw_setenv bootargs "$(cat /root/bootargs.orig)"`.

On **SPI NOR** boards, if `fw_printenv bootcmd` does not start with
`setenv setargs setenv bootargs ${bootargs};run setargs`, set it from the
U-Boot console (do **not** run this on SPI NAND boards, where OpenIPC U-Boot's
`bootcmd=run bootflash` already expands `${osmem}` and loads `/boot/uImage`
from `ubi0:rootfs`):

```
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x03100000 0x50000 0x200000;nvt_boot'
saveenv
```

Then change the split with `fw_setenv osmem <size>` and reboot. Choose the size
for your board: everything `osmem` gives to Linux is taken from video memory, so
a board with less RAM, or a heavier stream, needs a smaller value. As an
example, a 128 MB NT98566 with a 5 MP sensor boots and streams at both the
default 32M and at 54M.

### SD card (SDIO1) GPIO overrides

On `nt98562` and `nt98566` (firmware built from
[OpenIPC/firmware#2988](https://github.com/OpenIPC/firmware/pull/2988) and
[OpenIPC/linux#333](https://github.com/OpenIPC/linux/pull/333), 2026-11-28 or
later; older images do not load the SD driver at boot), `load_novatek` loads
`mmc_block` and `mmc_na51055` using the defaults from the camera's own device
tree passed by the bootloader. Because the bootloader DTB varies from board to
board (for example, the EVB DTB sets `cd_gpio=9` and `card_power_gpio=233`,
while other boards may omit `card_power_gpio`), inspect what your board's DTB
currently provides:

```sh
hexdump -C /proc/device-tree/mmc@f0420000/cd_gpio
ls /proc/device-tree/mmc@f0420000/   # card_power_gpio, no_cd_gpio, force_power_cycle if present
```

If your board wires the microSD slot differently from its bootloader DTB, set
any of these optional U-Boot environment variables (plain decimal GPIO numbers,
no leading zeros) and reboot:

| Variable | Values | Meaning |
|---|---|---|
| `sd_cd_gpio` | `0` or `<N>` | `0` = no card-detect pin (`no_cd_gpio`); `<N>` = override SDIO1 CD GPIO (keeps the card-detect polarity from the device tree; active-low when the DT has `no_cd_gpio` or omits it) |
| `sd_power_gpio` | `0` or `<N>` | `0` = no power switch; `<N>` = override SDIO1 card-power GPIO (with 500 ms power cycle on probe) |
| `sd_power_level` | `0` or `1` | Active level for `sd_power_gpio` (`0` = active-low, `1` = active-high; default from DT is `0`) |

Unset variables keep the device tree defaults without claiming or remuxing any
DT pins. For example, on Dahua `DH-IPC-HFW2449SP-S-IL` (no CD pin, `GPIO 9`
active-low SD power):

```sh
fw_setenv sd_cd_gpio 0
fw_setenv sd_power_gpio 9
reboot
```
