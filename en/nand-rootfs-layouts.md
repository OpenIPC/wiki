# OpenIPC Wiki
[Table of Content](../README.md)

NAND flash: squashfs over ubiblock, and UBIFS
=============================================

A camera with SPI NAND flash (usually 128 MiB) cannot run OpenIPC the way a NOR
camera does. NAND has bad blocks, wears out, and flips bits that ECC has to
correct, so OpenIPC puts almost everything on NAND inside
[UBI](https://docs.kernel.org/filesystems/ubifs.html). UBI is a volume manager
that hides bad blocks, spreads wear, and moves data off a block before its bit
errors become uncorrectable.

There are two ways to lay a root filesystem out on top of UBI, and OpenIPC
supports both:

| | squashfs over ubiblock | UBIFS |
|---|---|---|
| Kernel volume | `uImage` | FIT image (`fitImage`: kernel + device tree, hashed) |
| Rootfs volume | `rootfs.squashfs`, the same file as on NOR | `rootfs.ubifs` |
| Kernel command line | `root=/dev/ubiblock0_1 ubi.block=0,1` | `root=ubi0:rootfs rootfstype=ubifs` |
| Firmware package | the **NOR** package (`openipc.<soc>-nor-<variant>.tgz`) | the **NAND** package (`openipc.<soc>-nand-<variant>.tgz`) |
| Settings (overlay) | `rootfs_data` volume, UBIFS | `rootfs_data` volume, UBIFS |
| Where it is used | NAND U-Boot builds of every SoC that [u-boot-xmedia](https://github.com/OpenIPC/u-boot-xmedia) builds | GK7205V500, GK7205V510, GK7205V530 `ultimate` NAND builds |

Both layouts use the same UBI partition with the same three volumes, in this order:

```
mtdparts=nand:768k(boot),256k(env),-(ubi)

ubi0 volume 0  kernel
ubi0 volume 1  rootfs
ubi0 volume 2  rootfs_data   (fills the rest of the flash)
```

In both, the root filesystem is mounted **read-only**. Everything you change on
the camera (settings, files you add) goes into `rootfs_data`, which is mounted on
top as an overlay. A factory reset (`firstboot`, or `sysupgrade -n`) empties
`rootfs_data` and leaves the rest alone. What actually differs between the
layouts is the format of the read-only image underneath, and what that means for
size, checking and upgrades.

### Squashfs over ubiblock

The `rootfs` volume holds a squashfs image, byte for byte the same file the NOR
build of that SoC uses. Squashfs needs a block device, and a UBI volume isn't
one, so the kernel's `ubiblock` driver presents volume 1 as the read-only block
device `/dev/ubiblock0_1` (that is what `ubi.block=0,1` asks for), and the kernel
mounts the squashfs from it.

**Pros**

- **Smallest image.** Squashfs with xz is the densest format OpenIPC builds. In
  one GK7205V500 `ultimate` build the same root filesystem came to 6.5 MiB as
  squashfs and 12.1 MiB as UBIFS.
- **One package for NOR and NAND.** The upgrade downloads the NOR package, about
  8 MB for that build against 21 MB for the NAND one. It also needs less room in
  RAM to unpack before flashing, which matters on a camera that gives Linux only
  32 MiB.
- **Same rootfs as NOR.** A problem that reproduces on a NOR camera of the same
  SoC is running the same files.

**Cons**

- **No checksums.** Squashfs keeps none. A block that has gone bad shows up as
  a decompression error in whichever file happens to use it, not as a clear
  "this image is damaged".
- **The kernel is a legacy uImage.** U-Boot checks its CRC only if `verify` is
  not `n`, and OpenIPC's NAND bootloaders without FIT support set `verify=n` on
  every boot.
- **An extra block layer.** The kernel needs `ubiblock` built in, and reads go
  through it and through the squashfs cache.

### UBIFS

The `rootfs` volume holds a UBIFS image, a filesystem that UBI hosts directly
with no block layer in between. On the GK7205V500 family, the `kernel` volume
holds a FIT image instead of a uImage: the kernel and its device tree, each with
a CRC32 and a SHA-1 hash.

**Pros**

- **The filesystem checks itself.** UBIFS stores a CRC with every node it
  writes, and always checks the nodes that hold the filesystem's structure
  (directories, inodes, the index) when it reads them. Checking file contents
  as well is the `chk_data_crc` mount option, which is off by default. Squashfs
  has no checksums at all.
- **The kernel is checked before it runs.** U-Boot verifies both FIT hashes and
  refuses to boot a kernel or device tree that the flash has corrupted, instead
  of starting it and crashing somewhere later. During boot this looks like:

  ```
  Verifying Hash Integrity ... crc32+ sha1+ OK
  ```

- **No block layer.** UBIFS mounts the volume directly.

**Cons**

- **About twice the size.** UBIFS compresses each node on its own (LZO by
  default), which can't match squashfs with xz. Above: 12.1 MiB against 6.5 MiB.
- **A separate, bigger package.** The NAND package carries `fitImage`,
  `rootfs.ubifs` and `rootfs.ubi` (the whole UBI image, for a fresh install).
  It is about 21 MB to download and needs correspondingly more room in RAM to
  unpack.
- **Its own build.** Only the GK7205V500 family has a UBIFS + FIT NAND build
  today.

### Which one is my camera using?

```sh
cat /proc/cmdline
```

`root=/dev/ubiblock0_1` means squashfs over ubiblock. `root=ubi0:rootfs` means
UBIFS. `mount` shows the same thing from the other side: `ubi0:rootfs on /rom type ubifs`
for UBIFS, a squashfs on `/rom` for ubiblock.

### Upgrading with sysupgrade

`sysupgrade` works out the layout from the kernel command line and fetches the
package that matches it: the NOR package for ubiblock, the NAND package for
UBIFS. With `--archive` or `--url` you choose the file yourself. It refuses a
rootfs in the wrong format before writing anything:

```
This camera boots a UBIFS rootfs, and /tmp/rootfs.squashfs.gk7205v500 is not one. Nothing was written.
```

In both layouts the rootfs volume is in use for as long as the camera runs, and
UBI only lets a volume be rewritten when nothing else has it open. So an upgrade
that writes the rootfs (`-r`, or a full upgrade) or wipes the settings (`-n`)
works much like OpenWrt's. The camera stops its services, moves into a small
copy of itself in RAM, lets go of the flash, writes the volumes, and reboots.
Your console and SSH session end when that move happens, and the camera does not
come back until it reboots. A kernel-only upgrade (`-k`) doesn't need any of this.

**sysupgrade does not convert one layout into the other.** The layout is chosen
by the bootloader environment and installed once. To switch, reinstall from
U-Boot (below) and reset the environment's `bootargs` and `bootcmd` to the
defaults.

### Building a NAND package

There is no separate NAND build or script. A board whose defconfig enables
UBI produces the NAND package from the ordinary build, next to the NOR one when
the board has squashfs enabled as well. On a SigmaStar board that looks like
this:

```
BR2_TARGET_ROOTFS_UBI=y
BR2_TARGET_ROOTFS_UBI_SUBSIZE=2048
BR2_TARGET_ROOTFS_UBI_USE_CUSTOM_CONFIG=y
BR2_TARGET_ROOTFS_UBI_CUSTOM_CONFIG_FILE="$(BR2_EXTERNAL)/scripts/ubifs/ubinize_sigmastar.cfg"
BR2_TARGET_ROOTFS_UBIFS_LEBSIZE=0x1f000
```

The custom config file picks the volume layout. Each vendor has its own under
`general/scripts/ubifs/` in OpenIPC/firmware.

From [OpenIPC/firmware](https://github.com/OpenIPC/firmware):

```sh
make BOARD=ssc338q_ultimate
ls output/images/openipc.*-nand-*.tgz
```

From [OpenIPC/builder](https://github.com/OpenIPC/builder), for a device
profile or one of the shared `devices/common` builds such as `ssc338q_fpv`:

```sh
./builder.sh ssc338q_fpv
ls archive/ssc338q_fpv/*/
```

builder runs the same firmware build, so it produces the same
`openipc.<soc>-nand-<variant>.tgz`. Its `repack.sh` is a different tool: it
writes Wi-Fi credentials into a whole-flash **NOR** image and has no NAND
counterpart.

What the package holds depends on the vendor:

| Vendor | Package contents | Kernel |
|---|---|---|
| SigmaStar, Rockchip | `rootfs.ubi` only | inside `rootfs.ubi`, as volume `kernel` |
| GK7205V500 family | `fitImage`, `rootfs.ubifs`, `rootfs.ubi` | `fitImage`, also inside `rootfs.ubi` |
| Other HiSilicon, Goke | `uImage`, `rootfs.ubi` | `uImage`, written separately |

Every file is named after the SoC, so `rootfs.ubi.ssc338q` and so on. The build
fails if `rootfs.ubi` is over 16 MiB.

The SigmaStar and Rockchip layout has four volumes rather than three: `kernel`
(`uImage`, or `zboot.img` on Rockchip), `rootfs` (squashfs), `rootfs_data`, and
`other`, which fills the rest of the flash.

No build produces a raw image of the whole chip, boot loader included. The
`ssc338q-fpv.bin` that [the SSC338Q NAND guide](fpv-sigmastar.md) writes with
`nandwrite` is a one-off image from that guide's download, not the output of a
build.

### Installing

From U-Boot, with a TFTP server holding the files. The GK7205V500 family shares
one build, so its packages name every file after `gk7205v500`. U-Boot's `${soc}`
is the camera's own SoC, though, so on a GK7205V510 or GK7205V530 rename the
files on the TFTP server to match (`rootfs.ubi.gk7205v510`, and so on).

The commands below erase from 1 MiB, the end of the `boot` and `env`
partitions, to the end of the chip. The U-Boot boot log gives the chip size on
its `Chipsize:` line. The erase length is that size minus 1 MiB:

| Chip | Erase |
|---|---|
| 128 MiB | `nand erase 0x100000 0x7f00000` |
| 256 MiB | `nand erase 0x100000 0xff00000` |

**UBIFS** (GK7205V500 family). The kernel in this package is a FIT image, which
only a FIT-capable bootloader can start, so check yours first (see
[The bootloader](#the-bootloader) below). With an older one the install writes
cleanly and the camera then fails to boot it.

The NAND package's `rootfs.ubi` already contains all three volumes, so on a
128 MiB chip one command writes it:

```
run urnand
```

`urnand` fetches `rootfs.ubi.${soc}` over TFTP, erases the UBI partition, and
writes the image with `nand write.trimffs`. It erases a fixed 128 MiB layout. On
any other chip size, run its steps by hand with the erase length from the table
above (shown here for a 256 MiB chip):

```
tftpboot ${baseaddr} rootfs.ubi.${soc}
nand erase 0x100000 0xff00000
nand write.trimffs ${baseaddr} 0x100000 ${filesize}
```
 Use `write.trimffs`, not a plain
`nand write`, if you ever write a UBI image by hand. A UBI image pads each block
with empty pages. A plain write programs those pages, ECC included. When UBIFS
later writes real data into one of them, the page has been programmed twice and
its ECC no longer matches. `trimffs` leaves the padding unprogrammed, which is
what UBI expects. This is the failure reported in
[#2519](https://github.com/OpenIPC/firmware/issues/2519).

**Squashfs over ubiblock**: create the three volumes and write the NOR package's
two files into them. The order matters: `rootfs` must be volume 1. The erase
line is the 128 MiB one; use the table above for another size.

```
nand erase 0x100000 0x7f00000
ubi part ubi
ubi create kernel 0x400000
ubi create rootfs 0x1000000
ubi create rootfs_data
tftpboot ${baseaddr} uImage.${soc}
ubi write ${baseaddr} kernel ${filesize}
tftpboot ${baseaddr} rootfs.squashfs.${soc}
ubi write ${baseaddr} rootfs ${filesize}
```

`rootfs_data` is left empty, and the camera formats it as UBIFS on first boot.
The size you give `rootfs` caps every future upgrade's rootfs, so leave
headroom.

### The bootloader

On a GK7205V500-family NAND camera, the U-Boot built with FIT support boots
**both** layouts. Its boot command reads the `kernel` volume first. A FIT image
gets the UBIFS root, anything else gets the ubiblock root.

That bootloader also brings an environment saved by an older one up to date, once,
on its first boot. It removes a saved `verify=n` so the FIT hashes are checked. It
replaces the stock boot command of the older bootloader. And in `bootargs` it
replaces only the hard-coded `root=` arguments, keeping everything else,
including the memory settings that firmware writes there. A boot command you
edited yourself is left as it is.

The NAND bootloaders that u-boot-xmedia builds for other SoCs boot only the
ubiblock layout.

To tell whether a GK7205V500-family camera already has the FIT-capable U-Boot,
type `help fdt` at its prompt. The FIT build has the `fdt` command, and an older
one answers `Unknown command`. To install it, download
`u-boot-<soc>-nand.bin` for your SoC from the
[firmware release](https://github.com/OpenIPC/firmware/releases/tag/latest),
put it on the TFTP server, and write it over the `boot` partition:

```
mw.b ${baseaddr} ff 0xc0000
tftpboot ${baseaddr} u-boot-${soc}-nand.bin
nand erase 0 0xc0000
nand write ${baseaddr} 0 0xc0000
reset
```

Rewriting the bootloader is the one step here that can leave the camera unable
to start at all. Have a way back before you do it, such as a UART adapter and a
tool that loads U-Boot over the SoC's boot ROM, like
[defib](https://github.com/OpenIPC/defib).

### A third layout: HiSilicon with a raw kernel partition

Some HiSilicon NAND installs (Hi3516EV200, Hi3516EV300 `ultimate`) keep the kernel
outside UBI, in its own flash partition, and use UBI only for the root filesystem:

```
mtdparts=hinand:1024k(boot),1024k(env),8192k(kernel),-(ubi)
```

The rootfs there is UBIFS (`rootfs.ubi`, `root=ubi0:rootfs`), but the kernel is
a uImage in a raw partition that UBI does not manage. `sysupgrade` does not treat
it as a UBI layout, and its upgrade path is not covered on this page.

### See also

- [Upgrade firmware](sysupgrade.md)
- [Factory reset and the unclaimed camera](first-boot.md)
- [#2524](https://github.com/OpenIPC/firmware/issues/2524): NAND layout follow-ups
