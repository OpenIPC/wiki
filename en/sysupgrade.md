# OpenIPC Wiki
[Table of Content](../README.md)

Upgrading firmware
------------------

### Upgrading from GitHub
For old firmware running `sysupgrade` without parameters is enough. For newer firmware, run `sysupgrade -k -r` to update both kernel and rootfs.

__ATTENTION! Upgrading firmware can lead to "bricking" your camera. Make sure you are prepared both morally and skillwise. Have your rescue SD card and/or UART adapter ready. Be prepared to de-solder and reprogram flash chip as the last resort. Do not upgrade production cameras unless you really have to!__

### Upgrading from a TFTP server

[Set up a TFTP server](installation-tftpd.md).

Go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC.
Extract content of the bundle into the root directory of your TFTP server.

On the camera run:

#### Github: From Linux

```bash
soc=$(fw_printenv -n soc)
serverip=$(fw_printenv -n serverip)
busybox tftp -r rootfs.squashfs.${soc} -g ${serverip}
busybox tftp -r uImage.${soc} -g ${serverip}
```

#### Github: Alternatively, from U-Boot

for 8MB image

```bash
tftp ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}

tftp ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x250000 0x500000; sf write ${baseaddr} 0x250000 ${filesize}
```

for 16MB image

```bash
tftp ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}

tftp ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x250000 0xA00000; sf write ${baseaddr} 0x250000 ${filesize}
```

### Upgrading from local files

Go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC.
Unpack the bundle and upload its content on camera using `scp`:

```bash
tar xvf <firmware.tgz>
scp uImage* rootfs* root@<yourcameraip>:/tmp/
```

On the camera run:

```bash
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/tmp/uImage.${soc} --rootfs=/tmp/rootfs.squashfs.${soc} -z
```

### Upgrading from SD card

#### SD Card: From Linux

Go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC.
Insert an SD card into your desktop PC. Unpack the bundle and copy its content to the card:

```bash
tar xvf <firmware.tgz>
cp uImage* rootfs* /media/<username>/<card-id>/
```

Insert the SD card into your camera.
On the camera run:

```bash
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/mnt/mmcblk0p1/uImage.${soc} --rootfs=/mnt/mmcblk0p1/rootfs.squashfs.${soc} --force_ver -z
```

#### SD Card: Alternatively, from U-Boot

for 8MB image

```bash
mw.b ${baseaddr} 0xff 0x200000
fatload mmc 0:1 ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}

mw.b ${baseaddr} 0xff 0x500000
fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x250000 0x500000; sf write ${baseaddr} 0x250000 ${filesize}
```

for 16MB image

```bash
mw.b ${baseaddr} 0xff 0x300000
fatload mmc 0:1 ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x300000; sf write ${baseaddr} 0x50000 ${filesize}

mw.b ${baseaddr} 0xff 0x500000
fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x350000 0xa00000; sf write ${baseaddr} 0x350000 ${filesize}
```

### Flashing U-Boot via ymodem

Clean 320K of RAM amd load bootloader file into it:

```bash
mw.b ${baseaddr} 0xff 0x50000
loady
```

> _(press "Ctrl-a" followed by ":", then type)_

```bash
exec !! sz --ymodem u-boot.bin
```

After the file if uploaded, write it into ROM:

```bash
sf probe 0
sf erase 0x0 0x50000
sf write ${baseaddr} 0x0 ${filesize}
```

### Troubleshooting

If you got this error:

```console
losetup: /tmp/rootfs.squashfs.${soc}: No such file or directory
Rootfs: Unable to get hostname, execution was interrupted...
```

then try to update only kernel first:
`sysupgrade -k`

If it doesn't help, use `--force` option:
`sysupgrade -r --force`

If you caught a glitch, retrieve the most recent version of the utility:

```bash
curl -k -L -o /usr/sbin/sysupgrade "https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade"
```
