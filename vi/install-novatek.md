# Wiki OpenIPC
[Mục lục](../README.md)

**CHỈ** dành cho bo mạch của nhà cung cấp XM với SoC NT98562 và NT98566!!!
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



