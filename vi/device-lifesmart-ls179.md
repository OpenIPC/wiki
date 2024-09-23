# OpenIPC Wiki
[Mục lục](../README.md)

Dành cho camera LifeSmart: LS179

## BOM

SoC: HI3518EV200  
Flash: ENQH127A (16MB NOR)  
Cảm biến: soif23 (???)

## Cài đặt

Làm theo [hướng dẫn](help-uboot.md#bypassing-password-protected-bootloader) để truy cập vào U-boot.

Sao lưu flash và cài đặt OpenIPC theo [hướng dẫn](https://openipc.org/cameras/vendors/hisilicon/socs/hi3518ev200).

Chọn flash NOR 16MB và sử dụng firmware Ultimate nếu bạn muốn sử dụng WiFi.

## WiFi

Để kết nối với WiFi, bạn cần cấu hình [thiết bị không dây](wireless-settings.md#initial-configuration) với `rtl8188fu-hi3518ev200-lifesmart`

```
fw_setenv wlandev rtl8188fu-hi3518ev200-lifesmart
# cũng cấu hình WiFi của bạn
fw_setenv wlanssid "MySSID"
fw_setenv wlanpass "password"
# và sau đó...
reboot
```

Thao tác này sẽ cấp nguồn cho mô-đun WiFi USB (GPO #54) và tải trình điều khiển Kernel thích hợp (`8188fu`).

## Đèn LED

Các đèn LED được điều khiển bởi GPO #2.

```bash
# bật
gpio set 2

# tắt
gpio clear 2
```

