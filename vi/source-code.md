# Hướng dẫn Phát triển Firmware OpenIPC

## Mục lục
- Giới thiệu
- Xây dựng từ Nguồn
- Cài đặt Firmware
- Giải phẫu Dự án
- Sửa đổi và Thêm Gói
- Xây dựng Phiên bản Firmware Tùy chỉnh
- Dữ liệu Thống kê

## Giới thiệu

Tài liệu này đóng vai trò là hướng dẫn toàn diện cho các nhà phát triển muốn đóng góp vào firmware OpenIPC, bao gồm cách xây dựng từ nguồn, tìm hiểu cấu trúc của dự án, sửa đổi và thêm các gói mới, cũng như hướng dẫn cài đặt firmware trên thiết bị.

Chúng tôi liên tục nỗ lực để tạo ra kho lưu trữ mã nguồn chất lượng cao. Sự kiên nhẫn của bạn được đánh giá cao khi chúng tôi cố gắng mang đến một dự án hoàn thiện và sẵn sàng sử dụng. Chúng tôi hoan nghênh những suy nghĩ và phản hồi của bạn thông qua [kênh telegram OpenIPC](https://t.me/openipc/117235)

## Xây dựng từ Nguồn

Trước khi bạn bắt đầu xây dựng firmware của riêng mình, điều cần thiết là phải thực hiện một số thay đổi đối với hệ thống của bạn và hiểu quy trình chung.

### Sao chép Kho lưu trữ Git Firmware OpenIPC
Bước đầu tiên là tạo một bản sao cục bộ của mã nguồn firmware OpenIPC. Chúng tôi đang sử dụng 'mylocalOpenIPC/src' trong tập lệnh bên dưới nhưng bạn có thể thay đổi điều này thành bất kỳ vị trí nào bạn muốn, ví dụ: ~/myprojects/myOpenIPC

```cd
mkdir -p mylocalOpenIPC/src
cd mylocalOpenIPC/src
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
```
Bây giờ chúng ta có một bản sao của mã nguồn kho lưu trữ firmware.

### Cài đặt các Gói Bắt buộc
Để đảm bảo hệ thống của bạn có các phần phụ thuộc cần thiết cho bản dựng thành công, bạn có thể sử dụng lệnh **make deps** được tạo sẵn trong thư mục gốc openipc-firmware mà bạn vừa tạo hoặc nhập các lệnh theo cách thủ công trong cửa sổ terminal.

Để chạy tập lệnh make (cách được khuyến nghị vì điều này sẽ được duy trì trong chính kho lưu trữ git mã nguồn), hãy thực hiện điều này
```bash
sudo make deps
```

hoặc để tự nhập các lệnh theo cách thủ công, hãy làm như sau:
```sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential cpio \
 curl file fzf git libncurses-dev libtool lzop make rsync unzip wget libssl-dev
```

### Tạo Bộ nhớ Lưu trữ Vĩnh viễn cho các Gói Đã tải xuống
[Buildroot](https://buildroot.org/) là bản phân phối Linux được sử dụng cho OpenIPC. Nó được sử dụng trong nhiều hệ thống nhúng vì nó có dung lượng rất nhỏ và có thể dễ dàng tùy chỉnh để bao gồm hoặc loại trừ chức năng cụ thể (xem [bài viết này](https://github.com/OpenIPC/wiki/blob/master/en/dev-buildroot-packages.md) về những gì được bao gồm trong bản dựng OpenIPC).

Theo mặc định, mỗi khi bạn build firmware, tập lệnh build OpenIPC sẽ tạo một cây tệp nguồn buildroot mới dẫn đến việc tải xuống hoặc sao chép tệp không cần thiết. Để tránh điều này, bạn có thể tạo một vị trí vĩnh viễn và đặt biến môi trường BR2_DL_DIR để thông báo cho tập lệnh build sử dụng điều này mỗi lần.

Thêm đoạn mã sau vào tệp `.profile` trong thư mục chính của bạn bằng trình soạn thảo văn bản yêu thích của bạn, ví dụ: nano ~/.profile
```bash
#Thư mục Buildroot cho bản dựng OpenIPC
BR2_DL_DIR="${HOME}/buildroot_dl"
[ ! -d "$BR2_DL_DIR" ] && mkdir -p $BR2_DL_DIR
export BR2_DL_DIR
```

Sau đó, lấy nguồn thay đổi để chúng có hiệu lực ngay lập tức.

```bash
source ~/.profile
```

### Xây dựng firmware.
Nếu bạn đã làm theo các bước trên, thì bây giờ bạn đã sẵn sàng để build firmware cho model camera cụ thể của mình.

Makefile nằm trong thư mục firmware chứa tập lệnh build cho mỗi model camera được hỗ trợ.

Bạn chỉ cần đảm bảo rằng bạn đang ở trong thư mục firmware, ví dụ: ~/mylocalOpenIPC/src/openipc-firmware và chạy make.

```bash
cd ~/mylocalOpenIPC/src/openipc-firmware
make
```

Bạn sẽ được chào đón bằng một danh sách các mục tiêu khả dụng.

![hình ảnh](https://github.com/user-attachments/assets/4e3c87e7-560a-45bb-89e5-2259282e8f2a)

Tên của mỗi mục tiêu bao gồm tên của nhà cung cấp, model SoC (System-on-Chip,
trái tim của camera IP, bộ xử lý trung tâm với các tính năng bổ sung) và hương vị
biểu thị các bản phát hành cho các mục đích khác nhau - **Lite**, bản phát hành nhỏ gọn cho
camera chỉ có 8MB ROM; **Ultimate**, bản phát hành mở rộng cho camera
có ROM 16MB +, **FPV**, bản phát hành được tạo riêng để sử dụng trong máy bay không người lái,
hoặc **Mini**, phiên bản firmware được giải phóng hoàn toàn với một
trình phát trực tuyến mã nguồn mở thay thế.

Chọn mục tiêu mong muốn và nhấn enter. Việc xây dựng sẽ bắt đầu.

_Nếu bạn gặp lỗi 'tar: This does not look like a tar archive', hãy xem Lưu ý ở cuối phần này_

Quá trình build tệp nhị phân firmware mất từ 15-20 phút đến vài giờ
tùy thuộc vào hiệu suất máy tính của bạn và mục tiêu đã chọn. Nếu bạn muốn
tăng tốc quá trình, hãy đảm bảo rằng bạn sử dụng máy tính có SSD thay vì HDD vì
quá trình biên dịch liên quan đến rất nhiều thao tác đọc và ghi. CPU nhanh hơn
cũng có lợi và không thể có quá nhiều RAM. Bạn thậm chí có thể thuê
một máy chủ ảo trực tuyến với giá vài xu để biên dịch firmware của mình bằng
sức mạnh của điện toán đám mây.

Lần chạy đầu tiên là lâu nhất vì tập lệnh sẽ tải xuống mọi
gói nguồn cần thiết để biên dịch thành công. Các lần chạy tiếp theo sẽ mất ít hơn một chút
thời gian.

Sau khi quá trình biên dịch hoàn tất, bạn sẽ tìm thấy kernel nhị phân cuối cùng **uImage** và
hình ảnh **rootfs** trong thư mục `output/images/`.

```
~/mylocalOpenIPC/src/openipc-firmware/output/images$ ls -la
total 39352
-rw-rw-r-- 1 chrisdev chrisdev  6515434 Sep  5 14:52 openipc.v83x-nor-lite.tgz
-rw-r--r-- 1 chrisdev chrisdev 12971008 Sep  5 14:52 rootfs.cpio
-rw-r--r-- 1 chrisdev chrisdev  4464640 Sep  5 14:52 rootfs.squashfs.v83x
-rw-r--r-- 1 chrisdev chrisdev 14274560 Sep  5 14:52 rootfs.v83x.tar
-rw-r--r-- 1 chrisdev chrisdev  2058032 Sep  5 14:50 uImage.v83x
```


** **Lưu ý: Lỗi 'tar: This does not look like a tar archive'** \
Nếu bạn đang sử dụng Ubuntu, bạn có thể gặp phải sự cố khi sử dụng wget trong các tập lệnh make khiến bản dựng không thành công và được báo cáo cho bảng điều khiển với thông báo 'tar: This does not look like a tar archive'. Điều này là do lệnh wget được sử dụng trong tập lệnh không xác thực đúng cách và do đó kết quả là một tệp trống.

Cách giải quyết cho vấn đề này là đảm bảo Makefile trong thư mục firmware được cập nhật với việc thêm '--ca-directory=/etc/ssl/certs' để phần chuẩn bị bây giờ sẽ đọc
```
prepare:
	@if test ! -e $(TARGET)/buildroot-$(BR_VER); then \
		wget -c -q --ca-directory=/etc/ssl/certs $(BR_LINK)/$(BR_VER).tar.gz -O $(BR_FILE); \
		mkdir -p $(TARGET); tar -xf $(BR_FILE) -C $(TARGET); fi
```
và tệp general/external.mk cũng được cập nhật để bao gồm:
```
export WGET := wget --ca-directory=/etc/ssl/certs --show-progress --passive-ftp -nd -t5 -T10
```


## Cài đặt Firmware

Sau khi bạn đã xây dựng firmware, bạn cần cài đặt nó trên camera.

Bạn có thể làm điều đó theo nhiều cách:
1) Nếu bạn có bảng mạch camera được hỗ trợ đầy đủ thì sau khi sao chép các tệp uImage và rootfs.squashfs mới từ thư mục output/images của bạn sang máy chủ tftp, hãy sử dụng hướng dẫn Cài đặt Nâng cao là một phần của hướng dẫn được tạo mà bạn đã sử dụng ban đầu. Nếu bạn không có sẵn điều này, thì [chỉ cần tạo lại](https://openipc.org/supported-hardware/featured).

2) Làm theo tài liệu wiki về [nâng cấp firmware](https://github.com/OpenIPC/wiki/blob/master/en/sysupgrade.md) bằng cách sử dụng các tệp do bạn tạo ra.
   
3) Cài đặt thủ công: khởi động camera của bạn, kết nối nó với mạng cục bộ của bạn và sau đó sử dụng scp để sao chép hai tệp (rootfs và uImage) vào thư mục /tmp của camera (/tmp là bộ nhớ tạm thời, lớn bằng RAM trống của camera).
Sau đó, chạy các lệnh này:

```
sysupgrade --kernel=/tmp/uImage.... --rootfs=/tmp/rootfs.... -z
```
Thay thế uImage... và rootfs... bằng tên tệp thực tế của bạn là kết quả của quá trình xây dựng.
Bạn có thể thêm khóa -n nếu bạn cần dọn dẹp lớp phủ sau khi cập nhật (đặt lại tất cả cài đặt về mặc định).
Sau khi cài đặt hoàn tất, camera sẽ tự động khởi động lại.
Kết nối lại với camera và chạy lệnh này (giống như -n trong lệnh trước):

```
firstboot
```

Hãy nhớ! Tên người dùng và mật khẩu sẽ được đặt lại về mặc định trong hầu hết các trường hợp (mặc định thường là root/12345)

## Giải phẫu Dự án

Firmware OpenIPC v2 sử dụng [Buildroot][1] để xây dựng các tệp nhị phân firmware của nó. Vì vậy,
bạn nên tự làm quen với [Tài liệu Buildroot][2] nếu bạn
muốn không chỉ biên dịch mã nguồn mà còn thực hiện các sửa đổi của riêng bạn
cho firmware.

Bạn có thể thêm trình điều khiển hoặc phần mềm không có trong bản phát hành chính thức của chúng tôi, bạn
có thể xóa trình điều khiển hoặc phần mềm không cần thiết mà bạn sẽ không sử dụng để giải phóng
dung lượng trong firmware. Bạn có thể thay đổi cài đặt mặc định để phù hợp hơn
với nhu cầu của bạn. Vẻ đẹp của mã nguồn mở là bất kỳ ai cũng có thể cải thiện nó, bất cứ lúc nào.
Chỉ cần đừng quên đóng góp những thay đổi của bạn trở lại kho lưu trữ ngược dòng để
mọi người đều có thể hưởng lợi từ nó.

Xin lưu ý rằng OpenIPC sử dụng phiên bản Buildroot hơi lỗi thời. Tính đến
hôm nay, đó là Buildroot 2024.02.1, vì vậy bạn có thể cần kiểm tra
tài liệu cho phiên bản cụ thể đó, vì các phiên bản sau có thể có
những thay đổi không tương thích.

Nguồn firmware OpenIPC được tổ chức trong các thư mục theo nhà cung cấp SoC camera IP
như các cây bên ngoài Buildroot, cụ thể là `br-ext-chip-<tên nhà cung cấp>`.

![hình ảnh](https://github.com/user-attachments/assets/bd060676-7008-41ae-9ec6-f0ed18f6f48e)

Mỗi thư mục có một số thư mục con: `board/`, `configs/`, `linux/` và
`packages/` và một số tệp cấu hình, tất cả đều liên quan đến các bảng khác nhau mang
chip từ nhà cung cấp cụ thể đó.

Thư mục `board/` bao gồm các thư mục con được đặt tên theo các nhóm bộ xử lý được gọi là
họ. Bên trong mỗi thư mục họ như vậy chứa cấu hình kernel
tệp cho các bộ xử lý riêng lẻ trong họ đó, các bản vá chung và các
tệp dành riêng cho họ khác.

Thư mục `configs/` bao gồm các tệp cấu hình mặc định (defconfig) cho
nhiều bảng có bộ xử lý từ nhà cung cấp đã cho. Các tệp cấu hình này cũng
có thể khác nhau về cài đặt phần cứng, tập hợp các gói bao gồm, mặc định
cài đặt khác nhau, thương hiệu, v.v. Mỗi tệp defconfig này là một
gói riêng biệt dẫn đến một tệp nhị phân firmware riêng biệt.

Thư mục `linux/` bao gồm các tệp cấu hình để vá kernel để tạo
nó hoạt động với các đốm màu nhị phân do nhà cung cấp cung cấp, nếu có.

Thư mục `package/` có các liên kết tượng trưng đến các gói được sử dụng để xây dựng kết quả
firmware.

`Config.in` là một tệp cấu hình hợp nhất các tệp cấu hình từ tất cả
các gói được cung cấp.

`external.mk` là một makefile tham chiếu đến các makefile từ tất cả các gói được cung cấp.

`external.desc` là một tệp có mô tả về cây bên ngoài.


### Thực hiện Thay đổi và Thêm Gói

Bạn có thể sửa đổi các gói hiện có hoặc thêm các gói mới để đáp ứng nhu cầu của dự án. Phần này cung cấp các hướng dẫn về cách thực hiện các thay đổi này một cách hiệu quả.

Khi bạn bắt đầu mày mò với các gói, bạn sẽ nhận ra rằng mình cần một cách để
xây dựng lại chỉ một gói cụ thể, mà không cần xây dựng lại toàn bộ dự án.
Điều đó có khả thi không? May mắn thay, có. Tất cả những gì bạn phải làm sau khi thực hiện thay đổi
đối với cấu hình gói là chạy một vài lệnh:
```
make br-<package>-dirclean
make br-<package>-rebuild
```
trong đó _\<package>_ là tên của gói bạn muốn biên dịch lại. Mặc dù,
như hướng dẫn sử dụng Buildroot đã nêu,

> Mặc dù `br-<package>-rebuild` ngụ ý `br-<package>-reinstall` và `br-<package>-reconfigure`
> ngụ ý `br-<package>-rebuild`, các mục tiêu này cũng như `<package>` chỉ hoạt động trên
> gói đã nói và không kích hoạt việc tạo lại hình ảnh hệ thống tệp gốc.
> Nếu cần tạo lại hệ thống tệp gốc, bạn nên chạy thêm
> `make br-all`.

Chạy `make br-linux-rebuild br-all` để xây dựng lại hình ảnh kernel Linux,
`make br-busybox-rebuild br-all` để xây dựng lại busybox và đóng gói nó vào hình ảnh rootfs.

Hãy nhớ rằng tên của gói trong hai lệnh trên là tên thư mục của gói của bạn, không phải tên gói mà bạn đã đặt trong tệp Config.in

Nếu bạn muốn thêm gói mới vào một dự án cụ thể, đây là những thay đổi bạn cần thực hiện (lấy ví dụ bảng goke, loại firmware fpv; các bước có thể được áp dụng cho bất kỳ hoặc tất cả các dự án):
  * Thêm gói mới của bạn vào thư mục [root]/general/package/ (trong đó [root] là thư mục cục bộ nơi bạn đã sao chép kho lưu trữ firmware);
  * Thêm tệp Config.in gói mới của bạn vào danh sách các gói nguồn trong tệp này: [root]/general/package/Config.in
  * Sửa đổi cấu hình dự án mục tiêu của bạn (ví dụ: bảng goke, firmware fpv) để bao gồm và xây dựng gói mới của bạn, thêm gói của bạn vào tệp này: [root]/br-ext-chip-qoke/configs/gk7205v200_fpv_def_config
  * Xây dựng firmware.

Sau khi bản dựng hoàn tất, gói của bạn (nếu nó đã cài đặt bất kỳ tệp nào) sẽ là một phần của hình ảnh và hệ thống tệp được tạo.


### Xây dựng Phiên bản Firmware Tùy chỉnh

Đôi khi bạn cần thêm trình điều khiển hoặc gói vào firmware. Làm thế nào bạn có thể
thực hiện điều đó bằng cách sử dụng nguồn Firmware OpenIPC được cung cấp? Nó thực sự dễ dàng. Sao chép
kho lưu trữ firmware cục bộ và biên dịch các tệp nhị phân cho phần cứng cụ thể
của bạn.

Quá trình biên dịch phụ thuộc rất nhiều vào hiệu suất máy tính của bạn. Càng có nhiều CPU
luồng và bộ nhớ bạn nhận được, quá trình càng nhanh. Dù sao, bạn có thể mong đợi
quá trình biên dịch ban đầu sẽ kéo dài khoảng nửa giờ, cho hoặc nhận. Các kết quả
tệp nhị phân sẽ nằm trong thư mục `output/images`. Nếu bạn không thực hiện bất kỳ
thay đổi nào đối với nguồn thì các tệp này sẽ giống hệt với những tệp đó
[có sẵn từ GitHub][4].

Quá trình biên dịch cũng đã xây dựng một chuỗi công cụ phù hợp để biên dịch các gói
cho phiên bản firmware của bạn. Chuỗi công cụ nằm trong `output/host`
danh mục.

Để tùy chỉnh firmware của bạn, thêm hoặc xóa gói, hãy chạy `make br-menuconfig`.
Điều đó sẽ tải menu cấu hình buildroot, nơi bạn có thể thực hiện thay đổi theo
[Hướng dẫn sử dụng Buildroot][5]. Thực hiện thay đổi của bạn và lưu cấu hình đã sửa đổi khi thoát.
Sau đó chạy `make clean all`.

**Hãy lưu ý rằng việc xây dựng firmware trực tiếp với Buildroot sẽ không đổi tên
các tệp hình ảnh kết quả bằng cách thêm hậu tố soc vào chúng. Bạn có thể tự làm
hoặc điều chỉnh firmware của mình bằng cách cập nhật các lệnh cho phù hợp.**


[1]: https://buildroot.org/
[2]: https://buildroot.org/docs.html
[3]: https://github.com/OpenIPC/firmware/blob/96b2a0ed2f5457fda5b903ab67146f30b5062147/Makefile#L25
[4]: https://github.com/OpenIPC/firmware/releases/tag/latest
[5]: https://buildroot.org/downloads/manual/manual.html

