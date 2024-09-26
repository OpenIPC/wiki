# OpenIPC Wiki
[Mục lục](../README.md)

Truy cập SSH, telnet, FTP và các dịch vụ khác
---------------------------------------------

Rất thường xuyên, firmware gốc cung cấp quyền truy cập vào hệ điều hành của nó nhưng
quyền truy cập bị đóng với mật khẩu không được tiết lộ. Chúng ta có thể khôi phục hàm băm mật mã
của mật khẩu đó trong khi trích xuất bản sao của hình ảnh firmware.

### Hàm băm mật khẩu

```console
$1$bh2njiGH$4duacOMcXDh6myANzbZTf.
```

Chuỗi mật khẩu muối băm bao gồm ba phần: mã định danh thuật toán băm,
muối và hàm băm mật khẩu, mỗi phần được đặt trước bởi dấu đô la.
Phần đầu tiên, `$1`, là thuật toán băm được mã hóa bằng một (hiếm khi là hai)
ký tự. Nó biểu thị phương pháp mật mã được sử dụng để tạo hàm băm:

- `$1` - Thuật toán MD5.
- `$2` - Thuật toán Blowfish.
- `$2a` - Thuật toán eksblowfish
- `$5` - Thuật toán SHA-256
- `$6` - Thuật toán SHA-512

Phần thứ hai, `$bh2njiGH`, là muối - một chuỗi ký tự được thêm vào
mật khẩu văn bản thuần túy trước khi băm nó để ngẫu nhiên hóa các hàm băm kết quả
cho cùng một mật khẩu và ngăn chặn các cuộc tấn công [bảng cầu vồng][1].

Phần cuối cùng, `$4duacOMcXDh6myANzbZTf.`, là hàm băm. Khi bạn nhập
mật khẩu, nó được nối với muối được cung cấp sau đó được băm bằng
thuật toán băm được cung cấp và kết quả được so sánh với hàm băm.
Cùng một mật khẩu, muối và phương pháp băm sẽ luôn tạo ra kết quả giống nhau.

Các thuật toán băm là các phương pháp mã hóa một chiều có nghĩa là hàm băm không thể
được giải mã trở lại mật khẩu văn bản thuần túy, nhưng có thể thực hiện băm
các biến thể có sẵn của mật khẩu văn bản thuần túy cho đến khi tìm thấy kết quả khớp.
Phương pháp này được gọi là [tấn công brute-force][2].

Camera IP có xu hướng sử dụng thuật toán băm MD5 tương đối đơn giản và nhanh
nên việc sử dụng phần mềm phá mật khẩu và tài nguyên máy tính mạnh mẽ thì
mật khẩu văn bản thuần túy ban đầu có thể được chọn trong vài tuần hoặc vài ngày, nếu không
phải vài giờ, đặc biệt là sử dụng từ điển chất lượng cao.

Trong ví dụ trên, chúng tôi đã sử dụng mật khẩu "openipc". Bạn có thể kiểm tra tính hợp lệ của
mật khẩu bằng `mkpasswd` hoặc `openssl`:

```bash
$ mkpasswd -m md5crypt -S bh2njiGH openipc
$1$bh2njiGH$4duacOMcXDh6myANzbZTf.
$ openssl passwd -1 -salt bh2njiGH openipc
$1$bh2njiGH$4duacOMcXDh6myANzbZTf.
```

Khi mật khẩu được tìm thấy, nên chia sẻ công khai để những người khác
nhà nghiên cứu trong lĩnh vực này có thể dành nguồn lực mật mã của họ cho
khám phá thêm nhiều mật khẩu chưa biết. Chia sẻ là quan tâm, các bạn!

### Một số mật khẩu mà chúng tôi tìm thấy trong các firmware khác nhau

