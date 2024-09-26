# Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bo mạch của nhà cung cấp XM với SoC XM510!!!
-------------------------------------------

### Cập nhật firmware thiết bị ban đầu

```
setenv bootargs 'mem=18M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=xm_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'sf probe 0; sf read 0x80007fc0 0x50000 0x200000; bootm 0x80007fc0'
setenv uk1 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 uImage.${soc}'
setenv uk2 'sf probe 0; sf erase 0x50000 0x200000; sf write 0x80007fc0 0x50000 ${filesize}'
setenv uk 'run uk1 ; run uk2'
setenv ur1 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 rootfs.squashfs.${soc}'
setenv ur2 'sf probe 0; sf erase 0x250000 0x500000; sf write 0x80007fc 0x250000 ${filesize}'
setenv ur 'run ur1 ; run ur2'
saveenv

setenv soc xm510                 # SoC của bạn. xm510.
setenv osmem 18M                 # 18M cho xm510.
setenv totalmem 32M              # 32M cho xm510.
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
để định dạng phân vùng jffs2 được sử dụng để lưu trữ cài đặt.

### Các vấn đề đã biết




