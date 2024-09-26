# OpenIPC Wiki
[Mục lục](../README.md)

## Khắc phục sự cố: Majestic không hoạt động, camera khởi động lại

Để khắc phục sự cố majestic, trước tiên bạn cần truy cập vào nhật ký của nó, ngay tại thời điểm nó gặp sự cố, 
điều này dẫn đến việc watchdog khởi động lại hệ thống và xóa nhật ký khỏi camera. Vì vậy, bạn cần sao chép 
nhật ký đến một nơi an toàn khi nó được tạo ra. Và bạn có thể đạt được điều đó bằng cách sử dụng quyền truy cập ssh vào camera và chuyển 
đầu ra sang một tệp trên máy tính để bàn của bạn.

Chạy lệnh này trên máy tính để bàn Linux của bạn (đừng quên thay thế _192.168.1.10_ bằng địa chỉ IP thực tế của camera)
và đợi camera khởi động lại một lần nữa. Tệp nhật ký kết quả sẽ nằm trong cùng thư mục được đặt tên và 
được ghi ngày tháng tương tự như _majestic-2022-12-14.log_
```
ssh root@192.168.1.10 "killall majestic; sleep 2; majestic" > majestic-$(date +"%F").log
```
