# OpenIPC Wiki
[Mục lục](../README.md)

OpenIPC AIO "Mario"
-------------------

https://store.openipc.org/OpenIPC-AIO-Mario-v1-0-p633320808

![image](https://github.com/user-attachments/assets/ad675599-61ce-4cec-a9bf-5933d907c53a)

Gỡ bỏ lớp phim bảo vệ ống kính trước khi sử dụng

![image](https://github.com/user-attachments/assets/9ead08a6-f4eb-45a0-bc63-19d3abd3ec1e)



Vỏ camera Mario với 4 vít M1.2.

Các lỗ gắn bên có ren vít M2 x2.

Cài đặt ăng-ten cho AIO.

![image](https://github.com/user-attachments/assets/e10e6671-553f-4840-aacd-16816be0813b)



### Chức năng LED

Đỏ nhấp nháy: Bật nguồn với Pin

Đỏ: Liên kết có dây

Xanh lam nhấp nháy: Máy phát RF

Xanh lá: TBD

Kích thước bo mạch 30mmx32mm với 4 lỗ gắn *M2.

Tản nhiệt với lỗ gắn 20mmx20mm.

![image](https://github.com/user-attachments/assets/1c7e34c1-76a9-45ee-9caf-ffd33261e154)




### Phần nguồn

Nguồn vào:

2S-6S

Dung lượng BEC hai chiều trên bo mạch:

BEC RF trên bo mạch có đầu ra lên đến 3A 5V

BEC MSIC trên bo mạch có đầu ra lên đến 2A 5V

Truy cập uboot sử dụng thiết bị UART kết nối với đầu bảng AIO (R0,T0).

Cách nhận đầu vào điện áp thấp hơn cho đầu vào DC

Nguồn điện AIO từ pin 2s-3S cần dòng điện lớn hơn và yêu cầu kết nối 4 dây, nhưng điện áp cao hơn 4S+ có thể hoạt động với kết nối 2 dây.

Tháo hai điện trở sau đó bạn có thể nhận được đầu vào thấp tới 5,4V.

![image](https://github.com/user-attachments/assets/24218925-fca8-47e2-bc4a-1326dabeaa68)




### Kết nối cổng gỡ lỗi USB

Cắm cáp USB để kết nối AIO và PC trước, sau đó bật nguồn DC hoặc chỉ cấp nguồn USB.

Nếu có thiết bị USB không xác định trong máy tính, cần cài đặt trình điều khiển [corechip-sr9900](https://github.com/user-attachments/files/16829005/corechip-sr9900-usb20-to-fast-ethernet-adapter-1750095.zip) sau.

Thao tác trên Mac OS

<img width="686" alt="Screenshot 2024-09-21 at 10 07 24 AM" src="https://github.com/user-attachments/assets/15fde52d-8f14-4377-87ed-cec6e05dc70a">

<img width="714" alt="Screenshot 2024-09-21 at 10 09 18 AM" src="https://github.com/user-attachments/assets/ce029aab-7505-41f8-81fc-283e41dfe84a">

<img width="544" alt="Screenshot 2024-09-21 at 10 11 31 AM" src="https://github.com/user-attachments/assets/97aff8d8-1a1b-4682-a304-4af58a29e68a">



#### Tự động thiết lập trong Windows
Vui lòng tải xuống tệp [Auto_Set_Mario_CDC.zip](https://github.com/user-attachments/files/17010487/Auto_Set_Mario_CDC.zip), giải nén và chạy với quyền quản trị viên.

hoặc cài đặt thủ công như sau:

đi tới bảng điều khiển - internet - mạng:

tìm Bộ chuyển đổi USB 2.0 sang Ethernet nhanh

đặt địa chỉ ipv4 của thẻ này thành 192.168.1.11 mặt nạ: 255.255.255.0

áp dụng

sau đó mở ssh để kết nối địa chỉ AIO: 192.168.1.10

người dùng: root mật khẩu: 12345

**Cách kết nối internet cho AIO**

1. Mở kết nối mạng trên Windows của bạn, nhấp chuột phải vào thuộc tính bộ chuyển đổi mạng chính của bạn --- Chia sẻ: Cho phép người dùng mạng khác chọn USB CDC


![image](https://github.com/user-attachments/assets/e3f41122-7601-4dff-b599-a325e0693b8c)

Áp dụng, sau đó ethernet CDC sẽ tự động nhận địa chỉ IP 192.168.137.1


![image](https://github.com/user-attachments/assets/bac7350b-399e-419c-8a4a-557d4378cf79)

mở terminal quản trị

![image](https://github.com/user-attachments/assets/7eaae7ca-16c6-4e59-a8de-9178c9e3b77c)

sử dụng arp -a để tìm IP của AIO

![image](https://github.com/user-attachments/assets/f6d2641e-a5e9-45cd-90cb-5328d423a6c7)

ở đây 192.168.137.147 là địa chỉ ip của AIO của tôi.

mở kết nối ssh đến AIO, Xong.

![5ed177f3dc690f9e70452e3e4c93b17](https://github.com/user-attachments/assets/48f44a3d-ae04-4780-aac7-b878a043c3e6)

Bây giờ bạn có thể sử dụng sysupgrade -r -k -n --force_ver để cập nhật firmware của mình.




### Nâng cấp firmware

Có thể cập nhật firmware qua thẻ SD hoặc chỉ cần sử dụng WinSCP, kéo các tệp rootfs và kernel vào /tmp

```
sysupgrade -n -z --kernel=/tmp/uImage.ssc338q --rootfs=/tmp/rootfs.squashfs.ssc338q
```

Bạn có thể [tải xuống](https://github.com/OpenIPC/wiki/blob/master/en/fpv-openipc-aio-ultrasight.md#software) firmware qua liên kết được sử dụng cho các bản cập nhật trực tuyến.

Bạn cũng có thể đọc các cuộc thảo luận và đề xuất hiện tại tại đây:

- https://t.me/c/1809358416/98818/103632
- https://t.me/c/1809358416/98818/108052

Hoặc chỉ cần sử dụng trình cấu hình - https://github.com/OpenIPC/configurator


### Phần RF

Đặc điểm ăng-ten RF

![image](https://github.com/user-attachments/assets/d54050b4-2769-4942-95d7-8aad3b5e2e21)

![image](https://github.com/user-attachments/assets/0a709f70-ac8b-4880-93f5-49e1d958eb1b)


Ăng-ten mặc định là ANT1 cho 1T1R, ANT0+ANT1 là 2T2R

Cài đặt RF được khuyến nghị 

Công suất RF tối đa 18dBm cho đầu vào PA trên bo mạch.
Đối với 1T1R, phạm vi cài đặt rf: 1-63 firmware được cập nhật lên phiên bản mới nhất!
stbc = 0, ldpc = 0 Giá trị công suất RF được đề xuất < 45

Chỉ số MCS 1,3 (0-7 là 1T1R, 8+ là 2T2R)

Tốc độ bit video: 4096/8192/12688 (mcs 3+)

khi sử dụng stbc = 1, ldpc = 1, khuyến nghị cài đặt công suất rf cho MCS3 từ 8-15 để kiểm tra.

Giữ công suất RF <= 15 khi kiểm tra trên bàn (khi chỉ kết nối USB)


### Khe cắm SD cho bản ghi camera trên không

trong thử nghiệm băng ghế dự bị hoặc gỡ lỗi, chức năng ghi bị tắt theo mặc định

Để bật chức năng ghi, hãy đặt (giá trị ghi) true trong majestic.yaml

Thẻ SD phải được lắp vào trước khi Bật nguồn.


**Tản nhiệt và quạt làm mát trên bo mạch:**

công suất đầu ra của quạt làm mát tối đa 500mA

tất cả các lỗ gắn tản nhiệt đều có ren vít M2.


### Mở rộng đầu nối**

![image](https://github.com/user-attachments/assets/af8124e3-539f-42c6-a757-a560eb93e3fe)


**LƯU Ý**

USB chỉ dành cho chế độ gỡ lỗi, khi chỉ có nguồn DC, ethernet cdc hoạt động ở chế độ ngủ để tiết kiệm năng lượng.

Chế độ chỉ nguồn USB Nguồn vào giới hạn 5W.

**Nâng cấp Firmware lên Ruby FPV**

cắm cáp usb và cài đặt cdc ethernet ipv4: 192.168.1.11 255.255.255.0

sử dụng winscp kéo các tệp giải nén vào /tmp

sử dụng ssh login và sao chép lệnh sau:

sysupgrade --kernel = / tmp / uImage.ssc338q --rootfs = / tmp / rootfs.squashfs.ssc338q -z -n

sau khi cập nhật và khởi động lại

sử dụng ssh login và đặt lệnh:

fw_setenv sensor imx335 && fw_setenv nâng cấp https://github.com/OpenIPC/firmware/releases/download/latest/openipc.ssc338q-nor-rubyfpv.tgz && khởi động lại

