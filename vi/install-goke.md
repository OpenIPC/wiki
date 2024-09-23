# Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bảng XM với SoC GK7202V300, GK7205V200, GK7205V300!!!
-----------------------------------------------------------------

### Cảm biến được hỗ trợ

Vui lòng tra cứu cảm biến của bạn trong [danh sách thiết bị được hỗ trợ][1].

### Cập nhật firmware thiết bị ban đầu

```
setenv bootargs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x42000000 0x50000 0x200000; bootm 0x42000000'
setenv uk 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 uImage.${soc} && sf probe 0; sf erase 0x50000 0x200000; sf write 0x42000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x42000000 ff 1000000; tftp 0x42000000 rootfs.squashfs.${soc} && sf probe 0; sf erase 0x250000 0x500000; sf write 0x42000000 0x250000 ${filesize}'
saveenv

setenv soc gk7xxxxxxx            # Đặt SoC của bạn. gk7202v300, gk7205v200, hoặc gk7205v300.
setenv osmem 32M
setenv totalmem 64M              # 64M cho gk7202v300, gk7205v200, 128M cho gk7205v300.
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254    # Địa chỉ IP máy chủ TFTP của bạn.
saveenv

run uk; run ur; reset            # Flash kernel, rootfs và khởi động lại thiết bị
```

### Cập nhật nhanh tiếp theo

```
run uk; run ur; reset
```

### Thủ thuật dành cho người dùng GK7205V300+IMX335

```
echo -e "!/bin/sh\n\ndevmem 0x120100f0 32 0x19\n" >/etc/init.d/S96trick
chmod +x /etc/init.d/S96trick
```

Cách thay thế [tại đây](https://github.com/OpenIPC/firmware/pull/117/files)

### Khu vực nguy hiểm

Bạn luôn có tùy chọn cập nhật bootloader. Tuy nhiên, bạn cần hiểu những gì bạn đang làm.

Lưu ý! Thay thế tên tệp bootloader bằng tên phù hợp với SoC của bạn.
Danh sách đầy đủ có [tại đây](https://github.com/OpenIPC/firmware/releases/tag/latest).

```
mw.b 0x42000000 ff 1000000
tftp 0x42000000 u-boot-gk7xxxxxxxx-beta.bin
sf probe 0
sf erase 0x0 0x50000
sf write 0x42000000 0x0 ${filesize}
reset
```

[1]: guide-supported-devices.md


**Giải thích thuật ngữ:**

* **XM boards:** Bảng mạch XM, là một loại bảng mạch được sử dụng trong camera IP.
* **SoC (System on a Chip):** Hệ thống trên một vi mạch, là một mạch tích hợp chứa tất cả các thành phần cần thiết của một hệ thống máy tính.
* **GK7202V300, GK7205V200, GK7205V300:** Là tên của các SoC được sản xuất bởi Goke.
* **Sensor:** Cảm biến, là một thiết bị chuyển đổi tín hiệu vật lý thành tín hiệu điện.
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **U-Boot:** Là một bootloader phổ biến được sử dụng trong các hệ thống nhúng.
* **Bootloader:** Là một chương trình nhỏ được thực thi khi thiết bị khởi động, chịu trách nhiệm tải hệ điều hành.
* **Kernel:** Là phần cốt lõi của hệ điều hành.
* **Rootfs:** Hệ thống tệp gốc, là hệ thống tệp chứa các tệp cần thiết để khởi động hệ điều hành.
* **TFTP (Trivial File Transfer Protocol):** Giao thức truyền tệp đơn giản, là một giao thức mạng được sử dụng để truyền tệp giữa máy khách và máy chủ.
* **IP address:** Địa chỉ IP, là một địa chỉ định danh duy nhất cho một thiết bị trên mạng.
* **Bootsel pin:** Chân bootsel, là một chân trên bảng mạch được sử dụng để chọn chế độ khởi động.
* **IMX335:** Là tên của một cảm biến hình ảnh được sản xuất bởi Sony.
* **Danger zone:** Khu vực nguy hiểm, là một phần của tài liệu cảnh báo người dùng về các thao tác có thể gây hại cho thiết bị.







