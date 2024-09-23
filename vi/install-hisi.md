## Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bảng XM với SoC Hi35{16Ev200,16Ev300,18Ev300}!!!
------------------------------------------------------------

Các bảng mạch khác có thể có bố cục bộ nhớ khác, ví dụ như HI3518Ev200 sử dụng 0x82000000 thay vì 0x42000000.

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

### Cập nhật nhanh tiếp theo

```
run uk; run ur; reset
```

### Thực thi lệnh sau lần chạy đầu tiên

Đối với bảng Hi3516Ev300:
```
set_allocator cma
firstboot
```

Đối với bảng Hi3516Ev200 hoặc Hi3518Ev300:
```
set_allocator hisi
firstboot
```

### Khu vực nguy hiểm

Bạn luôn có tùy chọn cập nhật bootloader. Tuy nhiên, bạn cần hiểu những gì bạn đang làm.

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


### Uboot không có lệnh tftp

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

Nếu có sự cố xảy ra, uboot có thể bị brick!

```
setenv bootfile backup.img
tftpboot
sf probe 0
sf erase 0x0000 0x800000
sf write 0x40080000 0x0 ${filesize}
reset
```

**Giải thích thuật ngữ:**

* **XM boards:** Bảng mạch XM, là một loại bảng mạch được sử dụng trong camera IP.
* **SoC (System on a Chip):** Hệ thống trên một vi mạch, là một mạch tích hợp chứa tất cả các thành phần cần thiết của một hệ thống máy tính.
* **Hi35{16Ev200,16Ev300,18Ev300}:** Là tên của các SoC được sản xuất bởi HiSilicon.
* **Memory layout:** Bố cục bộ nhớ, là cách tổ chức bộ nhớ trong thiết bị.
* **Sensor:** Cảm biến, là một thiết bị chuyển đổi tín hiệu vật lý thành tín hiệu điện.
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **U-Boot:** Là một bootloader phổ biến được sử dụng trong các hệ thống nhúng.
* **Bootloader:** Là một chương trình nhỏ được thực thi khi thiết bị khởi động, chịu trách nhiệm tải hệ điều hành.
* **Kernel:** Là phần cốt lõi của hệ điều hành.
* **Rootfs:** Hệ thống tệp gốc, là hệ thống tệp chứa các tệp cần thiết để khởi động hệ điều hành.
* **TFTP (Trivial File Transfer Protocol):** Giao thức truyền tệp đơn giản, là một giao thức mạng được sử dụng để truyền tệp giữa máy khách và máy chủ.
* **IP address:** Địa chỉ IP, là một địa chỉ định danh duy nhất cho một thiết bị trên mạng.
* **CMA (Contiguous Memory Allocator):** Bộ cấp phát bộ nhớ liền kề, là một phương pháp cấp phát bộ nhớ cho kernel Linux.
* **Hisi:** Là một bộ cấp phát bộ nhớ được sử dụng bởi HiSilicon.
* **Firstboot:** Khởi động lần đầu, là lần khởi động đầu tiên sau khi flash firmware.
* **Danger zone:** Khu vực nguy hiểm, là một phần của tài liệu cảnh báo người dùng về các thao tác có thể gây hại cho thiết bị.
* **Bricked:** Bị brick, là tình trạng thiết bị không hoạt động do lỗi firmware.
* **Backup:** Sao lưu, là quá trình tạo bản sao dữ liệu để phòng trường hợp mất dữ liệu.
* **Restore:** Khôi phục, là quá trình khôi phục dữ liệu từ bản sao lưu.






