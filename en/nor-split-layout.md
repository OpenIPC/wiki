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
            kernel       a uImage: the kernel with its device tree
                         appended, and a CRC32 in the header
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
a uImage from `0x50000` boots it, the factory one included. When the flash holds
the fixed slots instead, the command line is honoured as before.

### What it needs

**A bootloader that loads a uImage from `0x50000`.** The OpenIPC U-Boot,
`u-boot-<soc>-nor.bin` from the
[firmware release](https://github.com/OpenIPC/firmware/releases/tag/latest), is
the simplest: it looks at what is at `0x50000` on every boot, boots either
layout, and checks the uImage CRC before it starts the kernel:

```
   Verifying Checksum ... OK
```

The older `u-boot-<soc>-universal.bin` and the factory bootloader work too (see
[Keeping the factory U-Boot](#keeping-the-factory-u-boot)).

**The split firmware package** for your SoC,
`openipc.<soc>-nor-<variant>-split.tgz` from the same release, holding
`firmware.bin.<soc>`. The plain `openipc.<soc>-nor-<variant>.tgz` beside it is
the fixed-slot package: `uImage.<soc>` and `rootfs.squashfs.<soc>`.

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

### Moving a camera to the split layout

1. **Optionally, install the OpenIPC U-Boot.** Run this from the U-Boot console
   with a TFTP server, using the file for your SoC. It erases the boot partition
   only (`0x40000`), and leaves the environment where it is:

   ```
   tftp ${baseaddr} u-boot-gk7205v300-nor.bin
   sf probe 0
   sf erase 0x0 0x40000
   sf write ${baseaddr} 0x0 ${filesize}
   reset
   ```

   The camera boots its fixed slots as before.

2. **Upgrade with `sysupgrade -k -r`.** `sysupgrade` downloads the `-split`
   package and writes `firmware.bin` at `0x50000`. Your settings move with it
   (see below).

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
camera.

A new image that is bigger than the running one needs no repartitioning. The
image is not written into `rootfs`, whose size is that of the running image. It
is written into `firmware`, which always runs from `0x50000` to the end of the
chip. `kernel`, `rootfs` and `rootfs_data` are not a partition table on the
flash. The kernel works them out from the image on every boot, from the uImage
header and the squashfs size. On an 8 MB camera:

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
erase size is the chip size minus `0x50000`: `0x7b0000` on 8 MB flash, `0xfb0000`
on 16 MB.

```
tftp ${baseaddr} firmware.bin.gk7205v300
sf probe 0
sf erase 0x50000 0xfb0000
sf write ${baseaddr} 0x50000 ${filesize}
reset
```

### Keeping the factory U-Boot

The factory bootloader of these cameras (XM U-Boot 2016.11) has no FIT support
and its own idea of the partitions, but it reads a uImage from flash and boots
it. Only `bootcmd` has to change, to read the first 2 MiB at `0x50000`; the
kernel finds the rest by itself:

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

### Going back to fixed slots

Write `uImage.<soc>` at `0x50000` and `rootfs.squashfs.<soc>` at the fixed
rootfs slot, as in [Upgrade firmware](sysupgrade.md) (*From U-Boot*). On a
U-Boot environment from this bootloader, `run ur; run uk` does the same. The
bootloader sees the uImage at `0x50000` and boots the fixed slots again.

