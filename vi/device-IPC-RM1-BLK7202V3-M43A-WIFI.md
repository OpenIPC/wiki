# IPC-RM1-BLK7202V3-M43A-WIFI
- [Tổng quan](#tổng-quan)
  - [Thông tin thiết bị](#thông-tin-thiết-bị)
- [Đầu nối](#đầu-nối)
  - [Mặt trước](#mặt-trước)
  - [Mặt sau](#mặt-sau)
- [GPIO](#gpio)
  - [Ghép kênh](#ghép-kênh)
  - [Thẻ SD](#thẻ-sd)
  - [Loa](#loa)
- [Cài đặt](#cài-đặt)
  - [Bố cục bộ nhớ flash](#bố- cục-bộ-nhớ-flash)
- [Tóm tắt](#tóm-tắt)
- [Việc cần làm](#việc-cần-làm)

# Tổng quan
Bảng mạch được tìm thấy trong camera PTZ WiFi Cootli trong nhà giá rẻ. Bảng mạch trông rất giống với [XM IPG-G4-WR-BL](http://baike.xm030.cn:81/%E4%BA%A7%E5%93%81%E5%8F%82%E6%95%B0/English/IPG%E6%A8%A1%E7%BB%84/Parameters%20for%20IPG-G4-WR.pdf) nhưng bố cục PCB hơi khác một chút.

Tất cả các thử nghiệm đã hoàn thành trên firmware [gk7202v300_lite_cootli_camv0103-nor](https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_cootli_camv0103-nor.tgz) (bản dựng ngày 8 tháng 2 năm 2024).

## Thông tin thiết bị
| Hệ thống | Mô tả | Ghi chú | 
|-|-|-|
| SoC | GK7202V300 | |
| Flash | XMC XM25QH64CHIQ | 8MB |
| Cảm biến | SmartSens SC223A* | 1920x1080 |
| Âm thanh | MIC + SPK | |
| Lưu trữ | Thẻ nhớ Micro SD | |
| LAN | - | - |
| WiFi | iComm SV6355 | UF.L (IPX) |
| BT | +? | +? |
| Động cơ | 2x Stepper | GPIO + ULN2803A |
| Kích thước | 38 x 54 mm | |

\* - được báo cáo bởi ipctool

Mặt trước
![Mặt trước](../images/device-IPC-RM1-BLK7202V3-M43A-WIFI_front.jpg)

Mặt sau
![Mặt sau](../images/device-IPC-RM1-BLK7202V3-M43A-WIFI_back.jpg)

Dấu hiệu PCB
![Dấu hiệu PCB](../images/device-IPC-RM1-BLK7202V3-M43A-WIFI_markings.jpg)

# Đầu nối
Loại đầu nối JST 1.25mm
![Đầu nối JST](../images/device-IPC-RM1-BLK7202V3-M43A-WIFI_connectors.jpg)

## Mặt trước
| Đầu nối | Kiểu |
|:-:|:-|
| IRCUT | 2 chân JST |
| LED | 5 chân JST |
| MIC | 2 chân JST |

## Mặt sau
- Ổ cắm thẻ nhớ Micro SD
- UART (chưa hàn, ở bên trái SPK, chân 1 RX, chân 2 TX)

| Đầu nối | Kiểu |
|:-:|:-|
| SPK | 2 chân JST |
| H | 5 chân JST |
| V | 5 chân JST |
| +5V | 2 chân JST |
| RF | UF.L (IPX) |

# GPIO
| GPIO | Đầu nối | Mô tả |
|:-:|:-:|:-:|
| 0* | - | Nút đặt lại |
| 4 | Chân LED 5 | WLED |
| 8 | Mô-đun WiFi chân 3 | LO - Bật nguồn |
| 12 | Chân H 5 | Động cơ H |
| 13 | Chân H 2 | Động cơ H |
| 14 | Chân H 4 | Động cơ H |
| 15 | Chân H 3 | Động cơ H |
| 16 | Chân LED 4 | IRLED |
| 52 | Chân V 2 | Động cơ V |
| 53 | Chân V 3 | Động cơ V |
| 54 | Chân V 4 | Động cơ V |
| 55 | Chân V 5 | Động cơ V |
| 56 | Chân IRCUT 1 | LO - IRCUT BẬT |
| 57* | Chân LED 3 | Cảm biến IR |
| 58 | Chân IRCUT 2 | LO - IRCUT TẮT |
| 70 | - | Nguồn SD (LO - Bật nguồn) |
| 51 | - | Bộ khuếch đại ÂM THANH |

\* - chưa được xác nhận.

## Ghép kênh
Không cần ghép kênh nếu Majestic kiểm soát các chân. Nếu không, có thể thực hiện ghép kênh bằng cách sử dụng các lệnh sau.

Ghép kênh GPIO16 để kiểm soát chân IRLED:
```sh
devmem 0x120c0020 32 0x432      # GPIO2_0 (GPIO16)
```

Cũng dành cho động cơ.  
Ghép kênh GPIO12, GPIO14, GPIO15 (đầu nối động cơ H):
```sh
devmem 0x120c0010 32 0x1e02     # GPIO1_4 (GPIO12)
devmem 0x120c0018 32 0x1d02     # GPIO1_6 (GPIO14)
devmem 0x120c001c 32 0x1402     # GPIO1_7 (GPIO15)
```

Ngay sau **Đang tải các mô-đun hạt nhân...**, GPIO13 chuyển sang HI (một trong các cuộn dây động cơ được cấp nguồn liên tục), vì vậy có thể cần thiết phải chuyển nó sang LO:
```sh
gpio clear 13
gpio unexport 13
```

## Thẻ SD
Theo mặc định, Thẻ SD không được cấp nguồn, vì vậy chúng ta cần chuyển GPIO70 sang LO bằng cách nào đó.

Để bật nguồn Thẻ SD từ Kernel:
```sh
gpio clear 70
```
hoặc
```sh
devmem 0x120B8400 32 0x40       # chuyển GPIO8_6 sang chế độ đầu ra
devmem 0x120B8100 32 0x00       # đặt GPIO8_6 thành LO
```
Và gắn lại thẻ SD.

Để bật nguồn Thẻ SD từ U-Boot:
```sh
mw 0x120B8400 0x40      # chuyển GPIO8_6 sang chế độ đầu ra
mw 0x120B8100 0x00      # đặt GPIO8_6 thành LO
mmc rescan
```

## Loa
Thiết bị hỗ trợ phát PCM đã ký 16 bit little-endian, 8000 Hz, 1CH bằng cách gửi dữ liệu đến điểm cuối http://192.168.0.10/play_audio.

Tệp âm thanh có thể được mã hóa như sau:
```sh
ffmpeg -i input.wav -f s16le -ar 8000 -ac 1 output.pcm
```

Và gửi đến loa của camera:
```sh
curl -v -u user:pass -H "Content-Type: application/json" -X POST --data-binary @audio.pcm http://192.168.0.10/play_audio
```

# Cài đặt
Firmware gốc bị khóa pwd và giao diện LAN không có, vì vậy tôi đoán các phương pháp sau đây có sẵn để flash bảng này:
- [burn](https://github.com/OpenIPC/burn)  + [u-boot-gk7202v300-universal.bin](https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-gk7202v300-universal.bin) và sau đó tải lên FW qua X/Y/ZMODEM (ví dụ: **loady**. Mẹo: sử dụng tùy chọn **baud** để tăng tốc độ) hoặc từ thẻ SD (yêu cầu cung cấp nguồn, [xem ở trên](#thẻ-sd))
- tải toàn bộ hình ảnh thông qua giao diện web gốc (chưa được kiểm tra)
- lập trình viên flash
- bằng cách nào đó vào bộ nạp khởi động gốc

## Bố cục bộ nhớ flash
| Offset | Kích thước | Mô tả | 
|:-|:-|:-|
| 0x00000000 | 0x00040000 (262144 byte) | bộ nạp khởi động |
| 0x00040000 | 0x00010000 (65536 byte) | env |
| 0x00050000 | 0x00200000 (2097152 byte) | hạt nhân |
| 0x00250000 | 0x00500000 (5242880 byte) | rootfs |
| 0x00750000 | 0x000B0000 (720896 byte) | rootfs_data |

# Tóm tắt
- [X] WiFi hoạt động
- [X] Video đã được kiểm tra/phát trực tuyến
- [X] Ngày/đêm hoạt động (IRCUT và IRLED)
- [X] MIC hoạt động
- [X] Loa hoạt động
- [ ] PTZ/Động cơ (Chân GPIO được tìm thấy/có thể truy cập, trình điều khiển chưa được kiểm tra)

# Việc cần làm
- bằng cách nào đó vá/thích ứng camhi-motor.ko, để làm cho nó hoạt động trên bảng này.
