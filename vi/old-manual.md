# OpenIPC Wiki
[Mục lục](../README.md)

Giới thiệu
------------

Trang này mô tả biến thể firmware dựa trên OpenWRT.

### Các tính năng của Firmware

* RTSP, ONVIF, NETIP
* Hỗ trợ dịch vụ ipeye gốc
* Hỗ trợ squashfs, jffs2, overlayfs, vfat
* Hỗ trợ VLAN và cầu nối
* Hệ thống gói OPKG tiêu chuẩn
* Tiny SNMP daemon
* Curl với SSL để tải lên/tải xuống tệp
* Chạy lệnh tùy ý từ u-boot ENV (linux_cmd=)
* VPN L2/L3 đơn giản với định hình lưu lượng và nén (vtun)
* Bot Telegram gửi đơn giản (estgb)
* Hỗ trợ modem USB 3G/4G chi phí thấp ở chế độ hilink
* Dịch vụ đường hầm µVPN
* và hơn thế nữa ...


### Thiết bị được hỗ trợ

Chúng tôi hướng đến việc phát triển firmware **phổ biến**, di động hỗ trợ nhiều loại
nhà sản xuất và cung cấp các bản cập nhật và sửa lỗi mà các nhà cung cấp thường xuyên
không thể cung cấp.

Danh sách được cập nhật liên tục, vui lòng truy cập thường xuyên và/hoặc theo dõi các nhóm Telegram
của chúng tôi để nhận thông báo phát hành mới.

Thêm thông tin về cảm biến: [https://cctvsp.ru][8] (được dịch từ tiếng Nga
với Google Dịch).


### Giao diện web

* <http://192.168.1.10/> - Giao diện hệ thống tiêu chuẩn dựa trên OpenWrt Luci


### Trình phát trực tuyến Majestic

Majestic là một ứng dụng phát video trực tuyến, trái tim của firmware của chúng tôi (liên quan
đến chức năng giám sát camera/video). Nó có thể cấu hình thông qua
tệp `/etc/majestic.yaml` và theo mặc định, nhiều tính năng/dịch vụ được bật.
Các tùy chọn không cần thiết có thể được tắt để bảo mật và hiệu suất tốt hơn.

Để chạy `majestic` ở chế độ gỡ lỗi:

```bash
killall -sigint majestic; export SENSOR=$(ipctool --sensor_id); majestic
```

Để chạy `majestic` ở chế độ sản xuất, hãy khởi động lại camera hoặc chạy lệnh:

```bash
killall -sigint majestic; export SENSOR=$(ipctool --sensor_id); majestic 2>&1 | logger -p daemon.info -t majestic &
```


### URL liên quan đến camera trong firmware

Bạn có thể tìm thấy thông tin về URL của trình phát trực tuyến và mô tả của chúng trong [Wiki][9].


### Dữ liệu thống kê

Phần mềm có thể thực hiện thu thập dữ liệu sử dụng sản phẩm bao gồm tên SoC và kiểu cảm biến
để thu thập số liệu thống kê được sử dụng trong quy trình QA.

Chúng tôi đảm bảo rằng dữ liệu được ẩn danh hoàn toàn và không chứa bất cứ điều gì
có thể được coi là dữ liệu về một cá nhân, có thể được coi là dữ liệu của người dùng cuối;
hoặc điều đó có thể nhạy cảm hoặc bí mật đối với người dùng.


Nhận firmware
----------------

### Tải xuống (dev mới nhất)

