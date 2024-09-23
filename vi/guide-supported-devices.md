# OpenIPC Wiki
[Mục lục](../README.md)

Thiết bị được hỗ trợ
-----------------

Rất tiếc, chúng tôi không thể cung cấp cho bạn một danh sách dài các thiết bị chắc chắn tương thích với firmware của chúng tôi. Các nhà sản xuất camera có xu hướng thay đổi thiết kế phần cứng và hoán đổi các thành phần ngay cả trong cùng một dòng model mà không cần thông báo trước.

Dưới đây, chúng tôi đã liệt kê một số camera mà chúng tôi đã sở hữu, nhưng một lần nữa, không có gì đảm bảo rằng nếu bạn mua một trong những camera đó ngày hôm nay, bạn sẽ không nhận được phần cứng không được hỗ trợ.

Phương pháp hoạt động phần nào để xác định xem camera của bạn có được hỗ trợ bởi phiên bản firmware gần đây của chúng tôi hay không là mở[^1] vỏ camera và xem các dấu hiệu trên chip. Sau đó, tra cứu chip của bạn trong [danh sách phần cứng được hỗ trợ][1]
và kiểm tra trạng thái phát triển của nó.

Nếu bạn vẫn còn nghi ngờ, hãy chụp ảnh cận cảnh phần cứng với độ phân giải cao
và yêu cầu trợ giúp trong một trong các nhóm Telegram của chúng tôi.

[^1]: Chú ý! Khi làm như vậy, bạn tự chịu trách nhiệm hoàn toàn về hành động của mình.
Nhiều khả năng, việc mở vỏ máy sẽ làm mất hiệu lực bảo hành của thiết bị. Chúng tôi không thể
chịu trách nhiệm cho bất kỳ thiệt hại nào đối với camera, bản thân bạn, ngôi nhà của bạn, thú cưng của bạn
hoặc bất cứ thứ gì khác. Nếu bạn không cảm thấy thoải mái với phần cứng, dự án này
có thể không phù hợp với bạn.

Bạn cũng có thể xem danh sách các thiết bị được điều chỉnh trong một dự án Trình tạo đặc biệt -
https://github.com/OpenIPC/builder

_Nếu bạn có một thiết bị được hỗ trợ khác để thêm, vui lòng thực hiện [tại đây][2]._

