# OpenIPC Wiki
[Mục lục](../README.md)

OpenIPC AIO "UltraSight"
---
<a href="https://store.openipc.org"><img src="../images/fpv-openipc-aio.webp"></a>

## Có gì trong hộp
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-content-1.webp"><img src="../images/fpv-openipc-aio-content-1.webp" width="60%"></a>
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-content-2.webp"><img src="../images/fpv-openipc-aio-content-2.webp" width="60%"></a>

## Tổng quan về các bước đầu tiên
- Kết nối ăng-ten không dây và lắp tản nhiệt (xem phần Tản nhiệt).
- Kết nối PCB Gỡ lỗi và kết nối cáp mạng hoặc cáp USB-C.
- Đảm bảo làm mát thích hợp, luồng không khí sẽ cần thiết để bảo vệ bảng khỏi quá nhiệt.
- Cấp nguồn cho bảng (xem phần Nguồn) và kiểm tra Máy chủ DHCP của bạn (thường là bộ định tuyến của bạn) để tìm thiết bị mới và địa chỉ IP của nó, bảng sẽ cố gắng nhận IP được gán thông qua DHCP.
- Bạn có thể đăng nhập vào WebUI của OpenIPC bằng tên người dùng **admin** và mật khẩu **12345** để kiểm tra kết nối.

## Tản nhiệt
- Gói đi kèm với một tản nhiệt và miếng đệm nhiệt. Miếng đệm nhiệt được bao phủ bởi băng keo hai mặt 3M ở cả hai mặt. Hai vít được bao gồm trong bộ có thể được sử dụng để gắn tản nhiệt.
- Mục đích của tản nhiệt là để tản nhiệt từ các linh kiện Không dây trên PCB. Do đó, miếng đệm nhiệt và tản nhiệt cần được đặt ở mặt có chipset Không dây (ví dụ: đầu nối ăng-ten, chip Realtek và bộ khuếch đại công suất).

## Tổng quan về PCB
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-manual.webp"><img src="../images/fpv-openipc-aio-manual.webp" width="80%"></a>

### Bật nguồn cho bảng
- Trước khi bật nguồn cho bảng AIO, miếng đệm nguồn phải được hàn hoặc kết nối với nguồn điện **3A ở 5V DC** hoặc BEC đáng tin cậy. Con số ampe này sẽ cao hơn nếu chọn mức công suất RF cao hơn.
- Đảm bảo rằng việc làm mát là đầy đủ trong khi bảng được bật nguồn. quạt là điều cần thiết, tản nhiệt cũng được khuyên dùng khi có thể. Không cung cấp đủ khả năng làm mát cho bo mạch rất có thể sẽ gây hư hỏng cho bo mạch.
- Khi không có đủ điện dung tải trên BEC, nên thêm một tụ điện phân cực 470uF (có trong bộ) giữa BEC và bảng AIO để bảo vệ bảng AIO khỏi hư hỏng do đột biến và cung cấp tách rời. Cài đặt tụ điện càng gần AIO-PCB càng tốt.
- Để bảo vệ bổ sung, có thể hàn Diode Zener có dung lượng 1W và Điện áp tối đa 5,1V (ZMY5V1, BZX55C5V1, BZT52C5V1, 1N5338B) vào đầu ra của BEC trước tụ điện, sơ đồ sau cho thấy cách hàn các linh kiện:
![zener_diode_diagram](https://github.com/OneManChop/OpenIPCwiki/assets/33513057/f0ad9f0b-6146-45af-81b2-4bc530880370)

### Gỡ lỗi/Ethernet
- Bộ chuyển đổi Ethernet/Gỡ lỗi được bao gồm. Cáp dẹt linh hoạt được sử dụng để kết nối nó với AIO-PCB. Các chân của đầu nối nằm ở mặt PCB của đầu nối, hãy chú ý kết nối cáp dẹt linh hoạt với các kết nối lộ ra về phía PCB. Các dải "tay cầm" trên cáp dẹt linh hoạt sẽ hướng về phía tản nhiệt trên AIO-PCB và cách xa đầu nối RJ45 trên PCB Gỡ lỗi.

### Máy ảnh
- Đầu nối MIPI có thể được đẩy vào ổ cắm tương ứng trên AIO-PCB theo chiều dọc. Không cần lực lớn và không cần di chuyển cần gạt hay tháo kẹp. Để tháo, đầu nối có hai chốt nhỏ ở hai bên để hỗ trợ việc cầm nắm.

## Phần mềm

### Nâng cấp hệ thống tự động
- Kết nối thiết bị của bạn với mạng bằng bảng ethernet gỡ lỗi.
- Đăng nhập vào hệ thống (root:12345).
- Chạy các lệnh sau:
```
fw_setenv upgrade https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz
sysupgrade -k -r -n
```

### Cập nhật hệ thống thủ công
- Chuẩn bị thẻ nhớ SD được định dạng ở FAT32 với kích thước 1GB.
- Tải xuống và giải nén [gói này](https://github.com/openipc/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz).
- Sao chép uImage.ssc338q và rootfs.squashfs.ssc338q vào thẻ nhớ SD.
- Ngắt uboot bằng cách giữ phím enter.
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
- Điều khiển đèn LED:
```
gpio clear 108
gpio set 108
```

### Khả năng tương thích cáp của bên thứ ba
- Cáp DJI Pocket2 - TƯƠNG THÍCH với OpenIPC AIO
- Cáp mipi DJI O3 - KHÔNG phù hợp với OpenIPC AIO
- Cáp mipi RunCam - KHÔNG phù hợp với OpenIPC AIO

