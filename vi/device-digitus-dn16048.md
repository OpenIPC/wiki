# Digitus DN-16048 Optizoom PTZ
Xoay, Nghiêng, Lấy nét và Thu phóng (thông qua dòng lệnh ssh)

## Cài đặt OpenIPC:

Mở vỏ máy ra, hóa ra, SoC là **hi3518cv100**, **16MB** và cảm biến camera là **mt9p006**. Cài đặt máy chủ TFTP trên PC và làm theo hướng dẫn cài đặt: https://github.com/OpenIPC/wiki/blob/master/en/installation.md Tải xuống hình ảnh chính xác (16MB, Lite) từ đây https://openipc.org/cameras/vendors/hisilicon/socs/hi3518cv100 và đặt nó vào thư mục của máy chủ TFTP (trong trường hợp hình ảnh không được đóng gói, có thể bỏ qua bước "giải nén"). Như đã mô tả, kết nối bộ chuyển đổi UART với các chân trên bo mạch SoC và khởi động một terminal trên PC:

```sh
screen -L -Logfile ipcam-$(date +%s).log /dev/ttyUSB0 115200
```

Làm theo hướng dẫn được tạo bởi trang web OpenIPC. Để truy cập U-Boot, hãy nhấn Ctrl-C ngay sau khi cắm nguồn điện. Để làm cho mạng hoạt động sau này trong Linux: Trước lệnh "reset" cuối cùng trong U-Boot, hãy nhập các lệnh sau, theo: https://github.com/OpenIPC/wiki/blob/master/en/network-perversions.md

```sh
setenv extras 'hieth.phyaddru=3 hieth.mdioifu=0'
saveenv
```

Cuối cùng nhập:

```sh
reset
```

Đăng nhập vào Linux bằng "root" và "12345". Trong Linux, hãy nhập:

```sh
firstboot
```

Đăng nhập lại vào Linux. Cảm biến sẽ không được phát hiện tự động. Do đó, hãy nhập các lệnh sau trong Linux trên camera:

```sh
fw_setenv soc hi3518cv100
fw_setenv sensor mt9p006
```

Tìm địa chỉ IP của camera thông qua

```sh
ip a
```

## Thay đổi mật khẩu và địa chỉ MAC:
Truy cập giao diện web bằng trình duyệt qua cổng 85 và thay đổi mật khẩu và địa chỉ MAC.

## Cấu hình chuyển đổi chế độ ban đêm:
Thông qua ipctool (ipctool gpio scan), người ta có thể dễ dàng tìm ra rằng đầu vào cảm biến ánh sáng (để tự động chuyển đổi giữa ngày và đêm) là số 2. Bộ cắt IR được điều khiển bởi 1 và 0.

* Cài đặt Chế độ xem trước-Ban đêm:

```
Bật chế độ ban đêm: bật
Chân GPIO của tín hiệu từ cảm biến IR: 2
Chân GPIO1 của tín hiệu cho bộ lọc IR-cut: 1
Chân GPIO2 của tín hiệu cho bộ lọc IR-cut: 0
```

## Cấu hình độ phân giải camera:

* Luồng video chính (Video0):

```
Độ phân giải video: 1280x720
Tốc độ khung hình video: 10
```
Khi sử dụng RTSP, bạn có thể muốn tăng tốc độ khung hình ở Video0 lên 15. Tốc độ khung hình cao hơn có thể thực hiện được, nhưng trên 15 bộ nhớ sẽ chạy thấp và đột nhiên giao diện người dùng web có thể không truy cập được nữa (và có thể xảy ra các hiệu ứng không mong muốn khác).

* RTSP:

```
Bật đầu ra RTSP: bật
```

* MJPEG:

```
Độ phân giải video: 1280x720
```

* JPEG:

```
Kích thước ảnh chụp nhanh: 1280x720
```

## Cấu hình Bộ xử lý tín hiệu hình ảnh:

* Bộ xử lý tín hiệu hình ảnh (ISP):

```
Đường dẫn đến tệp cấu hình cảm biến: /etc/sensors/mt9p006_i2c_dc_720p.ini
Số khối: 4
```

## Cấu hình quản trị web:

* Hệ thống:

```
Phục vụ Quản trị Web thông qua Majestic: tắt
```

## Cấu hình watchdog:

* Watchdog:

```
Bật watchdog: bật
Thời gian chờ watchdog: 120
```

## Kiểm tra luồng MJPEG:
Ví dụ: sử dụng trình duyệt hoặc ứng dụng Android "IPCamViewer" (thay thế IP bằng IP hiện tại của bạn).

```sh
192.168.1.188/mjpeg
```

