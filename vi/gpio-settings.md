# OpenIPC Wiki
[Mục lục](../README.md)

Danh sách cài đặt GPIO dành riêng cho bo mạch
---------------------------------

### Bo mạch Anjoy / Anjvision

| Bộ xử lý | IRCUT1 | IRCUT2 | Đèn hồng ngoại | Đèn trắng | RESET | I/O | USB_ENA | BO MẠCH ĐÃ KIỂM TRA | ĐẦU RA ÂM THANH |
|-------------|--------|--------|----------|-------------|-------|-----|---------|------------------|-----------------|
| SSC30KQ     | 23     | 24     | 60/59    |             | 10    |     |         | MC-L12, MC-L12B  |      9          |
| SSC335      | 78     | 79     | 61/53    |             | 66    | 52  |         | MS-J10, YM200J10 |      80         |
| SSC337      | 78     | 79     | 61       |             | 66    | 52  |         | MC-F40, YM-J10D  |                 |
| SSC337DE    | 78     | 79     | 61       |             | 66    |     |         | MC500L8          |                 |
| SSC338Q     | 23     | 24     | 60       | 59          | 10    |     |    8    | MC800S-V3        |      39         |
| SSC377      | 11     | 80     | 9        | 13          |       |     |         | MC-A42P-V1.1     |      12         |

### Bo mạch CamHi / Xin

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | USB_ENA | UART2_RTS/RS485_DE | UART2_RXD/RS485_RO | UART2_TXD/RS485_DI | AUDIO_ENA | RESET | PWM | SD_VCC | BO MẠCH |
|-------------|--------|--------|----------|-------|---------|--------------------|--------------------|--------------------|-----------|-------|-----|--------|----------|
| Gk7205v200  | 14     | 15     | 8        | 4     | 9i      | 54                 | 12                 | 13                 | 12        | 50    |     |        | 2M-M2103 |
| Gk7205v200  | 13     | 15     | 8        | 4     | 9i      | 54                 | 12                 | 13                 | 12        | 50    |     |        | 2G-M3072 |
| Gk7205v300  | 10     | 11     | 8        | 72    | 7i      |                    |                    |                    | 52        | 42    |     |        |          |
|             |        |        |          |       |         |
| Hi3516Cv100 |        |        |          |       |         |
| Hi3516Cv200 |        |        |          |       |         |
| Hi3516Cv300 |        |        |          |       |         |
| Hi3516Ev100 |        |        |          |       |         |
| Hi3516Ev200 |        |        |          |       | 9i      |
| Hi3516Ev300 | 10     | 11     |          |       | 7i      | 63                 |                    |                    |           | 42    |
| Hi3518Ev100 | 43     |        | 74       |       |         |
| Hi3518Ev200 | 1      | 2      | 48       |       |         |
| Hi3518Ev300 |        |        |          |       |         |
|             |        |        |          |       |         |
| T31         | 58     | 57     |          | 49    | 61i     | 53                 | 55                 | 56                 | 63          | 11    | 50  | 62     |

> _i - đảo ngược_

```
Đã thử nghiệm trên GK7205V200 cho /dev/ttyАМА1:
  mux 12->UART2_RXD/RS485_RO: devmem 0x112c0070 32 2 
  mux 13->UART2_TXD/RS485_DI: devmem 0x112c0074 32 2
```
```
Đã thử nghiệm trên GK7205V300 cho /dev/ttyАМА1:
  mux 72->UART1_TXD: devmem 0x112c0078 32 1 
  mux 73->UART1_RXD: devmem 0x112c007c 32 1
```


### Bo mạch CCDCAM / Hankvision

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | USB_ENA | Mô tả |
|-------------|--------|--------|----------|-------|---------|-------------|
| GK7205V200 | 68     | 70     | 9        |       |         |             |
| GK7205V200 | 50     | 51     |          |       |         | Chuông cửa màn hình nhựa cũ |
| GK7205V300 | 68     | 70     | 9        |       |         |             |

> _Đúng vậy, thật ngạc nhiên nhưng nó thực sự khớp với hai bộ xử lý Goke_

### Bo mạch GSA / EnZhi

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | USB_ENA |
|-------------|--------|--------|----------|-------|---------|
| T31L       | 58     | 57     |          | 49     |         |


### Bo mạch Herospeed/Longse/Cantonk

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | ALM_IN | ALM_OUT | USB_ENA |
|-------------|--------|--------|----------|-------|--------|---------|---------|
| Gk7205v200  | 12     | 13     |          | 4     | 15     | 14      |         |
|             |        |        |          |       |        |         |         |
| Hi3516Cv100 | 18     | 19     |          |       |        |         |         |
| Hi3516Cv200 |        |        |          |       |        |         |         |
| Hi3516Dv100 | 3      | 4      | 85       |       |        |         |         |
| Hi3516Cv300 | 1      |  2     | 24       |       |        |         |         |
| Hi3518Ev200 | 65     | 64     | 63       |       |        |         |         |
| Hi3516Ev200 | 12     | 13     |          | 4     |        |         |         |
| Hi3516Av300 | 5      | 6      |          |       |        |         |         |


