# OpenIPC Wiki
[Mục lục](../README.md)

Việc cần làm
----

## Sửa lỗi

* Cần khắc phục sự cố khiến syslogd và logread ngừng hoạt động trên cấu hình hi35{16ev200,16ev300,18ev300}


## Cải tiến và Tính năng

* Thêm khẩn cấp hỗ trợ cho bộ xử lý Goke
* Thực hiện kiểm tra sự hiện diện của các thành phần nhị phân trong majestic, mini_snmpd, telnetd và các tập lệnh khác
* Xây dựng gói [motors-openipc](https://github.com/OpenIPC/motors/tree/master/XM) mới
* Tích hợp phiên bản mới của [libjson](https://github.com/json-c/json-c/tree/json-c-0.15) theo tiêu chuẩn OpenIPC và loại bỏ các liên kết tượng trưng cũ
* Tạo bản dựng Initramfs và cpio cho tất cả các nền tảng
* Tối ưu hóa các applet Busybox và tắt tất cả những cái không cần thiết
* Thêm khởi chạy daemon Crond
* Thêm tập lệnh bot Telegram từ dự án OpenIPC cũ
* Tối ưu hóa tập lệnh show_modules để hiển thị bộ nhớ được sử dụng động
* ~
* Tích hợp Hi3516Av300/Hi3516Cv500/Hi3516Dv300
* Tích hợp Hi3516Cv200/Hi3518Ev200/Hi3518Ev201
* Tích hợp Hi3516Av100/Hi3516Dv100
    * Kết nối tập lệnh để khởi tạo các mô-đun và khởi động hệ thống


## Giám sát và Quản lý

* Tải lên kho lưu trữ các ví dụ về làm việc với Ansible
* Cài đặt máy chủ prometheus cục bộ
* Đạt được phản hồi đo từ xa ổn định từ các thiết bị của ZFT Lab.


## Tài liệu

* Tạo trang Wiki để nhập dữ liệu của các bảng có động cơ và thông số kỹ thuật giao thức


