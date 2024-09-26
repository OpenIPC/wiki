# OpenIPC Wiki
[Mục lục](../README.md)

Câu hỏi thường gặp
---------------------------

### Tôi có một camera không có trong danh sách thiết bị được hỗ trợ. Bạn có thể làm cho nó hoạt động cho tôi không?

Câu trả lời ngắn gọn là không.

Nếu bạn có kỹ năng và mong muốn làm cho OpenIPC hoạt động trên phần cứng mới, chúng tôi có thể chia sẻ kiến thức mà chúng tôi có.
Nếu không, hãy tự mua một camera được hỗ trợ.

### Làm cách nào để biết phần cứng bên trong camera trước khi mua?

Hầu hết thời gian bạn không thể, đặc biệt là nếu đó là bản sao giá rẻ của Trung Quốc của một bản sao của một camera được đổi thương hiệu.
Đối với các thương hiệu tên tuổi uy tín đã trải qua chứng nhận phần cứng, bạn có thể xem xét bên trong camera trong các tài liệu chứng nhận. Tìm FCC ID trên hộp hoặc vỏ của camera
và sau đó tra cứu nó trong [cơ sở dữ liệu FCC ID](https://fccid.io/).

### Sự khác biệt giữa Lite và Ultimate

- Hỗ trợ máy chủ Amazon
- Hỗ trợ nhận dạng mã QR (cơ bản)
- Hỗ trợ iptables (tường lửa)
- Hỗ trợ đường hầm ZeroTier
- Hỗ trợ MQTT (thu thập dữ liệu từ xa)
- Hỗ trợ WiFi
- Hỗ trợ lame (mp3) và libwebsockets
- Hỗ trợ WebRTC thử nghiệm (chỉ dành cho Hisi/Goke gần đây)

$\color{red}{\text{Chúng tôi luôn khuyến nghị chỉ sử dụng firmware Lite}}$

### Cách loại bỏ tiêu đề trình bao bọc hình ảnh U-Boot khỏi hình ảnh nhị phân

Đôi khi firmware của nhà cung cấp bao gồm các hình ảnh nhị phân dành cho
sử dụng với trình tải hình ảnh U-Boot và được thêm vào trước tiêu đề ở
[định dạng trình bao bọc hình ảnh U-Boot](https://formats.kaitai.io/uimage/).
Tiêu đề nên được gỡ bỏ trước khi bạn có thể sử dụng hình ảnh đó
như một tệp nhị phân thô. Đây là cách bạn có thể loại bỏ 64 byte đầu tiên
khỏi một tệp:

```bash
dd if=tệp_đầu_vào.img of=tệp_đầu_ra.bin bs=64 skip=1
```

hoặc cách khác

```bash
tail -c +65 tệp_đầu_vào.img > tệp_đầu_ra.bin
```

### Làm cách nào để vào shell của bộ nạp khởi động?

[Có một số cách để truy cập shell của bộ nạp khởi động bị khóa](help-uboot.md#bypassing-password-protected-bootloader)

### Làm cách nào để đặt lại cài đặt camera từ U-Boot?

Đôi khi cài đặt không đúng khiến camera không ổn định đến mức
không thể đăng nhập hoặc không đủ thời gian trước khi khởi động lại để sửa cài đặt.
Đây là cách xóa hoàn toàn phân vùng lớp phủ trong firmware OpenIPC,
ngay từ shell của bộ nạp khởi động, để đưa camera về trạng thái ban đầu:

> **Chỉ dành cho phân vùng flash 8MB**

```
sf probe 0; sf erase 0x750000 0xb0000; reset
```

> **Chỉ dành cho phân vùng flash 16MB**

```
sf probe 0; sf erase 0xd50000 0x2b0000; reset
```

### Làm cách nào để đăng nhập vào camera qua SSH?

`ssh root@<địa_chỉ_ip_camera>`

Mật khẩu mặc định là _12345_.

### Làm cách nào để đăng nhập vào Giao diện người dùng Web của camera?

Mở http://<địa_chỉ_ip_camera> và đăng nhập bằng tên người dùng mặc định _root_
và mật khẩu mặc định _12345_. Bạn sẽ được yêu cầu thay đổi mật khẩu sau
khi đăng nhập thành công.

**Xin lưu ý, thao tác này cũng sẽ thay đổi mật khẩu root ssh của bạn!**

### Làm cách nào để đặt lại mật khẩu cho SSH/Giao diện người dùng Web?

Tạo kết nối nối tiếp với camera bằng bộ chuyển đổi UART và chương trình
thiết bị đầu cuối. Sau khi bật camera, hãy nhấn Ctrl-C để ngắt quá trình khởi động
và vào shell của bộ nạp khởi động.

Đối với camera có chip flash 8MB, hãy chạy

```bash
sf probe 0; sf erase 0x750000 0xb0000; reset
```

Đối với camera có chip flash 16MB, hãy chạy

```bash
sf probe 0; sf erase 0xd50000 0x2b0000; reset
```

### Làm cách nào để tìm thông tin về phần cứng và phần mềm của camera?

Đăng nhập vào camera qua `ssh` và chạy `ipctool`.

### Tôi không thấy ipctool trên camera. Tại sao?

Bạn không thấy nó vì ban đầu nó không có ở đó, nhưng có một lệnh shell
cùng tên.

_(Vì nó là một lệnh shell, nó sẽ không hoạt động từ Bảng điều khiển Web trong giao diện người dùng Web.
Hãy đăng nhập vào camera qua SSH và chạy lệnh ở đó.)_

Khi bạn chạy lệnh này, phiên bản mới nhất của tiện ích `ipctool` 
sẽ được tải xuống thư mục `/tmp/` và chạy từ đó. Vì tiện ích
nằm trong `/tmp/`, nó sẽ không tồn tại sau khi khởi động lại, do đó sẽ không chiếm bất kỳ dung lượng hữu ích nào
trên camera sau đó.

Nếu bạn cần biết có gì trong lệnh, hãy tìm kiếm `ipctool` trong
tệp `/etc/profile`.

### Thay thế bộ nạp khởi động từ Linux

Các lệnh được thực thi riêng biệt trên mỗi dòng với thời gian chờ cho đến khi kết thúc quá trình thực thi.
Tên đầy đủ của bộ nạp khởi động thay thế và tính khả dụng của nó có thể được kiểm tra [tại đây][3]

Trước khi chạy các lệnh, đừng quên nhập tên bộ nạp khởi động chính xác!

```
FILE=u-boot-SOC-LOẠI.bin
curl -k -L https://github.com/OpenIPC/firmware/releases/download/latest/${FILE} -o /tmp/${FILE}
flashcp -v /tmp/${FILE} /dev/mtd0
flash_eraseall /dev/mtd1
```

Lưu thông tin đăng nhập không dây:
```
FILE=/usr/share/openipc/wireless.sh
echo "#!/bin/sh" > ${FILE}
echo "fw_setenv wlandev $(fw_printenv -n wlandev)" >> ${FILE}
echo "fw_setenv wlanssid $(fw_printenv -n wlanssid)" >> ${FILE}
echo "fw_setenv wlanpass $(fw_printenv -n wlanpass)" >> ${FILE}
chmod 755 ${FILE}
```

### Làm cách nào để cập nhật firmware OpenIPC cũ?

Các lệnh được thực thi riêng biệt trên mỗi dòng với thời gian chờ kết thúc thực thi.
Lệnh đầu tiên cập nhật một tiện ích có thuật toán đã được thay đổi vào tháng 2 năm 2023.
Nếu bạn cần cập nhật tiện ích trên bộ xử lý T31, vui lòng thêm hậu tố -mips vào URL của tiện ích đã tải xuống.
Lệnh thứ hai cập nhật chính các thành phần firmware. 

```
curl -L -o /tmp/ipcinfo https://github.com/OpenIPC/ipctool/releases/download/latest/ipcinfo && chmod +x /tmp/ipcinfo; /tmp/ipcinfo -csF
curl -s https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade | sh -s -- -k -r -n
```

### Có thể chuyển đổi từ "lite" sang "ultimate" qua "Over the Air" không?

Trên Ingenic và Sigmastar, có thể tách rootfs.squashfs cuối cùng và flash nó vào phân vùng rootfs (mtd3) và overlay (mtd4).

```
dd if=rootfs.squashfs of=mtd3.bin bs=1k count=5120
dd if=rootfs.squashfs of=mtd4.bin bs=1k skip=5120
flashcp mtd3.bin /dev/mtd3 -v
flashcp mtd4.bin /dev/mtd4 -v
```

### Làm cách nào để dump toàn bộ firmware vào chia sẻ NFS?

Điều này có thể hoạt động nếu bạn may mắn, bạn đã truy cập vào shell Linux trên firmware gốc
và nó hỗ trợ gắn kết NFS:

```bash
fw=$(mktemp -t)
nfs=$(dirname $fw)/nfs
mkdir -p $nfs
mount -t nfs -o tcp,nolock 192.168.1.123:/path/to/nfs/share $nfs
cat /dev/mtdblock? > $fw
mv $fw ${nfs}/firmware_full.bin
```

Hãy chắc chắn sử dụng địa chỉ IP và đường dẫn của riêng bạn đến chia sẻ NFS!

### Làm cách nào để tìm địa chỉ MAC gốc trong bản dump firmware?

```bash
strings dumpfile.bin | grep ^ethaddr
```

### Làm cách nào để cấu hình ủy quyền phiên ssh bằng khóa?

**Trên camera**: Đăng nhập vào giao diện người dùng web trên cổng 85 của camera của bạn.

```bash
passwd
```

**Trên máy tính để bàn**: Sao chép khóa chung vào camera bằng cách đăng nhập bằng
mật khẩu đã tạo ở trên.

```bash
ssh-copy-id root@192.168.1.66
```

**Trên camera**: Tạo một thư mục `.ssh` trong thư mục chính của người dùng root
và sao chép tệp có kho khóa được ủy quyền vào đó.

```bash
mkdir ~/.ssh
cp /etc/dropbear/authorized_keys ~/.ssh/
```

**Trên máy tính để bàn**: Mở một phiên mới để xác minh rằng ủy quyền được
chuyển bằng cách sử dụng khóa chung mà không yêu cầu mật khẩu.

```bash
ssh root@192.168.1.66
```

### Majestic

#### Làm cách nào để lấy bản dump bộ nhớ để gỡ lỗi?

Bật và cấu hình Core Dump trong menu **Majestic** > **Majestic Debugging**.

#### Hình ảnh camera có màu hồng

Bạn cần chỉ định chân GPIO để điều khiển bộ lọc hồng ngoại.
Cài đặt cho một số camera có thể được tìm thấy trong [bảng này][1].
Nếu camera của bạn không có trong bảng, bạn cần sử dụng [tiện ích ipctool][2].

Firmware OpenIPC sẽ tự động tải xuống phiên bản mới nhất của
tiện ích vào thư mục `/tmp` khi `ipctool` được gọi lần đầu tiên.

Trên firmware gốc, bạn sẽ cần tự tải xuống tiện ích vào camera
bằng cách sử dụng bất kỳ công cụ nào có sẵn trong hệ thống: wget, curl, tftp, v.v.

Ví dụ: tải xuống tiện ích ipctool vào máy chủ TFTP trên mạng cục bộ,
sau đó tải xuống camera:

```bash
tftp -g -r ipctool -l /tmp/ipctool 192.168.1.1
chmod +x /tmp/ipctool
/tmp/ipctool
```

Nếu camera có quyền truy cập internet, bạn có thể thử gắn kết chia sẻ NFS công cộng
và chạy tiện ích từ đó, mà không cần tải xuống camera:

```bash
mkdir -p /tmp/utils
mount -o nolock 95.217.179.189:/srv/ro /tmp/utils/
/tmp/utils/ipctool
```

Sau khi tiện ích được tải xuống camera, hãy chạy lệnh `ipctool gpio scan`
trong thiết bị đầu cuối và đóng-mở ống kính camera vài lần bằng
lòng bàn tay của bạn.

Xem đầu ra của ipctool để xác định các chân chịu trách nhiệm điều khiển
màn che bộ lọc IR.

Nhập các giá trị thu được trong cài đặt cho chế độ ban đêm Majestic. Nếu
màu hồng vẫn còn, bạn có thể cần bật **đảo ngược tín hiệu cảm biến**.

Đừng quên thêm model camera và giá trị GPIO đã tìm thấy vào bảng!

#### Có thể hiển thị dữ liệu để đặt tự động lấy nét của ống kính
thay vì sample_af hiện tại trong /metrics tiêu chuẩn không?

Không, đây là một thuật toán khó, không có ý nghĩa để chạy theo cách này.

#### Sao chép tệp từ hệ thống Linux sang camera

Đôi khi bạn cần chuyển tệp sang camera. Ngoài phương pháp trên
sử dụng NFS (Hệ thống tệp mạng), bạn có thể sử dụng lệnh `scp` tiêu chuẩn của Linux
để sao chép tệp qua kết nối SSH:
```bash
scp ~/tệp_của_tôi root@192.168.1.65:/tmp/
```
Lệnh này sẽ sao chép `tệp_của_tôi` từ thư mục chính sang thư mục `/tmp/`
trên camera.

Trên các hệ thống Linux gần đây, lỗi sau có thể xảy ra:
```console
sh: /usr/libexec/sftp-server: không tìm thấy
scp: Kết nối đã đóng
```
Trong trường hợp này, hãy thêm tùy chọn `-O` vào lệnh:
```bash
scp -O ~/tệp_của_tôi root@192.168.1.65:/tmp/
```


[1]: https://openipc.org/wiki/en/gpio-settings.html
[2]: https://github.com/OpenIPC/ipctool/releases/download/latest/ipctool
[3]: https://github.com/OpenIPC/firmware/releases/tag/latest
