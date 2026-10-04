# OpenIPC Wiki
[Table of Content](../README.md)

NAND flash layouts
==================

A camera with SPI NAND flash (usually 128 MiB) cannot run OpenIPC the way a NOR
camera does. NAND has bad blocks, wears out, and flips bits that ECC has to
correct, so OpenIPC puts almost everything on NAND inside
[UBI](https://docs.kernel.org/filesystems/ubifs.html). UBI is a volume manager
that hides bad blocks, spreads wear, and moves data off a block before its bit
errors become uncorrectable.

### The layout on u-boot-xmedia SoCs

GK7205V500, GK7205V510, GK7205V530, Hi3516EV200, Hi3516EV300, Hi3518EV300 and
Hi3516DV200 all boot the bootloader built by
[u-boot-xmedia](https://github.com/OpenIPC/u-boot-xmedia). On NAND they use this
layout:

```
0x000000  boot   768K   U-Boot
0x0C0000  env    256K   U-Boot environment
0x100000  ubi    rest   one UBI device, to the end of the chip:
            rootfs       UBIFS, the root filesystem with the kernel inside it
            rootfs_data  UBIFS, your settings (the overlay)
```

The kernel isn't kept in a partition or volume of its own. It is a file in the
root filesystem, `/boot/fitImage`: the kernel and its device tree, each with a
CRC32 and a SHA-1 hash. U-Boot mounts the root filesystem, loads that file, checks
both hashes, and refuses to start a kernel the flash has corrupted. During boot
this looks like:

```
Loading file '/boot/fitImage' to addr 0x42000000...
   Verifying Hash Integrity ... crc32+ sha1+ OK
```

No flash is set aside for a kernel, so there is no kernel size to outgrow. The
`rootfs` volume is exactly as big as its image, and `rootfs_data` takes all the
rest. Both sizes change on every upgrade (see below), so a bigger kernel or root
filesystem in a later release simply takes a little more of the flash.

The root filesystem is mounted **read-only** at `/rom`. Everything you change on
the camera goes into `rootfs_data`, which is mounted on top as an overlay. A
factory reset (`firstboot`, or `sysupgrade -n`) empties `rootfs_data` and leaves
the rest alone.

The bootloaders are published per flash type in the
[firmware release](https://github.com/OpenIPC/firmware/releases/tag/latest):
`u-boot-<soc>-nor.bin` and `u-boot-<soc>-nand.bin`. On these SoCs they replace
the older `u-boot-<soc>-universal.bin`.

### Which layout is my camera using?

```sh
cat /proc/cmdline
ls /boot
```

`root=ubi0:rootfs` with `/boot/fitImage` present is the layout above. Anything
else on one of these SoCs is a retired layout (see the end of this page), and
the camera needs reinstalling before it can be upgraded.

### Upgrading with sysupgrade

`sysupgrade` recognises the layout and fetches the NAND package,
`openipc.<soc>-nand-<variant>.tgz`. It writes one image, `rootfs.ubifs`, which
carries the kernel too, so `-k` and `-r` both mean writing it. A local
`--kernel=FILE` on its own is refused: the kernel has to come inside a
`--rootfs=` image.

The root filesystem is in use for as long as the camera runs, and UBI only lets a
volume be rewritten when nothing else has it open. So the upgrade works much like
OpenWrt's. The camera stops its services, moves into a small copy of itself in
RAM and lets go of the flash. Then it:

1. copies your settings out of `rootfs_data` into RAM,
2. removes `rootfs_data`,
3. resizes `rootfs` to the new image,
4. writes the image,
5. creates `rootfs_data` again on everything that is left,
6. puts your settings back, and reboots.

Your console and SSH session end when the camera moves into RAM, and it doesn't
come back until it reboots.

If the settings can't be read or don't fit in RAM, or the new image and the
settings together don't fit the flash, the upgrade stops before anything is
written and the camera reboots as it was. `sysupgrade -r -n` upgrades without
the settings.

A power cut while the volumes are being rebuilt costs you the settings, not the
camera: it boots with its overlay in RAM, as after a factory reset. A cut while
the root filesystem itself is being written leaves no kernel to boot, as on any
camera, and the camera has to be reinstalled from U-Boot.

### Installing

From U-Boot, with a TFTP server holding the files: the bootloader first, then the
UBI image. openipc.org's installation page for each of these SoCs gives the same
commands with your addresses filled in.

```
mw.b ${baseaddr} 0xff 0xc0000
tftpboot ${baseaddr} u-boot-<soc>-nand.bin && nand erase 0x0 0xc0000 && nand write ${baseaddr} 0x0 0xc0000
reset
```

```
tftpboot ${baseaddr} rootfs.ubi.<board> && nand erase.part ubi && nand write.trimffs ${baseaddr} 0x100000 ${filesize}
reset
```

`<board>` is the name in the package: `gk7205v500` for the whole GK7205V500
family, otherwise the SoC itself.

- **`nand erase.part ubi`** erases the UBI partition by name, so to the end of
  the chip, whatever its size. Blocks left with old data past the image would be
  corrupted blocks to UBI when it attaches. The command comes with the current
  u-boot-xmedia NAND build, which is why the bootloader goes on first.
- **`nand write.trimffs`**, never a plain `nand write`, for a UBI image. A UBI
  image pads each block with empty pages. A plain write programs those pages, ECC
  included, and when UBIFS later writes real data into one of them the page has
  been programmed twice and its ECC no longer matches. `trimffs` leaves the
  padding unprogrammed, which is what UBI expects. This is the failure reported
  in [#2519](https://github.com/OpenIPC/firmware/issues/2519).

The bootloader's own `run urnand` does the second step with `rootfs.ubi.${soc}`,
so on a GK7205V510 or GK7205V530 it needs the file renamed to that SoC on the
TFTP server.

Rewriting the bootloader is the one step here that can leave the camera unable to
start at all. Have a way back before you do it, such as a UART adapter and a tool
that loads U-Boot over the SoC's boot ROM, like
[defib](https://github.com/OpenIPC/defib).

### The bootloader

The u-boot-xmedia NAND build boots the layout above and nothing else. Its boot
command mounts `ubi0:rootfs` and loads `/boot/fitImage`, or `/boot/uImage` on an
image built without a FIT, and boots it with `root=ubi0:rootfs`.

The environment survives a reinstall. When the bootloader finds an environment
saved by an earlier OpenIPC bootloader and the new layout is already on the
flash, it brings that environment up to date once:

- it replaces the old stock boot command;
- in `bootargs` it replaces only the hard-coded `root=` arguments, keeping
  everything else, including the memory settings firmware writes there;
- it removes a saved `verify=n`, so the kernel is always checked.

A boot command you edited yourself is left as it is. Until the new layout is
written, a camera keeps the boot command it had, so loading this bootloader into
RAM on a camera you aren't reinstalling changes nothing.

### Retired layouts

Cameras on these layouts keep booting, but `sysupgrade` refuses to upgrade them
and links to the installation page. They have to be reinstalled as above.

- **Split layout** (HiSilicon): a uImage in a raw `kernel` partition
  (`hinand:1024k(boot),1024k(env),8192k(kernel),-(ubi)`), a UBIFS root beside it.
- **Squashfs over ubiblock** on the SoCs above: a uImage in a `kernel` volume,
  the NOR package's squashfs in a `rootfs` volume (`root=/dev/ubiblock0_1`).
- **The first FIT layout** (GK7205V500 family): the FIT in a `kernel` volume of
  its own, a fixed-size UBIFS `rootfs` volume.

All three set flash aside for a kernel, which the current layout does not.

Hi3516AV100, Hi3516AV200, Hi3516DV100, Hi3516CV300 and Hi3518EV200 no longer
get NAND builds. None of them has a bootloader that can install or boot this
layout.

### Building a NAND package

There is no separate NAND build or script. A board whose defconfig enables UBI
produces the NAND package from the ordinary build, next to the NOR one when the
board has squashfs enabled as well. On a SigmaStar board that looks like this:

```
BR2_TARGET_ROOTFS_UBI=y
BR2_TARGET_ROOTFS_UBI_SUBSIZE=2048
BR2_TARGET_ROOTFS_UBI_USE_CUSTOM_CONFIG=y
BR2_TARGET_ROOTFS_UBI_CUSTOM_CONFIG_FILE="$(BR2_EXTERNAL)/scripts/ubifs/ubinize_sigmastar.cfg"
BR2_TARGET_ROOTFS_UBIFS_LEBSIZE=0x1f000
```

The custom config file picks the volume layout. The u-boot-xmedia SoCs use
`board/<family>/ubinize-nand.cfg` in their vendor tree, beside the
`nand-fit.its` their kernel FIT is built from; the other vendors' are under
`general/scripts/ubifs/` in OpenIPC/firmware.

From [OpenIPC/firmware](https://github.com/OpenIPC/firmware):

```sh
make BOARD=ssc338q_ultimate
ls output/images/openipc.*-nand-*.tgz
```

From [OpenIPC/builder](https://github.com/OpenIPC/builder), for a device profile
or one of the shared `devices/common` builds such as `ssc338q_fpv`:

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
| u-boot-xmedia SoCs (above) | `rootfs.ubifs`, `rootfs.ubi`, `fitImage` | `/boot/fitImage` inside the root filesystem; the `fitImage` beside it is what `sysupgrade` reads the SoC from |
| SigmaStar, Rockchip | `rootfs.ubi` only | inside `rootfs.ubi`, as volume `kernel` |

Every file is named after the build, so `rootfs.ubi.ssc338q` and so on. The
build fails if `rootfs.ubi` is over 24 MiB on the u-boot-xmedia SoCs (the RAM a
fresh install loads it into) or over 16 MiB elsewhere.

SigmaStar and Rockchip packages keep a layout of their own, with four volumes:
`kernel` (`uImage`, or `zboot.img` on Rockchip), `rootfs` (squashfs),
`rootfs_data`, and `other`, which fills the rest of the flash. The commands under
[Installing](#installing) are for the u-boot-xmedia SoCs and are not a way to
install a SigmaStar or Rockchip package.

No build produces a raw image of the whole chip, boot loader included. The
`ssc338q-fpv.bin` that [the SSC338Q NAND guide](fpv-sigmastar.md) writes with
`nandwrite` is a one-off image from that guide's download, not the output of a
build.

### See also

- [Upgrade firmware](sysupgrade.md)
- [Factory reset and the unclaimed camera](first-boot.md)
- [#2524](https://github.com/OpenIPC/firmware/issues/2524): NAND layout follow-ups