| Thương hiệu | Model              | Bộ xử lý   | Cảm biến | Bộ nhớ Flash | LAN | WLAN           | USB  | Thẻ |
|------------|--------------------|-------------|--------|--------------|-----|----------------|------|------|
|            |                    |             |        |              |     |                |      |      |
| Anjoy      | MS-J10             | SSC335      | IMX307 |              | Có  | Không           | Có   | Không |
| Anjoy      | YM-J10D            | SSC337      | IMX307 |              | Có  | Không           | Có   | Không |
| Amorvue    | NC1080AW           | HI3518EV200 | SC2135 | MX25L6405D   | Có  | RTL8188EUS[^2] | Không | Không |
| Chacon     | [IPCAM-RI01][3]    | HI3518EV300 | JXF23  | XM25QH128A   | Không | RTL8188FTV     | WiFi | Có   |
|            |                    |             |        |              |     |                |      |      |
| LTV        | CNE-724 48         | HI3516EV200 |        |              | Có  | Không           | Không | Có   |
|            |                    |             |        |              |     |                |      |      |
| Rotek      | Switcam HS303 (v1) | HI3518EV200 |        |              | Không | RTL8188FU      | WiFi | Có   |
| Rotek      | Switcam HS303 (v2) | HI3518EV200 | OV9732 | GD25Q128CSIG | Không | RTL8188EU      | WiFi | Có   |
| Rotek      | Switcam HS303 (v3) | HI3518EV200 |        |              | Không | RTL8188EU      | WiFi | Có   |
|            |                    |             |        |              |     |                |      |      |
| Smartwares | [CIP-37210][4]     | HI3518EV200 |        |              | Không | RTL8188FU      | WiFi | Có   |
|            |                    |             |        |              |     |                |      |      |
| TOP        | TOP-201/MCO-720P Mini Camera  | HI3518EV100 | OV9712 |   | Có  | Không           | Không | Không |
|            |                    |             |        |              |     |                |      |      |
| Xiaomi     | [MJSXJ02HL][7]     | HI3518EV300 |        |              | Không |                |      | Có   |
| Xiaomi     | [MJSXJ03HL][6]     | T31N        | JXQ03 | QH128A-104HIP | Không | RTL8189FTV     | Không | Có   |
| Xiaomi     | [CMSXJ25A]         | SSC325      | GC2053 | QH128A-104HIP| Có  | MT7603UN      | Không | Có   |
|            |                    |             |        |              |     |                |      |      |
| XM         | BLK18EV-0062-0035  | HI3518EV200 | JXH62  |              | Có  |                |      | Có   |
|            |                    |             |        |              |     |                |      |      |
| Zenotech   | HI3516D_MB_V13_RA  | HI3516DV100 | OV9689 | GD25Q128CSIG | Có  | Không           |      | Không |
| Tungson    | DS-YTJ5301         | SSC30KD     | GC2053 |              | Có  | RTL8188FTV     | Không | Không |
| Haier      | HCC-18B30-U1       | T31ZX       | SC3335 | NM25Q128EVB  | Không | SSV6X5X        | Không | Có   |
| iFlytek    | XFP301-M           | T31ZX       | JXQ03  | XM25QH128C   | Không | RTL8188FU      | Không | Có   |
| Qihoo 360  | AP6PCM03           | T31ZX       | GC4653 | EN25QH256A   | Có  | ATBM6031       | Không | Có   |
| Goke       | [MJ-C232V5-0SW1][5]| GK7205V200  | GC2305 | XM25QH128CHIQ| Có  | RTL8188FU      | Không | Không |
| Uniview    | CMCC-IPC-A35       | Hi3516EV300 | SP2305 | W25N01GV     | Có  |                | Không | Không |
| E-Life     | EF3113             | T31L        | GC2053 | ZB25VQ128    | Có  | SV6155P        | Không | Có   |
| E-Life     | ET-N3431H-DW       | T31X        | OS03B10| ZB25VQ128    | Có  | SV6155P        | Không | Có   |
| H3C        | C2041              | T31X        | JXK04  | XM25QH128C   | Có  | RTL8188FTV     | Không | Có   |
| MEGVII     | SmartEye-D1A-24A-P | T31X        | JXK04  | FM25Q128A    | Có  | Không           | Không | Có   |
| Uniview    | IPC-D122-PF28      | SSC335      | SC2335 | XM25QH64C    | Có  | Không           | Không | Không |


