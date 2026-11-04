# OpenIPC Wiki
[Table of Content](../README.md)

Novatek unbrick
---------------

This page covers NT9856x boards (NT98560, NT98561, NT98562, NT98566), such as
the XM boards whose U-Boot prompt is `nvt@na51089:`. Most of it comes from the
NT9856x ROM code Application Note and from a dump of the chip's mask ROM.
Sections marked **unverified** have not been proven on a camera yet. If you try
them, please add what you saw.

### How this differs from HiSilicon and Goke

On HiSilicon and Goke, the mask ROM listens on the UART at every power-on, so
[side-loading an unlocked bootloader](help-uboot.md#side-loading-an-unlocked-bootloader)
works on any board, bricked or not.

The Novatek ROM does not do that:

- It takes a download over the UART only when the boot straps say UART
  (BS[3:0] = 0xC). The straps are four SoC pins, latched at reset, which
  software cannot change. Camera boards, XM ones included, have them at 0:
  boot from SPI NOR.
- With a valid loader in flash, the ROM boots it. It never looks at the UART,
  the network or the SD card.
- With **no valid loader** in flash, it tries the next boot sources, in this
  order:

  SPI NOR → SD card → **Ethernet** (DHCP, then TFTP)

  Ethernet is in practice the last one. Once a DHCP server answers, the ROM
  asks the server named in the offer for `loader.bin` over TFTP and waits
  for it with no timeout. It goes on to USB and then UART only when nothing
  answers its DHCP, about 100 seconds after power-on.

So a bricked Novatek board is recovered over **Ethernet**, not over the UART.

### Reading the ROM's console output

The ROM prints single letters on the console (UART0, 115200 8N1) as it goes:

| Output | Meaning |
|---|---|
| `N` | ROM started |
| `P` | Trying SPI NOR |
| `D`, `R` | Trying SPI NAND (on-die ECC, RS ECC) |
| `S1` | Trying the SD card |
| `H` | Trying Ethernet, followed by `E` (built-in PHY), `O` or `I` (RMII) |
| `U` | Trying USB |
| `K2`…`K7` | Storage errors: `K2` no card, `K3` bad MBR, `K4` bad PBR, `K5`/`K7` loader read failed |
| `K9` | Loader checksum failed |
| `T` | Loader accepted, jumping to it |
| `X`, `A`, `R`, `S` | Secure boot is enabled; the loader must be signed |

A healthy board prints `NPIp>T` and then the loader's own messages
(`dma ok`, `Loader Start ...`, `LD_VER ...`).

A board with an empty or broken loader prints something like this:

```
NPIp>K9S1K2HE00003500000037000000D1E1s100FXS1RI
```

That is NOR failed (`K9`), no SD card (`S1K2`), and the Ethernet boot started
(`HE`). `S1` after `FX` is the first DHCP request.

If you then see `CDRI` repeating, the ROM got an address from your network's
DHCP server and is waiting for `loader.bin` from it for ever. Use the defib
method below, which answers the ROM before your router does.

### Unbricking over Ethernet with defib

[defib](https://github.com/OpenIPC/defib) answers the ROM's DHCP and serves it
a loader and an OpenIPC U-Boot over TFTP. U-Boot then starts from RAM, and you
get its console. Nothing is written to flash.

What you need:

- The camera on the same Ethernet segment as your computer. A direct cable is
  the safest choice. Your normal LAN works too: defib answers at once, and the
  ROM takes the first answer. But if your router answers first, the ROM waits
  on the router for good: `CDRI` repeats on the console and defib sees nothing.
  Power-cycle the camera to try again, or use a direct cable.
- The UART console connected, so defib can stop U-Boot's autoboot.
- Root access on a Linux computer, for UDP ports 67 (DHCP) and 69 (TFTP).
  Stop any TFTP server already running on that computer.

```shell
uv tool install git+https://github.com/OpenIPC/defib
sudo "$(command -v defib)" burn -c nt98562 -p /dev/ttyUSB0 --nic eth0
```

Use your SoC (`nt98560`, `nt98561`, `nt98562`, `nt98566`) and your network
interface. `sudo` may not find a tool installed for your user, hence the full
path. Only NT98562 has been verified so far; the other three use recovery sets
built the same way, but nobody has reported them yet.

Start defib first, then power the camera on. defib:

1. Answers DHCP only for the ROM and its loader. Both use a
   `00:00:00:xx:xx:xx` MAC address with a new random ending on every boot, so
   other devices on the network are left alone.
2. Serves `loader.bin` and then `FW<soc>T.BIN` (device tree plus U-Boot) from
   `novatek-recovery.tar.gz`, which it downloads from the OpenIPC/u-boot
   `novatek` release.
3. Sends Ctrl-C on the console until the `OpenIPC #` prompt appears.

On an NT98562 this takes about 30 seconds. `--host-ip` defaults to the
interface's own address (or `192.168.1.10` if it has none), and `--device-ip`
to `.251` in the same /24.

From the prompt, continue as for any OpenIPC U-Boot: restore your backup or
flash the firmware over TFTP. Writing flash from this U-Boot has not been
verified on Novatek yet. Check every step with `sf read` and `crc32`.

### When the board still has a valid loader

Ethernet recovery only starts when the loader at the start of flash (the
first 64 KiB, `mtd0`) is missing or broken. If the loader is intact but
U-Boot, the kernel or the root filesystem is damaged, the ROM boots the
loader every time and never reaches Ethernet.

If U-Boot itself still runs (only the kernel or root filesystem is damaged):

- Stop the vendor U-Boot: press Ctrl-C repeatedly from power-on. The boot
  delay is zero, so a single press is too late, and the "Hit X" message is
  misleading: X does not stop it.
- If it asks for a password, try `#Ux6@9V&4_Rz` (confirmed on NT98566). See
  [known bootloader passwords](help-uboot.md#known-bootloader-passwords).
- From the vendor prompt or the stock Linux shell, back up and repair.
  [Installation on Novatek](install-novatek.md) covers XM NT98562 and NT98566
  boards with NOR flash only, and uses their fixed partition offsets. On any
  other board, check your own layout before you erase anything.

If U-Boot itself is damaged behind an intact loader, no method is verified
yet other than a flash programmer. The two below are candidates.

#### Shorting flash pins to make the ROM skip the loader (**unverified**)

People report that shorting the flash at power-on makes the ROM skip a
working loader, as if the flash had failed. The ROM would then go on to SD
and Ethernet, where defib catches it. This would be the Novatek counterpart
of the HiSilicon trick in
[Shorting pins on flash chip](help-uboot.md#shorting-pins-on-flash-chip),
but it **has not been proven yet**.

The idea:

1. Start `defib burn ... --nic` as above.
2. Short pins 5 and 6 of the SOIC-8 flash chip (the corner opposite the
   pin 1 dot) while powering the camera on, so the ROM reads garbage.
3. Watch the console. The ROM should print `K9` and then `S1K2HE`.
   Release the short as soon as `HE` appears. U-Boot runs from RAM later and
   needs the flash readable again.

If you try it, please add to this page:

- Which pins you shorted.
- When you released them.
- The exact ROM output.
- Whether defib reached the `OpenIPC #` prompt.

__Do not short random chips.__ Read the flash chip's marking and find pin 1
first.

#### Watchdog reset (**unverified**)

The ROM dump shows that the ROM skips the current boot source when the
watchdog reset counter (`0xF0050080`, bits 15:8) is non-zero after a
watchdog reset. It then prints `J`. The vendor U-Boot's `reset` does not set
that counter. An attempt to arm the watchdog by hand from the vendor prompt
reset the board but did not set it either. If you find a way, it would let a
working board reach Ethernet recovery with no flash write and no shorting.

### Backups

Back up the whole flash before you write anything, and keep `mtd0` (the
loader) above all:

- The recovery set's `loader.bin` is an Ethernet loader. It can **not** be
  written to flash as a boot loader.
- A board whose flash loader is lost can boot again only with a loader from a
  backup or from another board of the same model.

Ways to take the backup:

- **From the stock Linux shell.** XM firmware gives a root shell on the
  console. On NOR flash, read each partition with `cat /dev/mtdN` and copy it
  off, for example over the network or to an SD card. On NAND flash, `cat`
  skips the out-of-band data and bad blocks: follow the NAND procedure in
  [Backing up stock firmware](backup-stock-firmware.md) instead.
- **With a flash programmer.**

The flash layout on XM NOR boards:

```
64k(loader) 256k(boot) 2048k(kernel) 5120k(rootfs) -(rootfs_data)
```

### UART recovery (boards with the straps at UART)

On a board whose straps you can set to UART (BS[3:0] = 0xC), such as an
evaluation board, defib can also recover over the UART alone:

```shell
defib burn -c nt98562 -p /dev/ttyUSB0
```

It sends `wrloader.bin` to the ROM, then the U-Boot pack to that loader.
The loader stage has been run on an NT98562. The ROM stage follows the ROM's
code, but has not been run on a camera, because no tested board exposes the
straps.

On a board with the straps at flash, this command reports that the ROM took
a DHCP lease and points you to `--nic`.

### Other Novatek families

- **NT9832x (NT98321, NT98323).** The straps differ: UART is 4, Ethernet is 3.
  The recovery sets exist, but nothing has been tested on hardware.
- **NT98532, NT98533.** The ROM guide says the ROM uses UART1, while the
  loader serves UART0. Untested.
- **NT9852x.** The SDK has no UART boot for these chips, and defib does not
  list them.
