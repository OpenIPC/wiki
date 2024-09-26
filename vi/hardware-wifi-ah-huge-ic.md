# Wiki OpenIPC
[Mục lục](../README.md)

Thêm trình điều khiển WiFi HaLow Huge-IC AH cho Ingenic T31
----------------------------------------------------
Người dùng cơ bản như tôi có thể tham khảo tài liệu này, người dùng nâng cao có thể bỏ qua.

Tài liệu này mô tả cách thêm trình điều khiển AH [WiFi HaLow](https://iot4beginners.com/wi-fi-halow/) của Huge-IC vào firmware OpenIPC.

### Lấy mã nguồn trình điều khiển và chỉnh sửa Makefile

Lấy tệp nguồn của trình điều khiển để bạn có thể biên dịch chúng và tải lên hệ thống camera. Nhờ đó, khi phần cứng được kết nối, camera (máy chủ) có thể nhận dạng phần cứng và kết nối với nó. Giống như khi bạn kết nối USB dongle với máy tính, nó sẽ tải trình điều khiển. Vi điều khiển của bạn không tự động tải trình điều khiển như PC, vì vậy bạn cần tự thực hiện.

Trước tiên, hãy xác định vị trí Makefile. Tệp này bao gồm các hướng dẫn biên dịch và nếu không thực hiện đúng, bo mạch camera của bạn sẽ không có wifi. Trong Makefile, hãy chỉnh sửa các giá trị cho ARCH, COMPILER và LINUX_KERNEL_PATH.

Ingenic sử dụng kiến trúc MIPS nên hãy sử dụng nó cho ARCH ‘ARCH := mips’

Đối với COMPILER và Kernel Path, nó sẽ là một dạng biên dịch chéo - phụ thuộc vào những gì bạn có trong OpenIPC. Để tìm hiểu thêm, hãy đọc bài viết này: https://blukat.me/2017/12/cross-compile-arm-kernel-module/

Bây giờ chúng ta có thể chuyển sang tải xuống và giải nén firmware OpenIPC, tệp đã giải nén sẽ cung cấp cho chúng ta các đường dẫn cho Trình biên dịch và Kernel.

### Tải xuống Firmware OpenIPC

```
cd
git clone git@github.com:OpenIPC/firmware.git
cd firmware
./building.sh t31_ultimate
```
(t31_ultimate vì bản ultimate đi kèm với hỗ trợ cho các thiết bị không dây. Bản lite bị loại bỏ những thiết bị đó để tiết kiệm dung lượng.)

Bây giờ bạn có thể thay đổi đường dẫn Trình biên dịch và Kernel trong Makefile nguồn trình điều khiển:

```
#Biên dịch trình điều khiển cho Ingenic T31
ARCH := mips
COMPILER := ~/firmware/output/host/bin/mipsel-linux-
LINUX_KERNEL_PATH := ~/firmware/output/build/linux-3.10.14
```

### Bây giờ hãy chạy ‘make fmac’

(ở đây FMAC hoặc bất kỳ tên liên quan nào khác cho trình điều khiển của bạn)

Nếu mọi việc diễn ra theo đúng kế hoạch, bạn sẽ có một tệp script và một hoặc nhiều tệp có phần mở rộng .ko. Các tệp .ko đó là trình điều khiển của bạn và tệp script bao gồm các hướng dẫn cho vi điều khiển máy chủ của bạn để tìm và kích hoạt trình điều khiển.

### Đã đến lúc tải trình điều khiển lên hệ thống camera

Nếu các tệp nhỏ và Ingenic có thêm dung lượng khả dụng, bạn có thể tải bổ sung trình điều khiển.

Tải các tệp .ko (trình điều khiển) và script `fmac` (tệp script của bạn có thể có tên khác) vào thư mục bạn chọn. Vui lòng đảm bảo chỉnh sửa các đường dẫn tương ứng trong tệp script fmac, nếu cần.

### Kiểm tra

Hãy kiểm tra với phần cứng WiFi của bạn để đảm bảo rằng nó hoạt động.

### Tiếp theo, tạo một gói

Sau khi bạn đã học cách tạo gói, vui lòng chia sẻ nó với các thành viên nhóm quản trị OpenIPC. Họ có thể đồng ý đưa gói trình điều khiển của bạn vào kho. Sau khi được đưa vào dưới dạng một gói, lần sau bạn có thể sử dụng nó bằng cách bỏ ghi chú và kích hoạt gói trong tệp cấu hình OpenIPC.

