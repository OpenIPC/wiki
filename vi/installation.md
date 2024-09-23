# Wiki OpenIPC

[Mục lục](../README.md)

Các phương pháp cài đặt có sẵn
==============================

Rất tiếc, các nhà sản xuất camera IP **chưa** cung cấp phần cứng được cài đặt sẵn OpenIPC, vì vậy để cài đặt OpenIPC lên camera vẫn đang sử dụng hình ảnh firmware gốc, bạn phải sử dụng một trong các phương pháp sau:

* Dự án [Coupler](https://github.com/openipc/coupler/) cung cấp hình ảnh firmware có thể được cài đặt bằng cách sử dụng các cơ chế nâng cấp firmware được tích hợp trong firmware gốc của nhiều camera.

* Flash firmware OpenIPC bằng cách sử dụng bootloader [*U-Boot*](https://en.wikipedia.org/wiki/Das_U-Boot) được bao gồm trong firmware của nhà cung cấp. Phương pháp này làm gián đoạn quá trình khởi động bình thường của firmware nhà cung cấp và thay vào đó hướng dẫn U-Boot tải firmware OpenIPC qua mạng và ghi nó vào bộ nhớ flash (thay thế phần chính của firmware nhà cung cấp). **Phương pháp này yêu cầu mở vỏ camera** để kết nối [**bộ chuyển đổi UART**][FTDI] với cổng nối tiếp/gỡ lỗi "bảng điều khiển" bên trong của camera.


Cài đặt firmware OpenIPC bằng Coupler.
--------------------------------------------

Hướng dẫn sử dụng [Coupler](https://github.com/openipc/coupler/) có thể được tìm thấy trong [tài liệu của dự án](https://github.com/openipc/coupler/).

Cài đặt firmware OpenIPC qua TFTP và UART, từng bước.
--------------------------------------------------------------

### Bước 1. Xác định Hệ thống trên Chip.

SoC bao gồm lõi CPU của camera, cũng như tất cả các thiết bị ngoại vi cần thiết như giao diện camera và mạng. Vì nhiều lý do khác nhau (bao gồm không gian lưu trữ hạn chế trên hầu hết các Camera IP), dự án OpenIPC hiện đang xây dựng các tệp nhị phân firmware riêng biệt cho mỗi model SoC. **Bạn phải xác định SoC mà camera của bạn sử dụng**, để bạn có thể sử dụng đúng tệp nhị phân firmware. Điều này có thể được thực hiện bằng cách đọc các dấu hiệu trên gói IC SoC trên PCB chính của camera (xem ảnh ví dụ bên dưới) hoặc bằng cách sử dụng phần mềm như [ipctool](https://github.com/openipc/ipctool/) để xác định model SoC từ firmware của nhà cung cấp.

![Đánh dấu SoC](../images/soc-hisilicon.webp)
![Đánh dấu SoC](../images/soc-ingenic-t20.webp)
![Đánh dấu SoC](../images/soc-ingenic-t31.webp)
![Đánh dấu SoC](../images/soc-ingenic-t40.webp)

_Đánh dấu SoC Hisilicon Hi3518EV100, Ingenic T20, T31 và T40.
Các ký hiệu liên quan được đánh dấu bằng màu vàng._

### Bước 2. Cài đặt và thiết lập máy chủ TFTP.

TFTP là viết tắt của _Trivial File Transfer Protocol_. Đúng như tên gọi của nó, đây là một giao thức rất đơn giản, nhằm mục đích truyền tệp qua mạng máy tính cục bộ. TFTP không hỗ trợ xác thực. Mã của nó rất nhỏ và đơn giản nên các máy khách TFTP được sử dụng rộng rãi trong các máy khách mỏng và hệ thống nhúng để truy xuất hình ảnh có thể khởi động từ máy chủ khởi động được chỉ định trên mạng cục bộ.

#### Nếu bạn có Linux ...

... thì rất dễ dàng. Gói nhị phân được biên dịch trước và sẵn sàng sử dụng cho bản phân phối của bạn rất có thể đã tồn tại trong kho lưu trữ của bản phân phối và bạn chỉ cần cài đặt và thiết lập nó.

```bash
sudo apt install tftpd-hpa
sudo sed -i '/^TFTP_OPTIONS/s/"$/ --create"/' /etc/default/tftpd-hpa
sudo systemctl restart tftpd-hpa.service
```

> **Lưu ý**: một số người dùng đã báo cáo sự cố (hết thời gian kết nối) khi sử dụng `tftpd-hpa` với các phiên bản Ubuntu gần đây. Trong trường hợp đó, bạn có thể thử với [máy chủ TFTP thay thế](https://askubuntu.com/a/457105/1074320).

### Bước 3. Kết nối với cổng UART của camera.

Để kết nối với cổng UART, bạn sẽ cần [bộ chuyển đổi cổng nối tiếp][FTDI] cho PC của mình.

![Mô-đun UART](../images/uart-module.webp)

__Trước khi kết nối bộ chuyển đổi đó với camera của bạn, hãy đảm bảo rằng điện áp hoạt động của nó được đặt thành 3,3 volt!__ Đôi khi, bạn chỉ cần lật một jumper để đạt được điều đó. Nhưng trong một số trường hợp, bạn có thể cần phải hàn dây, điện trở zero Ohm hoặc tạo kết nối giữa hai tiếp điểm bằng một giọt hàn. Một số bộ chuyển đổi chỉ hỗ trợ 5 volt. Trong trường hợp đó, bạn sẽ cần thêm [bộ chuyển đổi mức logic][TLLC] được kết nối giữa bộ chuyển đổi và cổng UART trên camera của bạn.

Một trong những miếng tiếp xúc mà bạn sẽ cần kết nối bộ chuyển đổi của mình là GND (đất). Rất dễ dàng để khám phá bằng cách sử dụng đồng hồ vạn năng ở chế độ liên tục. Đặt một trong các dây dẫn lên miếng tiếp xúc đất lộ ra đã biết. Thông thường, đây là những khu vực tiếp xúc bằng đồng mở rộng lớn xung quanh các lỗ vít gắn, vỏ cổng USB, thành kim loại của khe cắm thẻ SD. Sử dụng dây dẫn khác để chạm nhẹ vào các miếng tiếp xúc điều khiển cho đến khi bạn nhìn thấy hoặc nghe thấy thông báo từ đồng hồ vạn năng rằng mạch đã được đóng. Điều đó có nghĩa là bạn đã tìm thấy mặt đất. Bây giờ, bạn cần tìm thêm hai điểm nữa: `RX` và `TX`, cả hai được sử dụng để nhận và truyền dữ liệu tương ứng. Bắt đầu với `TX`. Nó truyền một loạt các ký tự và khá dễ phát hiện.

Lưu ý rằng bạn đang tìm kiếm một tiếp điểm có điện thế 3,3v giữa nó và mặt đất. Kiểm tra các điểm kết nối có thể có bằng đồng hồ vạn năng và đánh dấu những điểm hiển thị 3,3 volt. Bằng cách này, bạn sẽ không phải kiểm tra mọi thứ và bạn tự cứu mình khỏi việc đánh vào, chẳng hạn như đầu nối 12 volt dành cho dãy đèn LED hồng ngoại hoặc những thứ khác.

Kết nối chân `GND` trên camera của bạn với miếng `GND` của bộ chuyển đổi, kết nối đầu nối USB của bộ chuyển đổi với cổng USB trên PC của bạn, khởi động ứng dụng giả lập terminal và kết nối với bộ chuyển đổi của bạn. Đặt cài đặt terminal của bạn thành tốc độ baud 115200 bps, 8 bit, không có parity, 1 stopbit, không kiểm soát luồng.

Dưới đây là một số dòng lệnh cho các chương trình terminal khác nhau với tính năng ghi nhật ký phiên. Chọn cái bạn thích.

#### screen

Bắt đầu phiên với

```bash
screen -L -Logfile ipcam-$(date +%s).log /dev/ttyUSB0 115200
```

Sử dụng `Ctrl-a` theo sau là `\` để thoát khỏi phiên.

#### `minicom`

Bắt đầu phiên với

```bash
minicom -b 115200 -8 --capturefile=ipcam-$(date +%s).log --color=on -D /dev/ttyUSB0
```

Sử dụng `Ctrl-a` theo sau là `x` để thoát khỏi phiên.

#### `picocom`

Bắt đầu phiên với

```bash
picocom -b 115200 --databits 8 --parity n --stopbits 1 --flow n --logfile=ipcam-$(date +%s).log /dev/ttyUSB0
```

Sử dụng `Ctrl-a` theo sau là `Ctrl-x` để thoát khỏi phiên.

#### PuTTY

Nếu bạn chọn terminal GUI, cụ thể là [PuTTY](https://www.putty.org/), thì đây là giao diện của nó:

![Màn hình cài đặt PuTTY](https://user-images.githubusercontent.com/29582865/207894192-c6f66401-7715-4aa6-bee2-8343aae6c0a9.png)
![Màn hình kết nối PuTTY](https://user-images.githubusercontent.com/29582865/209340268-e34a010c-d455-4343-ae83-0866f0f0af15.png)

Sau đó, kết nối chân `RX` trên bộ chuyển đổi với tiếp điểm `TX` có thể có của cổng UART trên camera của bạn. Cấp nguồn cho camera bằng bộ chuyển đổi nguồn OEM của nó. Nếu bạn đoán may mắn thì bạn sẽ bắt đầu thấy nhật ký khởi động trong cửa sổ terminal của mình. Trong một số trường hợp, nếu bạn thấy văn bản bị lỗi trên màn hình thay vì kernel khởi động, bạn có thể cần thay đổi tốc độ kết nối thành 57600 bps và thử lại.

Nếu màn hình của bạn vẫn trống, hãy thử tiếp điểm UART khác, rồi tiếp điểm khác, cho đến khi bạn nhấn đúng điểm.

Sau khi bạn tìm thấy miếng `TX`, hãy kết nối nó với chân `RX` trên bộ chuyển đổi của bạn. Đúng vậy, đó là một kết nối chéo. Bất cứ thứ gì truyền đi sẽ đi vào bộ thu và ngược lại. Bây giờ, hãy đặt một vật nặng - một đai ốc đường sắt, một hộp thiếc hàn cổ, một ly vodka (đầy) - lên bất kỳ phím chữ nào trên bàn phím máy tính của bạn và bắt đầu kết nối chân `TX` còn lại của bộ chuyển đổi của bạn với các miếng khác nhau trên camera cho đến khi bạn thấy nó phản hồi lại terminal. Khi điều đó xảy ra, bạn đã kết nối UART thành công với camera của mình. Bây giờ bạn có thể uống vodka.

Lưu ý! Thông thường, có một tiếp điểm thứ tư trên đầu nối UART được đánh dấu `VCC`. Nó được sử dụng để cấp nguồn cho camera trong quá trình lập trình ban đầu bởi nhà sản xuất. Chúng tôi khuyên bạn không nên cấp nguồn cho camera của mình thông qua chân đó mà hãy sử dụng đầu nối nguồn OEM cho mục đích này.

### Bước 4. Truy cập bootloader.

Khởi động lại camera và thử làm gián đoạn trình tự khởi động của nó để truy cập bảng điều khiển bootloader bằng cách nhấn tổ hợp phím trên bàn phím máy tính của bạn, giữa thời điểm bootloader khởi động và trước khi kernel Linux khởi động. Các tổ hợp phím khác nhau tùy theo nhà cung cấp nhưng trong hầu hết các trường hợp, đó là `Ctrl-C`, ít phổ biến hơn là `Enter`, `Esc`, `*` hoặc bất kỳ phím nào. Đọc kỹ văn bản xuất hiện trên màn hình trong khi khởi động, bạn có thể thấy gợi ý ở đó. Một số camera yêu cầu các tổ hợp kỳ lạ hơn không được tiết lộ trong nhật ký khởi động. Bạn có thể thử tra cứu chúng trên internet hoặc hỏi trên [kênh Telegram của chúng tôi][telegram]. Rất có thể, chúng tôi đã xử lý một chiếc camera như vậy và biết tổ hợp đó.

Nếu bạn thành công và nhận được dấu nhắc lệnh thì xin chúc mừng, bạn đã có quyền truy cập vào bootloader của camera.

Từ thời điểm này trở đi, chúng tôi khuyên bạn nên ghi lại mọi thứ bạn làm. Bật ghi nhật ký phiên trong terminal của bạn. Tốt hơn nữa, hãy tạo một tệp văn bản trên máy tính của bạn và ghi lại tất cả các lệnh bạn chạy và cách hệ thống phản hồi với chúng.

### Bước 5. Xác định dung lượng bộ nhớ flash.

Hầu hết các camera IP ngày nay đều được trang bị bộ nhớ flash NOR hoặc NAND 8 hoặc 16 MB. Bạn có thể kiểm tra loại và dung lượng của chip được cài đặt trên camera của mình trong đầu ra nhật ký bootloader. Bạn sẽ thấy một cái gì đó như thế này:

```console
U-Boot 2010.06-svn (21 tháng 10 năm 2016 - 11:21:29)

Kiểm tra Bộ điều khiển bộ nhớ Flash v100 ... Đã tìm thấy
SPI Nor(cs 0) ID: 0xс2 0x20 0x18
spi_general_qe_enable(294): Lỗi: Tắt Quad không thành công! reg: 0x2
Khối: 64KB Chip: 16MB Tên: "MX25L128XX"
Tổng kích thước SPI Nor: 16MB
```

Một ví dụ khác:

```console
U-Boot 2013.07 (27 tháng 2 năm 2019 - 02:05:08)

DRAM:  64 MiB
MMC:   msc: 0
SF: Đã phát hiện EN25QH64
```

Điều này cho thấy model bộ nhớ flash (`EN25QH64`) mà bạn có thể tra cứu trực tuyến để tìm bảng dữ liệu. Ngoài ra, `64` trong số model gợi ý cho bộ nhớ 64 Megabit, tương đương với 8MB. Tương tự, `128` sẽ tương đương với 16MB.

Bạn cũng có thể xác định model của bộ nhớ flash bằng cách tra cứu trên bảng mạch, nhưng đây thường là một nhiệm vụ khó khăn vì các chip rất nhỏ và có thể không đi kèm với các dấu hiệu rõ ràng.

### Bước 6. Lưu firmware gốc.

Sau khi bạn truy cập vào bảng điều khiển bootloader, hãy chạy `help` để nhận danh sách các lệnh khả dụng. Kiểm tra xem bạn có `tftp` trong số đó hay không. Nếu có, thì việc lưu firmware gốc sẽ rất dễ dàng. Bạn chỉ cần thiết lập quyền truy cập vào máy chủ TFTP của mình từ bước 2.

Lưu ý! Nếu bootloader của bạn không có `tftp`, bạn vẫn có thể tạo bản sao của firmware gốc. [Đọc thêm tại đây](help-uboot.md).

Kiểm tra môi trường hệ thống bằng lệnh `printenv`. Tìm kiếm các tham số `ipaddr`, `netmask`, `gatewayip` và `serverip`. Ba tham số đầu tiên đặt địa chỉ IP, netmask của camera và địa chỉ IP của cổng mạng để truy cập mạng cục bộ. Tham số thứ tư là địa chỉ IP của máy chủ TFTP của bạn. Gán các giá trị bằng lệnh `setenv` (sử dụng địa chỉ IP và netmask tương ứng với mạng cục bộ của bạn), sau đó lưu các giá trị mới vào môi trường bằng lệnh `saveenv`.

```bash
setenv ipaddr 192.168.1.253
setenv netmask 255.255.255.0
setenv gatewayip 192.168.1.1
setenv serverip 192.168.1.254
saveenv
```

Để dump firmware gốc, bạn cần lưu nội dung bộ nhớ flash của camera vào một tệp. Đối với điều đó, trước tiên bạn phải tải nội dung vào RAM. Đây là cách bạn thực hiện điều đó. Khởi tạo bộ nhớ Flash. Làm sạch một vùng RAM đủ lớn để chứa toàn bộ nội dung của chip bộ nhớ flash. Đọc nội dung của flash vào vùng đó, sau đó xuất nó sang một tệp trên máy chủ TFTP.

Xin lưu ý rằng loại flash, kích thước và địa chỉ bắt đầu khác nhau đối với các camera khác nhau! Để biết các lệnh chính xác, vui lòng sử dụng [hướng dẫn được tạo tự động](https://openipc.org/supported-hardware/) cho phần cứng của bạn, tham khảo bảng dữ liệu hoặc tìm kiếm trợ giúp trên [kênh Telegram của chúng tôi][telegram].

### Bước 7. Cài đặt firmware OpenIPC.

#### Mở đầu.

Không có hai model camera nào giống nhau. Các model camera khác nhau bao gồm các bộ phận khác nhau. Quan trọng nhất trong số đó, bộ xử lý trung tâm và cảm biến hình ảnh, ảnh hưởng trực tiếp đến chất lượng hình ảnh và phạm vi chức năng vốn có của một camera cụ thể. Không giống như CPU máy tính để bàn, bộ xử lý của camera xử lý rất nhiều chức năng nên nó có một tên cụ thể -- Hệ thống trên Chip hoặc SoC, viết tắt.

Nhưng ngay cả các thành phần dường như ít quan trọng hơn cũng có thể đặt ra giới hạn cho camera và khả năng của firmware. Ví dụ: các camera khác nhau có thể có các chip bộ nhớ flash khác nhau được cài đặt. Một số camera có thể có 8MB bộ nhớ flash, trong khi những camera khác có thể có 16MB trở lên. Nhiều bộ nhớ flash có thể chứa nhiều mã phần mềm hơn và cho phép camera chạy các dịch vụ bổ sung không có sẵn trên camera có ít bộ nhớ flash hơn. Vì vậy, chúng tôi quyết định xây dựng hai phiên bản firmware của mình: phiên bản cơ bản (_Lite_) cho camera có bộ nhớ flash 8 MB và phiên bản nâng cao (_Ultimate_) với các tính năng bổ sung cho camera có bộ nhớ flash 16 MB.

Như đã nói trước đây, quy trình cài đặt firmware khác nhau đối với các camera khác nhau. Có các địa chỉ bộ nhớ khác nhau và các tham số môi trường khác nhau, vì vậy trước khi tiếp tục, hãy xác định loại SoC nào có trong camera của bạn, cảm biến nào, chip bộ nhớ flash nào và dung lượng bộ nhớ của nó.

Dưới đây, chúng tôi mô tả quy trình cài đặt firmware OpenIPC Lite trên camera có bộ nhớ flash 8 MB, làm ví dụ. Ngay cả khi camera của bạn có bộ nhớ flash lớn hơn, đừng bỏ qua phần văn bản này. Đọc kỹ để hiểu nguyên tắc và trình tự các thao tác. Chúng tôi sẽ cung cấp các lệnh cụ thể cho các camera khác nhau trong phần thứ hai của phần này.

#### Chuẩn bị firmware và máy chủ TFTP.

Truy cập <https://openipc.org/supported-hardware>, tìm SoC của bạn trong bảng phần cứng được hỗ trợ. Đảm bảo rằng có tệp nhị phân có thể tải xuống cho SoC đó. Hy vọng rằng có một tệp firmware được biên dịch trước cho bộ xử lý của bạn -- hãy tải xuống PC của bạn.

Nếu bạn đã làm theo bước 2, bạn đã có máy chủ TFTP của riêng mình phục vụ các tệp từ thư mục `/srv/tftp`. Giải nén các tệp từ gói bạn vừa tải xuống vào thư mục đó.

```bash
sudo tar -C /srv/tftp/ -xvf openipc.*.tgz
```

#### Chuẩn bị camera để flash.

Vì vậy, chúng ta có một con chuột lang, một chiếc camera có SoC hi3518ev100, được trang bị cảm biến OV9712, RAM 64 MB và bộ nhớ flash NOR 8MB.

Kết nối với camera qua cổng UART và truy cập bảng điều khiển bootloader. Đặt các tham số thành phần cho các biến môi trường thích hợp. Đặt các biến môi trường để tải kernel Linux và hệ thống tệp gốc của firmware mới. Đặt các biến môi trường để camera truy cập mạng cục bộ, trong đó `ethaddr` là địa chỉ MAC gốc của camera, `ipaddr` là địa chỉ IP của camera trên mạng, `gatewayip` là địa chỉ IP của bộ định tuyến để truy cập mạng, `netmask` là mặt nạ mạng con và `serverip` là địa chỉ IP của máy chủ TFTP từ bước 3. Lưu các giá trị đã cập nhật vào bộ nhớ flash.

Để biết các lệnh chính xác, vui lòng sử dụng [hướng dẫn được tạo tự động](https://openipc.org/supported-hardware/) cho phần cứng của bạn, tham khảo bảng dữ liệu hoặc tìm kiếm trợ giúp trên [kênh Telegram của chúng tôi][telegram].

#### Cài đặt.

Để biết các lệnh chính xác, vui lòng sử dụng [hướng dẫn được tạo tự động](https://openipc.org/supported-hardware/) cho phần cứng của bạn, tham khảo bảng dữ liệu hoặc tìm kiếm trợ giúp trên [kênh Telegram của chúng tôi][telegram].

Lưu ý! Hãy chú ý đến các thông báo trên màn hình terminal! Nếu bất kỳ lệnh nào gây ra lỗi, hãy tìm hiểu xem điều gì đã xảy ra. Có thể bạn đã gõ sai chính tả? Trong mọi trường hợp, không tiếp tục quy trình cho đến khi tất cả các lệnh trước đó thành công. Nếu không, bạn có thể sẽ kết thúc với một chiếc camera bị brick!

### Bước 8. Khởi động lần đầu.

Nếu tất cả các bước trước đó được thực hiện chính xác, camera của bạn sẽ khởi động với firmware mới. Chào mừng bạn đến với OpenIPC!

Sau khi khởi động lần đầu với firmware mới, bạn cần dọn dẹp phân vùng lớp phủ. Chạy lệnh này trong cửa sổ terminal của bạn:

```bash
firstboot
```

[logo]: ../images/logo_openipc.png
[FTDI]: https://www.google.com/search?q=ftdi+usb+ttl
[TLLC]: https://google.com/search?q=logic+level+converter+3.3v+5v
[telegram]: https://t.me/OpenIPC