| Trạng thái build           | SoC         | U-Boot      | Kernel        | Rootfs        |
|----------------------------|-------------|-------------|---------------|---------------|
| ![Ảnh Hi3516Cv100][b1]  | Hi3516CV100 | [uboot][u1] | [kernel][k1]  | [rootfs][r1]  |
| ![Ảnh Hi3516Cv200][b2]  | Hi3516CV200 | [uboot][u2] | [kernel][k2]  | [rootfs][r2]  |
| ![Ảnh Hi3516Cv300][b3]  | Hi3516CV300 | [uboot][u3] | [kernel][k3]  | [rootfs][r3]  |
| ![Ảnh Hi3516Ev100][b4]  | Hi3516EV100 | [uboot][u4] | [kernel][k4]  | [rootfs][r4]  |
| ![Ảnh Hi3518Av100][b5]  | Hi3518AV100 | [uboot][u5] | [kernel][k5]  | [rootfs][r5]  |
| ![Ảnh Hi3518Cv100][b6]  | Hi3518CV100 | [uboot][u6] | [kernel][k6]  | [rootfs][r6]  |
| ![Ảnh Hi3518Ev100][b7]  | Hi3518EV100 | [uboot][u7] | [kernel][k7]  | [rootfs][r7]  |
| ![Ảnh Hi3518Ev200][b8]  | Hi3518EV200 | [uboot][u8] | [kernel][k8]  | [rootfs][r8]  |
| ![Ảnh Hi3518Ev201][b9]  | Hi3518EV201 | [uboot][u9] | [kernel][k9]  | [rootfs][r9]  |
| ![Ảnh Hi3520Dv100][b10] | Hi3520DV100 | !           | [kernel][k10] | [rootfs][r10] |
| ![Ảnh Hi3520Dv200][b11] | Hi3520DV200 | !           | [kernel][k11] | [rootfs][r11] |


### Bản phát hành

Các **bản phát hành** của firmware OpenIPC được lưu trữ tại <https://github.com/OpenIPC/chaos_calmer/releases>.


### Mã nguồn

**Mã nguồn** của firmware OpenIPC được lưu trữ tại <https://github.com/openipc/chaos_calmer>.


Xây dựng từ mã nguồn
--------------------

### Xây dựng trên máy Linux

Ví dụ sử dụng cho Debian 8/9

```bash
git clone --depth=1 https://github.com/OpenIPC/chaos_calmer.git OpenIPC
cd OpenIPC
./Project_OpenIPC.sh update
./Project_OpenIPC.sh 16cv300_DEFAULT
```


### Sử dụng Docker để xây dựng

> **Dockerfile.openipc mặc định**

```docker
FROM debian:stretch

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get --no-install-recommends -y install bc bison build-essential \
    ca-certificates cmake cpio curl dos2unix file flex gawk gcc-multilib \
    gettext gettext-base git intltool libc6-dev liblocale-gettext-perl \
    libncurses-dev libssl-dev locales mc openssl python rsync subversion \
    time tofrodos unzip upx wget zlib1g-dev \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias \
    en_US.UTF-8 && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.utf8

WORKDIR /src/openipc

RUN git clone --depth=1 https://github.com/OpenIPC/chaos_calmer.git /src/openipc
RUN ./Project_OpenIPC.sh update
RUN ./Project_OpenIPC.sh 18ev200_DEFAULT  # <= Thay đổi ID này thành hồ sơ của bạn
```

> **Bắt đầu xây dựng**

```bash
#!/bin/bash

docker build -t openipc -f Dockerfile.openipc .
```


Chuẩn bị cài đặt
--------------------

### Truy cập vào U-boot

Kết nối nối tiếp (UART) với thiết bị camera của bạn là bắt buộc.

* CamHi | Nhấn **Ctrl+C** trong khi khởi động U-boot và truy cập mật khẩu - HI2105CHIP
* Dahua | Nhấn **Shift 8** trong khi khởi động U-boot
* JVT | Nhấn **Ctrl+Q** trong khi khởi động U-boot
* XM | Nhấn **Ctrl+C** trong khi khởi động U-boot
* SigmaStar | Nhấn **Ctrl+B** (UNIV) hoặc **Enter** (Anjvision) trong khi khởi động U-boot


### Sao lưu MAC gốc

Bạn chắc chắn nên ghi lại MAC gốc của thiết bị trên cổng eth0.

Điều này rất **quan trọng** và sẽ cần thiết ở giai đoạn cấu hình thiết bị cuối cùng.


### Sao lưu firmware gốc

