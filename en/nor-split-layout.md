# OpenIPC Wiki
[Table of Content](../README.md)

NOR split layout (GK7205V200 family)
====================================

A NOR camera normally keeps the kernel and the root filesystem in fixed slots:
2 MiB for the kernel at `0x50000`, then 5 MiB (8 MB flash) or 10 MiB (16 MB
flash) for the root filesystem, then the overlay with your settings. Each image
has to fit its own slot. A kernel that grows past 2 MiB cannot borrow the room
the root filesystem leaves free, and the other way round.

On GK7205V200, GK7205V300, GK7202V300 and GK7605V100 there is a second layout.
Kernel and root filesystem sit back to back in one partition, and only their sum
has to fit the chip:

```
0x000000  u-boot    256K  U-Boot
0x040000  env        64K  U-Boot environment
0x050000  firmware  rest  one image, divided by the kernel at boot:
            kernel       a FIT: the kernel and its device tree, each with
                         a CRC32 and a SHA-1 hash
            rootfs       the squashfs, from the next 64 KiB block
            rootfs_data  your settings (the overlay), from the end of the
                         squashfs to the end of the chip
```

The image is `firmware.bin`. The kernel's `mtdsplit` finds where the FIT ends and
the squashfs begins, and adds the `kernel`, `rootfs` and `rootfs_data`
partitions itself. A bigger or smaller image simply moves where `rootfs_data`
starts.

U-Boot checks both hashes before it starts the kernel, so a kernel the flash has
corrupted is refused instead of crashing:

```
   Verifying Hash Integrity ... crc32+ sha1+ OK
```

### What it needs

**The OpenIPC U-Boot for your SoC**, `u-boot-<soc>-nor.bin` from the
[firmware release](https://github.com/OpenIPC/firmware/releases/tag/latest).
Only this bootloader boots the layout. It still boots the fixed slots too. It
looks at what is at `0x50000` on every boot and sets the partitions to match.
The older `u-boot-<soc>-universal.bin` boots fixed slots only.

**The split firmware package** for your SoC,
`openipc.<soc>-nor-<variant>-split.tgz` from the same release, holding
`firmware.bin.<soc>`. The plain `openipc.<soc>-nor-<variant>.tgz` beside it is
the fixed-slot package: `uImage.<soc>` and `rootfs.squashfs.<soc>`.

### Which layout is my camera using?

```sh
cat /proc/cmdline
cat /proc/mtd
```

On the split layout the command line has `mtdparts=sfc:256k(u-boot),64k(env),-(firmware)`,
and `/proc/mtd` shows `firmware` with the three partitions the kernel added:

```
dev:    size   erasesize  name
mtd0: 00040000 00010000 "u-boot"
mtd1: 00010000 00010000 "env"
mtd2: 00fb0000 00010000 "firmware"
mtd3: 001e0000 00010000 "kernel"
mtd4: 00dd0000 00010000 "rootfs"
mtd5: 00730000 00010000 "rootfs_data"
```

`openipc_nor_fit=1` on the command line means the bootloader can boot the split
layout, whichever layout the camera is on now. That's what `sysupgrade` looks
for before it installs a `firmware.bin`.

### Moving a camera to the split layout

1. **Install the OpenIPC U-Boot.** Run this from the U-Boot console with a TFTP
   server, using the file for your SoC. It erases the boot partition only
   (`0x40000`), and leaves the environment where it is:

   ```
   tftp ${baseaddr} u-boot-gk7205v300-nor.bin
   sf probe 0
   sf erase 0x0 0x40000
   sf write ${baseaddr} 0x0 ${filesize}
   reset
   ```

   The camera boots its fixed slots as before. `cat /proc/cmdline` now shows
   `openipc_nor_fit=1`.

2. **Upgrade with `sysupgrade -k -r`.** On a bootloader that boots the layout,
   `sysupgrade` downloads the `-split` package and writes `firmware.bin` at
   `0x50000`. Your settings move with it (see below).

   A camera whose firmware predates the split layout installs the plain package
   on the first run. Run `sysupgrade -k -r` once more to move to the split
   layout.

To set a camera up on the split layout from scratch, erasing its settings:

- **[openipc.org](https://openipc.org):** open your SoC's page
  (`/cameras/vendors/goke/socs/<soc>`, e.g.
  [GK7205V300](https://openipc.org/cameras/vendors/goke/socs/gk7205v300)).
  It installs the `u-boot-<soc>-nor.bin` bootloader. Where the `-split` package
  is published for your edition, it links that package and writes
  `firmware.bin` at `0x50000` with the rest of the chip erased. Editions
  without one, such as OpenIPC/builder's FPV builds, keep the two-image install.
- **[defib](https://github.com/OpenIPC/defib):** `defib install` with the
  `-split` package, over UART.

### Upgrades and your settings

`sysupgrade -k -r`, `--url`, `--channel` and `--archive` work as on any other
camera. Because the overlay starts wherever the new image ends, `sysupgrade`
does more than write the image:

1. It packs the overlay into RAM.
2. It writes `firmware.bin`.
3. It stages the settings where the new `rootfs_data` will start:

   ```
   Writing /tmp/firmware.bin.gk7205v300 at 0x50000
   Settings staged at 0x8d0000 for the first boot
   ```

On the first boot, before the overlay is mounted, the camera restores them:

```
Restoring settings carried over by an upgrade...
Settings restored.
```

`sysupgrade -n` stages nothing to restore. The first boot then starts from
defaults:

```
Clearing settings after an upgrade...
```

`sysupgrade` reads every write back from the flash before it reboots. It refuses
the following before writing anything, and the camera keeps running:

- a `firmware.bin` for another SoC;
- an image that leaves no room for the settings;
- the plain package on a camera already on the split layout;
- a split image on a bootloader without `openipc_nor_fit=1`.

### Writing the image from U-Boot

This replaces everything after the environment and erases the settings. The
erase size is the chip size minus `0x50000`: `0x7b0000` on 8 MB flash, `0xfb0000`
on 16 MB.

```
tftp ${baseaddr} firmware.bin.gk7205v300
sf probe 0
sf erase 0x50000 0xfb0000
sf write ${baseaddr} 0x50000 ${filesize}
reset
```

### Going back to fixed slots

Write `uImage.<soc>` at `0x50000` and `rootfs.squashfs.<soc>` at the fixed
rootfs slot, as in [Upgrade firmware](sysupgrade.md) (*From U-Boot*). On a
U-Boot environment from this bootloader, `run ur; run uk` does the same. The
bootloader sees the uImage at `0x50000` and boots the fixed slots again.

