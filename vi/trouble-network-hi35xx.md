# OpenIPC Wiki
[Mục lục](../README.md)

## Khắc phục sự cố: Mạng không hoạt động trên hi35xx
Nếu mạng không hoạt động trên thiết bị hi35xx của bạn sau khi cài đặt OpenIPC (không có liên kết), bạn có thể phải điều chỉnh cài đặt MII (Giao diện Độc lập Phương tiện).
Đối với U-Boot, điều này được thực hiện bằng cách đặt giá trị cho `phyaddru`, `phyaddrd` và `mdio_intf`.
Các giá trị có thể có cho `phyaddru` và `phyaddrd` là: `0-3`, các giá trị có thể có cho `mdio_intf` là: `rmii`, `rgmii`, `gmii`.
Đối với kernel Linux / Hệ điều hành, các giá trị có thể được đặt thông qua các biến khởi động `extras` là `hieth.phyaddru`, `hieth.phyaddrd`, `hieth.mdioifu` và `hieth.mdioifd`.

Thông thường, các giá trị chính xác có thể được tìm thấy trong firmware gốc của bạn. Việc xem nhật ký khởi động hoặc chạy [ipctool](https://github.com/OpenIPC/ipctool) trên firmware gốc của bạn có thể cung cấp manh mối.

Dưới đây là một số kết hợp bạn có thể thử:

### Đối với ethernet trong Linux:

Trong bảng điều khiển Linux, hãy chạy lệnh này:
```
fw_setenv extras 'hieth.phyaddru=0 hieth.phyaddrd=1' && reboot
```
Nếu cài đặt trên không hoạt động, hãy thử cài đặt này:
```
fw_setenv extras 'hieth.phyaddru=1 hieth.phyaddrd=0' && reboot
```
Hoặc:
```
fw_setenv extras 'hieth.mdioifu=0 hieth.mdioifd=0' && reboot
```
Hoặc:
```
fw_setenv extras 'hieth.mdioifu=1 hieth.mdioifd=1' && reboot
```
Hoặc:
```
fw_setenv extras hieth.mdioifu=0 hieth.mdioifd=0 hieth.phyaddru=1 hieth.phyaddrd=2 && reboot
```
Hoặc:
```
fw_setenv extras hieth.phyaddru=3 hieth.mdioifu=0 && reboot
```

*Lưu ý: nếu một kết hợp nhất định khiến thiết bị của bạn không khởi động được, bạn có thể xóa các biến trong dấu nhắc U-Boot bằng cách gọi `setenv <biến>`, tức là đặt biến bằng một đối số trống, theo sau là `saveenv`.*

### Đối với ethernet trong U-boot:

Đặt các biến `phyaddru` và `phyaddrd` từ bảng điều khiển U-Boot:
```
setenv phyaddru 0; setenv phyaddrd 1; saveenv; reset
```
Nếu cài đặt trên không hoạt động, hãy thử cài đặt này
```
setenv phyaddru 1; setenv phyaddrd 0; saveenv; reset
```
Hoặc:
```
setenv phyaddru 0; setenv phyaddrd 0; saveenv; reset
```
Hoặc:
```
setenv phyaddru 1; setenv phyaddrd 1; saveenv; reset
```

*Lưu ý: để khởi tạo và kiểm tra kết nối mạng trong U-Boot, có thể sử dụng lệnh `ping`.*

Một số kết hợp đã biết cho các bảng cụ thể:

### XiongMai, HI3518EV100
*Đối với mạng U-boot:*
```
    setenv phyaddru 1
    setenv phyaddrd 2
    setenv mdio_intf rmii
    saveenv
```
*Đối với mạng Linux:*
```
    setenv extras 'hieth.phyaddru=1 hieth.phyaddrd=2'
    saveenv
```

### XiongMai IPG-53H20AF, HI3516CV100

*Đối với mạng Linux:*
```
   setenv hieth.mdioifu=0 hieth.mdioifd=0 hieth.phyaddru=1 hieth.phyaddrd=2
   saveenv
```

### CamHi/HiChip/Xin, HI3518EV200

*Đối với mạng U-boot:*
```
    setenv phyaddru 0
    setenv phyaddrd 1
    saveenv
```

### HiWatch, HI3518CV100

*Đối với mạng U-boot:*
```
    setenv phyaddru 3
    saveenv
```

*Đối với mạng Linux:*
```
    setenv extras 'hieth.phyaddru=3 hieth.mdioifu=0'
    saveenv
```

### Harex (5013A-CF/5020A-FF), HI3516CV100

*Đối với mạng U-boot:*
```
    setenv extras 'hieth.phyaddru=1 hieth.mdioifu=0'
    saveenv
```

Nếu không có cách nào ở trên hiệu quả với bạn, vui lòng hỏi trong [kênh Telegram của chúng tôi](https://t.me/openipc).
