# OpenIPC Wiki
[Table of Content](../README.md)

NOR split layout
================

A NOR camera normally keeps the kernel and the root filesystem in fixed slots:
2 MiB for the kernel at `0x50000`, then 5 MiB (8 MB flash) or 10 MiB (16 MB
flash) for the root filesystem, then the overlay with your settings. Each image
has to fit its own slot. A kernel that grows past 2 MiB cannot borrow the room
the root filesystem leaves free, and the other way round.

The split layout puts kernel and root filesystem back to back in one partition,
and only their sum has to fit the chip. These SoCs use it:

| SoC | Boot area | Firmware from | Bootloader | Packages |
|-----|-----------|---------------|------------|----------|
| GK7205V200, GK7205V300, GK7202V300, GK7605V100 | 256K boot + 64K env | `0x50000` | `u-boot-<soc>-nor.bin` | `-split` and the fixed-slot one |
| Hi3516CV300, Hi3516EV100 | 256K boot + 64K env | `0x50000` | `u-boot-<soc>-nor.bin` | `-split` and the fixed-slot one |
| Hi3516EV200, Hi3518EV300, Hi3516DV200 | 256K boot + 64K env | `0x50000` | `u-boot-<soc>-nor.bin` | `-split` and the fixed-slot one |
| Hi3516EV300 | 256K boot + 64K env | `0x50000` | `u-boot-<soc>-nor.bin` | `-split` only (neo: fixed slots) |
| GK7205V500, GK7205V510, GK7205V530 | 256K boot + 64K env | `0x50000` | `u-boot-<soc>-nor.bin` | `-split` and the fixed-slot one, both `gk7205v500` |
| GK7201V200 | 256K boot + 64K env | `0x50000` | `u-boot-gk7201v200-nor.bin` | `-split` and the fixed-slot one |
| Hi3516CV200, Hi3518EV200 | 256K boot + 64K env | `0x50000` | `u-boot-<soc>-nor.bin`, or the older `-universal.bin` (U-Boot 2010.06), which boots the split image as well | `-split` and the fixed-slot one |
| Hi3516CV610, Hi3516CV608 | 256K boot + 64K env | `0x50000` | `boot-<soc>[-<board>]-nor.bin` | `-split` only |
| Hi3519DV500 | 512K boot + 256K env | `0xC0000` | `boot-hi3519dv500-<board>-nor.bin` | `-split` only |

```
0x000000  u-boot    boot      U-Boot (on Hi3516CV6xx/Hi3519DV500 the signed
                              boot image, with the board's memory setup)
          env       env       U-Boot environment
firmware  firmware  rest      one image, divided by the kernel at boot:
            kernel       a uImage: the kernel with its device tree (appended
                         on 32-bit parts; on Hi3519DV500 a multi-file uImage
                         carrying it), and a CRC32 in the header
            rootfs       the squashfs, from the next 64 KiB block
            rootfs_data  your settings (the overlay), from the end of the
                         squashfs to the end of the chip
```

The image is `firmware.bin`. The layout lives in the kernel, not on the command
line: the device tree names `u-boot`, `env` and `firmware`, and the kernel's
`mtdsplit` finds where the uImage ends and the squashfs begins, then adds the
`kernel`, `rootfs` and `rootfs_data` partitions itself. A bigger or smaller
image simply moves where `rootfs_data` starts.

Because of that, the kernel ignores whatever `mtdparts=` and `root=` the
bootloader passes when the flash holds a split image. Any U-Boot that can read
a uImage from the start of the firmware partition boots it, the factory one
included. When the flash holds the fixed slots instead, the command line is
honoured as before.

The kernel is still read by the bootloader in one go, so it has a limit of its
own: 2 MiB on every SoC above but Hi3519DV500, where it is 6 MiB. The build
refuses a kernel larger than that.

### What it needs

