# Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bo mạch XM với SoC Hi35{16Ev200,16Ev300,18Ev300}!!!
------------------------------------------------------------

Các bo mạch khác có thể có bố cục bộ nhớ khác, ví dụ như HI3518Ev200 sử dụng 0x82000000 thay vì 0x42000000.

### Cảm biến được hỗ trợ

Vui lòng tra cứu cảm biến của bạn trong [danh sách thiết bị được hỗ trợ][1].

### Cập nhật firmware thiết bị ban đầu

```
setenv bootargs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x42000000 0x50000 0x200000; bootm 0x42000000'
setenv uk 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 uImage.${soc} && sf probe 0; sf erase 0x50000 0x200000; sf write 0x42000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 rootfs.squashfs.${soc} && sf probe 0; sf erase 0x250000 0x500000; sf write 0x42000000 0x250000 ${filesize}'
saveenv

setenv soc hi351xxxxxxx          # Đặt SoC của bạn. hi3516ev200, hi3516ev300, hoặc hi3518ev300.
setenv osmem 32M
setenv totalmem 64M              # 64M cho hi3516ev200, hi3518ev300, 128M cho hi3516ev300.
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    # Địa chỉ IP máy chủ TFTP của bạn.
saveenv

run uk; run ur; reset            # Flash kernel, rootfs và khởi động lại thiết bị
```

### Các bản cập nhật nhanh tiếp theo

```
run uk; run ur; reset
```

### Thực thi lệnh sau lần chạy đầu tiên

Đối với bo mạch Hi3516Ev300:
```
set_allocator cma
firstboot
```

Đối với bo mạch Hi3516Ev200 hoặc Hi3518Ev300:
```
set_allocator hisi
firstboot
```

### Khu vực nguy hiểm

Bạn luôn có tùy chọn cập nhật bootloader. Tuy nhiên, bạn cần hiểu rõ những gì bạn đang làm.

Lưu ý! Thay thế tên tệp bootloader bằng tên phù hợp với SoC của bạn.
Danh sách đầy đủ có [tại đây](https://github.com/OpenIPC/firmware/releases/tag/latest).

```
mw.b 0x42000000 ff 1000000
tftp 0x42000000 u-boot-hi3516xxxxx-beta.bin
sf probe 0
sf erase 0x0 0x50000
sf write 0x42000000 0x0 ${filesize}
reset
```

[1]: guide-supported-devices.md


### U-Boot không có lệnh tftp

```
setenv uk 'mw.b 0x42000000 ff 1000000; setenv bootfile uImage.${soc} && tftpboot && sf probe 0; sf erase 0x50000 0x200000; sf write 0x40080000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; setenv bootfile rootfs.squashfs.${soc} && tftpboot && sf probe 0; sf erase 0x250000 0x500000; sf write 0x40080000 0x250000 ${filesize}'
```


### Sao lưu thiết bị

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    # Địa chỉ IP máy chủ TFTP của bạn.

sf read 0x42000000 0x0 0x800000
tftpput 0x42000000 0x800000 backup.img
```


### Khôi phục thiết bị

Nếu có sự cố xảy ra, u-boot có thể bị brick!

```
setenv bootfile backup.img
tftpboot
sf probe 0
sf erase 0x0000 0x800000
sf write 0x40080000 0x0 ${filesize}
reset
```

