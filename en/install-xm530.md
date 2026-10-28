# OpenIPC Wiki
[Table of Content](../README.md)

For XM vendor boards with XM530/XM550 SoC ONLY !!!
--------------------------------------------------

### Initial device firmware update

```
setenv bootargs 'mem=35M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=xm_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'sf probe 0; sf read 0x80007fc0 0x50000 0x200000; bootm 0x80007fc0'
setenv uk1 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 uImage.${soc}'
setenv uk2 'sf probe 0; sf erase 0x50000 0x200000; sf write 0x80007fc0 0x50000 ${filesize}'
setenv uk 'run uk1 ; run uk2'
setenv ur1 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 rootfs.squashfs.${soc}'
setenv ur2 'sf probe 0; sf erase 0x250000 0x500000; sf write 0x80007fc0 0x250000 ${filesize}'
setenv ur 'run ur1 ; run ur2'
saveenv

setenv soc xm530                 # Your SoC. xm530 for both xm530 and xm550.
setenv osmem 35M                 # 35M for xm530, 96M for xm550: the same as mem= in bootargs.
setenv totalmem 64M              # 64M for xm530, 128M for xm550.
setenv ipaddr 192.168.1.10       # Your camera IP address.
setenv serverip 192.168.1.254    # Your TFTP server IP address.
saveenv

run uk; run ur; reset            # Flash kernel, rootfs and reboot device
```

On an XM550, replace `mem=35M` in `bootargs` with `mem=96M` before `saveenv`.

#### How memory is split

`mem=` in `bootargs` is the memory Linux gets. The rest of `totalmem` is the media memory zone (MMZ), where the video drivers and the camera application keep their frame and stream buffers. Linux cannot use that memory, even when the zone is mostly empty. `/proc/umap/mmz` lists what is allocated in the zone and shows the free space on its last line.

On an XM550 with an IMX335 at 1080p, majestic uses at most 28.4 MB of the zone: H.264 main stream plus snapshots. H.265 uses 19–22 MB. `mem=96M` leaves a 32 MB zone, which gives Linux 32 MB more than `mem=64M`. If you raise resolutions or add streams, check the free space in `/proc/umap/mmz` first.

To change the split on a camera that is already running OpenIPC:

```
fw_setenv osmem 96M
fw_setenv bootargs $(fw_printenv -n bootargs | sed 's/mem=[0-9]*M/mem=96M/')
reboot
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Notes

After you have finished flashing new firmware, please run `firstboot` command
to format jffs2 partition used to store settings.

### Known issues


### Uboot with out tftp command

```
setenv uk1 'mw.b 0x81000000 ff 1000000; setenv bootfile uImage.${soc}; tftpboot'
setenv uk2 'sf probe 0; sf erase 0x50000 0x200000; sf write 0x81000000 0x50000 ${filesize}'
setenv uk 'run uk1 ; run uk2'
setenv ur1 'mw.b 0x81000000 ff 1000000; setenv bootfile rootfs.squashfs.${soc}; tftpboot'
setenv ur2 'sf probe 0; sf erase 0x250000 0x500000; sf write 0x81000000 0x250000 ${filesize}'
setenv ur 'run ur1 ; run ur2'
saveenv

run uk; run ur; reset
```

### Backup device (no tftpput)

open the serial console with a logfile
Note: dumping via Serial takes long

```
sf probe 0
sf read 0x81000000 0x0 0x800000
md.b 0x81000000 0x800000
```

use `cut -b 11-57 | xxd -r -p` to reconstruct the binary from `md.b` output

