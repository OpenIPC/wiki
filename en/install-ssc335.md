# OpenIPC Wiki
[Table of Content](../README.md)

For Anjoy/Brovotech/Gospell/Uniview boards with SSC335 Soc ONLY!!!
------------------------------------------------------------------

### Initial device firmware update

```
setenv bootargs 'mem=${osmem:-32M} console=ttyS0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init LX_MEM=0x3fe0000 mma_heap=mma_heap_name0,miu=0,sz=0x1C00000 mma_memblock_remove=1 mtdparts=NOR_FLASH:256k(boot),64k(tech),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x21000000 0x50000 0x200000; bootm 0x21000000'
setenv uk 'mw.b 0x21000000 ff 1000000; tftpboot 0x21000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x21000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x21000000 ff 1000000; tftpboot 0x21000000 rootfs.squashfs.${soc}; sf probe 0; sf erase 0x250000 0x500000; sf write 0x21000000 0x250000 ${filesize}'
saveenv

setenv soc ssc335                # Your SoC. ssc325, ssc335, or ssc337.
setenv sensor none               # Your sensor. gc2053, imx307, or sc3335.
setenv osmem 32M
setenv totalmem 64M              # 64M for ssc335.
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


### Other info

#### Human-readable processor names for SigmaStar devices.
The data is obtained from the original firmware.

| Engraving | /sys/class/mstar/msys/CHIP_ID | /sys/devices/soc0/soc_id | /sys/devices/soc0/machine        |
|-----------|-------------------------------|--------------------------|----------------------------------|
| SSC325DE  | not found                     | 239                      | INFINITY6 SSC009B-S01A QFN128    |
|           |                               |                          |                                  |
| SSC335    | 0xF2                          | 242                      | INFINITY6B0 SSC009A-S01A QFN88   |
| SSC337    | 0xF2                          | 242                      | INFINITY6B0 SSC009A-S01A QFN88   |
| SSC337DE  | 0xF2                          | 242                      | INFINITY6B0 SSC009B-S01A QFN128  |
| SSC338Q   | 0xF1                          | 241                      | INFINITY6E SSC012B-S01A          |
