## Wiki OpenIPC
[Mục lục](../README.md)

Thêm trình điều khiển WiFi HaLow Huge-IC AH cho Ingenic T31
----------------------------------------------------
Đối với người dùng cơ bản như tôi, người dùng nâng cao có thể hoàn toàn bỏ qua tài liệu này.

Tài liệu này mô tả cách thêm trình điều khiển AH [WiFi HaLow](https://iot4beginners.com/wi-fi-halow/) của Huge-IC vào firmware OpenIPC.

### Lấy mã nguồn trình điều khiển và chỉnh sửa Makefile

Lấy tệp nguồn của trình điều khiển để bạn có thể biên dịch các trình điều khiển đó và tải lên hệ thống camera của mình. Nhờ đó, khi phần cứng được kết nối, camera (máy chủ) có thể nhận dạng phần cứng và kết nối với nó. Giống như khi bạn kết nối USB dongle với máy tính, nó sẽ tải trình điều khiển. Bộ vi xử lý của bạn không tải trình điều khiển như PC của bạn, vì vậy bạn cần tự thực hiện.

Trước tiên, hãy xác định vị trí Makefile. Tệp này bao gồm các hướng dẫn biên dịch và nếu không thực hiện đúng cách sẽ đồng nghĩa với việc bảng mạch camera của bạn không có wifi. Trong Makefile, hãy chỉnh sửa các giá trị cho ARCH, COMPILER và LINUX_KERNEL_PATH.

Ingenic sử dụng kiến trúc MIPS nên hãy sử dụng nó cho ARCH ‘ARCH := mips’

Đối với COMPILER và Kernel Path, nó sẽ là một dạng biên dịch chéo - phụ thuộc vào những gì bạn có trong OpenIPC. Để hiểu rõ hơn, hãy đọc bài viết này: https://blukat.me/2017/12/cross-compile-arm-kernel-module/

Bây giờ chúng ta có thể chuyển sang tải xuống và giải nén firmware OpenIPC, tệp giải nén của nó sẽ cung cấp cho chúng ta các đường dẫn cho Trình biên dịch và Kernel.

### Tải xuống Firmware OpenIPC

```
cd
git clone git@github.com:OpenIPC/firmware.git
cd firmware
./building.sh t31_ultimate
```
(t31_ultimate vì ultimate đi kèm với hỗ trợ cho các thiết bị không dây. lite bị loại bỏ những thiết bị đó để tiết kiệm dung lượng.)

Bây giờ bạn có thể thay đổi đường dẫn Trình biên dịch và Kernel trong Makefile nguồn trình điều khiển:

```
#Driver Compilation for Ingenic T31
ARCH := mips
COMPILER := ~/firmware/output/host/bin/mipsel-linux-
LINUX_KERNEL_PATH := ~/firmware/output/build/linux-3.10.14
```

### Bây giờ chạy ‘make fmac’

(ở đây FMAC hoặc bất kỳ tên liên quan nào khác cho trình điều khiển của bạn)

Nếu mọi việc diễn ra theo đúng kế hoạch, bạn sẽ có một tệp script và một hoặc nhiều tệp mở rộng .ko. Các tệp mở rộng .ko đó là trình điều khiển của bạn và tệp script bao gồm các hướng dẫn để bộ vi điều khiển máy chủ của bạn tìm và kích hoạt trình điều khiển.

### Đã đến lúc tải trình điều khiển lên hệ thống camera

Nếu các tệp nhỏ và Ingenic có thêm dung lượng khả dụng, bạn có thể tải phụ trình điều khiển.

Tải lên các tệp .ko (trình điều khiển) và script `fmac` (tệp script của bạn có thể có tên khác) vào thư mục bạn chọn. Vui lòng đảm bảo chỉnh sửa các đường dẫn tương ứng trong tệp script fmac, nếu cần.

### Kiểm tra

Kiểm tra nó với phần cứng WiFi của bạn để đảm bảo rằng nó hoạt động.

### Tiếp theo, tạo một gói

Sau khi bạn đã học cách tạo gói, vui lòng chia sẻ nó với các thành viên nhóm quản trị OpenIPC. Họ có thể đồng ý đưa gói trình điều khiển của bạn vào kho lưu trữ. Sau khi được đưa vào dưới dạng một gói, lần sau bạn có thể sử dụng nó bằng cách bỏ ghi chú và kích hoạt gói trong tệp cấu hình OpenIPC.


**Giải thích thuật ngữ:**

* **WiFi HaLow:** Là một tiêu chuẩn WiFi năng lượng thấp, tầm xa được thiết kế cho Internet of Things (IoT).
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **Makefile:** Là một tệp văn bản chứa các hướng dẫn cho công cụ make để tự động hóa quá trình biên dịch mã nguồn.
* **MIPS:** Là một kiến trúc tập lệnh (ISA) của bộ vi xử lý.
* **Cross Compilation:** Là quá trình biên dịch mã nguồn trên một nền tảng (ví dụ: PC) để chạy trên một nền tảng khác (ví dụ: bộ vi điều khiển nhúng).
* **Kernel:** Là phần cốt lõi của hệ điều hành.
* **Driver:** Trình điều khiển, là một phần mềm cho phép hệ điều hành giao tiếp với phần cứng.
* **Sideload:** Là quá trình cài đặt ứng dụng hoặc tệp vào thiết bị mà không cần thông qua cửa hàng ứng dụng chính thức.
* **Repo:** Kho lưu trữ, là một nơi lưu trữ mã nguồn hoặc các tệp khác.
* **Package:** Gói, là một tập hợp các tệp và hướng dẫn để cài đặt phần mềm.
* **Config file:** Tệp cấu hình, là một tệp văn bản chứa các cài đặt cho một chương trình hoặc hệ thống.




