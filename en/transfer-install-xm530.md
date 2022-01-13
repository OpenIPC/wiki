## For XM vendor boards ONLY with SoC XM530/XM550 !!!

### Initial device firmware update

```
#

setenv bootargs 'mem=35M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=xm_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'sf probe 0; sf read 0x80007fc0 0x50000 0x200000; bootm 0x80007fc0'
setenv uk 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 uImage.${soc} && sf probe 0; sf erase 0x50000 0x200000; sf write 0x80007fc0 0x50000 ${filesize}'
setenv ur 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 rootfs.squashfs.${soc} && sf probe 0; sf erase 0x250000 0x500000; sf write 0x80007fc0 0x250000 ${filesize}'
saveenv

setenv soc xm530                 <= Set you SoC as xm530 for xm530 and xm550
setenv osmem 35M                 <= 35M for xm530 and 64M for xm550
setenv totalmem 64M              <= 64M for xm530 and 128M for xm550
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    <= Set you TFTP server IP
saveenv

run uk; run ur; reset            <= Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Notes

After the first flash firmware of the device, please run the **firstboot** command to format the jffs2 partition of the settings.

-----

### Load kernel modules

```
cd /lib/modules/3.10.103\+/xiongmai/
/usr/bin/load_xiongmai
```

P.S. At the moment, video support is in development
