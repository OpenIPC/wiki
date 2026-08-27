# OpenIPC Wiki
[Table of Content](../README.md)

For XM boards with Hi35{16Ev200,16Ev300,18Ev300} SoC ONLY!!!
------------------------------------------------------------

Other boards may have different memory layout like HI3518Ev200
uses 0x82000000 instead 0x42000000

### Supported sensors

Please look up your sensor in [the list of supported devices][1].

### Initial device firmware updates

```
setenv bootargs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x42000000 0x50000 0x200000; bootm 0x42000000'
setenv uk 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 uImage.${soc} && sf probe 0; sf erase 0x50000 0x200000; sf write 0x42000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 rootfs.squashfs.${soc} && sf probe 0; sf erase 0x250000 0x500000; sf write 0x42000000 0x250000 ${filesize}'
saveenv

setenv soc hi351xxxxxxx          # Set your SoC. hi3516ev200, hi3516ev300, or hi3518ev300.
setenv osmem 32M
setenv totalmem 64M              # 64M for hi3516ev200, hi3518ev300, 128M for hi3516ev300.
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    # Your TFTP server IP address.
saveenv

run uk; run ur; reset            # Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Executing a command after the first run

For a Hi3516Ev300 board:
```
set_allocator cma
firstboot
```

For a Hi3516Ev200 or Hi3518Ev300 board:
```
set_allocator hisi
firstboot
```

### Danger zone

You always have an option to update the bootloader. However, you need to
understand what you do.

NB! Replace bootloader filename with the one matching your SoC. 
Full list is [here](https://github.com/OpenIPC/firmware/releases/tag/latest).

#### Hi3518EV200: check whether your board is DDR2 or DDR3 first

This SoC ships with either kind of memory and the two bootloaders are not
interchangeable — the DRAM type is fixed in a register table inside the image,
so the wrong one leaves the board with no working memory at all. It flashes
and verifies perfectly and then boots nothing, which looks like a bad flash
and is not one.

Read the memory controller from any working HiSilicon U-Boot prompt — the
vendor's own bootloader will do, you do not need OpenIPC running yet:

```
hisilicon # md.l 0x20111050 1
20111050: 00000016    ....
```

The last hex digit is the DRAM type:

| last digit | memory | bootloader to flash |
|---|---|---|
| `5` | DDR2 | `u-boot-hi3518ev200-universal.bin` |
| `6` | DDR3 | `u-boot-hi3518ev200-ddr3-universal.bin` |

Do not tell the two apart by file size or checksum — the build embeds a
timestamp, so those change between builds of identical sources.

The `-recovery.bin` images are a different thing again: they are built to fit
the boot ROM's SRAM window so they can be uploaded over UART to a board that
will not boot at all. Do not flash them.

Use `${baseaddr}` rather than a literal address. `0x42000000` is only RAM on
SoCs whose DRAM starts at `0x40000000` (Hi3516EV200/EV300, Hi3518EV300,
GK720x). On Hi3516CV200 and Hi3518EV200 DRAM starts at `0x80000000`, so that
address is not memory at all and the command ends in `data abort` and a reset.
U-Boot already sets `baseaddr` correctly for the board; if `printenv baseaddr`
comes back empty see [Help: U-Boot](help-uboot.md).

```
printenv baseaddr
mw.b ${baseaddr} ff 1000000
tftp ${baseaddr} u-boot-hi3516xxxxx-beta.bin
sf probe 0
sf erase 0x0 0x50000
sf write ${baseaddr} 0x0 ${filesize}
reset
```

Run those as separate lines, and do not join them into one line with `&&`:
U-Boot expands `${filesize}` when it parses the line, before `tftp` has run
and set it, so the write gets no length and does nothing.

Note also that `sf erase 0x0 0x50000` deliberately clears only the bootloader
and its environment. Erasing the whole chip (`sf erase 0x0 0x1000000`) takes
the kernel and rootfs with it, and the board will not boot again until all
three are written back.

[1]: guide-supported-devices.md


### Uboot without tftp command

```
setenv uk 'mw.b 0x42000000 ff 1000000; setenv bootfile uImage.${soc} && tftpboot && sf probe 0; sf erase 0x50000 0x200000; sf write 0x40080000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; setenv bootfile rootfs.squashfs.${soc} && tftpboot && sf probe 0; sf erase 0x250000 0x500000; sf write 0x40080000 0x250000 ${filesize}'
```


### backup device

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    # Your TFTP server IP address.

sf read 0x42000000 0x0 0x800000
tftpput 0x42000000 0x800000 backup.img
```


### restore device

if something goes wrong uboot can be bricked!

```
setenv bootfile backup.img
tftpboot
sf probe 0
sf erase 0x0000 0x800000
sf write 0x40080000 0x0 ${filesize}
reset
```