#### Flash 8MB

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 1000000
sf read 0x82000000 0x0 0x800000
tftp 0x82000000 fullflash.img 0x800000
```

#### Flash 16MB

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 1000000
sf read 0x82000000 0x0 0x1000000
tftp 0x82000000 fullflash.img 0x1000000
```

#### Flash 32MB

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 2000000
sf read 0x82000000 0x0 0x2000000
tftp 0x82000000 fullflash.img 0x2000000
```


### Flash và bố cục bộ nhớ

Chúng tôi đã phát triển một hệ thống phân vùng phổ biến cho chip flash camera,
và hiện nó có sẵn dưới dạng tiêu chuẩn cho tất cả các loại thiết bị. (Lưu ý
rằng điều đó có nghĩa là nó có thể không khớp với bố cục flash của nhà cung cấp.)

#### Bố cục flash OpenIPC

```txt
0x000000000000-0x000000040000 : "boot"
0x000000040000-0x000000050000 : "env"
0x000000050000-0x000000250000 : "kernel"
0x000000250000-0x000000750000 : "rootfs"
0x000000750000-0x000001000000 : "rootfs_data"
```

#### Địa chỉ tải bộ nhớ Kernel

```txt
loadaddr-$(CONFIG_TARGET_hi35xx_16cv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16cv200) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16cv300) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16dv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16ev100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16ev200) := 0x40008000
loadaddr-$(CONFIG_TARGET_hi35xx_16ev300) := 0x40008000
loadaddr-$(CONFIG_TARGET_hi35xx_18cv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev200) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev201) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev300) := 0x40008000
loadaddr-$(CONFIG_TARGET_hi35xx_20dv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_20dv200) := 0x80008000
```


Flash firmware mới
---------------------

**Chú ý!**

Tất cả các ví dụ đều cho biết việc tải xuống các thành phần firmware thông qua máy chủ TFTP. 
Nếu thiết bị của bạn không có cổng Ethernet, hãy thay thế tất cả các lệnh `tftp` bằng
`fatload mmc 0:1`. Ví dụ:

```txt
tftp 0x82000000 openwrt-hi35xx-XXXXX-u-boot.bin
#
fatload mmc 0:1 0x82000000 openwrt-hi35xx-XXXXX-u-boot.bin
```

### Hi3516Cv100

**Loại bo mạch này có hệ thống điều khiển Ethernet bổ sung thông qua GPIO và
thanh ghi. Hãy tham khảo ý kiến chuyên gia!**

**Thiết bị thử nghiệm:**

* 00:12:16:FA:F3:52
* 00:12:12:10:31:54 - BLK18C_0222_38x38_S_v1.03

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3516Cv200

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv200-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv200-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv200-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3516Cv300

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3516Ev100

**Thiết bị thử nghiệm:**

* 00:12:13:02:d7:2c

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16ev100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3518Cv100

**Loại bo mạch này có hệ thống điều khiển Ethernet bổ sung thông qua GPIO và
thanh ghi. Hãy tham khảo ý kiến chuyên gia!**

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18cv100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3518Ev100

**Loại bo mạch này có hệ thống điều khiển Ethernet bổ sung thông qua GPIO và
thanh ghi. Hãy tham khảo ý kiến chuyên gia!**

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3518Ev200

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev200-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev200-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev200-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3520Dv100

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv100-experimental-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3520Dv200

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv200-experimental-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv200-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv200-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```


Cập nhật các phần của firmware
------------------------------

Nếu bạn đã cài đặt firmware OpenIPC, bạn có thể cập nhật riêng lẻ
các phân vùng flash từ dòng lệnh shell:


### Cập nhật u-boot

```bash
flashcp -v openwrt-hi35xx-XXXXX-u-boot.bin boot
```

> **hoặc**

```bash
flashcp -v openwrt-hi35xx-XXXXX-u-boot.bin /dev/mtd0
```


### Cập nhật kernel

```bash
flashcp -v openwrt-hi35xx-XXXXX-default-uImage kernel
```


### Cập nhật rootfs

```bash
flashcp -v openwrt-hi35xx-XXXXX-default-root.squashfs rootfs
```


