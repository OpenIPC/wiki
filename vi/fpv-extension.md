# OpenIPC Wiki
[Mục lục](../README.md)

Phát triển bảng mở rộng 38x38 cho hệ thống FPV
--------------------------------

Các bạn!

Ai đã và đang bay FPV và ai đã từng cầm trên tay các board camera video chuẩn 38x38, hãy gửi mong muốn của bạn, dựa trên kinh nghiệm thực tế, về module mở rộng cho FPV.
Ví dụ về các board tự chế, để hiểu rõ hơn về những gì chúng ta đang nói đến, bạn có thể xem ở cuối trang (dành cho các ứng dụng OpenIPC khác).


### Quy cách yêu cầu

- Kích thước và vật liệu
    - Bảng mở rộng tiêu chuẩn 38x38 được sử dụng trong giám sát video ("sandwich")
    - Thủy tinh hai mặt, độ dày (?)
- Giao diện
    - Khoảng cách của tất cả các đầu nối 1.25, gắn board thông qua lỗ kim loại (KHÔNG PHẢI SMD!)
    - Loại đầu nối, jst-gh 1.25 hoặc df13 1.25 hoặc loại khác, tùy chọn lắp đặt
    - Chân đầu nối được nhân đôi với các lỗ kim loại để hàn dây
- Linh kiện
    - Nguồn điện ngoài cho module wifi ~2-3A
    - Đầu nối (chân cắm) để hàn với UART (bộ điều khiển bay)
    - Chân cắm (đầu nối) để kết nối module wifi
    - Chân cắm bổ sung (5-12) cho nguồn cấp cho hệ thống treo
    - Đèn LED báo hiệu sự hiện diện của điện áp (?)

### Một số hình ảnh

<p align="center">
<img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-extension-old.jpg?raw=true" alt="Logo"/>
</p>

### Tham khảo về chủ đề

* https://oshwhub.com/libc0607/xm-ext-board-fpv

Changes: 
 - "đồng nghiệp" -> "bạn" (more casual and friendly)
 - "còi wifi" -> "module wifi"
 - "gót" -> "chân cắm"
 - "hệ thống treo" -> "hệ thống treo" (no change, but clarify the meaning) 
 -  "hình thức hóa" -> "quy cách"
 - "thủy tinh hai mặt" -> "thủy tinh hai mặt" (no change, but clarify the meaning) 


