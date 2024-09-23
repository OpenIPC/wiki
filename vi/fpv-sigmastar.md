# OpenIPC Wiki
[Mục lục](../README.md)

Hướng dẫn cài đặt firmware OpenIPC trên thiết bị SigmaStar
---

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

---

### SSC338Q + IMX415 + flash NAND, bo mạch từ nhà cung cấp CamHi
#### Lưu ý nhanh về các thử nghiệm, sẽ được sửa đổi và cập nhật

#### Tóm tắt
Sigmastar IPL (trình nạp khởi động trước) cho phép khởi động U-Boot tùy chỉnh từ thẻ nhớ SD.
Với firmware OpenIPC tạm thời này, bạn có thể tạo bản sao lưu của nand và flash firmware vĩnh viễn sau đó.

#### Chuẩn bị
- Kết nối thẻ nhớ SD của bạn với máy tính, tạo một phân vùng 1 GB và định dạng nó là FAT32 / VFAT.
- [Tải xuống ssc338q-initramfs.zip][1]
- Sao chép tất cả các tệp vào thư mục gốc của thẻ nhớ SD, cập nhật thông tin đăng nhập không dây của bạn trên autostart.sh:
```diff
#!/bin/sh
+WLAN_SSID="Router"
+WLAN_PASS="12345678"
```
- Đặt thẻ nhớ SD vào mô-đun camera, khởi động nó và đợi cho đến khi nó kết nối với bộ định tuyến của bạn.
- Sử dụng ssh để kết nối với camera:
```
ssh root@192.168.1.100
12345
```

#### Sao lưu
- /dev/mtd0 sử dụng toàn bộ kích thước phân vùng của flash nand.
- Điều này có thể mất một thời gian, việc sao lưu vào thẻ nhớ SD khá chậm.
```
nanddump -f /mnt/mmcblk0p1/backup-nand.bin /dev/mtd0
```

- Ngoài ra, nội dung flash có thể được tải lên qua tftp.
```
cd /dev
tftp 192.168.1.10 -pr mtd0
```

#### Cài đặt
```
flash_eraseall /dev/mtd0
nandwrite -k /dev/mtd0 /mnt/mmcblk0p1/ssc338q-fpv.bin
rm /mnt/mmcblk0p1/UBOOT
reboot -f
```

#### Mua thiết bị (nhà cung cấp CamHi)
- https://aliexpress.com/item/1005002879158570.html
- https://aliexpress.com/item/1005005750013595.html

---

### SSC338Q + IMX415 + flash NOR, bo mạch từ nhà cung cấp Anjoy
#### Việc thu thập thông tin vẫn tiếp tục
Việc thu thập thông tin vẫn tiếp tục

#### Mua thiết bị (nhà cung cấp Anjoy)
- https://aliexpress.com/item/1005003738087454.html

---

### Ghi chú khác
Để kiểm tra, vui lòng sử dụng trình phát [MPV](https://mpv.io/), trong đó có thể sử dụng tổ hợp phím Shift+I để lấy thông tin gỡ lỗi.

[1]: https://github.com/OpenIPC/wiki/files/13382282/ssc338q-initramfs.zip
