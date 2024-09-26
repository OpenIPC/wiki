# Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bo mạch của các nhà cung cấp Anjoy/Brovotech/Gospell/Uniview với SoC SSC335!!!
------------------------------------------------------------------

### Cập nhật firmware thiết bị ban đầu

```
setenv bootargs 'mem=${osmem:-32M} console=ttyS0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init LX_MEM=0x3fe0000 mma_heap=mma_heap_name0,miu=0,sz=0x1C00000 mma_memblock_remove=1 mtdparts=NOR_FLASH:256k(boot),64k(tech),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x21000000 0x50000 0x200000; bootm 0x21000000'
setenv uk 'mw.b 0x21000000 ff 1000000; tftpboot 0x21000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x21000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x21000000 ff 1000000; tftpboot 0x21000000 rootfs.squashfs.${soc}; sf probe 0; sf erase 0x250000 0x500000; sf write 0x21000000 0x250000 ${filesize}'
saveenv

setenv soc ssc335                # SoC của bạn. ssc325, ssc335, hoặc ssc337.
setenv sensor none               # Cảm biến của bạn. gc2053, imx307, hoặc sc3335.
setenv osmem 32M
setenv totalmem 64M              # 64M cho ssc335.
setenv ipaddr 192.168.1.10       # Địa chỉ IP camera của bạn.
setenv serverip 192.168.1.254    # Địa chỉ IP máy chủ TFTP của bạn.
saveenv

run uk; run ur; reset            # Flash kernel, rootfs và khởi động lại thiết bị
```

### Cập nhật nhanh tiếp theo

```
run uk; run ur; reset
```

### Ghi chú

Sau khi bạn hoàn thành việc flash firmware mới, vui lòng chạy lệnh `firstboot`
để định dạng phân vùng `jffs2` được sử dụng để lưu trữ cài đặt.


### Thông tin khác

#### Tên bộ xử lý ở dạng văn bản dành cho thiết bị SigmaStar.
Dữ liệu được lấy từ firmware gốc.

| Khắc | /sys/class/mstar/msys/CHIP_ID | /sys/devices/soc0/soc_id | /sys/devices/soc0/machine        |
|-----------|-------------------------------|--------------------------|----------------------------------|
| SSC325DE  | không tìm thấy              | 239                      | INFINITY6 SSC009B-S01A QFN128    |
|           |                               |                          |                                  |
| SSC335    | 0xF2                          | 242                      | INFINITY6B0 SSC009A-S01A QFN88   |
| SSC337    | 0xF2                          | 242                      | INFINITY6B0 SSC009A-S01A QFN88   |
| SSC337DE  | 0xF2                          | 242                      | INFINITY6B0 SSC009B-S01A QFN128  |
| SSC338Q   | 0xF1                          | 241                      | INFINITY6E SSC012B-S01A          |



