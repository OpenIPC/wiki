# OpenIPC Wiki
[Table of Content](../README.md)

Selecting hardware to complete OpenIPC FPV kits
-----------------------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>


### Upgrade HI3536 NVR board to OpenIPC FPV firmware

- download actual [firmware](https://github.com/OpenIPC/firmware/releases/download/latest/openipc.hi3536dv100-nor-fpv.tgz) from OpenIPC site
- unpack firmware archive to your TFTP server
- connect UART adapter to NVR board
- go to u-boot (press Ctrl+C)
- execute a set of commands each line separately, changing the ip address of the nvr board and the ip address of your tftp server

```
setenv ipaddr 192.168.0.222
setenv serverip 192.168.0.8
setenv netmask 255.255.255.0
setenv bootcmd 'sf probe 0; sf read 0x82000000 0x50000 0x200000; bootm 0x82000000'
setenv uk 'mw.b 0x82000000 ff 1000000; tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x82000000 ff 1000000; tftp 0x82000000 rootfs.squashfs.${soc}; sf probe 0; sf erase 0x250000 0x800000; sf write 0x82000000 0x250000 ${filesize}'
setenv bootargs 'mem=192M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),8192k(rootfs),-(rootfs_data)'
setenv osmem '192M'
setenv totalmem '256M'
setenv soc 'hi3536dv100'
setenv da; setenv du; setenv dr; setenv dw; setenv dl; setenv dc; setenv up; setenv tk; setenv dd; setenv de; setenv jpeg_addr
setenv jpeg_size; setenv vobuf; setenv loadlogo; setenv appVideoStandard; setenv appSystemLanguage; setenv appCloudExAbility
saveenv

run uk
run ur

reset
```

### Alternative variant not ready yet !

Guideline flash Hi3536DV100 NVR board from original to OpenIPC FPV firmware

- Install [PUTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) and [TFTP](https://pjo2.github.io/tftpd64/) server
- Turn off NVR power, Connect USB com to your camera, specify which COM port on your PC
- Go to U-Boot with quick press Ctrl+C at power on
- Execute a set of commands each line separately

```
# Сhanging the ip address of the NVR board and the ip address of your TFTP server
setenv ipaddr 192.168.1.10; setenv serverip 192.168.1.254
mw.b 0x82000000 0xff 0x1000000
tftpboot 0x82000000 openipc-hi3536dv100-fpv-16mb.bin
sf probe 0; sf lock 0;
sf erase 0x0 0x1000000; sf write 0x82000000 0x0 0x1000000
reset
```

![](../images/fpv-nvr-hi3536dv100-openipc-ready-800x600.webp)
