[Mục lục](../README.md)

Phục hồi Ingenic T31 bằng thẻ SD
---

#### LƯU Ý:
```
Trên một số thiết bị, như nhiều model Wyze và Atom, thẻ SD được cấp nguồn thông qua kết nối GPIO
(Đầu vào/Đầu ra đa năng). Điều này có nghĩa là bạn phải kích hoạt một GPIO cụ thể trong U-Boot hoặc trong hệ thống Linux để cấp nguồn sử dụng thẻ SD. Nếu thiết bị của bạn được thiết lập theo cách này, bạn không thể sử dụng phương pháp này mà không thực hiện thay đổi vật lý đối với phần cứng.
```

### Trình tự khởi động Ingenic T31

![](../images/t31_boot_sequence.png)

Nếu không khởi động được từ u-boot trên bộ nhớ flash, T31 sẽ thử khởi động từ thẻ SD, bất kể chân bootsel được đặt là gì. Vì vậy, nếu u-boot trên chip flash bị hỏng, chúng ta có thể ghi u-boot vào thẻ SD và khởi động từ đó. Tệp u-boot phải được biên dịch đặc biệt để khởi động thẻ SD, bạn không thể sử dụng tệp dành cho khởi động flash thông thường.

### Biên dịch u-boot để khởi động thẻ SD

```
mkdir /opt/openipc
cd /opt/openipc
git clone https://github.com/Dafang-Hacks/mips-gcc472-glibc216-64bit.git
git clone https://github.com/OpenIPC/u-boot-ingenic.git
export PATH="$PATH:/opt/openipc/mips-gcc472-glibc216-64bit/bin"
cd u-boot-ingenic
make distclean
```
Bây giờ hãy chọn lệnh `make` cuối cùng theo loại chip T31 của bạn

SoC  | Lệnh
---- | ---------------------------
T31N | `make isvp_t31_msc0` 
T31L | `make isvp_t31_msc0_lite`
T31X | `make isvp_t31_msc0_ddr128M`
T31A | `make isvp_t31a_msc0_ddr128M`

Bây giờ bạn sẽ nhận được tệp u-boot đã biên dịch `u-boot-with-spl.bin`

### Ghi u-boot vào thẻ SD

Lắp thẻ SD vào PC của bạn, chạy `fdisk -l` để kiểm tra, bạn sẽ thấy thiết bị giống như trong trường hợp của tôi là `Disk /dev/sdb: 29.72 GiB, 31914983424 bytes, 62333952 sectors`.

**THẬN TRỌNG!** kiểm tra kỹ tên thiết bị `/dev` có thực sự là thẻ SD của bạn hay không, nếu không bạn có thể mất dữ liệu trên các ổ đĩa khác

```
dd if=./u-boot-with-spl.bin of=/dev/sdb bs=512 seek=34
```
Điều này sẽ ghi tệp u-boot vào thẻ SD ở vị trí offset 17KB từ 0x0

### Khởi động từ thẻ SD

