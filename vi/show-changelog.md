# Wiki OpenIPC
[Bảng nội dung](../README.md)

Lộ trình
-------

### Truy cập nhanh vào nhật ký Git cho các kho lưu trữ phổ biến:

- [firmware](https://github.com/OpenIPC/firmware/commits/master), [builder](https://github.com/OpenIPC/builder/commits/master), [coupler](https://github.com/OpenIPC/coupler/commits/main)
- [ipctool](https://github.com/OpenIPC/ipctool/commits/master), [webui](https://github.com/OpenIPC/webui/commits/master), [webui-next](https://github.com/OpenIPC/webui-next/commits/master), [wiki](https://github.com/OpenIPC/wiki/commits/master)

### Các thay đổi dự kiến:

- Thêm webui-next làm giao diện mặc định.
- Tích hợp tốt hơn với Majestic và webui-next.
- Tiếp tục tái cấu trúc các script và gói firmware.
- Mở rộng hỗ trợ builder.
- Mở rộng hỗ trợ tài liệu.
- Mở rộng hỗ trợ majestic-plugins.
- Cập nhật buildroot lên phiên bản sắp tới 2024.
- Cập nhật các lệnh xây dựng wiki.
- Cập nhật các lệnh majestic wiki.

### 19.02.2024:
- [hisilicon/goke] Sửa lỗi muxing các GPIO không cần thiết đang làm cháy IRCUTs trên các bo mạch XM

### 12.02.2024:
- Thêm cải tiến cho phép Majestic chạy các script cgi không liên quan đến sdk.
- Sửa lỗi không cho phép ràng buộc lại cổng rtsp.
- Sửa vấn đề với thư mục chính của máy chủ web Majestic.
- Sửa một ngoại lệ trên lựa chọn codec.
- Cải thiện ổn định nếu majestic.yaml không có sẵn.
- Giảm khung thời gian cho việc tắt Majestic trên các thiết bị Ingenic.

### 05.02.2024:
- Thêm xem trước mjpeg vào webui-next.
- Thêm hỗ trợ mjpeg cho Ingenic.
- Thêm chuyển hướng cổng 85 đến máy chủ web Majestic.
- Điều chỉnh một số cài đặt cấu hình Majestic cho webui-next.
- Sửa chế độ điều khiển ban đêm trên webui-next.
- Sửa vấn đề với việc đảo ngược ircut đơn.
- Đặt Majestic là máy chủ web duy nhất cho webui-next.
- Đặt majestic-webui là mặc định cho các thiết bị Sigmastar.
- Lưu ý: các tiện ích mở rộng majestic-webui hiện không có sẵn.

### 29.01.2024:
- Thêm hỗ trợ ipctool cho nhiều cảm biến Sony mới.
- Thêm các lệnh bổ sung khi khởi động và dừng majestic-plugins.
- Thêm nhiều lệnh bí danh mới (show_help)
- Thêm hỗ trợ IP6 thử nghiệm cho Majestic.
- Thêm kiểm tra để ngăn chặn việc thực hiện lặp lại cài đặt chế độ ban đêm.
- Thay thế building.sh bằng makefile.
- Tái cấu trúc một số script firmware và makefile gói.

### 22.01.2024:
- Thêm phát hiện chipset T40/T41.
- Thêm hỗ trợ âm thanh cho Sigmastar fpv.
- Thêm chế độ màu ban đêm tùy chọn.
- Sửa một số vấn đề ổn định của Majestic.
- Sửa vấn đề với việc phát hiện chuyển động Ingenic trên sighup/reload.
- Tăng ổn định của máy chủ web Majestic.
- Đưa gkrcparams vào cấu hình majestic.
- Cập nhật thư viện libevent và toolchains.
- Cập nhật thư viện nhà cung cấp Ingenic.

### 15.01.2024:
- Thêm nút chuyển đổi kiểm soát riêng biệt cho ircut và ánh sáng.
- Thêm phát hiện ban ngày/đêm dựa trên cảm biến.
- Thêm xác thực cho nhiều điểm cuối.
- Thêm hỗ trợ ban đầu cho việc quét thông tin đăng ký Ingenic.
- Sửa lỗi với Majestic không mở lại đúng cổng udp.
- Sửa lỗi với dòng rtsp Ingenic T10/T20.
- Sửa vấn đề với việc đặt đúng bitrate mã hóa hisilicon.

### 08.01.2024:
- Thêm hỗ trợ sighup Majestic cho các thiết bị Ingenic.
- Thêm hỗ trợ h265 cho rtmp.
- Thêm tùy chọn kết nối lại rtmp.
- Thêm hỗ trợ cho việc quét thông tin đăng ký Sigmastar.
- Sửa một số vấn đề xác thực rtmp.
- Sửa vấn đề với việc xoay trên một số trình điều khiển cảm biến Sigmastar.
- Loại bỏ việc phát hiện ban ngày/đêm dựa trên phần mềm Ingenic.