## OpenIPC Wiki
[Mục lục](../README.md)

Thêm driver wifi vào firmware của bạn
---
Vì hầu hết các camera đều có bộ nhớ flash rất nhỏ, nên các image firmware OpenIPC không chứa nhiều driver wifi, vì chúng có thể dễ dàng chiếm hơn 1.5MB cho mỗi driver.
Điều này có nghĩa là trong nhiều trường hợp, bạn sẽ phải thêm driver wifi thích hợp vào image firmware của mình.

### Bước 1: Chuẩn bị môi trường build
Bạn sẽ cần một môi trường Linux. Đầu tiên, hãy tải xuống kho lưu trữ firmware OpenIPC:

```
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
```

Cài đặt các gói cần thiết để build:

```
sudo make deps
```

### Bước 2: Xác định gói driver
Dưới đây là một số gói driver wifi phổ biến nhất:

#### AIC:
```
BR2_PACKAGE_AIC8800_OPENIPC
```

#### Altobeam:
*1. Chọn driver ATBM chung:*
```
BR2_PACKAGE_ATBM60XX
```
*2. Kích hoạt driver cho card cụ thể của bạn:*
```
BR2_PACKAGE_ATBM60XX_MODEL_601X
BR2_PACKAGE_ATBM60XX_MODEL_602X
BR2_PACKAGE_ATBM60XX_MODEL_603X
BR2_PACKAGE_ATBM60XX_MODEL_6041
```

*3. Đặt usb hoặc sdio:*
```
BR2_PACKAGE_ATBM60XX_INTERFACE_USB
BR2_PACKAGE_ATBM60XX_INTERFACE_SDIO
```

*Ví dụ: để build atbm603x_wifi_usb:*
```
BR2_PACKAGE_ATBM60XX=y
BR2_PACKAGE_ATBM60XX_MODEL_603X=y
BR2_PACKAGE_ATBM60XX_INTERFACE_USB=y
```

#### iComm:
*SSV615X/SSV625X, USB ID 0x6000:*

```
BR2_PACKAGE_SSV615X_OPENIPC
```

*SSV635X, USB ID 0x6011:*

```
BR2_PACKAGE_SSV635X_OPENIPC
```

#### MediaTek:
```
BR2_PACKAGE_MT7601U_OPENIPC
```

#### SigmaStar:
```
BR2_PACKAGE_SSW101B
```

#### Realtek:
```
BR2_PACKAGE_RTL8188EUS_OPENIPC
BR2_PACKAGE_RTL8188FU_OPENIPC
BR2_PACKAGE_RTL8189ES_OPENIPC
BR2_PACKAGE_RTL8189FS_OPENIPC
BR2_PACKAGE_RTL8192EU_OPENIPC
BR2_PACKAGE_RTL8733BU_OPENIPC
BR2_PACKAGE_RTL8812AU_OPENIPC
```

Hãy ghi nhớ biến `BR2_PACKAGE` cho driver bạn cần. Việc quan sát các thông báo khởi động từ firmware gốc để xác định thiết bị mạng và loại giao diện có thể hữu ích vì có thể không rõ ràng khi nhìn vào bảng mạch. Việc nhìn thấy `atbm603x_wifi_usb` trong các thông báo khởi động cho thấy camera này có thiết bị wifi `atbm603x` được kết nối nội bộ qua USB.

### Bước 3: Thêm biến BR2_PACKAGE vào cấu hình firmware của bạn
Các tệp cấu hình firmware được sắp xếp theo chipset trong các thư mục `br-ext-chip-*`. Điều hướng đến thư mục cho chipset bạn đang build, sau đó điều hướng đến thư mục `/configs/`.

Ví dụ: bạn có chipset hisilicon:

`cd br-ext-chip-hisilicon/configs/`

Bên trong, bạn sẽ thấy một số tệp `_defconfig`. Mở tệp cho chip và loại firmware mong muốn của bạn trong trình soạn thảo văn bản.
Thêm biến `BR2_PACKAGE` thích hợp vào tệp này, thêm `=y` vào cuối biến. 

Ví dụ: bạn muốn thêm driver RTL8188EUS:

`BR2_PACKAGE_RTL8188EUS_OPENIPC=y`

### Bước 4: Build firmware của bạn
Quay trở lại thư mục gốc của thư mục firmware openipc `openipc-firmware/`.
Chạy `make` và chọn cấu hình bạn đã chỉnh sửa trong bước trước.

Ngoài ra, bạn có thể chạy `make BOARD=<your_config>`, trong đó `<your_config>` là tên của tệp cấu hình bạn vừa chỉnh sửa, trừ `_defconfig`

Ví dụ: bạn muốn build `ultimate` cho `hi3516ev200`:

`make BOARD=hi3516ev200_ultimate`

Khi quá trình build hoàn tất, bạn sẽ tìm thấy đầu ra trong thư mục `output/images/`:

```
./rootfs.hi3516ev200.cpio
./openipc.hi3516ev200-nor-ultimate.tgz
./rootfs.squashfs.hi3516ev200
./rootfs.hi3516ev200.tar
./uImage.hi3516ev200
```

Bây giờ bạn có thể sử dụng `rootfs.squashfs.*` và `uImage.*` với [sysupgrade](./sysupgrade.md) hoặc cơ chế cập nhật ưa thích của bạn.

*Để biết thêm cấu hình wifi, hãy xem [cài đặt không dây](./wireless-settings.md).*

*Để biết thêm thông tin về việc build OpenIPC từ mã nguồn, hãy xem [Mã nguồn](./source-code.md).*
