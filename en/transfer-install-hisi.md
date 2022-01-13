## For XM boards ONLY with SoC Hi35{16Ev200,16Ev300,18Ev300} !!!

### Supported sensors

Please read this [info](https://github.com/OpenIPC/openipc-2.1/wiki/supported_devices).

-----

### Initial device firmware updates

```
#

setenv bootargs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x42000000 0x50000 0x200000; bootm 0x42000000'
setenv uk 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 uImage.${soc} && sf probe 0; sf erase 0x50000 0x200000; sf write 0x42000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 rootfs.squashfs.${soc} && sf probe 0; sf erase 0x250000 0x500000; sf write 0x42000000 0x250000 ${filesize}'
saveenv

setenv soc hi351xxxxxxx          <= Set you SoC as hi3516ev200 or hi3516ev300 or hi3518ev300
setenv osmem 32M
setenv totalmem 64M              <= 64M for hi3516ev200 or hi3518ev300 and 128M for hi3516ev300
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    <= Set you TFTP server IP
saveenv

run uk; run ur; reset            <= Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

-----

### Executing a command after the first run

If you have Hi3516Ev300 based board run this command:

```
set_allocator cma
firstboot
```

If you have Hi3516Ev200 or Hi3518Ev300 based board run this command:

```
set_allocator hisi
firstboot
```

-----

### Danger zone

You have the option to always update the bootloader. 

However, you should have the knowledge and replace the bootloader [file](https://github.com/OpenIPC/firmware/releases/tag/latest) name.

```
mw.b 0x42000000 ff 1000000; tftp 0x42000000 u-boot-hi3516xxxxx-beta.bin; sf probe 0
sf erase 0x0 0x50000; sf write 0x42000000 0x0 ${filesize}
reset
```