### Bo mạch Huishi / Vatilon

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRLED |
|-------------|--------|--------|----------|-------|
| SSC377      | 80     | 81     |          |       |
| SSC378DE    | 80     | 81     |          | 13    |


### Bo mạch Jabsco

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS |
|-------------|--------|--------|----------|
| Hi3516Ev200 | 52     | 53     | 9        |

### Bo mạch Jovision

| Bộ xử lý | IRCUT1 | IRCUT2 | Đèn | BO MẠCH ĐÃ KIỂM TRA                 |
|-------------|--------|--------|-------|------------------------------------|
| Hi3516Ev200 | 53     | 52     | 4     |                                    |
| Hi3516Cv100 | 42     | 43     | 6     | IPG5020A-H-V1.0, 5013A-CF/5020A-FF |

### Bo mạch JUAN (Sannce)

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS      | BO MẠCH ĐÃ KIỂM TRA | ID THIẾT BỊ |
|-------------|--------|--------|---------------|---------------|-----------|
| Hi3518Ev200 | 65     | 64     | 62 (đảo ngược) | 18EV200_V205P | N18EV2W   |

### Bo mạch JVT

| Bộ xử lý | IRCUT1 | IRCUT2 | Đèn |
|-------------|--------|--------|-------|
| Hi3516Cv100 |        |        |       |
| Hi3516Cv200 | 64     | 65     | 62    |
| Hi3516Cv300 |        |        |       |
| Hi3516Ev200 |        |        |       |
| Hi3518Ev200 | 64     | 65     | 47    |

### Camera mini "khối lập phương" iSNATCH (HeySmart)

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRLED    | RESET  |
|-------------|--------|--------|----------|----------|---------|
| T10         | 25     | 26     | -        | 19       |  60i   |

### Bo mạch Netcam NVT

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRLED    | Đèn LED đỏ | BO MẠCH           |
|-------------|--------|--------|----------|----------|---------|-----------------|
| T10         | 25     | 26     |          | 19       | 20      |                    |
| T10         | 25     | 26     | 81       | 80       |         |                    |
| T31L        | 58     | 57     |          |          |         | T31L_F37_V1.1   |

### Camera an ninh Qihoo 360 D603

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRLED    | WIFI  |  LED  |
|-------------|--------|--------|----------|----------|-------|-------|
| T20         | 25     |   26   | -        | 61       |  62   |   82  |

### Rostelecom IPC2122SR3-RU04

| Bộ xử lý | IRCUT1 | IRCUT2 |
|-------------|--------|--------|
| Hi3516Cv300 | 58     | 59     |

### Cảm biến Rotek Switcam E200/T200 JXF23

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS |
|-------------|--------|--------|----------|
| Hi3518Ev200 | 63     | 64     | 65       |

### Bo mạch SJG

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS      | BO MẠCH                     |
|-------------|--------|--------|---------------|---------------------------|
| Hi3518Ev200 | 64     |        | 62 (đảo ngược) | SJG_HI38_GW2M02_V1.3      |

> Đối với cảm biến `SC2135` trên bo mạch `SJG_HI38_GW2M02_V1.3`, cần phải thay đổi mặt nạ `ComMsk0` từ `fff0000` thành `3ff0000` trong cấu hình cảm biến (`/etc/sensors/sc2135_i2c_1080p.ini`) để loại bỏ hiện tượng ám hồng của hình ảnh ở chế độ ban ngày.

### Bo mạch Tiandy

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | RESET |
|-------------|--------|--------|----------|-------|-------|
| SSC335      | 78     | 79     | ---      | 37    |       |

### Bo mạch Uniview

| Bộ xử lý | IRCUT1 | IRCUT2 | RESET | IRCTL | IRLED | WiFi | ID THIẾT BỊ                             |
|-------------|--------|--------|-------|-------|-------|------|---------------------------------------|
| Hi3516Ev300 | 63     | 67     | 64    |       |  72   |  7   | Rostelecom IPC8232SWC-WE, C1L-2WN-G   |
| SSC335DE    | 61     | 79     |       |   4   |       |      | Rostelecom IPC8232SWC-WE-B            |
| SSC335      | 61     | 79     |       |       |  76   |      | Uniarch UV-IPC-D122-PF28              |

### Wansview