## Kiểm tra luồng RTSP:
Ví dụ: sử dụng "mpv" trên Linux hoặc ứng dụng Android "IPCamViewer". Khi sử dụng "IPCamViewer", hãy chọn "Generic RTSP over UDP" (thay thế mật khẩu và IP bằng mật khẩu và IP hiện tại của bạn).

```sh
mpv rtsp://root:12345@192.168.1.188:554/stream=0
```

## Kiểm tra xoay, nghiêng, thu phóng và lấy nét:
Hóa ra, camera sử dụng giao thức Pelco-D qua cổng nối tiếp ttyAMA1, vì vậy hãy đăng nhập vào camera qua ssh (sử dụng IP của bạn):

```sh
ssh root@192.168.1.188
```

Cổng nối tiếp có thể được cấu hình thông qua lệnh stty sau:

```sh
stty -F /dev/ttyAMA1 2400
```

Tạo các tập lệnh sau với trình soạn thảo "vi" hoặc sao chép các tệp qua tftp. Sử dụng chmod để làm cho các tệp có thể thực thi được. Ví dụ:

```sh
chmod +x ./right
```


### Tập lệnh ./right

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x02\x20\x00\x23' >/dev/ttyAMA1 
sleep 0.1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./left

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x04\x20\x00\x25' >/dev/ttyAMA1  
sleep 0.1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./up

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' > /dev/ttyAMA1 
printf '\xFF\x01\x00\x08\x20\x00\x29' > /dev/ttyAMA1 
sleep 0.1 
printf '\xFF\x01\x00\x00\x00\x00\x01' > /dev/ttyAMA1
```


### Tập lệnh ./down

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x10\x20\x00\x31' >/dev/ttyAMA1 
sleep 0.1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./in (Thu phóng)

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x20\x00\x00\x21' >/dev/ttyAMA1 
sleep 1  
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./out (Thu phóng)

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x40\x00\x00\x41' >/dev/ttyAMA1  
sleep 1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./near (Lấy nét)

```sh
#!/bin/sh
stty -F /dev/ttyAMA1 2400
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
printf '\xFF\x01\x01\x00\x00\x00\x02' >/dev/ttyAMA1 
sleep 0.1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./far (Lấy nét)

```sh
#!/bin/sh
stty -F /dev/ttyAMA1 2400
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
printf '\xFF\x01\x00\x80\x00\x00\x81' >/dev/ttyAMA1 
sleep 0.1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


### Tập lệnh ./scanh

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
sleep 0.5 
printf '\xFF\x01\x00\x04\x08\x00\x0d' >/dev/ttyAMA1
```


### Tập lệnh ./scanv

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
sleep 0.5 
printf '\xFF\x01\x00\x08\x08\x00\x11' >/dev/ttyAMA1
```


### Tập lệnh ./stop
Tập lệnh sau đây dừng mọi hành động bao gồm quét ngang và dọc. Đó là một cách giải quyết, bởi vì lệnh "dừng" Pelco-D thông thường không phải lúc nào cũng hoạt động. Hóa ra "lên", "xuống", "trái", "phải" luôn dừng các lệnh quét, vì vậy các lệnh trái + phải ngắn được bao gồm trong tập lệnh này:

```sh
#!/bin/sh 
stty -F /dev/ttyAMA1 2400 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x02\x20\x00\x23' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x04\x20\x00\x25' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x04\x20\x00\x25' >/dev/ttyAMA1 
printf '\xFF\x01\x00\x00\x00\x00\x01' >/dev/ttyAMA1
```


## Những cải tiến có thể có trong tương lai:

- Camera dường như có bo mạch PoE, nhưng dường như nó không hoạt động. Có thể có hai phiên bản (một phiên bản 12V và một phiên bản PoE) khác nhau chủ yếu ở cáp. Vì vậy, có thể camera có thể được sửa đổi để sử dụng bo mạch PoE.

- Có khe cắm thẻ nhớ SD (mặc dù chỉ có thể truy cập khi mở vỏ). Nó không hoạt động vào lúc này. Mặc dù đã có bản cập nhật firmware gốc giải quyết rõ ràng chức năng SDCard, nhưng không chắc chắn liệu nó có bao giờ hoạt động với firmware gốc hay không.

- Camera có mô-đun Wi-Fi. Có thể điều này có thể được kích hoạt thông qua OpenIPC.

- Camera có bảng thu phóng và lấy nét. Tài liệu cho bảng này tồn tại bằng tiếng Trung Quốc (có thể được dịch qua Google Dịch). Dường như có một quy trình "hiệu chuẩn nhà máy" để gán cài đặt lấy nét "tiêu chuẩn" cho các mức thu phóng.

