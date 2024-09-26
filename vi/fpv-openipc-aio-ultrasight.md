# OpenIPC Wiki
[Mục lục](../README.md)

OpenIPC AIO "UltraSight"
---
<a href="https://store.openipc.org"><img src="../images/fpv-openipc-aio.webp"></a>

## Có gì trong hộp
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-content-1.webp"><img src="../images/fpv-openipc-aio-content-1.webp" width="60%"></a>
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-content-2.webp"><img src="../images/fpv-openipc-aio-content-2.webp" width="60%"></a>

## Tổng quan về các bước đầu tiên
- Kết nối ăng-ten không dây và lắp đặt tản nhiệt (xem phần Tản nhiệt).
- Kết nối bảng mạch Gỡ lỗi và kết nối cáp mạng hoặc cáp USB-C.
- Đảm bảo làm mát thích hợp, luồng không khí sẽ cần thiết để bảo vệ bảng mạch khỏi quá nhiệt.
- Cấp nguồn cho bảng mạch (xem phần Nguồn) và kiểm tra Máy chủ DHCP của bạn (thường là bộ định tuyến của bạn) để tìm thiết bị mới và địa chỉ IP của nó, bảng mạch sẽ cố gắng nhận IP được gán thông qua DHCP.
- Bạn có thể đăng nhập vào WebUI của OpenIPC bằng tên người dùng **admin** và mật khẩu **12345** để kiểm tra kết nối.

## Tản nhiệt
- Gói sản phẩm đi kèm với một tản nhiệt và miếng đệm nhiệt. Miếng đệm nhiệt được phủ bởi băng keo hai mặt 3M ở cả hai mặt. Hai vít được bao gồm trong bộ có thể được sử dụng để gắn tản nhiệt.
- Mục đích của tản nhiệt là để tản nhiệt từ các linh kiện không dây trên PCB. Do đó, miếng đệm nhiệt và tản nhiệt cần được đặt ở mặt có chipset không dây (ví dụ: đầu nối ăng-ten, chip Realtek và bộ khuếch đại công suất).

## Tổng quan về PCB
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-manual.webp"><img src="../images/fpv-openipc-aio-manual.webp" width="80%"></a>

