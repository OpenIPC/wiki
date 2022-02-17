# OpenIPC Wiki
[Table of Content](index.md)

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
setenv osmem 35M                 # 35M for xm530, 64M for xm550.
setenv totalmem 64M              # 64M for xm530, 128M for xm550.
setenv ipaddr 192.168.1.10       # Your camera IP address.
setenv serverip 192.168.1.254    # Your TFTP server IP address.
saveenv

run uk; run ur; reset            # Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Notes

After you have finished flashing new firmware, please run `firstboot` command
to format jffs2 partition used to store settings.

### Load kernel modules

```
cd /lib/modules/3.10.103\+/xiongmai/
/usr/bin/load_xiongmai
```
