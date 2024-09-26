# OpenIPC Wiki
[Table of Content](../README.md)

Upgrading firmware
------------------
Once the initial installation of the OpenIPC software for your camera is complete it is possible to upgrade it either via the web interface or manually via a terminal window.

This article is about how to manually perform an update using a terminal window using the sysupgrade command.

_Note: By default, sysupgrade will reboot the camera to complete the update. If you don't wish to do that then use the -x option (see sysupgrade --help for all options)_.

### Upgrading from the GitHub latest release.
By default, running sysupgrade will attempt to download the latest software for your camera model from the github sources. 

There are other options available so you can use a local copy of the Linux kernel (uImage) and camera software (rootfs.squashfs).

For old firmware running `sysupgrade` without parameters is enough. For newer firmware, run `sysupgrade -k -r` to update both kernel and rootfs is required.

__ATTENTION! Upgrading firmware can lead to "bricking" your camera. Make sure you are prepared both morally and skill wise. Have your rescue SD card and/or UART adapter ready. Be prepared to de-solder and reprogram flash chip as the last resort. Do not upgrade production cameras unless you really have to!__

### Using sysupgrade
Typically running sysupgrade will give you the latest release for your camera, as described above, however if you wish to revert to a previous image, or load your own updates, then use any the options described below. 

Remember once you are ready to run sysupgrade you must use the syntax </br></br>
`sysupgrade --kernel=/tmp/uImage.${soc} --rootfs=/tmp/rootfs.squashfs.${soc} -z` </br></br>where '${soc}' is your camera specific soc e.g. gk7205v300 
otherwise the latest release on Github will be downloaded.

### Using a TFTP server
#### On your host machine:
If you haven't already got a TFTP server running on your host machine then take a look at the Wiki article [Set up a TFTP server](installation-tftpd.md).

If you don't already have the uImage and rootfs.squashfs images for your camera then go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC and extract the content of the bundle into the root directory of your TFTP server.

```bash
tar xvf <firmware.tgz>
```

If you have built your own versions using a copy of the [firmware repository](https://github.com/OpenIPC/firmware) then your uImage and rootsfs.squashfs images will be in your _output/images_ folder. Copy these to the root of your tftp server.

#### On the camera:
You can either update the images from a Linux terminal session or from the U-Boot prompt, if you have a UART serial connection and interrupted Linux loading.

Check that your camera environment variable for the TFTP server is correct by looking for the _serverip_ entry when listing them with _fw_printenv_.

If it needs updating use _fw_setenv serverip <your.tftp.ip.address>_ command.

##### From Linux
```bash
soc=$(fw_printenv -n soc)
serverip=$(fw_printenv -n serverip)
cd /tmp
busybox tftp -r rootfs.squashfs.${soc} -g ${serverip}
busybox tftp -r uImage.${soc} -g ${serverip}
sysupgrade --kernel=/tmp/uImage.${soc} --rootfs=/tmp/rootfs.squashfs.${soc} -z
```

##### From U-Boot

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

Now restart the camera to load the new images.

### Using scp
#### On your host machine:
If you don't already have the uImage and rootfs.squashfs images for your camera then go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC and extract the contents.

```bash
tar xvf <firmware.tgz>
```

If you have built your own versions using a copy of the [firmware repository](https://github.com/OpenIPC/firmware) then your uImage and rootsfs.squashfs images will be in your _output/images_ folder.

Now copy these to the camera using scp.

```bash
scp uImage* rootfs* root@<yourcameraip>:/tmp/
```

**Note:** If you get an error that '/usr/libexec/sftp-server could not be found' it is because in later versions of scp sftp is now used behind the scenes and this is not built into the busybox implementation currently. To force scp to use the legacy behavour use the -O option so 
```bash
scp -O uImage* rootfs* root@<yourcameraip>:/tmp/
```

#### On the camera:
Now create a terminal session with the camera e.g. ssh root@192.168.1.10 and run the sysupgrade command pointing at your new images in /tmp.

```bash
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/tmp/uImage.${soc} --rootfs=/tmp/rootfs.squashfs.${soc} -z
```

### Upgrading from an SD card
#### On your host machine
If you don't already have the uImage and rootfs.squashfs images for your camera then go to <https://github.com/OpenIPC/firmware/releases/tag/latest> and download the latest firmware bundle for your SoC and extract the contents

If you have built your own versions using a copy of the [firmware repository](https://github.com/OpenIPC/firmware) then your uImage and rootsfs.squashfs images will be in your _output/images_ folder.

Insert an SD card into your host machine and copy the uImage and squashfs files to the card e.g.

```bash
cp uImage* rootfs* /media/<username>/<card-id>/
```

#### On your camera
Insert the SD card into your camera.

Create a terminal session and run the following

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

Clean 320K of RAM and load bootloader file into it:

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
