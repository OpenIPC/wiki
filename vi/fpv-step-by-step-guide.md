# OpenIPC Wiki
[Mục lục](../README.md)

Hướng dẫn cài đặt từng bước cho thiết lập FPV

Khi xem xét việc cài đặt OpenIPC để sử dụng cho FPV, về cơ bản, chúng ta có thể chia quy trình thành 6 bước chính.

1. Flash camera và trạm mặt đất với OpenIPC
2. Kết nối phần cứng bổ sung (bộ chuyển đổi wifi và BEC)
3. Tạo và cài đặt cặp khóa cho WFB-NG
4. Chỉnh sửa wfb.conf để đặt kênh wifi chính xác
5. Cấu hình vdec.conf trên trạm mặt đất
6. Cấu hình tệp majestic.yaml trên camera
7. Kiểm tra cấu hình
8. Hướng dẫn bằng video và các bước tiếp theo

Phần 1 và 2 bao gồm việc thiết lập phần cứng - mặc dù có nhiều bước phụ liên quan, vì vậy bạn có thể coi đây là "phần khó". Mặc dù phần mềm (các bước 3 - 6) có nhiều bước hơn, nhưng về cơ bản là chỉnh sửa một số tệp và do đó chúng ta có thể coi đó là "phần dễ"

### Yêu cầu phần cứng
Đối với hướng dẫn từng bước này, tôi đang sử dụng phần cứng cụ thể và mặc dù quy trình flash camera và trạm mặt đất nhìn chung giống nhau, nhưng mỗi quy trình có thể khá khác nhau về kết nối UART bạn có thể sử dụng, cũng như chipset và bộ nhớ khác nhau - vì vậy hãy đảm bảo bạn kiểm tra kỹ điều này cho các thiết bị của mình. Ở mức cơ bản, bạn sẽ cần một trạm mặt đất, một camera, 2 bộ chuyển đổi wifi, tối đa 4 UBEC và một bảng FTDI.

Để tham khảo cho camera của tôi, tôi đã đặt hàng một bảng dựa trên SSC338 với cảm biến Sony IMX415.  

![Máy ảnh](../images/sbs-Camera.jpg)

