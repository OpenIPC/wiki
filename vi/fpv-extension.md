# OpenIPC Wiki
[Mục lục](../README.md)

Phát triển bảng mở rộng 38x38 cho hệ thống FPV
--------------------------------

Các đồng nghiệp!

Ai bay và ai đã từng cầm trên tay bảng mạch của camera video tiêu chuẩn 38x38, hãy gửi mong muốn của bạn, dựa trên kinh nghiệm thực tế, về mô-đun mở rộng cho FPV.
Ví dụ về các bảng mạch tự chế, để nhận ra những gì chúng ta đang nói đến, bạn có thể xem ở cuối trang (dành cho các lĩnh vực sử dụng OpenIPC khác).


### Hình thức hóa các yêu cầu

- kích thước và vật liệu
    - bảng mở rộng tiêu chuẩn 38x38 được sử dụng trong giám sát video ("sandwich")
    - thủy tinh hai mặt, độ dày (?)
- giao diện
    - khoảng cách của tất cả các đầu nối 1,25, gắn bảng thông qua lỗ kim loại (KHÔNG PHẢI SMD!)
    - loại đầu nối, jst-gh 1.25 hoặc df13 1.25 hoặc thứ gì đó khác, được cài đặt tùy chọn
    - chân đầu nối được nhân đôi với các lỗ kim loại để hàn dây
- linh kiện
    - nguồn điện bên ngoài cho còi wifi ~2-3A
    - đầu nối (gót) để hàn dưới UART (bộ điều khiển bay)
    - gót (đầu nối) để kết nối còi
    - gót bổ sung (5-12) cho nguồn cung cấp hệ thống treo
    - chỉ báo sự hiện diện của điện áp bằng đèn LED (?)

### Tuyển chọn ảnh

<p align="center">
<img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-extension-old.jpg?raw=true" alt="Logo"/>
</p>

### Tài liệu tham khảo về chủ đề

* https://oshwhub.com/libc0607/xm-ext-board-fpv