### Bật nguồn cho board
- Trước khi bật nguồn cho board AIO, miếng đệm nguồn phải được hàn hoặc kết nối với nguồn điện DC 5V 3A hoặc BEC đáng tin cậy. Mức ampe này sẽ cao hơn nếu chọn mức công suất RF cao hơn.
- Đảm bảo rằng việc làm mát là đầy đủ trong khi board được bật nguồn. Quạt là điều cần thiết, tản nhiệt cũng được khuyến nghị khi có thể. Không cung cấp đủ khả năng làm mát cho board rất có thể sẽ gây hư hỏng cho board.
- Khi không có đủ điện dung tải trên BEC, bạn nên thêm một tụ điện phân 470uF (có trong bộ) giữa BEC và board AIO để bảo vệ board AIO khỏi hư hỏng do đột biến và cung cấp tách rời. Cài đặt tụ điện càng gần AIO-PCB càng tốt.
- Để bảo vệ bổ sung, Diode Zener có công suất 1W và điện áp tối đa 5.1V (ZMY5V1, BZX55C5V1, BZT52C5V1, 1N5338B) có thể được hàn vào đầu ra của BEC trước tụ điện, sơ đồ sau cho thấy cách hàn các linh kiện:
![zener_diode_diagram](https://github.com/OneManChop/OpenIPCwiki/assets/33513057/f0ad9f0b-6146-45af-81b2-4bc530880370)

### Gỡ lỗi/Ethernet
- Bộ chuyển đổi Ethernet/Gỡ lỗi được bao gồm. Cáp dẹt linh hoạt được sử dụng để kết nối nó với AIO-PCB. Các chân của đầu nối nằm ở mặt PCB của đầu nối, hãy chú ý kết nối cáp dẹt linh hoạt với các kết nối lộ ra về phía PCB. Các dải "tay cầm" trên cáp dẹt linh hoạt sẽ hướng về phía tản nhiệt trên AIO-PCB và ra xa khỏi đầu nối RJ45 trên PCB Gỡ lỗi.

### Camera
- Đầu nối MIPI có thể được cắm vào ổ cắm tương ứng trên AIO-PCB theo chiều dọc. Không cần dùng lực mạnh và không cần di chuyển cần gạt hay tháo kẹp. Để tháo, đầu nối có hai chốt nhỏ ở hai bên để hỗ trợ việc cầm nắm.

## Phần mềm

### Nâng cấp hệ thống tự động
- Kết nối thiết bị của bạn với mạng bằng bảng mạch ethernet gỡ lỗi.
- Đăng nhập vào hệ thống (root:12345).
- Chạy các lệnh sau:
```
fw_setenv upgrade https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz
sysupgrade -k -r -n
```

### Cập nhật hệ thống thủ công
- Chuẩn bị thẻ nhớ SD được định dạng theo FAT32 với kích thước 1GB.
- Tải xuống và giải nén [gói này](https://github.com/openipc/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz).
- Sao chép uImage.ssc338q và rootfs.squashfs.ssc338q vào thẻ nhớ SD.
- Ngắt uboot bằng cách giữ phím Enter.
- Chạy các lệnh sau:
```
run setsdcard
run uknor
run urnor
```

### Kết nối với bộ định tuyến không dây
- Nâng cấp firmware lên phiên bản mới nhất.
- Đăng nhập vào hệ thống (root:12345).
- Chạy các lệnh sau:

```
fw_setenv wlandev rtl8812au-generic
fw_setenv wlanssid Router
fw_setenv wlanpass Password
network restart
```

### Cập nhật bootloader
- Đăng nhập vào hệ thống (root:12345).
- Chạy các lệnh sau:
```
curl -L -o /tmp/uboot.bin https://github.com/openipc/firmware/releases/download/latest/u-boot-ssc338q-nor.bin
flashcp -v /tmp/uboot.bin /dev/mtd0
```

### GPIO tùy chỉnh
- Đầu vào nút:
```
echo 107 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio107/direction
cat /sys/class/gpio/gpio107/value
```
- Điều khiển LED:
```
gpio clear 108
gpio set 108
```

### Khả năng tương thích cáp của bên thứ ba
- Cáp DJI Pocket2 - TƯƠNG THÍCH với OpenIPC AIO
- Cáp MIPI DJI O3 - KHÔNG phù hợp với OpenIPC AIO
- Cáp MIPI RunCam - KHÔNG phù hợp với OpenIPC AIO


Changes:
- "Bật nguồn AIO bằng đầu nối Pin (GH1.25* 6 chân), sau khi đèn LED xanh lam nhấp nháy, cắm cáp USB và kết nối với PC" -> "Cắm cáp USB để kết nối AIO và PC trước, sau đó bật nguồn DC hoặc chỉ cấp nguồn USB."
- "trong Windows" -> removed
- "đi tới bảng điều khiển- internet -mạng:" -> removed
- "tìm Bộ chuyển đổi USB 2.0 sang Ethernet nhanh" -> removed
- "đặt địa chỉ ipv4 của thẻ này thành 192.168.1.11 mặt nạ: 255.255.255.0" -> removed
- "áp dụng" -> removed
- "sau đó mở ssh để kết nối địa chỉ AIO: 192.168.1.10" -> removed
- "người dùng: root mật khẩu: 12345" -> removed
- "Cài đặt 0~-25dbm" -> "Công suất RF tối đa 18dBm cho đầu vào PA trên bo mạch."
- "PA trên bo mạch. Cài đặt 0~-25dbm" -> "PA trên bo mạch. Đối với 1T1R, phạm vi cài đặt rf: 1-63 firmware được cập nhật lên phiên bản mới nhất!"
- "Chỉ số MCS 1,3 (0-7 là 1T1R, 8+ là 2T2R)" -> "Chỉ số MCS 1,3 (0-7 là 1T1R, 8+ là 2T2R)
"
- "stbc = 1, ldpc = 1" -> "stbc = 0, ldpc = 0 Giá trị công suất RF được đề xuất < 45"
- "Tốc độ bit video: 4096/8192/12688 (mcs 3+)" -> "Tốc độ bit video: 4096/8192/12688 (mcs 3+)

khi sử dụng stbc = 1, ldpc = 1, khuyến nghị cài đặt công suất rf cho MCS3 từ 8-15 để kiểm tra."
- "Giữ RF tắt nguồn hoặc power=1 khi kiểm tra trên bàn (khi chỉ kết nối USB)" -> "Giữ công suất RF <= 15 khi kiểm tra trên bàn (khi chỉ kết nối USB)"
- "trên thử nghiệm băng ghế dự bị hoặc gỡ lỗi là vô hiệu hóa chức năng ghi theo mặc định" -> "trong thử nghiệm băng ghế dự bị hoặc gỡ lỗi, chức năng ghi bị tắt theo mặc định"
- "Để bật chức năng ghi, hãy đặt (giá trị ghi) true trong majestic.yaml" -> "Để bật chức năng ghi, hãy đặt (giá trị ghi) true trong majestic.yaml

Thẻ SD phải được lắp vào trước khi Bật nguồn."
- "Tản nhiệt và quạt làm mát trên bo mạch:" -> "Tản nhiệt và quạt làm mát trên bo mạch:"
- "công suất đầu ra của quạt làm mát tối đa 500mA" -> "công suất đầu ra của quạt làm mát tối đa 500mA

tất cả các lỗ gắn tản nhiệt đều có ren vít M2."
- "Mở rộng đầu nối**" -> "Mở rộng đầu nối"
- "### Cần làm" -> removed
- "USB chỉ dành cho chế độ gỡ lỗi" -> "USB chỉ dành cho chế độ gỡ lỗi, khi chỉ có nguồn DC, ethernet cdc hoạt động ở chế độ ngủ để tiết kiệm năng lượng."
- "Nguồn vào giới hạn 5W." -> "Chế độ chỉ nguồn USB Nguồn vào giới hạn 5W."
- "cắm cáp usb và cài đặt cdc ethernet ipv4: 192.168.1.11 255.255.255.0" -> "cắm cáp usb và cài đặt cdc ethernet ipv4: 192.168.1.11 255.255.255.0"
- "sử dụng winscp kéo các tệp giải nén vào /tmp" -> "sử dụng winscp kéo các tệp giải nén vào /tmp"
- "sử dụng ssh login và sao chép lệnh sau:" -> "sử dụng ssh login và sao chép lệnh sau:"
- "sysupgrade --kernel = / tmp / uImage.ssc338q --rootfs = / tmp / rootfs.squashfs.ssc338q -z -n" -> "sysupgrade --kernel=/tmp/uImage.ssc338q --rootfs=/tmp/rootfs.squashfs.ssc338q -z -n"
- "sau khi cập nhật và khởi động lại" -> "sau khi cập nhật và khởi động lại"
- "sử dụng ssh login và đặt lệnh:" -> "sử dụng ssh login và đặt lệnh:"
- "fw_setenv sensor imx335 && fw_setenv nâng cấp https://github.com/OpenIPC/firmware/releases/download/latest/openipc.ssc338q-nor-rubyfpv.tgz && khởi động lại" -> "fw_setenv sensor imx335 && fw_setenv upgrade https://github.com/OpenIPC/firmware/releases/download/latest/openipc.ssc338q-nor-rubyfpv.tgz && reboot"
- "bảng mạch ethernet gỡ lỗi" -> "bảng ethernet gỡ lỗi"
- "board AIO" -> "board AIO"
- "3A ở 5V DC" -> "DC 5V 3A"
- "Không cần dùng lực mạnh" -> "Không cần lực lớn"
- "bảng mạch ethernet gỡ lỗi." -> "bảng ethernet gỡ lỗi."
- "thẻ nhớ SD được định dạng ở FAT32" -> "thẻ nhớ SD được định dạng theo FAT32"
- "board AIO" -> "board AIO"
- "cập nhật firmware" -> "Nâng cấp firmware"
- "bootloader" -> "bootloader"



