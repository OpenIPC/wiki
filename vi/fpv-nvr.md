# OpenIPC Wiki
[Mục lục](../README.md)

Trạm mặt đất OpenIPC FPV
--------------------------


#### Bản tin tổng hợp

- Hiện đã có thể quay video vào SSD hoặc USB được kết nối
- Cả đầu ra HDMI và VGA hiện đều hoạt động, không có giới hạn trong màn hình được kết nối
- Rất nhiều thứ khác nhau ;)


#### Nâng cấp từ firmware gốc của bảng HI3536DV100 NVR lên firmware OpenIPC FPV

- Cài đặt máy chủ [PUTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) và [TFTP](https://pjo2.github.io/tftpd64/)
- Tải xuống [hình ảnh](https://openipc.org/cameras/vendors/hisilicon/socs/hi3536dv100/download_full_image?flash_size=16&flash_type=nor&fw_release=fpv) thực tế cho NVR từ trang web OpenIPC
- Tải hình ảnh này lên máy chủ TFTP của bạn
- Tắt nguồn NVR, kết nối bộ chuyển đổi USB với UART của NVR, chỉ định cổng COM nào trên PC của bạn
- Vào U-Boot bằng cách nhấn nhanh Ctrl+C khi bật nguồn
- Thực thi một tập hợp các lệnh, mỗi dòng riêng biệt

```
# Thay đổi địa chỉ ip của bảng NVR và địa chỉ ip của máy chủ TFTP của bạn
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

