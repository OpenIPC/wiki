# OpenIPC Wiki
[Оглавление](../README.md)

Ростелекомовская камера с NAND
------------------------------

```
setenv bootargs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hinand:512k(boot),512k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; nand read 0x42000000 0x100000 0x300000; bootm 0x42000000'

setenv uk 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 uImage.${soc} && nand erase 0x100000 0x200000; nand write 0x42000000 0x100000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 rootfs.squashfs.${soc} && nand erase 0x300000 0x500000; nand write 0x42000000 0x300000 ${filesize}'

setenv soc hi3516ev300
setenv osmem 32M
setenv totalmem 128M
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.107
saveenv

nand erase 0x800000 0x7800000

run uk
run ur
reset
```
