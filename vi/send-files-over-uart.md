# OpenIPC Wiki
[Mục lục](../README.md)

Cách gửi tệp qua UART
---------------------------

Nếu đầu đọc thẻ SD bị lỗi và không có mạng nào được cấu hình trên camera của bạn, bạn có thể cần gửi firmware mới qua giao diện UART để cập nhật camera.

## Bên gửi:

1- Đầu tiên, chúng ta mã hóa các tệp

```bash
base64 uImage > uImage.b
```

2- Bây giờ hãy đảm bảo lệnh gửi tệp com của bạn là ascii-xfr, đây là dòng lệnh kết nối của tôi

```bash
picocom -f n -p n -d 8 -b 115200  --send-cmd "ascii-xfr -snv" /dev/ttyUSB0

```

Thông thường, chúng ta muốn ascii-xfr ở phía nhận, nhưng vì chúng ta không có, nên -n giải quyết vấn đề này bằng cách duy trì các kết thúc dòng chính xác.



## Bên nhận:

3- Bây giờ chúng ta đã kết nối, hãy chuyển đến thư mục nơi bạn muốn nhận tệp.
```bash
cd /tmp/
```

4- Bắt đầu nhận tệp bằng uart
```bash
cat > uImage.b
```
5- Trên picocom, tôi chỉ CTRL+a+s, và nhập đường dẫn đầy đủ của tệp tôi đang gửi. Sau khi quá trình truyền hoàn tất, bạn sẽ cần CTRL+c để ngắt lệnh cat.

6- Bây giờ chúng ta giải mã tệp,
```bash
base64 -d uImage.b > uImage
```

7- Hãy làm bất cứ điều gì bạn có thể để xác minh rằng tệp GIỐNG HỆT với tệp bạn đã gửi, vì truyền ASCII không có bảo vệ tổng kiểm tra. 
Openipc có sha512sum, nhưng bất kỳ lệnh tổng kiểm tra nào cũng đủ. 


```bash
sha256sum uImage
```
Sau khi bạn xác nhận thủ công rằng các tổng khớp nhau, bạn có thể giả định rằng quá trình truyền đã thành công!

Lặp lại các bước 4, 5 và 6 cho rootfs và bây giờ bạn sẽ có thể nâng cấp bằng sysupgrade

```bash
sysupgrade --kernel=/tmp/uImage --rootfs=/tmp/rootfs.squashfs --force_ver -z
```