| Bộ xử lý | IRCUT1 | IRCUT2 | Đèn LED IR | RESET | ETH_GR_BL | ETH_ORANGE| ID THIẾT BỊ                    |
|-------------|--------|--------|---------|-------|-----------|-----------|-----------------------------|
| T21         | 80     | 79     |  49     | 50    |    73     |     72    |   Wansview W5/W6/Q5 (1080p) |

### Bo mạch Xiaomi

| Bộ xử lý | IRCUT1 | IRCUT2 | Đèn LED IR | ID THIẾT BỊ     | ORANGE_LED | BLUE_LED | RESET | AUDIO_ENA |
|-------------|--------|--------|---------|---------------|------------|----------|-------|-----------|
| SSC325      | 78     | 79     |  52     | CMSXJ25A      |            |          |       |           |
| Hi3518Ev300 | 70     | 68     |  54     | MJSXJ02HL     |     52     |    53    |   0   |    55     |
| T31N        | 49     | 50     |  60     | MJSXJ03HL     |     38     |    39    |       |           |

### XiongMai, bo mạch XM

| Bộ xử lý       | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | ALM_IN | ALM_OUT | ETH_ACT | ETH_STA | RESET | USB_ENA | AUDIO_POW | RS485_CTL | W_LED | GHI CHÚ |
|-----------------|--------|--------|----------|-------|--------|---------|---------|---------|-------|---------|-----------|-----------|-------|-------|
| GK7205V200      | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         | 40        |           |       |       |
| GK7205V210      | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         | 40/53     |           |       |       |
| GK7205V300      | 11     | 10     | 66       | 52    | 4      |         | 30      | 31      | 0     |         | 60        | 24        |       |       |
| GK7205V300[^4]  | 11     | 10     | 65       | 52    |        |         | 30      | 31      | 67    |         | 64/65     | 24        | 4     |       |
| GK7605V100      | 10     | 11     | 66       | 52    | 4      |         | 30      | 31      | 0     |         | 60        | 24        |       |       |
|                 |        |        |          |       |        |         |         |         |       |         |
| Hi3516Cv100     | 38     | 39     | 24       |       | 49     | 26      |         |         |       |         |           |           |       |       |
| Hi3516Dv100[^1] | 14     | 15     |  3       |       |        |         |         |         |       |         |           |           |       |       |
| Hi3516Dv100[^2] | 121    | 120    |  3       |       |        |         |         |         |       |         |           |           |       |       |
| Hi3516Cv200     |        |        |          |       |        |         |         |         |       |         |           |           |       |       |
| Hi3516Cv300     | 53     | 54     | 64       | 66    | 55     | 1       |         |         | 2     | 63      |           |           |       |       |
| Hi3516Ev100     | 53     | 54     | 64       |       |        |         |         |         |       |         |           |           |       |       |
| Hi3516Ev200     | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         |           |           |       |       |
| Hi3516Ev300     | 11     | 10     | 66       | 52    | 4, 67  | 65      | 30      | 31      | 0     |         |           |           |       |       |
| Hi3518Ev100     | 39     | 38     | 24       |       | 49     | 26      |         |         |       |         |           |           |       |       |
| Hi3518Ev200     | 33     | 34     | 24       |       | 61     | 35      |         |         |       |         | 3       |           |       | IPG-50HV20PET-S |
| Hi3518Ev300[^3] | 8      |        |  55      |       | 13     |         |         |         | 15    |         | 3       |           |       |       |

> Có một bản đồ giữa các cột của bảng và các tham số trong phần `nightMode` trong `majestic.yaml`<br>
> IRCUT1 là irCutPin1<br>
> IRCUT2 là irCutPin2<br>
> IRCTL là backlightPin<br>
> IRSTATUS là irSensorPin

[^1]: HI3516D_N81820, firmware 00014914
[^2]: Hi3516Dv100 cho IPC_HI3516D_83H20 00014911
[^3]: Hi3518EV300 cho 50H20L
[^4]: IPC_GK7205V300_G6S (firmware 000699Q3)


### Zenotech/Videopark

| Bộ xử lý | IRCUT1 | IRCUT2 | IRLED | ID THIẾT BỊ                |
|-------------|--------|--------|-------|--------------------------|
| GK7205V200  | 58     | 59     | 8     | ZN-CM-GK200S1L-P         |
|             |        |        |       |                          |
| Hi3516Ev300 | 14     | 12     |       | ZN-CM-HSC500S1L-PZ       |
| Hi3516Ev300 | 40     | 41     | 65    | unknown                  |


### Zosi

| Bộ xử lý | IRCUT1 | IRCUT2 | IRSTATUS     | ID THIẾT BỊ     |
|-------------|--------|--------|--------------|---------------|
| Hi3518Ev200 | 61     | 60     | 1 (đảo ngược) | ZG2622MW      |