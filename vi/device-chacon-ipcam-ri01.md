# Chacon IPCAM-RI01

![device_chacon_ipcam-ri01](https://user-images.githubusercontent.com/1659543/149517176-6803cc6d-600f-4841-ac9b-69eeea23d0a6.jpg)

[Tờ dữ liệu sản phẩm](https://chacon.com/datasharing/doc/IPCAM-RI01/ipcam-ri01_user_manual.pdf)

Camera này là sản phẩm đổi thương hiệu của một công ty sản xuất được xác định bởi "PPStrong".
Tôi chắc chắn rằng có những camera khác ngoài kia đang sử dụng cùng một phần cứng (hoặc tương tự với những thay đổi nhỏ).

## Phần cứng

| Hệ thống | Mô tả                          |
|--------|--------------------------------------|
| SoC    | HI3518EV300                          |
| Cảm biến | JXF23                                |
| Flash  | 16Mb (XM25QH128A) hoặc 8Mb (XM25QH64A) |
| WiFi   | RTL8188FU                            |

### Trạng thái OpenIPC

| Thành phần     | Trạng thái                                                   |
|---------------|----------------------------------------------------------|
| WiFi          | [Hoạt động](https://github.com/OpenIPC/firmware/issues/48) |
| Động cơ        | [Hoạt động](#motor-driver) (trình điều khiển được vá)                |
| Đèn LED đỏ/xanh | [Hoạt động](#leds)                                         |
| Đèn LED IR        | Hoạt động                                                  |
| Cắt IR        | Hoạt động                                                  |


### Chi tiết phần cứng

Bo mạch chủ của camera được xác định bởi "SPEED5S-H1MB_F23".

![device_chacon_ipcam-ri01_board_top](https://user-images.githubusercontent.com/1659543/149513254-d326f57f-902b-4c58-98e6-73bfe7fa33d2.jpg)
Ở phía trên của bo mạch chủ:
- một khe cắm thẻ nhớ micro sd ở bên phải
- đầu nối có nhãn "IR" cấp nguồn cho đèn LED IR, đèn LED đỏ và đèn LED xanh
- đầu nối "ICR" cấp nguồn cho bộ lọc cắt IR
- đầu nối không được xác định là đầu vào cho micrô
- chip flash SPI NOR (QH128A)


![device_chacon_ipcam-ri01_board_bot](https://user-images.githubusercontent.com/1659543/149514958-1bb4c576-6190-48e1-860c-7c3ebe00b204.jpg)
Ở phía dưới của bo mạch chủ:
- SoC Hi3518EV300
- Mô-đun WiFi RTL8188FTV
- Công tắc đặt lại
- Đầu nối (từ trên xuống dưới):
  - Nguồn (5V từ đầu nối micro usb)
  - Động cơ bước nghiêng/dọc
  - Động cơ bước xoay/ngang
  - Loa
- Chân UART ở phía dưới bên trái

### SoC
[Hi35218EV300](https://www.hisilicon.com/en/products/smart-vision/consumer-camera/IOTVision/Hi3518EV300)
- ARM Cortex-A7@ 900 MHz
- 64Mb DDR2

![device_chacon_ipcam-ri01_soc](https://user-images.githubusercontent.com/1659543/149517468-169ebcc9-76b4-4dcf-ad8c-5be2db5aafa4.jpg)


### Wifi
[RTL8188FTV](https://www.realtek.com/en/products/communications-network-ics/item/rtl8188ftv)
- 802.11b/g/n 2.4G
- Giao diện USB

![device_chacon_ipcam-ri01_rtl8188ftv](https://user-images.githubusercontent.com/1659543/149518487-d18066b5-94fe-4b72-95f9-5ca198047bab.jpg)


### Flash SPI NOR
[XM25QH128A](https://www.xmcwh.com/en/site/product_con/200)
- 16Mb SPI NOR Flash

![device_chacon_ipcam-ri01_flash](https://user-images.githubusercontent.com/1659543/149519439-7ac8f1c0-4d00-495f-94ab-82ba9c552822.jpg)


### Chân UART (cổng nối tiếp)

![device_chacon_ipcam-ri01_uart](https://user-images.githubusercontent.com/1659543/149518771-a33ab23f-a4f0-44db-83a6-873bd1802056.jpg)


### GPIO

| số        | Mô tả   |
|-----------|---------------|
| 0x0f (15) | irCut_1       |
| 0x0c (12) | irCut_2       |
| 0x28 (40) | Đèn LED IR        |
| 0x33 (51) | Đèn LED đỏ       |
| 0x32 (50) | Đèn LED xanh      |
| 0x0d (13) | nguồn wlan    |
| 0x00 (0)  | AcShdn        |
| 0x09 (9)  | Nút đặt lại  |
| 0x3b (59) | Động cơ nghiêng A1 |
| 0x3a (58) | Động cơ nghiêng A2 |
| 0x39 (57) | Động cơ nghiêng B1 |
| 0x38 (56) | Động cơ nghiêng B2 |
| 0x47 (71) | Động cơ xoay A1  |
| 0x45 (69) | Động cơ xoay A2  |
| 0x46 (70) | Động cơ xoay B1  |
| 0x44 (68) | Động cơ xoay B2  |

### Sửa đổi
#### Cổng USB nối tiếp

Có một đầu nối micro usb để cấp nguồn cho camera và với một số hàn, đầu nối này cũng có thể được sử dụng cho bộ chuyển đổi nối tiếp sang usb.
Nếu bạn thấy khó hàn dây trên đầu nối micro usb của camera, hãy mua một [bảng breakout micro usb](https://www.google.com/search?q=micro+usb+breakout+board&tbm=isch).

![device_chacon_ipcam-ri01_usbmod](https://user-images.githubusercontent.com/1659543/149561868-f991f75e-e766-4b71-920e-ea2918182796.jpg)

1. Lấy bộ chuyển đổi 3.3V TTL sang USB (sử dụng bộ chuyển đổi pl2303hx rẻ tiền)
2. Tháo đầu nối và chân USB-A
3. Kết nối cổng micro usb của camera với bộ chuyển đổi
4. Kết nối uart của camera với bộ chuyển đổi


## Firmware gốc

Camera uBoot được bảo vệ bằng mật khẩu với "pps_password".

### Tạo bản sao lưu
Để sao lưu firmware gốc, bạn cần một bộ chuyển đổi nối tiếp USB được kết nối với bo mạch và một thẻ nhớ sd.

Tìm ra kích thước chip flash của bạn:
```
pps # getinfo spi
Block:64KB Chip:8MB*1
D:0x20 0x70 0x17
Name:"XM25QH64AHIG"
```

Các lệnh uBoot để sao lưu toàn bộ bộ nhớ flash trên thẻ nhớ sd (**tất cả nội dung thẻ nhớ sd sẽ bị mất**).
Tùy thuộc vào kích thước bộ nhớ flash của camera, hãy thay thế \<kích thước1\>/\<kích thước2\> bằng:
- 0x800000/0x4000 cho flash 8M
- 0x1000000/0x8000 cho flash 16Mb
(kích thước2 = kích thước1 / 512)

```
sf probe
sf read 0x40000000 0 <kích thước1>
mmc write 0 0x40000000 0 <kích thước2>
```

Ví dụ đầu ra (flash 8Mb):
```
pps # sf probe
pps # sf read 0x40000000 0 0x800000
device 0 whole chip

SF: 8388608 bytes @ 0x0 Read: OK
pps # mmc write 0 0x40000000 0 0x4000
had init

MMC write: dev # 0, block # 0, count 16384 ... had init
16384 blocks written: OK
pps # 
```

Điều này sẽ ghi toàn bộ flash vào thẻ mmc ở "chế độ thô" (không có hệ thống tệp).

**CẢNH BÁO**: nếu bạn để thẻ trong camera và nó khởi động FW gốc, thẻ sẽ bị định dạng và bản sao lưu sẽ bị mất!
  
Sau đó, để lưu bản dump vào một tệp, hãy lắp thẻ vào hệ thống đang chạy linux và:
```
dd if=/dev/mmcblk0 of=./flash_backup.bin bs=512 count=<kích thước2>
```


### cat /proc/mtd

Phiên bản flash 8Mb
```
dev:    size   erasesize  name
mtd0: 00030000 00010000 "bld"     196608        0
mtd1: 00010000 00010000 "env"     65536         196608
mtd2: 00010000 00010000 "enc"     65536         262144
mtd3: 00010000 00010000 "sysflg"  65536         327680
mtd4: 00310000 00010000 "sys"     3211264       393216
mtd5: 00420000 00010000 "app"     4325376       3604480
mtd6: 00070000 00010000 "cfg"     458752        7929856 - 8388608
```

Phiên bản flash 16Mb
```
dev:    size   erasesize  name
mtd0: 00060000 00010000 "bld"     393216        0
mtd1: 00010000 00010000 "env"     65536         393216
mtd2: 00010000 00010000 "enc"     65536         458752
mtd3: 00010000 00010000 "sysflg"  65536         524288
mtd4: 00380000 00010000 "sys"     3670016       589824
mtd5: 00680000 00010000 "app"     6815744       4259840
mtd6: 00180000 00010000 "cfg"     1572864       11075584
mtd7: 00100000 00010000 "recove"  1048576       12648448
mtd8: 002d0000 00010000 "user"    2949120       13697024
mtd9: 00020000 00010000 "oeminfo" 131072        16646144 - 16777216
```


### dmesg
(quá dài để dịch, nếu bạn cần phần này được dịch, vui lòng cho tôi biết)


### Khởi động telnetd

FW gốc của camera chạy máy chủ REST với xác thực (người dùng: PpStRoNg, mật khẩu: #%&wL1@\*tU123zv).

Một trong những tính năng thú vị nhất là chức năng "runcmd" (thay thế \<your_cam_ip\> bằng địa chỉ IP camera của bạn):

Gửi yêu cầu (lưu ý \\ thoát khỏi & cho mật khẩu):
```
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://<your_cam_ip>:80/devices/runcmd --request POST --data '{"cmd":"ls"}'
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 0
```

Nhận đầu ra (định dạng json):
```
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://<your_cam_ip>:80/devices/runcmd
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 129
{
        "value":        "usr\nsys\netc\nmnt\nlib\nproc\nboot\nopt\nlinuxrc\nbin\ndev\ninit\nhome\nsbin\nnfsroot\nroot\ntmp\nvar\ndevinfo\n"
}
```

Trong FW mới nhất, họ đã xóa tệp nhị phân "telnetd", vì vậy bạn cần đặt nó trên thẻ nhớ sd:
[telnetd.zip](https://github.com/ljalves/wiki/files/7875319/telnetd.zip)


Để khởi động máy chủ, hãy sao chép tệp nhị phân telnetd vào thẻ nhớ sd và chạy:
```
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://<your_cam_ip>:80/devices/runcmd --request POST --data '{"cmd":"echo 'anyone::0:0:root:/:/bin/sh' >> /etc/passwd"}'
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://<your_cam_ip>:80/devices/runcmd --request POST --data '{"cmd":"/mnt/mmc01/telnetd &"}'
```

Tại thời điểm này, bạn sẽ có thể telnet vào camera:
```
$ telnet <your_cam_ip>
Trying <your_cam_ip>...
Connected to <your_cam_ip>.
Escape character is '^]'.
(none) login: anyone


BusyBox v1.26.2 (2019-04-16 05:35:27 PDT) built-in shell (ash)

/ #
```


### Đầu ra [ipctool](https://github.com/OpenIPC/ipctool) (flash 8Mb):

```
/mnt/mmc01 # ./ipctool
---
chip:
  vendor: HiSilicon
  model: 3518EV300
  id: 022c40074e0038f1ee70030a0d73b5d32549ab0c81a025e3
mdio busy
mdio busy
ethernet:
  mac: "c4:3a:35:75:bf:71"
  u-mdio-phyaddr: 0
  phy-id: 0x00000000
  d-mdio-phyaddr: 0
rom:
  - type: nor
    block: 64K
    partitions:
      - name: sys
        size: 0x310000
        sha1: c890f4a1
      - name: app
        size: 0x420000
        sha1: 32c12243
      - name: cfg
        size: 0x70000
        path: /home/cfg,jffs2,rw
    size: 7M
    addr-mode: 3-byte
ram:
  total: 64M
  media: 27M
firmware:
  kernel: "4.9.37 (Mon Jul 22 00:51:54 PDT 2019)"
  libc: uClibc 0.9.33.2
  sdk: "Hi3516EV200_MPP_V1.0.1.0 B050 Release (May  9 2019, 22:51:50)"
  main-app: ./ppsapp
sensors:
- vendor: Silicon Optronics
  model: JXF23
  control:
    bus: 0
    type: i2c
    addr: 0x80
  data:
    type: MIPI
    input-data-type: DATA_TYPE_RAW_10BIT
    lane-id:
    - 0
    - 1
    image: 1920x1080
  clock: 27MHz
/mnt/mmc01 #
```


## Firmware OpenIPC

## Flash OpenIPC
(sớm...)

### Dump khởi động
(quá dài để dịch, nếu bạn cần phần này được dịch, vui lòng cho tôi biết)


(sớm...)

### rtl8188fu
(sớm...)

### Trình điều khiển động cơ

Camera có 2 động cơ bước để điều khiển độ nghiêng (lên/xuống) và xoay (trái/phải).

Thay thế trình điều khiển động cơ tại /lib/modules/4.9.37/hisilicon/camhi-motor.ko bằng trình điều khiển được bao gồm bên dưới.

Tệp .zip cũng bao gồm bản dựng được sửa đổi một chút của [mã điều khiển mẫu](https://github.com/OpenIPC/motors) mà bạn có thể sao chép vào /bin.

[camhi-motor.zip](https://github.com/ljalves/wiki/files/7873614/camhi-motor.zip)

Cách sử dụng:
```
motor_ctrl -d u        # di chuyển/nghiêng lên (theo mặc định là 20 bước)
motor_ctrl -d d        # di chuyển/nghiêng xuống
motor_ctrl -d l        # di chuyển/xoay sang trái
motor_ctrl -d r -s 50  # di chuyển/xoay sang phải 50 bước
```

### Cấu hình cảm biến/chân Majestic

```
image:
  mirror: true
  flip: true
(...)
nightMode:
  irCutPin1: 15
  irCutPin2: 12
  backlightPin: 40

```

### Đèn LED
Camera có đèn LED hai màu (đỏ/xanh) được kết nối với GPIO 50 và 51.
Để điều khiển các đèn LED đó, bạn có thể sử dụng api /sys:
```
# làm cho GPIO có thể truy cập được
echo 50 > /sys/class/gpio/export
# và đặt hướng (chỉ cần thực hiện một lần)
echo out > /sys/class/gpio50/direction
echo out > /sys/class/gpio51/direction

# bật đèn LED xanh
echo 1 > /sys/class/gpio50/value
# tắt đèn LED xanh
echo 0 > /sys/class/gpio50/value

# bật đèn LED đỏ
echo 1 > /sys/class/gpio51/value
# tắt đèn LED đỏ
echo 0 > /sys/class/gpio51/value
```
