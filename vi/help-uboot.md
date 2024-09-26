# Wiki OpenIPC
[Mục lục](../README.md)

Trợ giúp: U-Boot
------------

### Chuẩn bị môi trường
Trong shell của bootloader, kiểm tra xem biến `baseaddr` đã được định nghĩa chưa.

```bash
printenv baseaddr
```

Nếu nó không có ở đó, hãy tự thiết lập.

```bash
# Tra cứu địa chỉ cho SoC của bạn tại https://openipc.org/supported-hardware/
setenv baseaddr 0x80600000
```

Gán kích thước hex của chip flash của bạn cho một biến có tên là `flashsize`.

```bash
# Sử dụng 0x800000 cho chip flash 8MB, 0x1000000 cho 16MB.
setenv flashsize 0x800000
```

Lưu các giá trị này vào môi trường sau đó.

```bash
saveenv
```

### Lưu firmware gốc mà không cần sử dụng TFTP.

Trước khi bạn bắt đầu, [chuẩn bị môi trường](#prepare-the-environment).

Trong chương trình terminal mà bạn sử dụng để kết nối với cổng UART, hãy bật tính năng lưu tệp nhật ký của phiên làm việc. Tôi thích sử dụng `screen` cho việc này và lệnh của tôi để kết nối với bộ chuyển đổi UART với việc ghi nhật ký phiên làm việc vào một tệp sẽ trông như thế này:

```bash
screen -L -Logfile fulldump.log /dev/ttyUSB0 115200
```

Sau khi kết nối với bảng điều khiển bootloader, hãy chạy một tập hợp các lệnh để đọc toàn bộ dữ liệu từ chip bộ nhớ flash vào RAM, sau đó xuất nó dưới dạng các giá trị thập lục phân vào cửa sổ terminal.

```shell
mw.b ${baseaddr} 0xff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
md.b ${baseaddr} ${flashsize}
```

Vì quá trình đọc sẽ mất một khoảng thời gian đáng kể (theo đúng nghĩa đen là hàng giờ), bạn có thể muốn ngắt kết nối khỏi phiên làm việc terminal để tránh các lần nhấn phím vô tình làm nhiễm bẩn đầu ra. Nhấn `Ctrl-a` theo sau là `d` để tách phiên làm việc khỏi terminal đang hoạt động. Chạy `screen -r` khi bạn cần kết nối lại sau, sau khi kích thước của tệp nhật ký ngừng tăng. Việc đọc bộ nhớ flash 8 MB sẽ tạo ra tệp nhật ký ~ 40 MB và đối với chip 16 MB, tệp sẽ có kích thước gấp đôi.

Chuyển đổi kết xuất hex thành tệp firmware nhị phân và sử dụng nó để nghiên cứu thêm hoặc khôi phục camera về trạng thái ban đầu.

```bash
cat fulldump.log | sed -E "s/^[0-9a-f]{8}\b: //i" | sed -E "s/ {4}.{16}\r?$//" > fulldump.hex
xxd -revert -plain fulldump.hex fulldump.bin
```

Sử dụng [binwalk](https://github.com/ReFirmLabs/binwalk) để giải nén tệp nhị phân.

### Lưu firmware qua thẻ SD.

Trước khi bạn bắt đầu, [chuẩn bị môi trường](#prepare-the-environment).

Đôi khi camera của bạn chỉ có kết nối không dây, không hoạt động trực tiếp từ bootloader. Rất thường xuyên những camera như vậy có khe cắm thẻ nhớ microSD. Trong trường hợp này, bạn có thể thử lưu một bản sao của firmware gốc bằng cách sử dụng thẻ SD làm phương tiện trung gian.

Vì bạn sẽ lưu firmware ở dạng nhị phân, nên lượng dữ liệu sẽ là 8 MB hoặc 16 MB, tùy thuộc vào kích thước của chip bộ nhớ flash của camera. Vì vậy, bất kỳ thẻ SD nào cũng được, kể cả thẻ nhỏ nhất.

Lắp thẻ vào khe cắm thẻ trên camera, kết nối bộ chuyển đổi nối tiếp với cổng UART, cấp nguồn cho camera và dừng quá trình khởi động để vào bảng điều khiển bootloader.

Khởi tạo quyền truy cập vào thẻ và xóa một số dung lượng để lưu firmware. Dữ liệu được ghi lên thẻ theo khối 512 byte. Bạn cần xóa 16384 khối để xóa 8 MB, 32768 khối cho 16 MB, tương ứng là 0x4000 và 0x8000 thập lục phân.

Lưu ý rằng chúng ta sẽ ghi trực tiếp vào các thanh ghi thẻ, bỏ qua bảng phân vùng. Để tránh xung đột khi truy cập dữ liệu thẻ sau này từ PC của bạn, hãy offset 8 kilobyte từ đầu thẻ (8 * 1024 = 8192 byte hoặc 16 khối 512 byte, hoặc 0x10 khối ở dạng thập lục phân).

Ví dụ cho 8MB:

```shell
mmc dev 0
mmc erase 0x10 0x4000
```

Ví dụ cho 16MB:

```shell
mmc dev 0
mmc erase 0x10 0x8000
```

Bây giờ bạn cần sao chép nội dung của firmware từ chip bộ nhớ flash sang RAM của camera. Để làm điều đó, hãy xóa một phần RAM (0x800000 byte cho chip 8MB hoặc 0x1000000 byte cho chip 16MB), đọc bộ nhớ flash và sao chép toàn bộ nội dung vào không gian đã chuẩn bị trong RAM. Sau đó xuất dữ liệu đã sao chép từ RAM sang thẻ.

Ví dụ cho 8MB:

```shell
mw.b ${baseaddr} ff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}

mmc write ${baseaddr} 0x10 0x4000
```

Một ví dụ khác, cho 16MB:

```shell
mw.b ${baseaddr} ff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}

mmc write ${baseaddr} 0x10 0x8000
```

Tháo thẻ ra khỏi camera và lắp vào máy tính chạy Linux. Sử dụng lệnh `dd` để sao chép dữ liệu từ thẻ sang tệp nhị phân trên máy tính.

Ví dụ cho 8MB:

```bash
sudo dd bs=512 skip=16 count=16384 if=/dev/sdc of=./fulldump.bin
```

Ví dụ cho 16MB:

```bash
sudo dd bs=512 skip=16 count=32768 if=/dev/sdc of=./fulldump.bin
```

### Tải lên ảnh nhị phân qua kết nối nối tiếp.

Có những camera chỉ có kết nối không dây không khả dụng trực tiếp từ bootloader. Hầu hết các camera như vậy cũng có khe cắm thẻ SD nhưng một số thì không, hoặc nó không hoạt động vì lý do nào đó, hoặc bạn không có thẻ, hoặc đại loại như vậy. Dù sao, bạn vẫn có thể tải lên ảnh nhị phân lên camera và chạy nó hoặc lưu nó vào bộ nhớ flash. Đây là cách thực hiện.

Trước hết, bạn sẽ cần cài đặt gói `lrzsz` trên máy tính để bàn của mình. Tôi đoán nó chạy Linux và tốt nhất là thuộc họ Debian, điều đó sẽ dễ dàng hơn trên các ví dụ. Vì vậy, hãy chạy lệnh này để đáp ứng các điều kiện tiên quyết:

```bash
apt install lrzsz
```

Bây giờ bạn đã sẵn sàng.

Đặt tệp nhị phân mà bạn định tải lên vào cùng thư mục mà bạn sẽ bắt đầu phiên `screen` đến camera của mình. Bắt đầu phiên và khởi động vào bảng điều khiển bootloader bằng cách ngắt quy trình khởi động bằng tổ hợp phím.

Bây giờ bạn có thể chạy `help` và kiểm tra xem các giao thức truyền dữ liệu nào được hỗ trợ bởi phiên bản bootloader của bạn. Nếu bạn thấy `loady` trong danh sách các lệnh, thì bạn có thể sử dụng giao thức ymodem. Chạy `loady` trên camera của bạn, sau đó nhấn `Ctrl-a` theo sau là `:` (dấu hai chấm). Nó sẽ chuyển bạn vào dòng lệnh ở dưới cùng của màn hình.

Nhập `exec !! sz --ymodem filename.bin` trong đó _filename.bin_ là tên tệp của bạn và xem tệp của bạn được tải lên qua kết nối nối tiếp. Ở tốc độ 115200 bps. Chậm, rất chậm.

Sau khi tệp được tải lên, bạn có thể thực hiện phép thuật thông thường. Hoặc khởi động từ ảnh bộ nhớ ngay lập tức bằng cách sử dụng `bootm`, hoặc ghi nó vào bộ nhớ flash.

### Flash toàn bộ ảnh qua kết nối nối tiếp

Trước khi bạn bắt đầu, [chuẩn bị môi trường](#prepare-the-environment).

Tải xuống firmware nhị phân đầy đủ cho SoC và chip flash của bạn từ [trang web OpenIPC](https://openipc.org/supported-hardware/) sau khi gửi biểu mẫu cài đặt và nhấp vào liên kết ẩn dưới nút "Phương pháp thay thế".

![](../images/firmware-full-binary-link.webp)

Mở `screen` và kết nối với cổng UART.

```bash
screen /dev/ttyUSB0 115200
```

Đăng nhập vào shell bootloader và chạy:

```shell
mw.b ${baseaddr} 0xff ${flashsize}
loady ${baseaddr}
```

nhấn "Ctrl-a" theo sau là ":", sau đó nhập

```bash
exec !! sz --ymodem fullimage.bin
```

sau khi ảnh được tải, tiếp tục

```shell
sf probe 0
sf erase 0x0 ${flashsize}
sf write ${baseaddr} 0x0 ${filesize}
```

### Flash toàn bộ ảnh từ TFTP

Trước khi bạn bắt đầu, [chuẩn bị môi trường](#prepare-the-environment).

Tải xuống [firmware nhị phân đầy đủ cho SoC của bạn](https://openipc.org/supported-hardware/) và đặt nó vào thư mục gốc của máy chủ TFTP cục bộ của bạn.

Bắt đầu phiên và khởi động vào bảng điều khiển bootloader bằng cách ngắt quy trình khởi động bằng tổ hợp phím. Khi ở trong bảng điều khiển, hãy thiết lập các tham số của mạng cục bộ của bạn, nếu cần.

```bash
setenv ipaddr 192.168.1.10
setenv netmask 255.255.255.0
setenv gatewayip 192.168.1.1
setenv serverip 192.168.1.254
```

Sử dụng các lệnh sau để flash lại camera của bạn bằng hình ảnh đầy đủ:

Ví dụ cho 8MB:

```shell
mw.b ${baseaddr} 0xff ${flashsize}
tftpboot ${baseaddr} openipc-${soc}-lite-8mb.bin
sf probe 0; sf erase 0x0 ${flashsize}; sf write ${baseaddr} 0x0 ${filesize}
reset
```

Ví dụ cho 16MB:

```shell
mw.b ${baseaddr} 0xff ${flashsize}
tftpboot ${baseaddr} openipc-${soc}-ultimate-16mb.bin
sf probe 0; sf erase 0x0 ${flashsize}; sf write ${baseaddr} 0x0 ${filesize}
reset
```

Ở lần khởi động đầu tiên, hãy đăng nhập vào shell bootloader một lần nữa và ánh xạ lại phân vùng bằng cách chạy lệnh `run setnor16m`.

### Đọc ảnh nhị phân từ thẻ SD.

Trước khi bạn bắt đầu, [chuẩn bị môi trường](#prepare-the-environment).

Nếu camera của bạn hỗ trợ thẻ SD và bạn có lệnh `fatload` trong bootloader, thì bạn có thể đọc các tệp nhị phân firmware từ thẻ SD.

Đầu tiên, chuẩn bị thẻ: định dạng nó thành hệ thống tệp FAT và đặt bootloader, kernel và tệp nhị phân rootfs vào đó. Lắp thẻ vào camera và khởi động vào bảng điều khiển bootloader.

Kiểm tra xem bạn có quyền truy cập vào thẻ hay không.

```bash
mmc rescan
```

Sau đó, mở khóa quyền truy cập vào bộ nhớ flash và bắt đầu ghi nội dung của các tệp từ thẻ vào bộ nhớ flash.

Lưu ý! Xin lưu ý rằng địa chỉ tải và tên của các tệp được sử dụng trong ví dụ này không nhất thiết phải khớp với địa chỉ tải và tên của các tệp cho camera cụ thể của bạn. Tham khảo tài liệu hoặc tìm kiếm sự trợ giúp trên [kênh Telegram của chúng tôi][telegram].

Flash bootloader.

```shell
mw.b ${baseaddr} 0xff 0x50000
sf probe 0
sf erase 0x0 0x50000
fatload mmc 0:1 ${baseaddr} u-boot-with-spl.bin
sf write ${baseaddr} 0x0 ${filesize}
```

Flash kernel.

```shell
mw.b ${baseaddr} 0xff 0x200000
sf probe 0
sf erase 0x50000 0x200000
fatload mmc 0:1 ${baseaddr} uImage.${soc}
sf write ${baseaddr} 0x50000 ${filesize}
```

Flash hệ thống tệp gốc.

```shell
mw.b ${baseaddr} 0xff 0x500000
sf probe 0
sf erase 0x250000 0x500000
fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc}
sf write ${baseaddr} 0x250000 ${filesize}
```

### Vượt qua bootloader được bảo vệ bằng mật khẩu.

Thay đổi bootloader là một thao tác rủi ro. Có khả năng cao biến camera của bạn thành cục chặn giấy nếu có sự cố xảy ra. Vì vậy, trước khi bạn flash bootloader mới, bạn phải cân nhắc tất cả các rủi ro và lợi ích. Trong hầu hết các trường hợp, bootloader gốc cộng với kernel mới và hệ điều hành mới sẽ hoạt động tốt. Nhưng có những trường hợp ngoại lệ.

#### Chập các chân trên chip flash

Nếu bạn không thể ngắt trình tự khởi động bằng tổ hợp phím hoặc nếu camera của bạn yêu cầu mật khẩu bootloader mà bạn không biết, bạn vẫn có thể khiến nó dừng khởi động kernel Linux và đưa bạn vào shell.

Điều đầu tiên cần làm là xác định vị trí chip bộ nhớ flash trên bảng mạch camera. Thông thường đây là một chip vuông có 8 chân được dán nhãn 25Q64 hoặc 25Q128, hiếm khi là 25L64 hoặc 25L128. Nếu bạn gặp sự cố khi xác định vị trí chip, hãy thử chụp một số ảnh bảng của bạn từ cả hai phía. Sau đó, hãy yêu cầu trợ giúp [trong kênh Telegram của chúng tôi](https://t.me/openipc).
__Không cố gắng làm đoản mạch bất kỳ chip ngẫu nhiên nào! Nó rất có thể sẽ làm cháy mạch camera của bạn.__

Làm đoản mạch các chân 5 và 6 của chip flash bằng một vật kim loại nhỏ, tua vít hoặc nhíp, ngay sau khi bootloader khởi động nhưng trước khi nó gọi kernel Linux.

Các chân 5 và 6 của chip SOIC8 nằm ở góc đối diện với chân 1, được biểu thị bằng dấu chấm nổi hoặc vẽ bên cạnh nó.

![](../images/flash-pins.webp)
![](../images/flash-pins-2.webp)

[Bài viết chi tiết về thủ thuật này](https://cybercx.co.nz/bypassing-bios-password/) hoặc phiên bản [đã lưu trữ](https://github.com/OpenIPC/wiki/blob/master/en/help-uboot.md#bypassing-password-protected-bootloader) của bài viết

#### Hạ cấp firmware gốc.

Ngày nay, chúng ta thấy ngày càng nhiều camera có quyền truy cập vào bảng điều khiển bootloader được bảo vệ bằng mật khẩu. Do đó, ngay cả khi bạn kết nối với cổng UART của camera, tất cả những gì bạn sẽ thấy sau khi ngắt chu kỳ khởi động tiêu chuẩn là lời nhắc nhập mật khẩu. Trong trường hợp đó, một giải pháp tương đối an toàn là hạ cấp firmware xuống phiên bản mà tính năng bảo vệ bằng mật khẩu chưa được triển khai. Ví dụ: đối với camera Xiongmai, tính năng bảo vệ bằng mật khẩu bootloader bắt đầu xuất hiện ở đâu đó vào khoảng tháng 7 năm 2021, do đó bạn cần firmware cho camera của mình từ ngày trước đó. Sau khi bạn hạ cấp thành công camera của mình xuống bootloader không có mật khẩu, bạn có thể cài đặt firmware OpenIPC theo cách thông thường.

#### Tải phụ bootloader đã mở khóa.

Nhiều camera hiện đại sử dụng giao thức fastboot cho phép camera tải mã nhị phân bootloader trực tiếp vào bộ nhớ và sau đó chạy nó từ đó. Kiểm tra xem [tiện ích ghi][burn] của chúng tôi có hỗ trợ SoC của camera của bạn hay không.

#### Sửa đổi firmware gốc.

Một cách để vượt qua bảo vệ bootloader là xuất firmware gốc và thay thế bootloader ở đó bằng một lựa chọn thay thế đã mở khóa. Hoặc bạn có thể flash toàn bộ firmware OpenIPC vì dù sao bạn cũng có chip trong bộ nạp.

__ĐỪNG QUÊN SAO LƯU FIRMWARE GỐC CỦA BẠN!__

## Khắc phục sự cố

Trước khi bạn bắt đầu, [chuẩn bị môi trường](#prepare-the-environment).

Nếu bạn gặp lỗi `Too many args` (quá nhiều đối số) trong khi cố gắng đặt biến môi trường, hãy thử làm điều đó từ trong Linux bằng cách sử dụng `fw_setenv` thay vì `setenv` trong U-boot.

__Bảng điều khiển U-boot:__

```shell
hisilicon # setenv uk 'mw.b ${baseaddr} 0xff ${flashsize}; tftp ${baseaddr} uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}'
** Too many args (max. 16) **
```

__OpenIPC Linux:__

```shell
root@openipc-hi3518ev100:~# fw_setenv uk 'mw.b ${baseaddr} 0xff ${flashsize}; tftp ${baseaddr} uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}'
```

[burn]: https://github.com/OpenIPC/burn
[telegram]: https://t.me/OpenIPC