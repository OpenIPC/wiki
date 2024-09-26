# OpenIPC Wiki
[Mục lục](../README.md)

Nâng cấp firmware
------------------

### Nâng cấp từ GitHub
Đối với firmware cũ, chạy `sysupgrade` không có tham số là đủ. Đối với firmware mới hơn, hãy chạy `sysupgrade -k -r` để cập nhật cả kernel và rootfs.

__CHÚ Ý! Nâng cấp firmware có thể dẫn đến việc "biến camera của bạn thành cục gạch". Hãy chắc chắn rằng bạn đã chuẩn bị cả về mặt tinh thần và kỹ năng. Chuẩn bị sẵn thẻ SD cứu hộ và/hoặc bộ điều hợp UART của bạn. Hãy chuẩn bị để hàn lại và lập trình lại chip flash như là phương sách cuối cùng. Không nâng cấp camera đang hoạt động trừ khi bạn thực sự phải làm vậy!__

### Nâng cấp từ máy chủ TFTP

[Thiết lập máy chủ TFTP](installation-tftpd.md).

Truy cập <https://github.com/OpenIPC/firmware/releases/tag/latest> và tải xuống gói firmware mới nhất cho SoC của bạn.
Giải nén nội dung của gói vào thư mục gốc của máy chủ TFTP của bạn.

Trên camera, hãy chạy:

#### Github: Từ Linux

```bash
soc=$(fw_printenv -n soc)
serverip=$(fw_printenv -n serverip)
busybox tftp -r rootfs.squashfs.${soc} -g ${serverip}
busybox tftp -r uImage.${soc} -g ${serverip}
```

#### Github: Ngoài ra, từ U-Boot

đối với ảnh 8MB

```bash
tftp ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}

tftp ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x250000 0x500000; sf write ${baseaddr} 0x250000 ${filesize}
```

đối với ảnh 16MB

```bash
tftp ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}

tftp ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x250000 0xA00000; sf write ${baseaddr} 0x250000 ${filesize}
```

### Nâng cấp từ tệp cục bộ

Truy cập <https://github.com/OpenIPC/firmware/releases/tag/latest> và tải xuống gói firmware mới nhất cho SoC của bạn.
Giải nén gói và tải nội dung của nó lên camera bằng cách sử dụng `scp`:

```bash
tar xvf <firmware.tgz>
scp uImage* rootfs* root@<yourcameraip>:/tmp/
```

Trên camera, hãy chạy:

```bash
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/tmp/uImage.${soc} --rootfs=/tmp/rootfs.squashfs.${soc} -z
```

### Nâng cấp từ thẻ SD

#### Thẻ SD: Từ Linux

Truy cập <https://github.com/OpenIPC/firmware/releases/tag/latest> và tải xuống gói firmware mới nhất cho SoC của bạn.
Lắp thẻ SD vào máy tính để bàn của bạn. Giải nén gói và sao chép nội dung của nó vào thẻ:

```bash
tar xvf <firmware.tgz>
cp uImage* rootfs* /media/<username>/<card-id>/
```

Lắp thẻ SD vào camera của bạn.
Trên camera, hãy chạy:

```bash
soc=$(fw_printenv -n soc)
sysupgrade --kernel=/mnt/mmcblk0p1/uImage.${soc} --rootfs=/mnt/mmcblk0p1/rootfs.squashfs.${soc} --force_ver -z
```

#### Thẻ SD: Ngoài ra, từ U-Boot

đối với ảnh 8MB

```bash
mw.b ${baseaddr} 0xff 0x200000
fatload mmc 0:1 ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}

mw.b ${baseaddr} 0xff 0x500000
fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x250000 0x500000; sf write ${baseaddr} 0x250000 ${filesize}
```

đối với ảnh 16MB

```bash
mw.b ${baseaddr} 0xff 0x300000
fatload mmc 0:1 ${baseaddr} uImage.${soc}
sf probe 0; sf erase 0x50000 0x300000; sf write ${baseaddr} 0x50000 ${filesize}

mw.b ${baseaddr} 0xff 0x500000
fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc}
sf probe 0; sf erase 0x350000 0xa00000; sf write ${baseaddr} 0x350000 ${filesize}
```

### Flash U-Boot qua ymodem

Dọn dẹp 320K RAM và tải tệp bộ tải khởi động vào đó:

```bash
mw.b ${baseaddr} 0xff 0x50000
loady
```

> _(nhấn "Ctrl-a" theo sau là ":", sau đó nhập)_

```bash
exec !! sz --ymodem u-boot.bin
```

Sau khi tệp được tải lên, hãy ghi nó vào ROM:

```bash
sf probe 0
sf erase 0x0 0x50000
sf write ${baseaddr} 0x0 ${filesize}
```

### Khắc phục sự cố

Nếu bạn gặp lỗi này:

```console
losetup: /tmp/rootfs.squashfs.${soc}: Không tìm thấy tệp hoặc thư mục
Rootfs: Không thể lấy tên máy chủ, quá trình thực thi đã bị gián đoạn...
```

thì hãy thử cập nhật kernel trước:
`sysupgrade -k`

Nếu không được, hãy sử dụng tùy chọn `--force`:
`sysupgrade -r --force`

Nếu bạn gặp trục trặc, hãy lấy phiên bản mới nhất của tiện ích:

```bash
curl -k -L -o /usr/sbin/sysupgrade "https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade"
```