**A bootloader that loads a uImage from the firmware offset.** The OpenIPC
U-Boot from the
[firmware release](https://github.com/OpenIPC/firmware/releases/tag/latest) is
the simplest: it looks at what is at the firmware offset on every boot, boots
either layout, and checks the uImage CRC before it starts the kernel:

```
   Verifying Checksum ... OK
```

On the GK7205V200 family it is `u-boot-<soc>-nor.bin`. Hi3516CV610, Hi3516CV608
and Hi3519DV500 boot a signed image -- the first-stage loader, the DDR table and
U-Boot -- published once per board, because the DDR table is the board's:

| Board | Boot image |
|-------|------------|
| Hi3516CV610, DDR2 64 MB (QFN) | `boot-hi3516cv610-10b-nor.bin` |
| Hi3516CV610, DDR3 128 MB (QFN) | `boot-hi3516cv610-20s-nor.bin` (`-20g` alike) |
| Hi3516CV610, DDR3 512 MB (BGA) | `boot-hi3516cv610-00s-nor.bin` (`-00g` alike) |
| Hi3516CV608, DDR2 64 MB | `boot-hi3516cv608-nor.bin` |
| Hi3519DV500, DDR4 2 GB, 6-layer board | `boot-hi3519dv500-dmeb-nor.bin` |
| Hi3519DV500, DDR4 2 GB, 4-layer fly-by board | `boot-hi3519dv500-dmebpro-nor.bin` |

The wrong DDR table does not train the memory: the camera stops in the boot
ROM and has to be recovered over UART (for example with
[defib](https://github.com/OpenIPC/defib)).

On Hi3516CV6xx and Hi3519DV500 these bootloaders also work out the size of the
DRAM at boot, and the kernel measures it again and lays out the media memory
itself; nothing about memory has to be set in the environment.

**The split firmware package** for your SoC from the same release:
`openipc.<soc>-nor-<variant>-split.tgz`, holding `firmware.bin.<soc>`. One
build serves Hi3516CV610 and Hi3516CV608 (`openipc.hi3516cv6xx-nor-lite-split.tgz`,
`-ultimate-split.tgz`) and one Hi3519DV500 (`openipc.hi3519dv500-nor-ultimate-split.tgz`;
there is no Lite). On the GK7205V200 family the plain `openipc.<soc>-nor-<variant>.tgz`
beside it is the fixed-slot package: `uImage.<soc>` and `rootfs.squashfs.<soc>`.

### Which layout is my camera using?

```sh
cat /proc/cmdline
cat /proc/mtd
```

On the split layout `/proc/mtd` shows `firmware` with the three partitions the
kernel added, and the kernel log says where they came from:

```
sfc: split NOR layout, device tree partitions
```

```
dev:    size   erasesize  name
mtd0: 00040000 00010000 "u-boot"
mtd1: 00010000 00010000 "env"
mtd2: 00fb0000 00010000 "firmware"
mtd3: 001e0000 00010000 "kernel"
mtd4: 00dd0000 00010000 "rootfs"
mtd5: 00730000 00010000 "rootfs_data"
```

On Hi3519DV500 `u-boot` is `00080000`, `env` `00040000`, and `firmware` starts
at `0xc0000`.

### Moving a camera to the split layout

1. **Optionally, install the OpenIPC U-Boot.** Run this from the U-Boot console
   with a TFTP server, using the file for your SoC (and board). It erases the
   boot partition only, and leaves the environment where it is. The boot
   partition is `0x40000` on all but Hi3519DV500, where it is `0x80000`:

   ```
   tftp ${baseaddr} u-boot-gk7205v300-nor.bin
   sf probe 0
   sf erase 0x0 0x40000
   sf write ${baseaddr} 0x0 ${filesize}
   reset
   ```

   On Hi3519DV500, with the image for your board:

   ```
   tftp ${baseaddr} boot-hi3519dv500-dmeb-nor.bin
   sf probe 0
   sf erase 0x0 0x80000
   sf write ${baseaddr} 0x0 ${filesize}
   reset
   ```

   The camera boots its fixed slots as before.

2. **Upgrade with `sysupgrade -k -r`.** `sysupgrade` downloads the `-split`
   package and writes `firmware.bin` at the firmware offset, which it reads
   from the camera's partitions. Your settings move with it (see below).

   A GK7205V200-family camera whose firmware predates the split layout
   installs the plain package on the first run. Run `sysupgrade -k -r` once
   more to move to the split layout. Hi3516CV6xx and Hi3519DV500 have no plain
   package any more: `sysupgrade` fetches its newest version before an upgrade
   and goes straight to the split one.

To set a camera up on the split layout from scratch, erasing its settings:

- **[openipc.org](https://openipc.org):** open your SoC's page
  (`/cameras/vendors/<vendor>/socs/<soc>`, e.g.
  [GK7205V300](https://openipc.org/cameras/vendors/goke/socs/gk7205v300)).
  Hi3516CV6xx and Hi3519DV500 have a page per board, named for its boot image:
  [Hi3516CV610 DDR3 128 MB](https://openipc.org/cameras/vendors/hisilicon/socs/hi3516cv610-ddr3-128m),
  [Hi3519DV500 dmeb](https://openipc.org/cameras/vendors/hisilicon/socs/hi3519dv500-dmeb)
  and the rest. The page installs the bootloader, links the `-split` package
  where it is published, and writes `firmware.bin` at the firmware offset with
  the rest of the chip erased. Editions without one, such as OpenIPC/builder's
  FPV builds, keep the two-image install.
- **[defib](https://github.com/OpenIPC/defib):** `defib install` with the
  `-split` package, over UART.
- **A full flash image** from the
  [image release](https://github.com/OpenIPC/firmware/releases/tag/image): the
  boot image at 0 and `firmware.bin` at the firmware offset, e.g.
  `openipc-hi3516cv610-ddr3-128m-nor-lite.bin` or
  `openipc-hi3519dv500-dmeb-nor-ultimate.bin`, for a programmer.

### Upgrades and your settings

`sysupgrade -k -r`, `--url`, `--channel` and `--archive` work as on any other
camera.

A new image that is bigger than the running one needs no repartitioning. The
image is not written into `rootfs`, whose size is that of the running image. It
is written into `firmware`, which always runs from the firmware offset to the
end of the chip. `kernel`, `rootfs` and `rootfs_data` are not a partition table
on the flash. The kernel works them out from the image on every boot, from the
uImage header and the squashfs size. On an 8 MB camera:

```
mtd2: 007b0000 "firmware"      the image is written here, 7872K
mtd3: 001e0000 "kernel"        worked out at boot from the image
mtd4: 005d0000 "rootfs"
mtd5: 000d0000 "rootfs_data"
```

An image 100K bigger than the running one moves the start of `rootfs_data` on by
two 64 KiB blocks, and the overlay is 128K smaller after the reboot. Because the
overlay starts wherever the new image ends, `sysupgrade` does more than write the
image:

1. It checks that the new image leaves room for the settings, and refuses
   before writing anything if it does not.
2. It packs the overlay into RAM.
3. It writes `firmware.bin` into `firmware`, over the old image and the old
   overlay.
4. It works out where the new `rootfs_data` will start (the uImage and the
   squashfs, each rounded up to 64 KiB), and stages the settings there:

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
- the plain package on a camera already on the split layout.

### Writing the image from U-Boot

This replaces everything after the environment and erases the settings. The
erase size is the chip size minus the firmware offset: with `0x50000`, `0x7b0000`
on 8 MB flash and `0xfb0000` on 16 MB; on Hi3519DV500 (`0xc0000`), `0xf40000` on
16 MB.

```
tftp ${baseaddr} firmware.bin.gk7205v300
sf probe 0
sf erase 0x50000 0xfb0000
sf write ${baseaddr} 0x50000 ${filesize}
reset
```

```
tftp ${baseaddr} firmware.bin.hi3519dv500
sf probe 0
sf erase 0xc0000 0xf40000
sf write ${baseaddr} 0xc0000 ${filesize}
reset
```

### Keeping the factory U-Boot

The factory bootloader of the GK7205V200-family cameras (XM U-Boot 2016.11) has
no FIT support and its own idea of the partitions, but it reads a uImage from
flash and boots it. Only `bootcmd` has to change, to read the first 2 MiB at
`0x50000`; the kernel finds the rest by itself:

```
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x42000000 0x50000 0x200000;bootm 0x42000000'
saveenv
```

Then write `firmware.bin` as in [Writing the image from U-Boot](#writing-the-image-from-u-boot).
The factory `root=/dev/mtdblock1` and `mtdparts=` stay on the command line and
are ignored:

```
VFS: root=/dev/mtdblock1 ignored, the flash names its own root
```

The factory U-Boot keeps its environment at `0x30000`, inside its own 256K,
while `fw_printenv` on the camera reads `0x40000`. Change the boot settings
from the U-Boot console, not with `fw_setenv`. `sysupgrade` works as usual.

The same goes for a vendor U-Boot on Hi3516CV6xx or Hi3519DV500, as long as it
reads the kernel from the firmware offset: 2 MiB from `0x50000`, or 6 MiB from
`0xc0000` on Hi3519DV500. Its boot image has to match the board's DDR, as above.

On Hi3516CV300 and Hi3516EV100 the older OpenIPC U-Boot 2010.06
(`u-boot-<soc>-universal.bin`) boots the split image unchanged: its `bootcmdnor`
reads 3 MiB from `0x50000`, and the kernel ignores the `root=` and the fixed
`mtdparts=` it passes. A Hi3516CV300 board with that U-Boot and its 16 MB
`mtdparts` booted `firmware.bin` from `0x50000` this way. For the scan, `fwupd`
and SD/USB recovery, install `u-boot-<soc>-nor.bin` (U-Boot 2022.10).

### Going back to fixed slots

On the GK7205V200 family: write `uImage.<soc>` at `0x50000` and
`rootfs.squashfs.<soc>` at the fixed rootfs slot, as in
[Upgrade firmware](sysupgrade.md) (*From U-Boot*). On a U-Boot environment from
this bootloader, `run ur; run uk` does the same. The bootloader sees the uImage
at `0x50000` and boots the fixed slots again. Hi3516CV300, Hi3516EV100,
Hi3516EV200, Hi3518EV300, Hi3516DV200, the GK7205V500 family, GK7201V200,
Hi3516CV200 and Hi3518EV200 go back the same way. Hi3516CV6xx,
Hi3519DV500 and Hi3516EV300 (lite and ultimate) are built only for the split
layout: Hi3516EV300's kernel fills the 2 MiB kernel slot, so no fixed-slot
package of it can ship beside the split one.