```
| Hash                                  | Văn bản thuần túy |
|---------------------------------------|------------|
| $1$MoCJ1nRA$NfsI1wlYcWoF5MbU4t3Og0    | ivdev      |
| $1$ZebZnWdY$QZ1Aa.7hwBshCS5k40MUE1    | xc12345    |
| $1$d3VPdE0x$Ztn09cyReJy5Pyn           | runtop10   |
| $1$qFa2kfke$vJob19l64Q6n8FvP8/kvJ0    | wabjtam    |
| $1$rHWQwR5V$i4FVDvwhuzau8msvAfHEt.    | 2601hx     |
| $1$tiaLlxGM$byeTUfQgqyET5asfwwNjg0    | hichiphx   |
| $1$0Me7S3z5$.uQ4Pr/QjJQ/0JUZI0w4m.    |            |
| $1$4dAkkeWK$HCy0K1z8E.wAuwgLV8bWd/    |            |
| $1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1    |            |
| $1$7BqzlCqK$nQXIfc53c1ACEwzNg7G3D.    |            |
| $1$cNGGWwI/$5/mZTMlcVfJlpE5DGrdsl/    |            |
| $1$FMNq4QIj$lJg6WzZxy1HWl3sL.YwIq1    |            |
| $1$IZfqary9$IrG6loat5pDTBLr6ksKTD0    |            |
| $1$ocmTTAhE$v.q2/jwr4BS.20KYshYQZ1    |            |
| $1$OIKWDzOV$WjZNcNtHSKVscbi9WQcpu/    |            |
| $1$rnjbbPTD$tR9oAIWgUp/jRrhjDuUwp0    |            |
| $1$RYIwEiRA$d5iRRVQ5ZeRTrJwGjRy.B0    | xmhdipc    |
| $1$uF5XC.Im$8k0Gkw4wYaZkNzuOuySIx/    |            |
| $1$vN9F.lHa$E09mbCRo70834AUfkytpX     |            |
| $1$wbAnPk8f$yz0PI9vnyLRmWbENUnce3/    |            |
| $1$ybdHbPDn$ii9aEIFNiolBbM9QxW9mr0    |            |
| $1$yq01TaSp$lkN/azu3IxE97owy27pve.    |            |
| $1$yFuJ6yns$33Bk0I91Ji0QMujkR/DPi1    |            |
| $1$yi$FS7W5j1RJmbRHDe0El/zX/          |            |
| $1$yi$MiivC6pLdwS0zp0pa0cUq1          | qw1234qw   |
| $Dg.cUjtWGTIVkuFS0ZYbN1               | fx1805     |
| $enWsv2cbxPCrd0WeXUXtX0               | nobody     |
| $qZV4X6DTqMHUDIyZG.8PH.               |            |
| $z2VkRbfNoE/xHLBj8i2cv.               | ftp        |
| 7wtxBdUGBnuoY                         | runtop10   |
| 9B60FC59706134759DBCAEA58CAF9068      | Fireitup   |
| LHjQopX4yjf1Q                         | ls123      |
| ab8nBoH3mb8.g                         | helpme     |
| absxcfbgXtb3o                         | xc3511     |
| xt5USRjG7rEDE                         | j1/_7sxw   |
| $1$EmcmB/9a$UrsXTlmYL/6eZ9A2ST2Yl/    |            |
| $1$soidjfoi$9klIbmCLq2JjYwKfEA5rH1    |            |
```

### Chiếm quyền mật khẩu mặc định
> _đã thử nghiệm trên Goke_

Qua giao diện UART, có thể tạm thời làm gián đoạn trình tự khởi động bình thường
và chuyển sang một trình bao Linux hạn chế ở giai đoạn đầu của
khởi động hệ thống.
```
setenv bootargs ${bootargs} single init=/bin/sh
boot
```
Trình bao này sẽ không tải toàn bộ hệ thống đang hoạt động, vì vậy bạn phải sửa đổi thủ công.
Đầu tiên, gắn kết hệ thống tệp `/rom`:
```
mount -t jffs2 /dev/mtdblock3 /rom
```
Gắn kết phần còn lại của các điểm gắn kết từ `/etc/fstab`:
```
mount -a
```
Ngoài ra, hãy gắn kết thẻ SD để sao chép tệp đến và đi:
```
mount /dev/mmcblk0p1 on /mnt/s0
```
Trên hệ thống tệp `/rom`, bạn có thể chỉnh sửa tệp `/room/etc/passwd` nhưng sau khi
thiết bị khởi động lại, nó sẽ được đặt lại về mặc định. Điều này xảy ra vì có
tệp bin hướng dẫn tạo lại tệp `passwd` trong mỗi lần khởi động, vì vậy chúng ta cần sửa đổi
tệp thực thi đó.

Sao chép `system.dat` vào thẻ SD:
```
cp /rom/system.dat /mnt/s0
```
Trên máy tính linux, giải nén tệp `system.dat` bằng cách sử dụng `unsquashfs`:
```
mkdir squashfs-temp
cd squashfs-temp
unsquashfs system.dat
```
Tìm tệp hướng dẫn và chỉnh sửa nội dung của nó trong trình soạn thảo hex để sửa đổi tên của
tệp mà mật khẩu được ghi trong mỗi lần khởi động lại. Tìm kiếm `/etc/passwd` và
thay đổi một chữ cái trong tên của nó thành một cái gì đó khác, như `/etc/passwT`.

Đóng gói hệ thống tệp squash bằng cách sử dụng `mksquashfs`:

```bash
mksquashfs ./squashfs-root ./file -comp xz -no-xattrs -noappend -no-exports -all-root -quiet -b 131072
```
và sao chép nó từ thẻ SD trở lại thư mục `/rom` trên camera.

Bây giờ bạn có thể thay thế mật khẩu trong `/rom/etc/passwd` bằng mật khẩu của riêng bạn và khi
bạn khởi động lại thiết bị, bạn sẽ có hệ thống hoạt động đầy đủ với mật khẩu của riêng bạn.


### Phần mềm

- [Hashcat](https://hashcat.net/)
- [John The Ripper](https://www.openwall.com/john/)
- [Hydra](https://github.com/vanhauser-thc/thc-hydra)

[1]: https://en.wikipedia.org/wiki/Rainbow_table
[2]: https://en.wikipedia.org/wiki/Brute-force_attack


---------------------------------------------------


