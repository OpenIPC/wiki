## For XM boards ONLY with SoC GK7202V300, GK7205V200, GK7205V300 !!!

### Supported sensors

Please read this [info](https://github.com/OpenIPC/openipc-2.1/wiki/supported_devices).

-----

### Initial device firmware updates

```
#

setenv bootargs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x42000000 0x50000 0x200000; bootm 0x42000000'
setenv uk 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 uImage.${soc} && sf probe 0; sf erase 0x50000 0x200000; sf write 0x42000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 rootfs.squashfs.${soc} && sf probe 0; sf erase 0x250000 0x500000; sf write 0x42000000 0x250000 ${filesize}'
saveenv

setenv soc gk7xxxxxxx            <= Set you SoC as gk7202v300 or gk7205v200 or gk7205v300
setenv osmem 32M
setenv totalmem 64M              <= 64M for gk7202v300 or gk7205v200 and 128M for gk7205v300
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    <= Set you TFTP server IP
saveenv

run uk; run ur; reset            <= Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### A trick for GK7205V300+IMX335 users

```
echo -e "!/bin/sh\n\ndevmem 0x120100f0 32 0x19\n" >/etc/init.d/S96trick; chmod +x /etc/init.d/S96trick
```
Alternative way [here](https://github.com/OpenIPC/firmware/pull/117/files)

-----

### Danger zone

You have the option to always update the bootloader. 

However, you should have the knowledge and replace the bootloader [file](https://github.com/OpenIPC/firmware/releases/tag/latest) name.

```
mw.b 0x42000000 ff 1000000; tftp 0x42000000 u-boot-gk7xxxxxxxx-beta.bin; sf probe 0
sf erase 0x0 0x50000; sf write 0x42000000 0x0 ${filesize}
reset
```
