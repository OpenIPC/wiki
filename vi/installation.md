# Wiki OpenIPC

[Bảng nội dung](../README.md)

Phương pháp cài đặt hiện có
==============================

Rất tiếc, các nhà sản xuất camera IP **chưa** giao hàng với
OpenIPC được cài đặt sẵn, vì vậy để cài đặt OpenIPC lên một chiếc camera vẫn đang sử dụng
hình ảnh firmware gốc, một trong những phương pháp sau đây phải được sử dụng:

* Dự án [Coupler](https://github.com/openipc/coupler/) cung cấp
  hình ảnh firmware có thể được cài đặt bằng cách sử dụng cơ chế nâng cấp firmware
  được tích hợp sẵn vào firmware gốc của nhiều camera.

* Ghi firmware OpenIPC sử dụng 
  bootloader [*U Boot*](https://en.wikipedia.org/wiki/Das_U-Boot) được bao gồm trong
  firmware của nhà cung cấp. Phương pháp này ngắt quá trình khởi động bình thường của firmware
  của nhà cung cấp, và thay vào đó hướng dẫn U-Boot tải firmware OpenIPC
  qua mạng, và ghi nó vào bộ nhớ flash (thay thế phần chính
  của firmware của nhà cung cấp). **Phương pháp này yêu cầu vỏ camera phải
  được mở** để kết nối một [**bộ chuyển đổi UART**][FTDI] với cổng "console" nội bộ
  /cổng debug của camera.


Cài đặt firmware OpenIPC sử dụng Coupler.
--------------------------------------------
Hướng dẫn sử dụng [Coupler](https://github.com/openipc/coupler/) có thể được
tìm thấy trong [tài liệu của dự án](https://github.com/openipc/coupler/).

Cài đặt firmware OpenIPC qua TFTP và UART, từng bước một.
--------------------------------------------------------------

### Bước 1. Xác định Hệ thống trên Chip.

Hệ thống trên Chip (SoC) bao gồm lõi CPU của camera, cũng như tất cả các phụ kiện
cần thiết như giao diện camera và mạng. Vì nhiều lý do
(bao gồm không gian lưu trữ onboard hạn chế trên hầu hết các Camera IP), dự án OpenIPC
hiện tại xây dựng các tệp nhị phân firmware riêng biệt cho mỗi mô hình SoC. **Bạn
phải xác định SoC mà camera của bạn sử dụng**, để bạn có thể sử dụng đúng
tệp nhị phân firmware. Điều này có thể được thực hiện bằng cách đọc các dấu hiệu trên gói IC SoC
trên PCB chính của camera (xem hình ảnh mẫu dưới đây), hoặc bằng cách sử dụng
phần mềm như [ipctool](https://github.com/openipc/ipctool/) để xác định
mô hình SoC từ firmware của nhà cung cấp.

![Dấu hiệu SoC](../images/soc-hisilicon.webp)
![Dấu hiệu SoC](../images/soc-ingenic-t20.webp)
![Dấu hiệu SoC](../images/soc-ingenic-t31.webp)
![Dấu hiệu SoC](../images/soc-ingenic-t40.webp)

_Dấu hiệu SoC Hisilicon Hi3518EV100, Ingenic T20, T31 và T40.
Các biểu tượng liên quan được đánh dấu bằng màu vàng._

### Bước 2. Cài đặt và thiết lập một máy chủ TFTP.

TFTP là viết tắt của _Trivial File Transfer Protocol_. Như tên gọi, đây là một
giao thức rất đơn giản dành cho việc chuyển tệp qua mạng máy tính cục bộ. TFTP không hỗ trợ xác thực. Mã của nó rất nhỏ gọn và đơn giản
đến nỗi các khách hàng TFTP được sử dụng rộng rãi trong các thin-client và hệ thống nhúng để
lấy các hình ảnh khởi động từ một máy chủ khởi động được chỉ định trên mạng cục bộ.

#### Nếu bạn đang sử dụng Linux...

...thì việc này rất dễ dàng. Có thể đã có gói nhị phân đã được biên dịch và sẵn sàng sử dụng cho hệ điều hành của bạn
trong kho lưu trữ của hệ điều hành, và bạn chỉ cần cài đặt nó và
thiết lập.

```bash
sudo apt install tftpd-hpa
sudo sed -i '/^TFTP_OPTIONS/s/"$/ --create"/' /etc/default/tftpd-hpa
sudo systemctl restart tftpd-hpa.service
```

> **Lưu ý**: Một số người dùng đã báo cáo vấn đề (thời gian chờ kết nối) khi sử dụng
`tftpd-hpa` với các phiên bản gần đây của Ubuntu. Trong trường hợp đó, bạn có thể thử với một
[máy chủ TFTP thay thế](https://askubuntu.com/a/457105/1074320).
### Bước 3. Kết nối với cổng UART của camera của bạn.

Để kết nối với cổng UART, bạn sẽ cần một
[bộ chuyển đổi cổng nối tiếp][FTDI] cho máy tính của bạn.

![Mô-đun UART](../images/uart-module.webp)

__Trước khi bạn kết nối bộ chuyển đổi này với camera của bạn, hãy đảm bảo rằng
điện áp hoạt động của nó được đặt ở 3.3 volt!__
Đôi khi, bạn chỉ cần lật một jumper để đạt được điều đó. Nhưng trong một số trường hợp, bạn
có thể cần hàn một dây, một điện trở không Ohm, hoặc tạo một kết nối giữa
hai tiếp xúc với một khối hàn. Một số bộ chuyển đổi chỉ hỗ trợ 5 volt. Trong trường hợp đó, bạn sẽ cần thêm một [bộ chuyển đổi mức logic][TLLC] kết nối
giữa bộ chuyển đổi và cổng UART trên camera của bạn.

Một trong những tiếp xúc mà bạn cần kết nối bộ chuyển đổi của mình là GND (mặt đất).
Nó dễ dàng khám phá bằng cách sử dụng đồng hồ đo điện tử ở chế độ liên tục. Đặt một trong các
dẫn vào các tiếp xúc mặt đất đã biết. Thông thường, đây là các khu vực tiếp xúc đồng lớn mở xung quanh lỗ ốc vít gắn kết, vỏ cổng USB, tường kim loại của khe cắm thẻ SD. Sử dụng dẫn khác để chạm nhẹ vào các tiếp xúc kiểm soát cho đến khi bạn thấy hoặc
nghe một thông báo từ đồng hồ đo điện tử của bạn rằng mạch đã đóng. Điều đó có nghĩa là,
bạn đã tìm thấy mặt đất. Bây giờ, bạn cần tìm thêm hai: `RX` và `TX`, cả hai đều được
sử dụng để nhận và truyền dữ liệu, tương ứng. Bắt đầu với `TX`. Nó truyền
chuỗi các ký tự và rất dễ nhận biết.

Hãy nhận biết rằng bạn đang tìm kiếm một tiếp xúc với tiềm năng 3.3v giữa nó và
mặt đất. Kiểm tra các điểm kết nối có thể với đồng hồ đo điện tử và đánh dấu những
hiển thị 3.3 volt. Bằng cách này, bạn sẽ không phải kiểm tra tất cả mọi thứ, và bạn tiết kiệm
bản thân khỏi việc đánh vào ví dụ một kết nối 12 volt dành cho mảng LED hồng ngoại
hoặc gì đó.
Kết nối chân `GND` trên camera của bạn với pad `GND` của bộ chuyển đổi, kết nối cổng USB của bộ chuyển đổi với cổng USB trên máy tính của bạn, khởi động một ứng dụng giả lập terminal và kết nối với bộ chuyển đổi của bạn. Đặt cài đặt terminal của bạn thành 115200 bps baudrate, 8 bit, không chẵn lẻ, 1 stopbit, không kiểm soát luồng.

Dưới đây là một số dòng lệnh cho các chương trình terminal khác nhau với ghi nhận phiên. Chọn phương pháp bạn thích.

#### screen

Bắt đầu một phiên với

```bash
screen -L -Logfile ipcam-$(date +%s).log /dev/ttyUSB0 115200
```

Sử dụng `Ctrl-a` theo sau là `\` để thoát khỏi phiên

#### `minicom`

Bắt đầu một phiên với

```bash
minicom -b 115200 -8 --capturefile=ipcam-$(date +%s).log --color=on -D /dev/ttyUSB0
```

Sử dụng `Ctrl-a` theo sau là `x` để kết thúc phiên.

#### `picocom`

Bắt đầu một phiên với

```bash
picocom -b 115200 --databits 8 --parity n --stopbits 1 --flow n --logfile=ipcam-$(date +%s).log /dev/ttyUSB0
```

Sử dụng `Ctrl-a` theo sau là `x` để kết thúc phiên.

#### PuTTY

Nếu bạn chọn một terminal GUI, cụ thể là [PuTTY](https://www.putty.org/), đây là cách nó nên trông như thế nào:

![Màn hình cài đặt PuTTY](https://user-images.githubusercontent.com/29582865/207894192-c6f66401-7715-4aa6-bee2-8343aae6c0a9.png)
![Màn hình kết nối PuTTY](https://user-images.githubusercontent.com/29582865/209340268-e34a010c-d455-4343-ae83-0866f0f0af15.png)

Sau đó, kết nối chân `RX` trên bộ chuyển đổi với một liên hệ `TX` có thể có của cổng UART trên camera của bạn. Cung cấp điện cho camera bằng bộ chuyển đổi nguồn tiêu chuẩn của nó. Nếu bạn đoán may mắn thì bạn sẽ bắt đầu thấy nhật ký khởi động trong cửa sổ terminal của bạn. Trong một số trường hợp, nếu bạn thấy văn bản bị xáo trộn trên màn hình của bạn thay vì kernel đang khởi động, bạn có thể cần thay đổi tốc độ kết nối thành 57600 bps và thử lại.

Nếu màn hình của bạn vẫn trống, hãy thử một liên hệ UART khác, và sau đó là một liên hệ khác, cho đến khi bạn tìm thấy cái phù hợp.

Sau khi bạn tìm thấy pad `TX`, kết nối nó với chân `RX` trên bộ chuyển đổi của bạn. Đúng vậy, đó là một kết nối chéo. Bất cứ thứ gì truyền đi sẽ vào một bộ thu và ngược lại. Bây giờ, đặt một vật nặng - một đai ốc đường sắt, một hàn thiếc cổ điển, một ly vodka (đầy) - trên bất kỳ phím chữ nào của bàn phím máy tính của bạn và bắt đầu kết nối chân `TX` còn lại của bộ chuyển đổi của bạn với các pad khác nhau trên camera cho đến khi bạn thấy nó phản hồi lại terminal. Khi điều đó xảy ra, bạn đã hoàn thành thành công một kết nối UART với camera của bạn. Bây giờ bạn có thể uống vodka.

Lưu ý! Thông thường, có một liên hệ thứ tư trên một kết nối UART được đánh dấu là `VCC`. Nó được sử dụng để cung cấp điện cho camera trong quá trình lập trình ban đầu của nhà sản xuất. Chúng tôi khuyên bạn không nên cung cấp điện cho camera của bạn qua chân này, nhưng sử dụng cổng nguồn OEM cho mục đích này.
### Bước 4. Truy cập vào bootloader.

Khởi động lại camera và cố gắng ngắt chuỗi khởi động của nó để truy cập
vào console bootloader bằng cách nhấn một tổ hợp phím trên bàn phím máy tính của bạn,
từ thời điểm bootloader bắt đầu và trước khi Linux kernel hoạt động.
Tổ hợp phím khác nhau từ nhà cung cấp này sang nhà cung cấp khác nhưng, trong hầu hết các trường hợp, đó là
`Ctrl-C`, ít phổ biến hơn -- `Enter`, `Esc`, `*` hoặc chỉ là bất kỳ phím nào. Đọc kỹ văn bản
xuất hiện trên màn hình trong khi khởi động, bạn có thể thấy một gợi ý ở đó. Một số camera
yêu cầu các tổ hợp phím khác biệt hơn không được tiết lộ trong nhật ký khởi động. Bạn có thể thử
tìm chúng trên internet, hoặc hỏi trên [kênh Telegram của chúng tôi][telegram].
Có khả năng, chúng tôi đã từng đối phó với loại camera như vậy và biết tổ hợp phím.

Nếu bạn thành công và nhận được dấu nhắc lệnh thì chúc mừng, bạn đã truy cập được vào
bootloader của camera.

Từ thời điểm này trở đi, chúng tôi khuyên bạn nên ghi lại mọi thứ bạn làm.
Kích hoạt ghi nhật ký phiên trong terminal của bạn. Thậm chí tốt hơn, tạo một tệp văn bản trên máy tính của bạn
và ghi lại tất cả các lệnh bạn chạy và cách hệ thống phản hồi với chúng.
### Bước 5. Xác định kích thước bộ nhớ flash.

Hầu hết các camera IP ngày nay được trang bị bộ nhớ flash NOR hoặc NAND 8 hoặc 16 MB.
Bạn có thể kiểm tra loại và kích thước của chip được cài đặt trên camera của bạn trong
đầu ra nhật ký bootloader. Bạn sẽ thấy một cái gì đó như thế này:

```console
U-Boot 2010.06-svn (Oct 21 2016 - 11:21:29)

Check Flash Memory Controller v100 ... Found
SPI Nor(cs 0) ID: 0xс2 0x20 0x18
spi_general_qe_enable(294): Error: Disable Quad failed! reg: 0x2
Block:64KB Chip:16MB Name:"MX25L128XX"
SPI Nor total size: 16MB
```

Ví dụ khác:

```console
U-Boot 2013.07 (Feb 27 2019 - 02:05:08)

DRAM:  64 MiB
MMC:   msc: 0
SF: Detected EN25QH64
```

Điều này cho thấy mô hình bộ nhớ flash (`EN25QH64`) mà bạn có thể tra cứu trực tuyến để
tìm bảng dữ liệu. Ngoài ra, `64` trong số mô hình gợi ý cho một bộ nhớ 64 Megabit,
tương đương với 8MB. Tương tự, `128` sẽ tương đương với 16MB.

Bạn cũng nên có thể xác định mô hình của bộ nhớ flash bằng cách nhìn lên
tại bo mạch, nhưng đây thường là một nhiệm vụ khó khăn vì các chip rất
nhỏ và có thể không đi kèm với các dấu hiệu rõ ràng.

### Bước 6. Lưu firmware gốc.

Sau khi bạn truy cập vào console bootloader, chạy `help` để nhận danh sách
các lệnh có sẵn. Kiểm tra xem bạn có `tftp` trong số đó không. Nếu có, thì việc lưu
firmware gốc sẽ rất dễ dàng. Bạn chỉ cần thiết lập quyền truy cập vào máy chủ TFTP của bạn từ bước 2.

Lưu ý! Nếu bootloader của bạn không có `tftp`, bạn vẫn có thể tạo một bản sao của
firmware gốc. [Đọc thêm tại đây](help-uboot.md).

Kiểm tra môi trường hệ thống bằng lệnh `printenv`. Tìm kiếm các tham số `ipaddr`,
`netmask`, `gatewayip` và `serverip`. Ba tham số đầu tiên thiết lập địa chỉ IP,
netmask của camera của bạn, và địa chỉ IP của cổng mạng để truy cập
mạng cục bộ. Tham số thứ tư là địa chỉ IP của máy chủ TFTP của bạn. Gán
các giá trị bằng lệnh `setenv` (sử dụng địa chỉ IP và netmask tương ứng với mạng cục bộ của bạn), sau đó lưu các giá trị mới vào môi trường với lệnh `saveenv`.

```bash
setenv ipaddr 192.168.1.253
setenv netmask 255.255.255.0
setenv gatewayip 192.168.1.1
setenv serverip 192.168.1.254
saveenv
```
Để sao lưu firmware gốc, bạn cần lưu nội dung của bộ nhớ flash của camera vào một tệp. Để làm điều đó, bạn phải đầu tiên tải nội dung vào RAM. Dưới đây là cách bạn thực hiện. Khởi tạo bộ nhớ Flash. Dọn dẹp một vùng RAM đủ lớn để chứa toàn bộ nội dung của chip bộ nhớ flash. Đọc nội dung của flash từ vùng đó, sau đó xuất nó ra một tệp trên máy chủ TFTP.

Xin lưu ý, loại flash, kích thước và địa chỉ bắt đầu khác nhau cho các loại camera khác nhau!
Để biết các lệnh chính xác, vui lòng sử dụng [hướng dẫn tự động tạo](https://openipc.org/supported-hardware/)
cho phần cứng của bạn, tham khảo bảng dữ liệu, hoặc tìm kiếm sự giúp đỡ trên [kênh Telegram của chúng tôi][telegram].

### Bước 7. Cài đặt firmware OpenIPC.

#### Lời mở đầu.

Không có hai mô hình camera nào giống nhau. Các mô hình camera khác nhau bao gồm các
bộ phận khác nhau. Hai trong số quan trọng nhất, bộ xử lý trung tâm và cảm biến hình ảnh,
ảnh hưởng trực tiếp đến chất lượng hình ảnh và phạm vi chức năng
đặc trưng cho một camera cụ thể. Khác với CPU máy tính để bàn, bộ xử lý của camera
xử lý nhiều chức năng đến mức nó có một tên cụ thể -- Hệ thống-trên-Chip hoặc SoC,
viết tắt.

Nhưng ngay cả những thành phần ít quan trọng hơn cũng có thể đặt giới hạn cho camera
và khả năng firmware của nó. Ví dụ, các camera khác nhau có thể có các chip bộ nhớ flash khác nhau
được cài đặt. Một số camera có thể có 8MB bộ nhớ flash, trong khi
những cái khác có thể có 16MB hoặc nhiều hơn. Nhiều bộ nhớ flash hơn có thể chứa nhiều mã phần mềm hơn và
cho phép camera chạy các dịch vụ bổ sung không có sẵn trên các camera
với ít bộ nhớ flash hơn. Vì vậy, chúng tôi quyết định xây dựng hai phiên bản firmware của chúng tôi:
phiên bản cơ bản (_Lite_) cho các camera có 8 MB bộ nhớ flash và phiên bản
nâng cao (_Ultimate_) với các tính năng bổ sung cho các camera có 16 MB
bộ nhớ flash.

Như đã nói trước, quy trình cài đặt firmware khác nhau cho các camera khác nhau.
Có các địa chỉ bộ nhớ khác nhau và các tham số môi trường khác nhau,
vì vậy trước khi tiếp tục, xác định loại SoC nào trong camera của bạn, cảm biến nào,
chip bộ nhớ flash nào và bao nhiêu bộ nhớ nó có.

Dưới đây, chúng tôi mô tả quy trình cài đặt firmware OpenIPC Lite trên một
camera có 8 MB bộ nhớ flash, như một ví dụ. Ngay cả khi camera của bạn có bộ nhớ flash lớn hơn,
đừng bỏ qua văn bản này. Đọc nó cẩn thận để hiểu
nguyên tắc và trình tự các hoạt động. Chúng tôi sẽ cung cấp các lệnh cụ thể
cho các camera khác nhau trong phần thứ hai của phần này.

#### Chuẩn bị firmware và máy chủ TFTP.

Hãy truy cập <https://openipc.org/supported-hardware>, tìm SoC của bạn trong bảng
phần cứng được hỗ trợ. Đảm bảo rằng có một tệp nhị phân có thể tải xuống cho SoC đó.
Hy vọng rằng có một tệp firmware đã được biên dịch sẵn cho bộ xử lý của bạn --
hãy tải nó về máy tính của bạn.

Nếu bạn đã thực hiện bước 2, bạn đã có máy chủ TFTP của riêng bạn phục vụ các tệp từ
thư mục `/srv/tftp`. Giải nén các tệp từ gói bạn vừa tải xuống vào
thư mục đó.

```bash
sudo tar -C /srv/tftp/ -xvf openipc.*.tgz
```
#### Chuẩn bị camera để flash.

Vậy, chúng ta có một con chuột bạch, một camera với SoC hi3518ev100, được trang bị cảm biến OV9712,
64 MB RAM và bộ nhớ flash NOR 8MB.

Kết nối với camera qua cổng UART và truy cập vào console bootloader.
Đặt các tham số thành phần cho các biến môi trường phù hợp. Đặt
biến môi trường để tải hệ điều hành Linux và hệ thống tệp gốc
của firmware mới. Đặt các biến môi trường để camera truy cập mạng cục bộ,
nơi `ethaddr` là địa chỉ MAC gốc của camera, `ipaddr` là địa chỉ IP của camera
trên mạng, `gatewayip` là địa chỉ IP của router để truy cập mạng,
`netmask` là mặt nạ mạng con, và `serverip` là địa chỉ IP của máy chủ TFTP
từ bước 3. Lưu các giá trị đã cập nhật vào bộ nhớ flash.

Để biết các lệnh chính xác, vui lòng sử dụng [hướng dẫn tự động tạo](https://openipc.org/supported-hardware/)
cho phần cứng của bạn, tham khảo bảng dữ liệu, hoặc tìm kiếm sự giúp đỡ trên [kênh Telegram của chúng tôi][telegram].

#### Cài đặt.

Để biết các lệnh chính xác, vui lòng sử dụng [hướng dẫn tự động tạo](https://openipc.org/supported-hardware/)
cho phần cứng của bạn, tham khảo bảng dữ liệu, hoặc tìm kiếm sự giúp đỡ trên [kênh Telegram của chúng tôi][telegram].

NB! Hãy chú ý đến các thông báo trên màn hình terminal! Nếu bất kỳ lệnh nào
gây ra lỗi, tìm hiểu xem đã xảy ra lỗi gì. Có thể bạn đã gõ sai? Trong mọi trường hợp,
đừng tiếp tục thủ tục cho đến khi tất cả các lệnh trước đó thành công. Nếu không,
bạn có thể kết thúc với một camera bị hỏng!

### Bước 8. Khởi động lần đầu.

Nếu tất cả các bước trước đây được thực hiện đúng, camera của bạn nên khởi động với
firmware mới. Chào mừng đến với OpenIPC!

Sau lần khởi động đầu tiên với firmware mới, bạn cần dọn dẹp
phân vùng overlay. Chạy điều này trong cửa sổ terminal của bạn:

```bash
firstboot
```

[logo]: ../images/logo_openipc.png
[FTDI]: https://www.google.com/search?q=ftdi+usb+ttl
[TLLC]: https://google.com/search?q=logic+level+converter+3.3v+5v
[telegram]: https://t.me/OpenIPC