Tôi đã đặt hàng cái này với ống kính 2.8mm (có vẻ hơi hẹp đối với FPV, nhưng nó là loại rộng nhất có sẵn) và với cáp Lan 12V. Cáp này rất quan trọng để flash camera. Máy ảnh này đã được chọn vì nó có thể thực hiện nhiều tốc độ khung hình và độ phân giải khác nhau, đồng thời cũng có cảm biến khá tốt. Tôi đã mua cái này từ AliExpress, URL cụ thể cho liên kết là [ở đây](https://www.aliexpress.com/item/1005004350557805.html)

Đối với trạm mặt đất, tôi đã chọn một bảng Nvr - có vẻ khá phổ biến trong cộng đồng OpenIPC và có chi phí rất thấp. Một lần nữa, mô hình cụ thể tôi đã mua là [ở đây](https://www.aliexpress.com/item/1005004023376532.html)

![Bảng Nvr](../images/sbs-Nvr.JPG)

Cả camera và trạm mặt đất đều cần một bộ chuyển đổi wifi để gửi tín hiệu FPV qua mạng không dây, vì vậy một giải pháp chi phí thấp khác là RTL8812AU. Cụ thể, tôi đã đặt hàng 2 cái [này](https://www.aliexpress.com/item/1005005638445796.html) 

![Bảng wifi](../images/sbs-wifi.png)

Vì chúng ta sẽ cần chạy camera và Nvr ở 12v và bộ chuyển đổi wifi ở 3.3v, tôi đã đặt hàng một số BEC đơn giản có thể được cấu hình để xuất ra 3.3v, 12v hoặc bất kỳ thứ gì ở giữa. Rất nhiều lựa chọn có sẵn ở đây. Tôi đã chọn 4 cái [này](https://www.ebay.co.uk/itm/254153188189) từ trang web eBay địa phương của tôi.

![BEC](../images/sbs-BECS.jpg)

Bộ chuyển đổi FTDI rất cần thiết để có thể kết nối bảng điều khiển trên thiết bị để bắt đầu quá trình flash. Chúng có sẵn rộng rãi trên eBay với giá khá rẻ [đây là một ví dụ](https://www.ebay.co.uk/itm/203581591537?hash=item2f66688ff1) Bạn nên đảm bảo rằng bộ chuyển đổi FTDI bạn chọn có một jumper có thể di chuyển nó giữa 5v và 3.3v

![](../images/sbs-ftdi.jpg)

Ngoài ra, rõ ràng là có một vài yêu cầu chung - dây để kết nối mọi thứ, mỏ hàn, đầu nối bạn chọn để cung cấp điện (có thể là XT60 - nhưng bạn có thể lựa chọn ở đây)

### Bước 1: Flash camera và trạm mặt đất với OpenIPC
Chúng ta sẽ chia nhỏ điều này thành một vài bước phụ và tách riêng camera và trạm mặt đất. Vì vậy, hãy bắt đầu với phần khó hơn.

### Bước 1.1: Flash camera

Đầu tiên, hãy kiểm tra camera và tất cả các điểm kết nối khác nhau của nó.

![Kết nối camera](../images/sbs-Camera-Pinout-v2.jpg)

Để flash OpenIPC, chúng ta cần sử dụng bộ chuyển đổi FTDI để mở kết nối bảng điều khiển trên camera, sau đó đột nhập vào bộ nạp khởi động. Điều này nghe có vẻ phức tạp hơn thực tế - tất cả những gì chúng ta phải làm là hàn một vài dây và nhấn RETURN vào đúng thời điểm.

Một điều khiến việc này trở nên khó khăn hơn trên camera cụ thể này là vị trí của các chân mà chúng ta cần kết nối. Tất nhiên, đó là 2 miếng đệm hàn rất nhỏ ở phía bên phải của bo mạch (như trong hình) Bạn có thể, rất cẩn thận, hàn trực tiếp vào các miếng đệm này - nhưng hãy cẩn thận không sử dụng quá nhiều nhiệt vì các miếng đệm này có thể dễ dàng bị bong ra!

Một giải pháp thay thế cho việc hàn, nếu bạn không tự tin về nó, là sử dụng một số chân pogo để tạo kết nối tạm thời trong khi bạn thực hiện quá trình flash. Tôi đã thiết kế một công cụ in 3D đơn giản để đạt được điều này, có thể được tải xuống từ Thingiverse [tại đây](https://www.thingiverse.com/thing:6358225) Bạn cũng sẽ cần một số chân pogo để hoàn thành công cụ này. Tôi đã đặt hàng [những thứ này](https://www.amazon.co.uk/dp/B08NT88C3G) từ Amazon (chỉ có sẵn 100 cái!) Lưu ý: Hàn các dây vào chân pogo trước khi bạn đẩy chúng vào bản in 3D. Nếu bạn hàn chúng trong khi in, PLA sẽ tan chảy và sẽ rất khó khăn để đưa các chân về đúng vị trí.

Bạn cần đẩy các chân pogo vào vừa đủ để bạn phải uốn cong dụng cụ một chút để đặt nó lên trên bảng và khi bạn buông tay, các chân sẽ hạ xuống và tiếp xúc tốt với các miếng đệm hàn (lưu ý: bức ảnh này được chụp trong khi tôi đang thử nghiệm nó để phù hợp - ở giai đoạn này, bạn nên đã hàn dây vào các chân pogo rồi)

![dụng cụ pogo](../images/sbs-pogo-tool.jpg)

Được rồi, vì vậy cho dù bạn đã hàn hay sử dụng công cụ, bây giờ bạn muốn kết nối với bộ chuyển đổi FTDI của mình. Đầu tiên, đặt jumper trên bộ chuyển đổi FTDI của bạn thành 3.3v và sau đó kết nối từ miếng đệm TX trên camera với chân RX trên bộ chuyển đổi FTDI, miếng đệm RX trên camera với chân TX trên bộ chuyển đổi FTDI và bất kỳ kết nối nào với mặt đất trên camera với chân nối đất trên bộ chuyển đổi FDTI.

Nếu bây giờ bạn đang nghĩ "Khoan đã, chân nối đất nào?". Hãy để tôi cho bạn xem sơ đồ kết nối chân được tinh chỉnh một chút của tôi về camera mà tôi gọi là "các chân hữu ích"

![Các chân hữu ích](../images/sbs-camera-userful-pins-v2.jpg)

Những gì chúng ta có ở đây là các chân thực sự có liên quan đến chúng ta khi nối dây cho camera này. Chúng ta đã kết nối TX/RX, vì vậy nếu bạn có đầu nối 3 chân cũ từ camera FPV, nó có thể vừa với kích thước để cắm vào ổ cắm chứa GND ở bên trái của bo mạch trong hình. Ít nhất thì đây là những gì tôi đã làm. Nếu bạn không có bất kỳ đầu nối JST nào như thế này - hãy lấy một số. Nơi nào có thể, tôi muốn tránh hàn xung quanh những linh kiện nhỏ bé này càng nhiều càng tốt.

Bạn cũng sẽ cần kết nối camera với mạng có dây của mình thông qua cổng ethernet trong cáp đi kèm (do đó hãy đặt hàng cáp Lan 12V) và đây cũng là nơi bạn cần cấp nguồn cho nó - bằng cách sử dụng phích cắm thùng 12v.

Với mọi thứ được kết nối, nó sẽ trông giống như thế này. Nhưng ngay trước khi chúng ta tiếp tục và cắm nguồn 12v, cần phải có sẵn phần mềm để mở bảng điều khiển nối tiếp để chúng ta có thể đột nhập vào bộ nạp khởi động và thực sự chạy một số lệnh.

![Sẵn sàng để flash camera](../images/sbs-flash-camera.jpg)

Trên máy Mac (hoặc Linux), điều này khá dễ dàng vì chúng tôi đã tích hợp sẵn tất cả các lệnh. Tôi sẽ chỉ đề cập đến MacOS và Windows trong tài liệu từng bước. Linux sẽ rất giống với MacOS, nhưng nếu bạn đang chạy Linux làm hệ điều hành chính của mình, thì tôi mong bạn đã biết các lệnh rồi!

### Bước 1.2 Thiết lập mô phỏng thiết bị đầu cuối nối tiếp

**MacOS**

Trước tiên, hãy cắm bộ chuyển đổi FTDI của bạn (nhưng hãy tắt nguồn camera ngay bây giờ), điều này sẽ cho phép hệ thống xác định bộ chuyển đổi FDTI. Trước hết, chúng ta sẽ cần mở một thiết bị đầu cuối. Bạn có thể tìm thấy điều này trong thư mục Ứng dụng của mình bên trong thư mục con Tiện ích. Khi bạn đã mở thiết bị đầu cuối này, chúng ta cần tìm ra thiết bị nào là bộ chuyển đổi FDTI của chúng ta. Để làm điều này, hãy gõ

```
$ ls -l /dev/tty.usbserial*
crw-rw-rw-  1 root  wheel    9,  10 20 Tháng 12 10:31 /dev/tty.usbserial-A50285BI
```

Như bạn có thể thấy, thiết bị của tôi được gọi là /dev/tty.usbserial-A50285BI. Nhưng của bạn có thể khác, chúng ta cần tên của thiết bị này để sử dụng trong lệnh tiếp theo, lệnh thực sự mở ra một trình giả lập nối tiếp trên thiết bị đó và cho phép chúng ta giao tiếp với camera. Để làm điều này, chúng ta có thể sử dụng lệnh screen. Trên dòng lệnh của bạn, hãy gõ 

`$ screen /dev/tty.usbserial-A50285BI 115200`

115200 là tốc độ baud mà chúng ta đang sử dụng. Ok, bây giờ chúng ta sẽ có một màn hình trống với con trỏ ở phía trên đang chờ một cái gì đó xuất hiện. Bạn có thể bỏ qua phần 1.3

**Windows**

Windows cần cài đặt thêm một chút phần mềm vì nó không có gì trong hệ điều hành cơ bản có thể hoàn thành công việc. Đối với cả mô phỏng thiết bị đầu cuối nối tiếp cũng như ssh và scp (chúng ta sẽ sử dụng hai phần mềm sau này), tôi khuyên bạn nên sử dụng Putty mà bạn có thể tải xuống [tại đây](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) Khi bạn đã tải xuống, cài đặt và chạy phần mềm này - hãy cắm bộ chuyển đổi FTDI, nhưng hãy tắt nguồn camera ngay bây giờ. Trước hết, chúng ta cần tìm cổng COM nào mà Windows đã phân bổ cho bộ chuyển đổi FTSI, để kiểm tra điều này, bạn có thể vào Trình quản lý thiết bị để tìm hiểu (chỉ cần nhập trình quản lý thiết bị vào thanh tìm kiếm) 

![Trình quản lý thiết bị](../images/sbs-com-port.jpg)

Trong trường hợp của tôi, bạn có thể thấy rằng bộ chuyển đổi FTDI đã được cấu hình là COM6. Quay lại màn hình Putty, thay đổi loại kết nối thành Nối tiếp, đặt cổng COM bạn thấy cho bộ chuyển đổi FTDI của bạn vào hộp văn bản Dòng nối tiếp và đặt Tốc độ thành 115200. Việc lưu điều này rất hữu ích để nó có thể được nhấp đúp để mở thiết bị đầu cuối này trong tương lai. Vì vậy, nếu bạn nhập Serial OpenIPC (hoặc bất cứ điều gì bạn muốn gọi nó) vào hộp văn bản Phiên đã lưu và nhấp vào Lưu.  

![Kết nối nối tiếp Putty](../images/sbs-putty-serial.jpg)

Bây giờ nếu chúng ta nhấp đúp vào phiên đã lưu đó, nó sẽ mở ra một màn hình mới sẵn sàng để nói chuyện với camera.

### Bước 1.3 Thiết lập máy chủ tftp

tftp là viết tắt của "Giao thức truyền tệp tầm thường". Bạn có thể đã sử dụng giao thức ftp đầy đủ chức năng hơn trong quá khứ. tftp theo truyền thống đã được sử dụng trong quá khứ để "khởi động mạng" các máy trạm từ xa. Khi khởi động, tất cả những gì các máy khách này biết là yêu cầu và máy chủ trên một địa chỉ ip cụ thể cho một tệp khởi động, và nó sẽ tải xuống và chạy tệp đó. Không có mật khẩu nào liên quan hoặc bất kỳ lệnh nào khác để chạy, đó chỉ là trường hợp "hãy cho tôi tệp này" do đó nó rất tầm thường. Mối lo ngại thông thường đối với mọi người khi chạy bất kỳ loại máy chủ nào trên hệ thống của họ là liệu nó có ảnh hưởng đến bảo mật của hệ thống của bạn hay không? Câu trả lời là không, nó không nên làm vậy. Bạn chỉ cần nhận kết nối trên mạng cục bộ của mình và bên cạnh đó - giao thức này rất cũ và được hiểu rõ. Bất kỳ lỗ hổng bảo mật nào có thể đã có ở đó đã được tìm thấy nhiều năm trước và đã được vá.

**MacOS**

MacOS có máy chủ tftp riêng sẵn sàng để chạy, nhưng nó không được khởi động theo mặc định. Để khởi động nó, hãy gõ

`$ sudo launchctl load -F /System/Library/LaunchDaemons/tftp.plist
`

Lệnh sudo có nghĩa là chạy với tư cách root, vì vậy bạn sẽ được nhắc nhập mật khẩu root của mình để lệnh chạy thành công. MacOS sẽ sử dụng thư mục /private/tftpboot để phục vụ các tệp, vì vậy chúng ta sẽ đặt hình ảnh khởi động của mình vào thư mục này sau.

**Windows**

Như bạn mong đợi, Windows cần cài đặt thêm phần mềm để chạy máy chủ tftp. Có rất nhiều lựa chọn ngoài kia, tôi đã sử dụng từ công ty Solarwinds mà bạn có thể truy cập [tại đây](https://www.solarwinds.com/free-tools/free-tftp-server?) Mặc dù đó là bản tải xuống miễn phí, nhưng công ty yêu cầu thông tin đăng ký. Những gì bạn chọn để đưa vào thông tin đăng ký, tất nhiên, hoàn toàn tùy thuộc vào bạn - vì nó không ảnh hưởng đến việc thực sự nhận được liên kết tải xuống để tải phần mềm. Khi bạn đã có phần mềm và đã cài đặt và chạy nó, bạn sẽ nhận được một cửa sổ như thế này.

![tftp trên windows](../images/sbs-tftp-win.jpg)

Máy chủ sẽ sử dụng thư mục C:\TFTP-Root để phục vụ các tệp, vì vậy chúng tôi sẽ đặt hình ảnh khởi động của mình vào thư mục này sau.

### Bước 1.4 Tải xuống hình ảnh firmware chính xác

SOC cho camera cụ thể này là SigmaStar SSC338Q. Xác định chính xác SOC nào đang có trên camera của bạn rõ ràng là rất quan trọng vì firmware dành riêng cho từng SOC. Rất may, trong trường hợp của camera của tôi (và nếu bạn nhìn vào sơ đồ kết nối chân ở trên), bạn có thể thấy nó được viết trên bo mạch. Để tìm firmware cho camera của bạn, từ [trang web](https://openipc.org/) chính của OpenIPC, hãy chuyển đến liên kết Tệp nhị phân được biên dịch trước, liên kết này sẽ đưa bạn đến [trang này](https://openipc.org/supported-hardware/featured) từ đây, chúng ta có thể thấy SigmaStar SSC338Q trên trang nổi bật, nhưng tùy thuộc vào model của SOC bạn có, bạn có thể chọn nhà sản xuất thích hợp trong các liên kết dọc theo đầu trang. Bất kỳ cái nào bạn có, bước tiếp theo là nhấp vào Tạo hướng dẫn cài đặt. Trong trường hợp này, nó đưa chúng ta đến [trang này](https://openipc.org/cameras/vendors/sigmastar/socs/ssc338q)

Bức ảnh cho thấy trang này **sau** khi tôi đã thay đổi các tùy chọn cho phiên bản firmware cụ thể mà tôi cần.

![Tạo firmware](../images/sbs-firmwae-gen.jpg)

Một vài lưu ý về những thay đổi này. Khi bạn lần đầu tiên truy cập trang này, trường địa chỉ MAC sẽ trống - vì vậy hãy nhấp vào tạo địa chỉ MAC hợp lệ để điền vào trường này. Đối với địa chỉ IP camera, chúng ta cần cung cấp cho nó một địa chỉ chưa sử dụng trên cùng một mạng con mà PC của chúng ta đang chạy. Trong hầu hết các trường hợp, mạng gia đình của bạn sẽ nằm trên mạng 192.168.0.x hoặc 192.168.1/x. Nếu bạn không chắc chắn về mạng con của mình là gì, thì chúng ta cũng cần tìm địa chỉ PC của mình cho tftpserver, đó là một cách để tìm hiểu.

Trên MacOS, tôi có thể chỉ cần sử dụng

```
$ ifconfig en0
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=50b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV,CHANNEL_IO>
	ether 3c:cd:36:5b:d4:80 
	inet6 fe80::c78:ab18:b66d:b615%en0 prefixlen 64 secured scopeid 0x4 
	inet 192.168.0.10 netmask 0xffffff00 broadcast 192.168.0.255
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect (1000baseT <full-duplex,flow-control,energy-efficient-ethernet>)
	status: active
```

Trên Windows, bạn có thể sử dụng một lệnh tương tự từ dòng lệnh (nhập cmd vào thanh tìm kiếm)

```
C:\>ipconfig

Cấu hình IP Windows


Bộ điều hợp Ethernet Ethernet0:

   Hậu tố DNS dành riêng cho kết nối. : localdomain
   Địa chỉ IPv6 liên kết cục bộ. . . . . : fe80::e34e:48bb:9e79:90b2%12
   Địa chỉ IPv4. . . . . . . . . . . : 192.168.0.10
   Mặt nạ mạng con. . . . . . . . . . . : 255.255.255.0
   Cổng mặc định. . . . . . . . . . : 192.168.0.1

Bộ điều hợp Ethernet Kết nối mạng Bluetooth:

   Trạng thái phương tiện. . . . . . . . . . . : Phương tiện đã ngắt kết nối
   Hậu tố DNS dành riêng cho kết nối. :
```

Từ lệnh này, chúng ta có thể thấy rằng địa chỉ IP của PC của tôi là 192.168.0.10 và mạng con của tôi là 192.168.0. Vì vậy, tôi có thể điền vào trường địa chỉ IP máy chủ TFTP của mình và đối với trường địa chỉ IP camera, tôi chỉ cần chọn một địa chỉ chưa được sử dụng. Tôi đã sử dụng 192.168.0.123 vì nó chưa được sử dụng. Nếu bạn không chắc chắn, bạn có thể thử ping địa chỉ này để kiểm tra.

```
$ ping 192.168.0.123
PING 192.168.0.123 (192.168.0.123): 56 byte dữ liệu
Yêu cầu hết thời gian chờ cho icmp_seq 0
Yêu cầu hết thời gian chờ cho icmp_seq 1
Yêu cầu hết thời gian chờ cho icmp_seq 2
```

Những lần chờ này thường cho biết rằng không có máy chủ nào ở địa chỉ đó và có thể an toàn để sử dụng.

Đối với phần còn lại của các tùy chọn, camera này có 16MB RAM flash (chúng ta có thể xem cách xác minh điều này sau), tôi đã thay đổi Phiên bản Firmware thành FPV và Giao diện mạng và khe cắm thẻ SD là các giá trị mặc định. Vì vậy, bây giờ, hãy nhấp vào Tạo Hướng dẫn Cài đặt. Sẽ hiển thị cho bạn một hướng dẫn như thế này.

![Hướng dẫn cài đặt](../images/sbs-install-guide.jpg)

Ý tưởng của hướng dẫn cài đặt này là một khi bạn đã mở bảng điều khiển trên camera, bạn có thể chỉ cần cắt và dán các lệnh vào cửa sổ bảng điều khiển để thực hiện sao lưu và flash firmware. Chỉ có một vấn đề với điều này, đó là một vài lỗi trong hướng dẫn. Công bằng mà nói, kể từ khi tôi thực hiện flash, nó đã được cải thiện, nhưng vẫn còn một vài lỗi cần được giải quyết.

Trước hết, toàn bộ phần Lưu firmware gốc sẽ không hoạt động. Điều này là do không có lệnh tftpput hoặc lệnh tftp nào trên hệ điều hành hạn chế của camera, vì vậy chúng ta không có cách nào để di chuyển bản sao lưu của camera ra khỏi chính camera. Điều đó có nghĩa là chúng ta phải bỏ qua toàn bộ phần này. Tôi được biết rằng các nhà phát triển có bản sao lưu này ở đâu đó - chỉ trong trường hợp bạn cần khôi phục nó. Nếu bạn thực sự muốn tạo bản sao lưu, có một [phương pháp hoạt động](help-uboot.md#saving-original-firmware-without-using-tftp), nhưng sẽ mất vài giờ để truyền dữ liệu.  

Rất may, việc flash thực tế sẽ hoạt động, nhưng trước khi chúng ta bắt đầu, chúng ta cần nhấp vào liên kết *Tải xuống hình ảnh Firmware OpenIPC (Fpc)*. Trong trường hợp của ví dụ này, chúng tôi sẽ tải xuống tệp openipc-ssc338q-fpv-16mb.bin. Theo hướng dẫn máy chủ tftp, trên MacOS, bạn cần đặt tệp này trong /private/tftpboot và trên Windows, hãy đặt nó vào thư mục C:\TFTP-Root. Trên MacOS, hệ điều hành sẽ cho bạn quyền bị từ chối khi cố gắng sao chép điều này với tư cách là người dùng của riêng bạn, vì vậy rất có thể bạn sẽ cần sử dụng lại lệnh sudo.

`$ sudo cp $HOME/Downloads/openipc-ssc338q-fpv-16mb.bin /private/tftpboot/`

Windows chặn tất cả các kết nối đến theo mặc định bằng Tường lửa Microsoft Defender, vì vậy chúng ta cần tạm thời tắt tính năng này. Nếu bạn nhập Bảo mật Windows vào thanh tìm kiếm và chạy ứng dụng Bảo mật Windows, sau đó chọn Tường lửa & Bảo vệ mạng. Phần tiếp theo phụ thuộc vào cách bạn đã cấu hình Windows. Nếu bạn đã cấu hình mạng cục bộ của mình là riêng tư, thì bạn có thể nhấp vào Mạng riêng tư và tắt Tường lửa Microsoft Defender. Tôi đã để Windows 10 (Máy ảo) của riêng mình theo mặc định và do đó nó không có mạng riêng tư được cấu hình và coi mọi thứ là mạng công cộng, vì vậy trong trường hợp của tôi, tôi nhấp vào Mạng công cộng và vô hiệu hóa tường lửa.

![Tường lửa Windows](../images/sbs-Win-Firewall.jpg)

### Bước 1.5 Mở bảng điều khiển và thực hiện flash!

Cuối cùng cũng đến lúc flash camera này. Vì vậy, nếu bạn vẫn kết nối bộ chuyển đổi FTDI của mình với PC và camera, cùng với bảng điều khiển nối tiếp đang mở, bạn đã sẵn sàng để sử dụng (nếu không, hãy quay lại 1.2 và mở thiết bị đầu cuối nối tiếp) Tất cả những gì bạn cần làm bây giờ là cắm nguồn 12v vào camera và bạn sẽ thấy rất nhiều thông báo khởi động xuất hiện trên bảng điều khiển nối tiếp. Ý tưởng ở đây là bạn nhấn phím return nhiều lần ngay khi thông báo khởi động xuất hiện. Nếu bạn bỏ lỡ nó và camera tiếp tục khởi động, cuối cùng bạn sẽ thấy lời nhắc đăng nhập như thế này.

![Lời nhắc đăng nhập](../images/sbs-bootloader-missed.jpg)

Mặc dù điều đó có nghĩa là bạn đã quá chậm khi nhấn phím return, nhưng nó cho thấy rằng bảng điều khiển đang hoạt động và camera đang khởi động bình thường. Đừng lo lắng, chỉ cần tắt nguồn camera và thử lại. Nếu lần này bạn đủ nhanh, bạn sẽ thấy một cái gì đó như thế này.

![Lời nhắc bootloader](../images/sbs-bootloader-int.jpg)

Được rồi, bây giờ chúng ta đang nấu ăn! Nhưng chờ đã, điều gì sẽ xảy ra nếu bạn không nhận được bất cứ thứ gì trên bảng điều khiển và bạn đang nhìn vào một màn hình hoàn toàn trống? Chà, nơi dễ bị nhầm lẫn nhất ở đây là khiến các kết nối TX/RX của bạn bị chéo nhau trên bảng FTDI. Miễn là camera có vẻ khởi động (có một hoặc hai đèn LED và đèn của tôi thậm chí còn phát ra một chút tiếng ồn khi khởi động), hãy thử hoán đổi các dây dẫn TX/RX của bạn trên bảng FTDI và xem điều đó có khắc phục được sự cố không. Đối với những người còn lại trong chúng ta, đã đến lúc bắt đầu cung cấp các lệnh từ hướng dẫn cài đặt.

Đây là những dòng mà hướng dẫn cho chúng ta chạy từng dòng một. Tôi sẽ cho bạn thấy phản hồi bạn có thể nhận được và những phần nào không nên chạy.

```
# Nhập lệnh theo từng dòng! Không sao chép và dán nhiều dòng cùng lúc!
setenv ipaddr 192.168.0.123; setenv serverip 192.168.0.10
mw.b 0x21000000 0xff 0x1000000
tftpboot 0x21000000 openipc-ssc338q-fpv-16mb.bin
# nếu không có tftpboot mà là tftp thì hãy chạy lệnh này thay thế
tftp 0x21000000 openipc-ssc338q-fpv-16mb.bin
sf probe 0; sf lock 0;
sf erase 0x0 0x1000000; sf write 0x21000000 0x0 0x1000000
reset
```

Hãy chạy một vài dòng đầu tiên. Trên camera của tôi, tôi biết rằng lệnh tftpboot có tồn tại, vì vậy chúng ta có thể bỏ qua lệnh tiếp theo bằng cách sử dụng tftp

```
Anjoy # setenv ipaddr 192.168.0.123; setenv serverip 192.168.0.10
Anjoy # mw.b 0x21000000 0xff 0x1000000
Anjoy # tftpboot 0x21000000 openipc-ssc338q-fpv-16mb.bin
Sử dụng thiết bị sstar_emac
TFTP từ máy chủ 192.168.0.10; địa chỉ IP của chúng tôi là 192.168.0.123
Tên tệp 'openipc-ssc338q-fpv-16mb.bin'.
Tải địa chỉ: 0x21000000
Đang tải: #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #######################################
         2.3 MiB/s
         
hoàn thành
Số byte đã chuyển = 16777216 (1000000 hex)
```

Khi bạn chạy lệnh tftpboot, bạn sẽ thấy các hàng # xuất hiện khi tệp được kéo từ máy chủ của bạn. Nhưng điều gì sẽ xảy ra nếu nó không hoạt động? Trên máy Mac, vấn đề phổ biến nhất sẽ là quyền truy cập tệp - tệp có quyền đọc trên toàn thế giới để có thể đọc bằng daemon tftp không. Chúng ta có thể đặt quyền mở trên tệp bằng cách chạy

`$ sudo chmod 777 /private/tftpboot/openipc-ssc338q-fpv-16mb.bin`

Trên Windows, máy chủ SolarWinds TFTP sẽ ghi lại các kết nối và bất kỳ nỗ lực nào để lấy tệp trong cửa sổ của nó, vì vậy bạn có thể kiểm tra điều này để giúp xác định sự cố. Nếu không có gì trong đó, thì yêu cầu không đến được máy chủ. Bạn đã tắt tường lửa phiền phức đó chưa? (nếu địa chỉ IP trong hình ảnh này trông kỳ lạ, thì đó là vì tôi đang chạy Windows trong máy ảo, máy ảo này tạo kết nối mạng riêng của nó để bắc cầu đến máy chủ)

![Thông báo gỡ lỗi tftp](../images/sbs-tftp-log.jpg)

Lệnh tiếp theo, theo hướng dẫn là chạy

`sf probe 0; sf lock 0;`

Điều này sẽ không hoạt động, vì phần 'khóa' của lệnh không được triển khai. Vì vậy, những gì chúng ta cần chạy ở đây chỉ đơn giản là phần đầu tiên của lệnh.

```
Anjoy # sf probe 0
Flash được phát hiện (0x0B05, 0xC8, 0x40, 0x18)
SF: Đã phát hiện nor0 với tổng kích thước 16Mib
```

Nếu bạn không chắc chắn flash trên camera của mình lớn bao nhiêu, thì chạy sf probe 0 là một cách tuyệt vời để kiểm tra điều đó. Nếu nó khác với những gì bạn đã đưa vào trang Tạo Hướng dẫn Cài đặt, thì bạn có thể chỉ cần quay lại trang đó và nhập thông tin chính xác để tạo hướng dẫn mới và hướng dẫn cài đặt mới. Khởi động lại camera của bạn và bắt đầu lại.

```
Anjoy # sf erase 0x0 0x1000000; sf write 0x21000000 0x0 0x1000000
_spi_flash_erase: addr 0x0, len 0x10000000 100% (mất 25076 ms)
SF: 16777216 byte @ 0x0 Đã xóa: OK
_spi_flash_write đến 0x0, len 0x1000000 từ 0x21000000 100% (mất 14084 ms)
SF: 16777216 byte @ 0x0 Đã ghi: OK
```

Hành động này mất vài phút, nhưng đây là phần flash thực sự thú vị đã hoàn thành. Nếu mọi việc suôn sẻ, tất cả những gì bạn cần làm bây giờ là khởi động lại bảng bằng cách nhập lệnh cuối cùng.

`Anjoy # reset`

Tại thời điểm này, camera sẽ khởi động lại nhiều lần. Bạn sẽ thấy rất nhiều thông báo trên bảng điều khiển cho đến khi tất cả dừng lại, có thể là thông báo

`Không phát hiện thấy thẻ wifi usb. Kiểm tra kết nối wifi stick, nguồn usb hoặc có thể hàn bị lỗi.`

Điều này là dự kiến. Chúng ta không nhận được lời nhắc đăng nhập ở đây, vì một phần của quá trình cài đặt OpenIPC đã tắt khả năng đăng nhập qua kết nối nối tiếp này (mặc dù rất đơn giản để bật lại) Tuy nhiên, cách tốt hơn để đăng nhập bây giờ là qua SSH vì camera nên đã hỏi máy chủ DHCP của bạn (thường là bộ định tuyến của bạn) cho một địa chỉ IP. Nếu bạn tìm kiếm các dòng trên bảng điều khiển bắt đầu bằng uhdcpc, bạn sẽ có thể thấy camera đã được cấp phát địa chỉ IP nào. Trong trường hợp của tôi, tôi có thể thấy

```
udhcpc: đã bắt đầu, v1.36.1
udhcpc: phát sóng khám phá
udhcpc: phát sóng lựa chọn cho 192.168.0.50, máy chủ 192.168.0.1
udhcpc: đã nhận được hợp đồng thuê 192.168.0.50 từ 192.168.0.1, thời gian thuê 86400
```

Điều này cho chúng ta biết rằng địa chỉ ip của chúng ta là 192.168.0.50, vì vậy bây giờ hãy kết nối với nó qua mạng. Trên MacOS, sử dụng

`$ ssh root@192.168.0.50`

Trên Windows, sử dụng Putty. Sẽ rất hữu ích nếu tạo một phiên đã lưu để bạn có thể nhấp đúp vào nó để mở cửa sổ ssh - như trong hình ở đây.

![Putty SSH](../images/sbs-putty-ssh.jpg)

Bạn sẽ được nhắc nhập mật khẩu root khi ssh vào camera, đó là 12345. Sau khi bạn nhập mật khẩu và mọi thứ đã diễn ra đúng, bạn sẽ được chào đón bằng một màn hình như thế này

![đăng nhập ssh](../images/sbs-ssh-openipc.jpg)

Điều đầu tiên bạn cần làm ở đây là thay đổi mật khẩu root. Bạn có thể thực hiện việc này trên dòng lệnh bằng cách nhập lệnh passwd. Thao tác này sẽ nhắc nhập mật khẩu root hiện tại, sau đó yêu cầu bạn nhập mật khẩu mới và xác nhận lại. Ngoài ra, bạn có thể sử dụng giao diện web. Để thực hiện việc này, hãy truy cập trình duyệt trên PC của bạn và nhập địa chỉ IP của camera, vì vậy trong trường hợp địa chỉ tôi có cho camera của mình là 192.168.0.50:85. Bạn sẽ được nhắc nhập tên người dùng (root) và mật khẩu (12345 nếu bạn chưa thay đổi)

Nếu bạn chưa thay đổi mật khẩu, thì nó sẽ yêu cầu bạn làm như vậy - chỉ cần nhập mật khẩu mới của bạn vào Lưu thay đổi

![thay đổi mật khẩu web](../images/sbs-web-pass.jpg)

Khi bạn thay đổi mật khẩu (hoặc nếu nó đã được thay đổi qua dòng lệnh, giao diện web sẽ thay đổi. Bạn sẽ nhận thấy tùy chọn thay đổi địa chỉ MAC của mình - bạn có thể tiếp tục và thực hiện việc này, nhưng hãy xem cảnh báo về địa chỉ IP của bạn có thể thay đổi. Một lần nữa, bạn có thể tìm kiếm điều này trong thông báo khởi động bảng