Nếu u-boot gốc trên chip flash bị hỏng hoặc trống, nó sẽ tự động chọn khởi động từ thẻ SD, nhưng nếu bạn chỉ muốn tải u-boot của riêng mình khi có u-boot đang hoạt động trên chip flash và chân `bootsel` của bảng mạch PCB camera được đặt thành 1, nó sẽ vẫn khởi động từ u-boot trên chip flash. Để buộc khởi động từ thẻ SD, bạn có thể ngắn mạch chân 5 và 6 của chip flash SOIC8 khi cấp nguồn cho camera để chặn việc đọc bộ nhớ flash, chi tiết [tại đây](https://github.com/gitgayhub/wiki/blob/master/en/help-uboot.md#shorting-pins-on-flash-chip).

#### Vấn đề tự động đặt lại của u-boot OpenIPC

U-boot của OpenIPC sẽ tự động đặt lại nếu không tải được kernel từ địa chỉ mặc định, nếu bạn đang cố gắng tải u-boot từ thẻ SD khi có một u-boot hợp lệ trên chip flash, điều này sẽ dẫn đến việc camera khởi động lại u-boot ban đầu. Để tắt chức năng tự động đặt lại, hãy chỉnh sửa `include/configs/isvp_common.h`, xóa `; reset` khỏi phần cuối của dòng `bootcmd`

### u-boot cho các SoC Ingenic khác T10 T20 T21 & T30

u-boot có thể được xây dựng để khởi động thẻ SD cho các SoC này, nhưng chưa được xác minh trên thiết bị thực

#### T10 & T20

SoC | Lệnh
--- | --------------------
T10 | `make isvp_t10_msc0`
T20 | `make isvp_t20_msc0`

#### T21 & T30

Chỉnh sửa `/opt/openipc/u-boot-ingenic/boards.cfg` thêm các dòng sau

```
isvp_t21_msc0                mips        xburst      isvp_t21            ingenic        t21         isvp_t21:SPL_MMC_SUPPORT,ENV_IS_IN_MMC,JZ_MMC_MSC0,SFC_COMMOND
isvp_t30_msc0                mips        xburst      isvp_t30            ingenic        t30        isvp_t30:SPL_MMC_SUPPORT,ENV_IS_IN_MMC,GPT_CREATOR,JZ_MMC_MSC0,SFC_COMMOND
isvp_t30_msc0_lite           mips        xburst      isvp_t30            ingenic        t30        isvp_t30:SPL_MMC_SUPPORT,ENV_IS_IN_MMC,GPT_CREATOR,JZ_MMC_MSC0,SFC_COMMOND,LITE_VERSION
isvp_t30_msc0_ddr128M        mips        xburst      isvp_t30            ingenic        t30        isvp_t30:SPL_MMC_SUPPORT,ENV_IS_IN_MMC,GPT_CREATOR,JZ_MMC_MSC0,SFC_COMMOND,DDR2_128M
isvp_t30a_msc0_ddr128M       mips        xburst      isvp_t30            ingenic        t30        isvp_t30:SPL_MMC_SUPPORT,ENV_IS_IN_MMC,GPT_CREATOR,JZ_MMC_MSC0,SFC_COMMOND,DDR2_128M,T30A
```

Chọn lệnh `make` theo loại chip của bạn

SoC  | Lệnh
-----| -----------------------------
T21  | `make isvp_t21_msc0`
T30N | `make isvp_t30_msc0`
T30L | `make isvp_t30_msc0_lite`
T30X | `make isvp_t30_msc0_ddr128M`
T30A | `make isvp_t30a_msc0_ddr128M`

### Cài đặt OpenIPC từ thẻ SD trong u-boot

Sử dụng T31ZX với flash NOR 16MB làm ví dụ, tải xuống [ảnh full size 16MB](https://openipc.org/cameras/vendors/ingenic/socs/t31x/download_full_image?flash_size=16&flash_type=nor&fw_release=ultimate)

#### Phương pháp 1

Được sử dụng nếu có lệnh `mmc` nhưng không có lệnh `fatload` trong u-boot, chúng ta có thể ghi firmware vào thẻ SD mà không cần bất kỳ hệ thống tệp nào

**THẬN TRỌNG!** kiểm tra kỹ tên thiết bị `/dev` có thực sự là thẻ SD của bạn hay không, nếu không bạn có thể mất dữ liệu trên các ổ đĩa khác

```bash
dd if=./openipc-t31x-ultimate-16mb.bin of=/dev/[thiết-bị-thẻ-sd] seek=20480
```

Điều này sẽ ghi hình ảnh OpenIPC vào thẻ SD ở offset 10MB, khi kích thước khối thẻ là 512 byte

Trong u-boot, chạy

```
mw.b 0x80600000 0xff 0x1000000
mmc read 0x80600000 0x5000 0x8000
sf probe 0
sf erase 0x0 0x1000000
sf write 0x80600000 0x0 0x1000000
```

#### Phương pháp 2

Được sử dụng nếu có lệnh `fatload` trong u-boot để tải trực tiếp tệp từ hệ thống tệp FAT

Gắn kết hệ thống tệp FAT của thẻ SD vào PC của bạn, sao chép hình ảnh firmware OpenIPC vào đó. Trong u-boot, chạy `fatls mmc 0` để liệt kê các tệp trong thẻ SD, sau đó

```
mw.b 0x80600000 0xff 0x1000000
fatload mmc 0 0x80600000 openipc-t31zx-ultimate-16mb.bin
sf probe 0
sf erase 0x0 0x1000000
sf write 0x80600000 0x0 0x1000000
```


