## Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bảng mạch XM với SoC NT98562 và NT98566!!!
---------------------------------------------------------

### Cập nhật firmware thiết bị ban đầu

> **Phần này sẽ được hoàn thành sau khi kết thúc nghiên cứu**

```
run uk; run ur; reset            # Flash kernel, rootfs và khởi động lại thiết bị
```

### Cập nhật nhanh tiếp theo

```
run uk; run ur; reset
```

### Ghi chú

Sau khi bạn hoàn thành việc flash firmware mới, vui lòng chạy lệnh `firstboot`
để định dạng phân vùng `jffs2` được sử dụng để lưu trữ cài đặt.

### Vấn đề đã biết

Thay đổi địa chỉ bộ nhớ cho một số thử nghiệm.

```
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x03100000 0x50000 0x200000;nvt_boot'
saveenv
```

**Giải thích thuật ngữ:**

* **XM vendor boards:** Bảng mạch của nhà cung cấp XM, là một loại bảng mạch được sử dụng trong camera IP.
* **SoC (System on a Chip):** Hệ thống trên một vi mạch, là một mạch tích hợp chứa tất cả các thành phần cần thiết của một hệ thống máy tính.
* **NT98562 và NT98566:** Là tên của các SoC được sản xuất bởi Novatek.
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **U-Boot:** Là một bootloader phổ biến được sử dụng trong các hệ thống nhúng.
* **Bootloader:** Là một chương trình nhỏ được thực thi khi thiết bị khởi động, chịu trách nhiệm tải hệ điều hành.
* **Kernel:** Là phần cốt lõi của hệ điều hành.
* **Rootfs:** Hệ thống tệp gốc, là hệ thống tệp chứa các tệp cần thiết để khởi động hệ điều hành.
* **jffs2 (Journaling Flash File System version 2):** Là một hệ thống tệp được thiết kế dành riêng cho bộ nhớ flash.
* **Partition:** Phân vùng, là một phần của bộ nhớ được chia thành các phần riêng biệt.
* **Known issues:** Vấn đề đã biết, là những vấn đề đã được xác định trong quá trình phát triển.
* **Memory address:** Địa chỉ bộ nhớ, là một vị trí cụ thể trong bộ nhớ.
* **nvt_boot:** Là một lệnh được sử dụng để khởi động kernel Novatek.





