# OpenIPC Wiki
[Mục lục](../README.md)

Trạm mặt đất OpenIPC FPV
--------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

Bạn có thể tham khảo [hướng dẫn bắt đầu](https://wiki.radxa.com/Zero/getting_started) nếu chưa quen thuộc với Radxa.

### Flash Firmware

* Thẻ SD
[Liên kết](https://github.com/OpenIPC/sbc-groundstations/releases) đến bản phát hành mới nhất

* EMMC
[Cách flash image vào bộ nhớ eMMC trên bo mạch](https://github.com/OpenIPC/sbc-groundstations/blob/master/radxa_pi_zero_3w/flashing_to_the_onboard_memory.md)


### Wifi

Bạn có thể [thiết lập Wi-Fi tích hợp](https://github.com/OpenIPC/sbc-groundstations/blob/master/radxa_pi_zero_3w/headless_setup.md#setup-of-autoconnect-on-boot) cho kết nối SSH. (quy tắc udev và networkmanager đã được cấu hình trong image này, bạn chỉ cần thực hiện các lệnh nmcli)

Lưu ý: đối với RubyFPV, bạn sẽ cần Dongle Mạng USB như hình bên dưới

 ![Hình ảnh](../images/fpv-radxa-usbc-lan.png)

hoặc truy cập console serial, vui lòng kiểm tra [tại đây](https://wiki.radxa.com/Zero/dev/serial-console) để biết cách thực hiện.

### DVR với firmware FPV

Chức năng DVR; Nó yêu cầu một nút nhấn được cài đặt vào header GPIO giữa các chân vật lý 25 và 27 như sau:


![image](../images/fpv-radxa-gpio.png)

Để ghi DVR, hãy nhấn nút một lần. Luồng sẽ bắt đầu và DVR sẽ bắt đầu ghi. Khi hoàn tất, hãy nhấn nút một lần để dừng ghi và lưu tệp.

DVR được lưu vào thư mục Videos trong thư mục chính của bạn. Bạn có thể truy cập DVR tại `/home/radxa/Videos` hoặc thông qua máy chủ media. Kết nối trạm mặt đất của bạn với mạng gia đình và có thể truy cập nó qua trình duyệt web tại `x.x.x.x:8080` -- thay thế `x.x.x.x` bằng địa chỉ IP cục bộ của trạm mặt đất của bạn.

Kết nối dây dài của LED với +5V, dây ngắn của LED qua điện trở 1k với GPIOAO_2 (chân XANH DƯƠNG khác trên Radxa),

```bash
sudo gpioset gpiochip4 11=0      # bật đèn LED
sudo gpioset gpiochip4 11=1      # tắt đèn LED (thực ra nó rất 
                             # đơn giản chỉ sáng vì tôi đoán mức logic 0 không phải là 0 vôn)
```

Cách đấu dây mạch: +5V —>  +LED- —-> điện trở 1k —> chân 28 trên Radxa Z3W (còn gọi là chân màu xanh dương khác)

<hr>

Lưu ý về ghi DVR trong image này. Để giảm tải cho bộ xử lý, chúng tôi ghi vào tệp .ts thay vì .mp4 hoặc .mkv. Do đó, sẽ không có hiệu ứng "nhòe" nào được ghi lại, các khung hình không được ghi lại sẽ bị bỏ qua. Bạn có thể nhận thấy hiện tượng giật trong bản ghi của mình ở những nơi không có thông tin khung hình.

### Liên kết đến một số công cụ hữu ích

* [Công cụ Windows](https://dl.radxa.com/zero/tools/windows/)
* [Công cụ khác, mọi hệ điều hành](https://dl.radxa.com/tools/)

### RubyFPV
Xem [Phần cứng RubyFPV](https://rubyfpv.com/hardware.php)

Changes:
- "Cài đặt" -> "Flash Firmware"
- "wifi trên bo mạch" -> "Wi-Fi tích hợp"
- "console nối tiếp" -> "console serial"
- "tiêu đề gpio" -> "header GPIO"
- "máy chủ phương tiện" -> "máy chủ media"
- "địa chỉ ip cục bộ" -> "địa chỉ IP cục bộ"
- "chân XANH LAM" -> "chân XANH DƯƠNG"
- "Cách đấu dây mạch" -> "Cách đấu dây mạch"
- ".ts thay vì .mp4 hoặc .mkv" -> ".ts thay vì .mp4 hoặc .mkv"
- "Công cụ Windows" -> "Công cụ Windows"
- "Khác, Tất cả hệ điều hành" -> "Công cụ khác, mọi hệ điều hành"
- "Phần cứng RubyFPV" -> "Phần cứng RubyFPV"


