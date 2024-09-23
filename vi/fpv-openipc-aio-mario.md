# OpenIPC Wiki
[Mục lục](../README.md)

OpenIPC AIO "Mario"
-------------------

https://store.openipc.org/OpenIPC-AIO-Mario-v1-0-p633320808

![image](https://github.com/user-attachments/assets/ad675599-61ce-4cec-a9bf-5933d907c53a)

Gỡ bỏ lớp phim bảo vệ ống kính trước khi sử dụng

![image](https://github.com/user-attachments/assets/9ead08a6-f4eb-45a0-bc63-19d3abd3ec1e)



Vỏ camera Mario với 4 vít M1.2.

Các lỗ gắn bên là ren vít M2 x2.

Cài đặt ăng-ten cho AIO.

![image](https://github.com/user-attachments/assets/e10e6671-553f-4840-aacd-16816be0813b)



### Chức năng LED

Đỏ nhấp nháy	Bật nguồn với Pin

Đỏ 	Liên kết có dây

Xanh lam nhấp nháy	Máy phát RF

Xanh lá	TBD

Kích thước bo mạch 30mmx32mm với 4 lỗ gắn *M2.

Tản nhiệt với lỗ gắn 20mmx20mm.

![image](https://github.com/user-attachments/assets/1c7e34c1-76a9-45ee-9caf-ffd33261e154)




### Phần nguồn

Nguồn vào:

2S-6S

Dung lượng BEC hai chiều trên bo mạch:

BEC RF trên bo mạch có đầu ra lên đến 3A 5V

BEC MSIC trên bo mạch có đầu ra lên đến 2A 5V

nhập uboot sử dụng thiết bị uart kết nối với đầu bảng AIO (R0,T0) pad.


### Kết nối cổng gỡ lỗi usb

Bật nguồn AIO bằng đầu nối Pin (GH1.25* 6 chân), sau khi đèn LED xanh lam nhấp nháy, cắm cáp usb và kết nối với PC

trong Windows:

đi tới bảng điều khiển- internet -mạng:

tìm Bộ chuyển đổi USB 2.0 sang Ethernet nhanh

đặt địa chỉ ipv4 của thẻ này thành 192.168.1.11 mặt nạ: 255.255.255.0

áp dụng

sau đó mở ssh để kết nối địa chỉ AIO: 192.168.1.10

người dùng: root mật khẩu: 12345


### Nâng cấp firmware

Có thể cập nhật firmware qua thẻ SD hoặc chỉ cần sử dụng win scp kéo các tệp rootfs và kernel vào /tmp

```
sysupgrade -n -z --kernel=/tmp/uImage.ssc338q --rootfs=/tmp/rootfs.squashfs.ssc338q
```

Bạn có thể [tải xuống](https://github.com/OpenIPC/wiki/blob/master/en/fpv-openipc-aio-ultrasight.md#software) firmware qua liên kết được sử dụng cho các bản cập nhật trực tuyến.


Hoặc chỉ cần sử dụng trình cấu hình - https://github.com/OpenIPC/configurator


### Phần RF

Đặc điểm ăng-ten RF

![image](https://github.com/user-attachments/assets/d54050b4-2769-4942-95d7-8aad3b5e2e21)

![image](https://github.com/user-attachments/assets/0a709f70-ac8b-4880-93f5-49e1d958eb1b)


Ăng-ten mặc định là ANT1 cho 1T1R, ANT0+ANT1 là 2T2R

Cài đặt RF được khuyến nghị
  
  Công suất RF tối đa 18dbm cho PA trên bo mạch. Cài đặt 0~-25dbm
  
  Chỉ số MCS 1,3 (0-7 là 1T1R, 8+ là 2T2R)
  
  stbc=1,ldpc=1
  
  Tốc độ bit video: 4096 /8192/12688 (mcs 3+)

  Giữ RF tắt nguồn hoặc power=1 khi kiểm tra trên bàn (khi chỉ kết nối usb)


### Khe cắm SD để ghi camera trên không

trên thử nghiệm băng ghế dự bị hoặc gỡ lỗi là vô hiệu hóa chức năng ghi theo mặc định

Để bật chức năng ghi, hãy đặt (giá trị ghi) thành true trong majestic.yaml


Tản nhiệt và quạt làm mát trên bo mạch:

công suất đầu ra của quạt làm mát lên đến 500mA tối đa

tất cả các lỗ gắn tản nhiệt đều là ren vít M2.


### Đầu nối mở rộng**

![image](https://github.com/user-attachments/assets/af8124e3-539f-42c6-a757-a560eb93e3fe)


### Cần làm

USB chỉ dành cho chế độ gỡ lỗi

Nguồn vào giới hạn 5W.




