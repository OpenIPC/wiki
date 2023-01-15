# OpenIPC Wiki
[Table of Content](../index.md)

Upgrading firmware
------------------

### Upgrading from GitHub
For old firmware running `sysupgrade` without parameters is enough. For newer firmware, run `sysupgrade -k -r` to update both kernel and rootfs.

__ATTENTION! Upgrading firmware can lead to "bricking" your camera. Make sure you are prepared both morally and skillwise. Have your rescure SD card or UART adapter ready. Be prepared to desolder and reprogram flash chip as the last resort. Do not upgrade production cameras unless you really have to!__

### Upgrading from a TFTP server
Go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC.
Extract content of the bundle into the root directory of your TFTP server.

On the camera run:
```
soc=$(fw_printenv -n soc)
serverip=$(fw_printenv -n serverip)
busybox tftp -r rootfs.squashfs.${soc} -g ${serverip}
busybox tftp -r uImage.${soc} -g ${serverip}
```

### Upgrading from local files
Go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC.
Unpack the bundle and upload its content on camera using `scp`:
```
tar xvf <firmware.tgz>
scp uImage* rootfs* root@<yourcameraip>:/tmp/
```
On the camera run:
```
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/tmp/uImage.${soc} --rootfs=/tmp/rootfs.squashfs.${soc} -z
```

### Upgrading from SD card

Go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC.
Insert an SD card into your desktop PC. Unpack the bundle and copy its content to the card:
```
tar xvf <firmware.tgz>
cp uImage* rootfs* /media/<username>/<card-id>/
```
Insert the SD card into your camera.
On the camera run:
```
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/mnt/mmcblk0p1/uImage.${soc} --rootfs=/mnt/mmcblk0p1/rootfs.squashfs.${soc} -z
```

### Troubleshooting

If you got this error:
```
losetup: /tmp/rootfs.squashfs.${soc}: No such file or directory
Rootfs: Unable to get hostname, execution was interrupted...
```
then try to update only kernel first:
`sysupgrade -k`

If it doesn't help, use `--force` option:
`sysupgrade -r --force`

If you caught a glitch, retrieve the most recent version of the utility:
```
curl -k -L -o /usr/sbin/sysupgrade "https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade"
```
