# OpenIPC Wiki
[Mục lục](../README.md)

Trạm mặt đất OpenIPC FPV
--------------------------


#### Tin tức

- Giờ đây bạn có thể ghi video vào ổ SSD hoặc USB được kết nối
- Cả hai đầu ra HDMI và VGA hiện đều hoạt động, không có giới hạn về màn hình được kết nối
- Rất nhiều cải tiến khác ;)


#### Nâng cấp từ firmware gốc của board HI3536DV100 NVR lên firmware OpenIPC FPV

- Cài đặt phần mềm [PUTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) và máy chủ [TFTP](https://pjo2.github.io/tftpd64/)
- Tải xuống [ảnh firmware](https://openipc.org/cameras/vendors/hisilicon/socs/hi3536dv100/download_full_image?flash_size=16&flash_type=nor&fw_release=fpv)  cho NVR từ trang web OpenIPC
- Tải ảnh firmware này lên máy chủ TFTP của bạn
- Tắt nguồn NVR, kết nối bộ chuyển đổi USB với cổng UART của NVR, xác định cổng COM nào trên PC của bạn
- Truy cập U-Boot bằng cách nhấn nhanh Ctrl+C khi bật nguồn
- Thực thi một tập hợp các lệnh, mỗi dòng riêng biệt

```
# Thay đổi địa chỉ IP của board NVR và địa chỉ IP của máy chủ TFTP của bạn
setenv ipaddr 192.168.1.10; setenv serverip 192.168.1.254
mw.b 0x82000000 0xff 0x1000000
tftp 0x82000000 openipc-hi3536dv100-fpv-16mb.bin
sf probe 0; sf lock 0;
sf erase 0x0 0x1000000; sf write 0x82000000 0x0 0x1000000
reset
```

#### Kết quả

![](../images/fpv-nvr-hi3536dv100-openipc-ready.webp)

#### Mua thiết bị

- [https://www.aliexpress.com/item/1005004023376532.html](https://www.aliexpress.com/item/1005004023376532.html)
- [https://www.aliexpress.com/item/1005002358182146.html](https://www.aliexpress.com/item/1005002358182146.html)

Changes:
- "Bản tin tổng hợp" -> "Tin tức"
- "hình ảnh" -> "ảnh firmware"
- "bảng HI3536DV100 NVR" -> "board HI3536DV100 NVR"
- "chỉ định cổng COM nào trên PC của bạn" -> "xác định cổng COM nào trên PC của bạn"




