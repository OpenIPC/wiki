## Wiki OpenIPC
[Mục lục](../README.md)


## Tích hợp OpenIPC vào HomeKit
---

Hiện tại OpenIPC chưa có hỗ trợ HomeKit gốc, việc tích hợp được thực hiện bởi gói bên thứ 3 [go2rtc](https://github.com/AlexxIT/go2rtc "go2rtc"), cảm ơn [@gtxaspec](https://github.com/gtxaspec "@gtxaspec") đã thêm gói này vào OpenIPC.

### Yêu cầu phần cứng

Vì tệp nhị phân đã biên dịch sẽ có kích thước 3,3MB, kích thước chip flash phải ít nhất là 16MB, kích thước DDR phải ít nhất là 128MB.

### Biên dịch gói go2rtc

Cài đặt go và upx trước
```
apt update
apt install golang upx
```
- #### Phương pháp 1: Biên dịch toàn bộ firmware
Chỉnh sửa tệp cấu hình bảng trong thư mục `firmware/br-ext-chip-xxxx/configs`, thêm dòng sau để bật gói go2rtc
```
BR2_PACKAGE_GO2RTC=y
```
sau đó chạy
```
make distclean
make all BOARD=board_config_name
```
- #### Phương pháp 2: Chỉ biên dịch gói
```
make distclean
make br-go2rtc-rebuild BOARD=board_config_name
```
Tệp nhị phân go2rtc đã biên dịch sẽ nằm tại `firmware/output/per-package/go2rtc/target/usr/bin`, tệp cấu hình mặc định tại `firmware/output/per-package/go2rtc/target/etc`.

### Chỉnh sửa tệp cấu hình

Đặt tệp cấu hình `go2rtc.yaml` vào thư mục `/etc/`, ví dụ cấu hình:

```
log:
  level: info  # mức mặc định
  api: trace
  exec: debug
  ngrok: info
  rtsp: warn
  streams: error
  webrtc: fatal

rtsp:
  listen: ":8553"

webrtc:
  candidates:
    - stun:8555

streams:
  openipc: rtsp://admin:12345@127.0.0.1/stream=0

homekit:
  openipc:                   # cùng ID luồng từ danh sách luồng
    pin: 19550224           # mã PIN tùy chỉnh, mặc định: 19550224
    name: openipc-ssc30kq      # tên camera tùy chỉnh, mặc định: được tạo từ ID luồng
    device_id: openipc       # ID tùy chỉnh, mặc định: được tạo từ ID luồng
```

### Chạy go2rtc

```
/usr/bin/go2rtc -config /etc/go2rtc.yaml &
```

Mở ứng dụng Home trên thiết bị Apple của bạn, nhấp vào nút `+` ở góc trên cùng bên phải, camera OpenIPC sẽ xuất hiện ở đó tự động, nhập mã PIN trong tệp cấu hình để ghép nối với nó.

### Tự động chạy khi khởi động

Thêm các dòng sau vào /etc/rc.local

```
/usr/bin/go2rtc -config /etc/go2rtc.yaml &
```

### Giới hạn

- Chưa hỗ trợ HomeKit Secure Video.
- Chưa hỗ trợ cảm biến chuyển động.
- Chưa hỗ trợ âm thanh hai chiều.


**Giải thích thuật ngữ:**

* **HomeKit:** Là một nền tảng tự động hóa nhà của Apple.
* **go2rtc:** Là một ứng dụng trung gian cho phép bạn tích hợp các camera RTSP vào HomeKit.
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **Flash chip:** Chip flash, là một loại bộ nhớ không bay hơi được sử dụng để lưu trữ firmware.
* **DDR:** Double Data Rate, là một loại bộ nhớ truy cập ngẫu nhiên.
* **Board config file:** Tệp cấu hình bảng, là một tệp văn bản chứa các cài đặt cho quá trình biên dịch firmware.
* **Binary file:** Tệp nhị phân, là một tệp chứa dữ liệu ở dạng nhị phân.
* **Config file:** Tệp cấu hình, là một tệp văn bản chứa các cài đặt cho một chương trình.
* **RTSP:** Real Time Streaming Protocol, là một giao thức mạng được sử dụng để truyền phát video và âm thanh trực tiếp.
* **WebRTC:** Web Real-Time Communication, là một bộ API cho phép truyền thông âm thanh và video trực tiếp trong trình duyệt web.
* **STUN:** Session Traversal Utilities for NAT, là một giao thức mạng được sử dụng để vượt qua NAT.
* **Home app:** Ứng dụng Home, là ứng dụng của Apple để điều khiển các thiết bị HomeKit.
* **PIN:** Personal Identification Number, là một mã số bí mật được sử dụng để xác thực.
* **HomeKit Secure Video:** Là một tính năng của HomeKit cho phép bạn lưu trữ video được mã hóa từ camera của mình trên iCloud.
* **Motion sensor:** Cảm biến chuyển động, là một cảm biến phát hiện chuyển động.
* **Two-way audio:** Âm thanh hai chiều, là khả năng nói chuyện và nghe qua camera.