| Bộ xử lý | Cảm biến           | Nhà cung cấp | SKU          | Nhận dạng bảng              |
|-------------|------------------|------------|--------------|---------------------------------|
| Hi3516Cv100 | IMX222_spi_dc    | XM         |              | [BLK18C-0222-38X38_S-V1.03][1]  |
| Hi3516Cv100 | OV2710_i2c_dc    | Jovision   |              | IPG5020A-H-V1.0                 |
|             |                  |            |              |                                 |
| Hi3516Cv200 | IMX323_i2c_dc    | XM         |              | BLK16CV-0323-38X38-V1.01        |
| Hi3516Cv200 | IMX323_i2c_dc    | JVT        | S323H16VF    | IPS323-H16V-38X38-V2            |
| Hi3516Cv200 | IMX323_i2c_mipi  | XM         |              |                                 |
|             |                  |            |              |                                 |
| Hi3516Cv300 | AR0237_i2c_dc    | XM         |              | BLK16CV3-0237P-38X38-S-V1.01    |
| Hi3516Cv300 | IMX307_i2c_lvds  | Raysharp   |              | RS-CM-188D 2018-03-16 E150111   |
| Hi3516Cv300 | IMX323_i2c_dc    | Longse/HS  |              | HI3516CV300-IMX323-POE-TF V1.1  |
| Hi3516Cv300 | IMX323_i2c_dc    | Sunywo     | ZB6323       | IPG5020A-T-N6-V0.1              |
| Hi3516Cv300 | IMX323_i2c_dc    | XM         |              | IVG-HP201Y-AE                   |
| Hi3516Cv300 | IMX291_i2c_lvds  | XM         |              | IVG-HP203Y-AE                   |
| Hi3516Cv300 | IMX323_spi_dc    | JVT        | S323H16XF    | IPS323-H16X-38X38-V2/V3         |
| Hi3516Cv300 | JXF22_i2c_dc     | XM         |              | BLK16CV3-0022-38X38-S-V1.01     |
|             |                  |            |              |                                 |
| Hi3516Ev100 | IMX323_i2c_dc    | XM         |              | BLK16E-0323-38X38-B-V1.01       |
| Hi3516Ev100 | SC2235P_i2c_dc   | XM         | 80HE20PS-S   | BLK16E-0235-38X38-S-V2.03       |
|             |                  |            |              |                                 |
| Hi3516Ev200 | IMX307_i2c_mipi  | XM         |              | IVG-85HF20PY-S                  |
| Hi3516Ev200 | SC4239P_i2c_mipi | XM         |              | IVG-85HF30PS-S                  |
|             |                  |            |              |                                 |
| Hi3516Ev300 | IMX335_i2c_mipi  | XM         |              | IVG-85HG50PYA-S                 |
|             |                  |            |              |                                 |
| Hi3518Ev100 | OV9712_i2c_dc    | CamHi/Xin  |              | IPC18E_9712_V2.0/V3.1           |
|             |                  |            |              |                                 |
| Hi3518Ev200 | AR0130_i2c_dc    | XM         |              | BLK18EV-0732-0035-38X38-V1.01   |
| Hi3518Ev200 | JXF22_i2c_dc     | XM         |              | BLK18EV-0002-2035-38X38-V1.01   |
| Hi3518Ev200 | JXF22_i2c_dc     | XM         |              | BLK18EV-0022-0130-38X38-V1.01   |
| Hi3518Ev200 | OV2735_i2c_dc    | Dahua      | DH-IPC-C22P  | E305654 JX02 94V-0              |
| Hi3518Ev200 | OV9732_          | XM         |              | BLK18EV-0732-0035-38X38-V1.01   |
| Hi3518Ev200 | OV9732_i2c_dc    | Longse/HS  | LS-IP100/40  | 3518EV200-OV9732-V1.0           |
| Hi3518Ev200 | OV9732_i2c_dc    | Rostelecom | QVC-IPC-136W | E305654 JX02 94V-0              |
| Hi3518Ev200 | SC2135_i2c_dc    | Amorvue    |              | 18EV200_V202P                   |
| Hi3518Ev200 | SC2135_i2c_dc    | XM         |              | BLK18EV-0035-0042-38X38_S-V1.01 |
| Hi3518Ev200 | SC2235_i2c_dc    | XM         |              | BLK18EV-0235-38X38-B-V1.01      |
|             |                  |            |              |                                 |
|             |                  |            |              |                                 |
| SSC335      | SC3335           | Uniview    |              | Uniview                         |
| SSC338Q     | IMX415           | CamHi/Xin  |              | SSC338Q_38M_1.1                 |


[1]: https://openipc.org/supported-hardware
[2]: https://github.com/OpenIPC/wiki/blob/master/en/guide-supported-devices.md
[3]: https://github.com/OpenIPC/wiki/blob/master/en/device-chacon-ipcam-ri01.md
[4]: https://ipcamtalk.com/threads/smartwares-cip-37210-wifi.64605/
[5]: http://www.hnamg.cn/h-col-139.html
[6]: https://github.com/OpenIPC/device-mjsxj03hl
[7]: https://github.com/OpenIPC/device-mjsxj02hl


[^2]: WiFi có thể được bật với flash 8MB bằng cách sử dụng bản dựng tùy chỉnh hoặc bằng cách nâng cấp lên flash 16MB và sử dụng firmware Ultimate.


