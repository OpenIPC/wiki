## Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bảng mạch XM với SoC XM530/XM550!!!
--------------------------------------------------

### Cập nhật firmware thiết bị ban đầu

```
setenv bootargs 'mem=35M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=xm_sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'sf probe 0; sf read 0x80007fc0 0x50000 0x200000; bootm 0x80007fc0'
setenv uk1 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 uImage.${soc}'
setenv uk2 'sf probe 0; sf erase 0x50000 0x200000; sf write 0x80007fc0 0x50000 ${filesize}'
setenv uk 'run uk1 ; run uk2'
setenv ur1 'mw.b 0x80007fc0 ff 1000000; tftp 0x80007fc0 rootfs.squashfs.${soc}'
setenv ur2 'sf probe 0; sf erase 0x250000 0x500000; sf write 0x80007fc0 0x250000 ${filesize}'
setenv ur 'run ur1 ; run ur2'
saveenv

setenv soc xm530                 # SoC của bạn. xm530 cho cả xm530 và xm550.
setenv osmem 35M                 # 35M cho xm530, 64M cho xm550.
setenv totalmem 64M              # 64M cho xm530, 128M cho xm550.
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

### Vấn đề đã biết


### Uboot không có lệnh tftp

```
setenv uk1 'mw.b 0x81000000 ff 1000000; setenv bootfile uImage.${soc}; tftpboot'
setenv uk2 'sf probe 0; sf erase 0x50000 0x200000; sf write 0x81000000 0x50000 ${filesize}'
setenv uk 'run uk1 ; run uk2'
setenv ur1 'mw.b 0x81000000 ff 1000000; setenv bootfile rootfs.squashfs.${soc}; tftpboot'
setenv ur2 'sf probe 0; sf erase 0x250000 0x500000; sf write 0x81000000 0x250000 ${filesize}'
setenv ur 'run ur1 ; run ur2'
saveenv

run uk; run ur; reset
```

### Sao lưu thiết bị (không có tftpput)

Mở bảng điều khiển nối tiếp với một tệp nhật ký
Lưu ý: việc dump qua Serial mất nhiều thời gian

```
sf probe 0
sf read 0x81000000 0x0 0x800000
md.b 0x81000000 0x800000
```

Sử dụng `cut -b 11-57 | xxd -r -p` để tái tạo lại tệp nhị phân từ đầu ra của `md.b`


**Giải thích thuật ngữ:**

* **XM vendor boards:** Bảng mạch của nhà cung cấp XM, là một loại bảng mạch được sử dụng trong camera IP.
* **XM530/XM550 SoC:** Hệ thống trên một vi mạch XM530/XM550, được sản xuất bởi Xiongmai.
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **U-Boot:** Là một bootloader phổ biến được sử dụng trong các hệ thống nhúng.
* **Bootloader:** Là một chương trình nhỏ được thực thi khi thiết bị khởi động, chịu trách nhiệm tải hệ điều hành.
* **Kernel:** Là phần cốt lõi của hệ điều hành.
* **Rootfs:** Hệ thống tệp gốc, là hệ thống tệp chứa các tệp cần thiết để khởi động hệ điều hành.
* **TFTP (Trivial File Transfer Protocol):** Giao thức truyền tệp đơn giản, là một giao thức mạng được sử dụng để truyền tệp giữa máy khách và máy chủ.
* **IP address:** Địa chỉ IP, là một địa chỉ định danh duy nhất cho một thiết bị trên mạng.
* **jffs2 (Journaling Flash File System version 2):** Là một hệ thống tệp được thiết kế dành riêng cho bộ nhớ flash.
* **Known issues:** Vấn đề đã biết, là những vấn đề đã được xác định trong quá trình phát triển.
* **tftpput:** Là một lệnh trong U-Boot được sử dụng để truyền tệp đến máy chủ TFTP.
* **Serial console:** Bảng điều khiển nối tiếp, là một giao diện dòng lệnh được truy cập thông qua cổng nối tiếp.
* **md.b:** Là một lệnh trong U-Boot được sử dụng để hiển thị nội dung của bộ nhớ theo định dạng thập lục phân.
* **cut:** Là một lệnh trong Linux được sử dụng để trích xuất các phần của tệp.
* **xxd:** Là một lệnh trong Linux được sử dụng để chuyển đổi tệp giữa định dạng nhị phân và thập lục phân.




