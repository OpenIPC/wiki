# OpenIPC Wiki
[Mục lục](../README.md)

Lộ trình
-------

### Truy cập nhanh Nhật ký Git cho các kho lưu trữ phổ biến:

- [firmware](https://github.com/OpenIPC/firmware/commits/master), [builder](https://github.com/OpenIPC/builder/commits/master), [coupler](https://github.com/OpenIPC/coupler/commits/main)
- [ipctool](https://github.com/OpenIPC/ipctool/commits/master), [webui](https://github.com/OpenIPC/webui/commits/master), [webui-next](https://github.com/OpenIPC/webui-next/commits/master), [wiki](https://github.com/OpenIPC/wiki/commits/master)

### Các thay đổi đã lên kế hoạch:

- Thêm webui-next làm giao diện mặc định.
- Tích hợp tốt hơn với Majestic và webui-next.
- Tiếp tục tái cấu trúc các tập lệnh firmware và gói.
- Mở rộng hỗ trợ trình build.
- Mở rộng hỗ trợ tài liệu.
- Mở rộng hỗ trợ majestic-plugins.
- Cập nhật buildroot lên phiên bản 2024 sắp tới.
- Cập nhật các lệnh build wiki.
- Cập nhật các lệnh majestic wiki.

### 19.02.2024:
- [hisilicon/goke] Khắc phục việc ghép kênh các GPIO không cần thiết khiến IRCUT bị cháy trên bo mạch XM

### 12.02.2024:
- Đã thêm một cải tiến cho phép Majestic chạy các tập lệnh cgi tách biệt khỏi sdk.
- Khắc phục sự cố ngăn chặn việc liên kết lại cổng RTSP.
- Khắc phục sự cố với thư mục chính của máy chủ web Majestic.
- Khắc phục ngoại lệ về lựa chọn codec.
- Cải thiện tính ổn định nếu majestic.yaml không khả dụng.
- Giảm khung thời gian để Majestic tắt trên các thiết bị Ingenic.

### 05.02.2024:
- Đã thêm bản xem trước MJPEG vào webui-next.
- Đã thêm hỗ trợ MJPEG cho Ingenic.
- Đã thêm chuyển hướng cổng 85 đến máy chủ web Majestic.
- Điều chỉnh một số cài đặt cấu hình Majestic cho webui-next.
- Khắc phục các điều khiển chế độ ban đêm trên webui-next.
- Khắc phục sự cố với việc đảo ngược IRCUT đơn.
- Đặt Majestic làm máy chủ web duy nhất cho webui-next.
- Đặt majestic-webui làm mặc định cho các thiết bị Sigmastar.
- Lưu ý: các phần mở rộng majestic-webui hiện không khả dụng.

### 29.01.2024:
- Đã thêm hỗ trợ ipctool cho nhiều cảm biến Sony mới.
- Đã thêm các lệnh bổ sung khi majestic-plugins được khởi động và dừng.
- Đã thêm nhiều lệnh bí danh mới (show_help)
- Đã thêm hỗ trợ IP6 Majestic thử nghiệm.
- Đã thêm một kiểm tra để ngăn chặn việc thực hiện lặp lại các cài đặt chế độ ban đêm.
- Thay thế building.sh bằng makefile.
- Tái cấu trúc một số tập lệnh firmware và makefile gói.

### 22.01.2024:
- Đã thêm tính năng phát hiện chipset T40/T41.
- Đã thêm hỗ trợ âm thanh cho Sigmastar fpv.
- Đã thêm chế độ màu ban đêm tùy chọn.
- Khắc phục một số sự cố ổn định Majestic.
- Khắc phục sự cố với phát hiện chuyển động Ingenic trên sighup/reload.
- Tăng tính ổn định của máy chủ web Majestic.
- Bao gồm gkrcparams vào cấu hình majestic.
- Cập nhật thư viện libevent và chuỗi công cụ.
- Cập nhật thư viện nhà cung cấp Ingenic.

### 15.01.2024:
- Đã thêm nút chuyển đổi điều khiển riêng biệt cho IRCUT và ánh sáng.
- Đã thêm tính năng phát hiện ngày/đêm dựa trên cảm biến.
- Đã thêm xác thực cho các điểm cuối khác nhau.
- Đã thêm hỗ trợ ban đầu cho quét thông tin đăng ký Ingenic.
- Khắc phục sự cố Majestic không mở lại ổ cắm UDP một cách chính xác.
- Khắc phục sự cố với luồng RTSP Ingenic T10/T20.
- Khắc phục sự cố với việc đặt tốc độ bit bộ mã hóa hisilicon chính xác.

### 08.01.2024:
- Đã thêm hỗ trợ sighup Majestic cho các thiết bị Ingenic.
- Đã thêm hỗ trợ H.265 cho RTMP.
- Đã thêm tùy chọn kết nối lại RTMP.
- Đã thêm hỗ trợ cho quét thông tin đăng ký Sigmastar.
- Khắc phục một số sự cố xác thực RTMP.
- Khắc phục sự cố với xoay vòng trên một số trình điều khiển cảm biến Sigmastar.
- Đã xóa tính năng phát hiện ngày/đêm dựa trên phần mềm Ingenic.




