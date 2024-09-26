# OpenIPC Wiki
[Mục lục](../README.md)

Tích hợp Wyze
----------------
Đây là nơi chúng tôi sẽ ghi lại hướng dẫn flash các thiết bị mới và báo cáo về các thử nghiệm của chúng tôi.  Các bảng bên dưới cũng bao gồm một số "bản sao" do Hualai, nhà cung cấp ODM cho Wyze sản xuất để tham khảo.

### Các phiên bản camera đã biết:

| MODEL     | IC 25466- | FCC ID         | PHIÊN BẢN PCB                     | SoC      | WIFI                  | TIỀN TỐ MAC | ĐƯỢC HỖ TRỢ | GHI CHÚ                                                     |
|-----------|-----------|----------------|-----------------------------------|----------|-----------------------|------------|-----------|-----------------------------------------------------------|
| WYZEC2    |           | 2ANJHWYZEC2    | 2019-06-38                        | T20X BGA | SDIO: Realtek 8189FTV | 2C:AA:8E   | CÓ        | https://gist.github.com/csev1755/e60abe15d8708e0d2b0a592e808b2022  |
| WYZECP1   |           | 2ANJHHWYZECP1  | DF3-IFPM01 V1.4                   | T20X BGA | SDIO: Realtek 8189ES  | 2C:AA:8E   | CÓ        |                                                           |
| WYZEC3    | WYZEC3    | 2AUIUWYZEC3    | WYZEV3_T31GC2053 V1.4_20201010    | T31ZX    | SDIO: Realtek 8189FTV | 7C:78:B2   | CÓ        | https://t.me/openipc/49957 https://youtu.be/t7Nzo-KXTH0   | 
| WYZEC3    | WYZEC3A   | 2AUIUWYZEC3A   | WYZEV3_T31GC2053 V1.2_20200715    | T31X     | SDIO: Realtek 8189FTV | 7C:78:B2   | CÓ        | https://youtu.be/jm4wze_HY78                              |
| WYZEC3    | WYZEC3A   | 2AUIUWYZEC3A   | WYZEV3_T31GC2053 V2.02_20210523   | T31ZX    | SDIO: AltoBeam 6031   | D0:3F:27   | CÓ        | https://t.me/openipc/49049 https://t.me/openipc/49050     |
| WYZEC3    | WYZEC3A   | 2AUIUWYZEC3A   | WYZEV3_T31GC2053 V2.03_20211206   | T31X     | SDIO: AltoBeam 6031   | D0:3F:27   | CÓ        | https://t.me/openipc/45444 https://t.me/openipc/48942     |
| WYZEC3    | WYZEC3B   | 2AUIUWYZEC3B   | WYZEV3_T31GC2053 V2.02_20210523   | T31ZX    | SDIO: Realtek 8189FTV | D0:3F:27   | CÓ        | https://t.me/openipc/38728 https://t.me/openipc/38753     |
| WYZEC3    | WYZEC3B   | 2AUIUWYZEC3B   | WYZEV3_T31GC2053 V2.03_20211206   | T31X     | SDIO: Realtek 8189FTV | D0:3F:27   | CÓ        | https://t.me/openipc/76036                                |
| WYZEC3    | WYZEC3F   | 2AUIUWYZEC3F   | WYZEV3_T31AGC2053 V3.2_20210714   | T31A BGA | SDIO: AltoBeam 6031   | D0:3F:27   | CÓ        | https://t.me/openipc/43299 https://t.me/openipc/38755 https://t.me/openipc/38757     |
| WYZEC3    | WYZEC3F   | 2AUIUWYZEC3F   | WYZEV3_T31AGC2053 V3.2_20210714   | T31A BGA | SDIO: AltoBeam 6031   | D0:3F:27   | CÓ        | https://youtu.be/VkqX9yg0odU                              |
| WVDBV1    | WVDB1A    | 2AUIUWVDB1A    | WYZEDB3_MB_T31_2.2                | T31X     | SDIO: Realtek 8189FTV | 7C:78:B2   | CÓ        |                                                           |
| WYZECP2   | WYZECP2A  | 2AUIUWYZECP2   | DF3-MCU-S01-V2.2                  | T31X     | SDIO: AltoBeam 6031   | 7C:78:B2   | CÓ        |                                                           |
| WYZECPAN3 | WYZECPAN3 | 2AUIUWYZECPAN3 | WYZE PAN V3 MB V 1.3              | T31X     | SDIO: AltoBeam 6031   | D0:3F:27   | KHÔNG     | KHÔNG ĐƯỢC HỖ TRỢ - Khởi động An toàn ĐÃ ĐƯỢC BẬT           |
| WYZEC3P   | WYZEC3P   | 2AUIUWYZEC3P   | WYZEV3PRO_T40GC4653_v2.2_20220228 | T40XP    | SDIO: Realtek 8192FS  | D0:3F:27   | CHƯA THỬ NGHIỆM | CHƯA THỬ NGHIỆM                                                  |
| WVOD2     | WVOD2     | 2AUIUWVOD2     | HL_WCO2 MAIN01 V1.0               | T31ZX    | SDIO: BCM43438        | D0:3F:27   | CHƯA THỬ NGHIỆM | CHƯA THỬ NGHIỆM - Nền tảng pin Ingenic Zeratul               |
| ATOMCAM2  |           |                | V3C_T31GC2063 V1.1_202001110      | T31ZX    | SDIO: AltoBeam 6031   | 7C:DD:E9   | CÓ        | AtomCam 2 Nhật Bản http://www.atomtech.co.jp                 |
| PERSONALCAM  |           |                |                                | T31??    | SDIO: AltoBeam 6031   | ??:??:??   | CÓ        | Camera Personal Wifi https://tienda.personal.com.ar       |