Cấu hình hệ thống sau khi cài đặt
--------------------------------------

### Định dạng phân vùng overlayfs

**Phải được thực hiện trong lần chạy đầu tiên!**

```txt
flash_eraseall -j /dev/$(awk -F ':' '/rootfs_data/ {print $1}' /proc/mtd)
reboot
```


### Cài đặt MAC gốc

> **U-boot ENV và Linux UCI**

```txt
fw_setenv ethaddr 00:01:02:03:04:05
uci set network.lan.macaddr=00:01:02:03:04:05
uci commit
```


### Cài đặt cảm biến chính xác

> **Chỉ định cảm biến chính xác, loại điều khiển và bus dữ liệu của bạn**

```txt
fw_setenv sensor imx291_i2c_lvds
```


Đặt lại cấu hình
-----------------------

Nếu có sự cố xảy ra, bạn có thể đặt lại cấu hình về mặc định.


### Dọn dẹp overlayfs (đặt lại)

> **Khôi phục về cài đặt Linux mặc định**

```txt
firstboot
reboot
```


### Dọn dẹp môi trường u-boot

> **Khôi phục về môi trường u-boot mặc định**

```txt
flash_eraseall -j /dev/$(awk -F ':' '/env/ {print $1}' /proc/mtd)
reboot
```


### Khôi phục firmware sao lưu

Nếu có sự cố nghiêm trọng xảy ra và bạn muốn khôi phục lại firmware đã sao lưu của mình

> **Khôi phục firmware sao lưu qua cổng nối tiếp**

Cài đặt kermit bằng cách sử dụng [hướng dẫn này](https://glasstty.com/?p=662) hoặc tương tự.
Dưới đây là các lệnh mẫu cho Flash 8MB.

```
kermit
Linux Kermit> CONNECT
Kết nối với /dev/ttyUSB0, tốc độ 115200
 Ký tự thoát: Ctrl-\ (ASCII 28, FS): đã bật
Nhập ký tự thoát theo sau là C để quay lại,
hoặc theo sau là ? để xem các tùy chọn khác.
----------------------------------------------------
## Tổng kích thước      = 0x002fb3f1 = 3126257 Byte
## Địa chỉ bắt đầu      = 0x82000000
OpenIPC # sf probe 0
8192 KiB hi_sfc tại 0:0 hiện là thiết bị hiện tại
OpenIPC # mw.b 0x82000000 ff 1000000
OpenIPC # loadb 0x82000000
## Sẵn sàng để tải xuống nhị phân (kermit) đến 0x82000000 với tốc độ 115200 bps...

(Quay lại tại alex-B85M-D3H)
----------------------------------------------------
Linux Kermit> SEND /srv/tftp/fullflash.img
Linux Kermit> CONNECT
Kết nối với /dev/ttyUSB0, tốc độ 115200
 Ký tự thoát: Ctrl-\ (ASCII 28, FS): đã bật
Nhập ký tự thoát theo sau là C để quay lại,
hoặc theo sau là ? để xem các tùy chọn khác.
----------------------------------------------------
## Tổng kích thước      = 0x00800000 = 8388608 Byte
## Địa chỉ bắt đầu      = 0x82000000
OpenIPC # sf erase 0x0 0x00800000
Đang xóa tại 0x800000 -- 100% hoàn tất.
OpenIPC # sf write 0x82000000 0x0 ${filesize}
Đang ghi tại 0x800000 -- 100% hoàn tất.
OpenIPC #
```
> **Khôi phục firmware sao lưu qua TFTP**

Dưới đây là các lệnh cho Flash 8MB.

```shell
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 fullflash.img
sf erase 0x0 0x00800000
sf write 0x82000000 0x0 ${filesize}
```


## Sách tham khảo

Sẽ được viết ...

[1]: https://aliexpress.com/item/32493067946.html
[2]: https://aliexpress.com/item/32851596596.html
[3]: https://aliexpress.com/item/1005002315913099.html
[4]: https://aliexpress.com/item/1005002298832047.html
[5]: https://aliexpress.