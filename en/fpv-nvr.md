# OpenIPC Wiki
[Table of Content](../README.md)

Selecting hardware to complete OpenIPC FPV kits
-----------------------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>


### Upgrade you HI3536 NVR to OpenIPC FPV firmware

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