GPIO:

| MODEL     | IRCUT1 | IRCUT2 | Đèn LED IR1 | Đèn LED IR2 | WIFI   | Đèn LED1 | Đèn LED2 | LOA     | TF_EN  | TF_CD  | SD_ABLE | SD_PWR | NÚT 1  | NÚT 2  | SUB1G  | USB    |
|-----------|--------|--------|---------|---------|--------|--------|--------|---------|--------|--------|---------|--------|--------|---------|--------|--------|
| WYZEC2    | GPIO25 | GPIO26 | GPIO49  |         | GPIO62 | GPIO38 | GPIO39 | GPIO63  | GPIO43 | GPIOXX | GPIO48  |        | GPIO46 |         |        | GPIO47 |
| WYZECP1   | GPIO26 | GPIO25 | GPIO49  |         | GPIO62 | GPIO38 | GPIO39 | GPIO63  | GPIO43 | GPIOXX | GPIO48  |        | GPIO46 |         |        | GPIO47 |
| WYZEC3    | GPIO53 | GPIO52 | GPIO47  | GPIO49  | GPIO57 | GPIO38 | GPIO39 | GPIO63  | GPIO50 | GPIO62 | GPIO48  |        | GPIO51 |         |        |        |
| WYZEDBV1  | GPIO53 | GPIO52 | PWM2    |         | GPIO57 | GPIO38 | GPIO39 | GPIO58  |        |        | GPIO62  |        | GPIO06 | GPIO07  | GPIO61 |        |
| WYZECP2   | GPIO49 | GPIO50 | GPIO60  |         | GPIO58 | GPIO38 | GPIO39 | GPIO07  | GPIO47 | GPIO48 | GPIO54  |        | GPIO06 |         |        |        |
| WYZECPAN3 |        |        |         |         |        |        |        |         |        |        |         |        |        |         |        |        |
| WYZEC3PRO | GPIO118| GPIO119| GPIO66  | GPIO67  | GPIO57 | GPIO105| GPIO106| GPIO63  | GPIO58 | GPIO70 | GPIO71  | GPIO121| GPIO107|         |        |        |
| WVOD2     |        |        |         |         |        |        |        |         |        |        |         |        |        |         |        |        |
| ATOMCAM2  | GPIO53 | GPIO52 | GPIO26  |         | GPIO57 | GPIO38 | GPIO39 | GPIO63  | GPIO50 | GPIO59 | GPIO48  |        | GPIO51 |         |        | GPIO47 |
| PERSONALCAM  |        |        | GPIO14  |         | GPIO57 | GPIO47 | GPIO48 | GPIO63  | GPIO50 | GPIO59 | GPIO39  |        |        |         |        |        |


ĐỘNG CƠ: 
| MODEL     | HST1   | HST2   | HST3   | HST4   | VST1   | VST2   | VST3   | VST4   | HMAX | VMAX  | TỐC ĐỘ TỐI ĐA |
|-----------|--------|--------|--------|--------|--------|--------|--------|--------|------|-------|-----------|
| WYZECP1   | GPIO54 | GPIO53 | GPIO52 | GPIO51 | GPIO75 | GPIO76 | GPIO79 | GPIO80 | 2590 | 720   | 900       |
| WYZECP2   | GPIO52 | GPIO53 | GPIO57 | GPIO51 | GPIO59 | GPIO61 | GPIO62 | GPIO63 | 2540 | 720   | 900       |
| WYZECPAN3 |        |        |        |        |        |        |        |        |      |       |           |
| PERSONALCAM | GPIO49 | GPIO57 | GPIO54 | GPIO51 | GPIO60 | GPIO61 | GPIO62 | GPIO63 | 2130 | 1600  | 900       |

---

## Camera Wyze Cam Pan v3 có khóa phần cứng trong secure boot và không thể nâng cấp lên OpenIPC!

---

### Cài đặt OpenIPC

> [!CẢNH BÁO]
> Liên kết bên dưới không còn hoạt động. Vui lòng thay thế liên kết bằng liên kết hoạt động hoặc được cập nhật.

[Sử dụng các tập lệnh này](https://github.com/themactep/device-wyze-v3/blob/master/installation.md) để chuyển đổi Wyze Cam V3 của bạn sang OpenIPC.

### Các vấn đề hiện tại

* ~~Độ phơi sáng không hoạt động tốt https://github.com/OpenIPC/majestic/issues/102~~
* ~~Thẻ SD không hoạt động trong U-Boot (nguồn có sẵn)~~ đã sửa
* ~~Vấn đề với việc tải u-boot từ thẻ nhớ microSD. Nó không đến được dấu nhắc lệnh. Không chỉ trên wyze v3 (https://t.me/openipc_modding/179369), mà còn trên một bo mạch T31L khác (https://t.me/openipc/47739). Rất có thể nó sẽ KHÔNG THỂ, bởi vì trong camera có MOSFET quản lý nguồn microSD, phải được bật TRƯỚC KHI khởi động từ thẻ (thí nghiệm với u-boot chưa được tải đầy đủ là có thể do nguồn điện trực tiếp đến thẻ microSD, bỏ qua bóng bán dẫn). Vui lòng xác nhận phiên bản của tôi nếu không thể làm cách khác.~~ không thể thực hiện được nếu không sửa đổi (nguồn điện trực tiếp 3.3V cho đầu đọc thẻ microSD)




