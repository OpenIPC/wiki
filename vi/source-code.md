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

Chúng tôi hiện đang phát triển kho lưu trữ mã nguồn chất lượng cao. Sự kiên nhẫn của bạn được đánh giá cao khi chúng tôi cố gắng mang đến một dự án hoàn thiện và sẵn sàng sử dụng.

## Xây dựng từ Nguồn

Trước khi bạn bắt đầu xây dựng firmware của riêng mình, điều cần thiết là phải thực hiện một số thay đổi đối với hệ thống của bạn và hiểu quy trình chung.

### Sao chép Kho lưu trữ Git Firmware OpenIPC

```cd
mkdir -p local/src
cd local/src
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
```

### Cài đặt các Gói Bắt buộc

```bash
sudo make deps
```

Đối với Debian/Ubuntu, một ví dụ về việc cài đặt các gói cần thiết và tải xuống kho lưu trữ của chúng tôi:

```sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
git clone --depth=1 https://github.com/OpenIPC/firmware.git
cd firmware
```

Ngoài ra, bạn có thể sử dụng lệnh sau trong thư mục gốc của thư mục firmware OpenIPC của bạn để cài đặt các phụ thuộc:

```bash
sudo make deps
```

### Xây dựng Nhanh từ Nguồn

Để xây dựng phiên bản firmware mong muốn cho bộ xử lý của bạn, hãy chạy lệnh sau trong thư mục gốc của dự án. Các tệp sẽ có sẵn trong thư mục "output/images".

```bash
./building.sh hi3518ev300_ultimate
```

Ví dụ về việc xây dựng lại kernel Linux, hệ thống tệp gốc và các gói riêng lẻ trong dự án của chúng tôi:

```BOARD=hi3518ev300_ultimate  make br-linux-{dirclean,rebuild}
BOARD=hi3518ev300_ultimate  make br-rootfs-{squashfs,tar}
BOARD=hi3518ev300_ultimate  make br-vtund-openipc-{dirclean,rebuild}
```

### Tạo Bộ nhớ Lưu trữ Vĩnh viễn cho các Gói Đã tải xuống

Theo mặc định, Buildroot lưu trữ tất cả các tệp đã tải xuống trong thư mục `dl/` bên trong
cây tệp buildroot.

Tập lệnh xây dựng OpenIPC tạo một cây tệp buildroot mới trước mỗi lần
biên dịch, nghĩa là xóa tất cả các gói đã tải xuống hoặc sao chép chúng qua lại
trước và sau khi tạo thiết lập mới.

Bạn có thể đặt thư mục lưu trữ của riêng mình bên ngoài cây buildroot. Thêm
đoạn mã sau vào tệp `.profile` trong thư mục chính của bạn:

```bash
BR2_DL_DIR="${HOME}/buildroot_dl"
[ ! -d "$BR2_DL_DIR" ] && mkdir -p $BR2_DL_DIR
export BR2_DL_DIR
```

Sau đó, lấy nguồn thay đổi.

```bash
source ~/.profile
```

### Xây dựng firmware.

Việc xây dựng một firmware nhị phân cho camera IP của bạn khá dễ dàng. Chỉ cần sao chép
mã nguồn từ kho lưu trữ và chạy:

```bash
make
```

Bạn sẽ được chào đón với một danh sách các mục tiêu khả dụng.

![](../images/firmware-building-whiptail.webp)

Tên của mỗi mục tiêu bao gồm tên của nhà cung cấp, kiểu SoC (System-on-Chip,
trái tim của camera IP, bộ xử lý trung tâm với các tính năng bổ sung) và hương vị
biểu thị các bản phát hành cho các mục đích khác nhau - **Lite**, bản phát hành nhỏ gọn cho
camera chỉ có 8MB ROM; **Ultimate**, bản phát hành mở rộng cho camera
có ROM 16MB +, **FPV**, bản phát hành được tạo riêng để sử dụng trong máy bay không người lái,
hoặc **Mini**, phiên bản firmware được giải phóng hoàn toàn với một
bộ phát trực tuyến mã nguồn mở thay thế.

Chọn mục tiêu mong muốn và nhấn enter. Việc xây dựng sẽ bắt đầu.

Quá trình xây dựng firmware nhị phân mất từ 15-20 phút đến vài giờ
tùy thuộc vào hiệu suất máy tính của bạn và mục tiêu đã chọn. Nếu bạn muốn
tăng tốc quá trình, hãy đảm bảo bạn sử dụng máy tính có SSD thay vì HDD vì
quá trình biên dịch liên quan đến rất nhiều thao tác đọc và ghi. CPU nhanh hơn
cũng có lợi và người ta cũng không thể có quá nhiều RAM. Bạn thậm chí có thể thuê
một máy chủ ảo trực tuyến với giá vài xu để biên dịch firmware của mình với
sức mạnh của điện toán đám mây.

Lần chạy đầu tiên là lâu nhất vì tập lệnh sẽ tải xuống mọi
gói nguồn cần thiết để biên dịch thành công. Các lần chạy tiếp theo sẽ mất ít hơn một chút
thời gian.

Sau khi quá trình biên dịch hoàn tất, bạn sẽ tìm thấy kernel nhị phân cuối cùng và
hình ảnh `rootfs` trong thư mục `output/images/`.

```
paul@r610:~/src/openipc-firmware$ ls -l output/images/
total 35628
-rw-r--r-- 1 paul paul  4816896 Nov 22 06:06 rootfs.squashfs.t10
-rw-r--r-- 1 paul paul 14520320 Nov 22 06:06 rootfs.t10.cpio
-rw-r--r-- 1 paul paul 15544320 Nov 22 06:06 rootfs.t10.tar
-rw-r--r-- 1 paul paul  1597586 Nov 22 06:02 uImage.t10
```

## Cài đặt Firmware

Sau khi bạn xây dựng firmware tùy chỉnh của mình, bạn cần cài đặt nó trên camera.
Bạn có thể làm điều đó theo hai cách:
1. Sử dụng hướng dẫn Cài đặt Nâng cao như bạn đã làm lần đầu tiên bạn flash camera: sao chép các tệp bản dựng vào máy chủ TFTP của bạn và sau đó thực hiện quy trình flash như được giải thích trong Hướng dẫn Nâng cao cụ thể cho camera của bạn;
2. Cài đặt thủ công: khởi động camera của bạn, kết nối nó với mạng cục bộ của bạn và sau đó sử dụng scp sao chép hai tệp (rootfs và uImage) vào thư mục /tmp của camera của bạn (thư mục /tmp là bộ nhớ tạm thời, lớn bằng RAM trống của camera).
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

Hãy nhớ! Người dùng và mật khẩu sẽ được đặt lại về mặc định trong hầu hết các trường hợp (mặc định thường là root/12345)

## Giải phẫu Dự án

OpenIPC firmware v2 sử dụng [Buildroot][1] để xây dựng các tệp nhị phân firmware của nó. Vì vậy
bạn nên làm quen với [Tài liệu Buildroot][2] nếu bạn
muốn không chỉ biên dịch mã nguồn được cung cấp mà còn thực hiện các sửa đổi của riêng bạn
cho firmware.

Bạn có thể thêm trình điều khiển hoặc phần mềm không có trong bản phát hành chính thức của chúng tôi, bạn
có thể xóa trình điều khiển hoặc phần mềm không cần thiết mà bạn sẽ không sử dụng, để giải phóng
một số dung lượng trong firmware. Bạn có thể thay đổi cài đặt mặc định để phù hợp hơn
với nhu cầu của bạn. Vẻ đẹp của mã nguồn mở là bất kỳ ai cũng có thể cải thiện nó, bất cứ lúc nào.
Chỉ cần đừng quên đóng góp những thay đổi của bạn trở lại kho lưu trữ ngược dòng để
mọi người đều có thể hưởng lợi từ nó.

Xin lưu ý rằng OpenIPC sử dụng phiên bản Buildroot hơi lỗi thời. Kể từ
hôm nay, đó là Buildroot [2021.02.12][3], vì vậy bạn có thể cần kiểm tra
tài liệu cho phiên bản cụ thể đó, vì các phiên bản sau có thể có
những thay đổi không tương thích.

Nguồn firmware OpenIPC được tổ chức trong các thư mục theo nhà cung cấp SoC camera IP
như các cây bên ngoài Buildroot, cụ thể là `br-ext-chip-<tên nhà cung cấp>`. Mỗi
thư mục như vậy có một số thư mục con: `board/`, `configs/`, `linux/` và
`packages/` và một số tệp cấu hình, tất cả đều liên quan đến các bảng khác nhau mang
chip từ nhà cung cấp cụ thể đó.

Thư mục `board/` bao gồm các thư mục con được đặt tên theo các nhóm bộ xử lý được gọi là
họ. Bên trong mỗi thư mục gia đình như vậy có cấu hình kernel
tệp cho các bộ xử lý riêng lẻ trong họ đó, các bản vá chung và các
tệp dành riêng cho gia đình khác.

Thư mục `configs/` bao gồm các tệp cấu hình mặc định (defconfig) cho
nhiều bảng có bộ xử lý từ nhà cung cấp đã cho. Các tệp cấu hình này cũng
có thể khác nhau về cài đặt phần cứng, tập hợp các gói bao gồm, cài đặt mặc định
khác nhau, thương hiệu, v.v. Mỗi tệp defconfig này là một
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
Liệu điều đó có khả thi? May mắn thay, có. Tất cả những gì bạn phải làm sau khi thực hiện thay đổi
đối với cấu hình gói là chạy một vài lệnh:
```
make br-<package>-dirclean
make br-<package>-rebuild
```
trong đó _\<package>_ là tên của gói bạn muốn biên dịch lại. Mặc dù,
như hướng dẫn sử dụng Buildroot đã nêu,

> Trong khi `br-<package>-rebuild` ngụ ý `br-<package>-reinstall` và `br-<package>-reconfigure`
ngụ ý `br-<package>-rebuild`, các mục tiêu này cũng như `<package>` chỉ hoạt động trên
gói đã nói và không kích hoạt việc tạo lại hình ảnh hệ thống tệp gốc.
Nếu cần tạo lại hệ thống tệp gốc, ngoài ra, người ta nên chạy
`make br-all`.

Chạy `make br-linux-rebuild br-all` để xây dựng lại hình ảnh kernel Linux,
`make br-busybox-rebuild br-all` để xây dựng lại busybox và đóng gói nó vào hình ảnh rootfs.

Hãy nhớ! tên của gói trong hai lệnh trên là tên thư mục của gói của bạn, không phải tên gói mà bạn đã đặt trong tệp Config.in

Nếu bạn muốn thêm gói mới vào một dự án cụ thể, đây là những thay đổi bạn cần thực hiện (ví dụ: bảng goke, loại firmware fpv; các bước có thể được áp dụng cho bất kỳ dự án nào hoặc tất cả các dự án):
  * Thêm gói mới của bạn vào thư mục [root]/general/package/ (trong đó [root] là thư mục cục bộ nơi bạn đã sao chép kho lưu trữ firmware);
  * Thêm tệp Config.in gói mới của bạn vào danh sách các gói nguồn trong tệp này: [root]/general/package/Config.in
  * Sửa đổi cấu hình dự án mục tiêu của bạn (tức là bảng goke, firmware fpv) để bao gồm và xây dựng gói mới của bạn, hãy thêm gói của bạn vào tệp này: [root]/br-ext-chip-qoke/configs/gk7205v200_fpv_def_config
  * Xây dựng firmware.

Sau khi bản dựng hoàn tất, gói của bạn (nếu nó đã cài đặt bất kỳ tệp nào) sẽ là một phần của hình ảnh và hệ thống tệp được tạo.


### Xây dựng Phiên bản Firmware Tùy chỉnh

Đôi khi bạn cần thêm trình điều khiển hoặc gói vào firmware. Làm thế nào bạn có thể
thực hiện điều đó bằng cách sử dụng nguồn Firmware OpenIPC được cung cấp? Nó thực sự dễ dàng. Sao chép
kho lưu trữ firmware cục bộ và biên dịch các tệp nhị phân cho cụ thể của bạn
phần cứng.

Quá trình biên dịch phụ thuộc rất nhiều vào hiệu suất máy tính của bạn. Càng nhiều CPU
luồng và bộ nhớ bạn nhận được, quá trình càng nhanh. Dù sao, bạn có thể mong đợi
việc biên dịch ban đầu sẽ kéo dài khoảng nửa giờ, cho hoặc nhận. Kết quả
các tệp nhị phân sẽ nằm trong thư mục `output/images`. Nếu bạn không thực hiện bất kỳ
thay đổi nào đối với nguồn thì các tệp này sẽ giống hệt với các tệp đó
[có sẵn từ GitHub][4].

Quá trình biên dịch cũng đã xây dựng một chuỗi công cụ phù hợp để biên dịch các gói
cho phiên bản firmware của bạn. Chuỗi công cụ nằm trong `output/host`
danh mục.

Để tùy chỉnh firmware của bạn, thêm hoặc xóa một gói, hãy chạy `make br-menuconfig`.
Điều đó sẽ tải menu cấu hình buildroot, nơi bạn có thể thực hiện thay đổi theo
[Hướng dẫn sử dụng Buildroot][5]. Thực hiện thay đổi của bạn và lưu cấu hình đã sửa đổi khi thoát.
Sau đó chạy `make clean all`.

__Hãy lưu ý rằng việc xây dựng firmware trực tiếp với buildroot sẽ không đổi tên
các tệp hình ảnh kết quả bằng cách thêm hậu tố soc vào chúng. Bạn có thể tự làm
điều đó hoặc điều chỉnh firmware của mình bằng cách cập nhật các lệnh cho phù hợp.__


[1]: https://buildroot.org/
[2]: https://buildroot.org/docs.html
[3]: https://github.com/OpenIPC/firmware/blob/96b2a0ed2f5457fda5b903ab67146f30b5062147/Makefile#L25
[4]: https://github.com/OpenIPC/firmware/releases/tag/latest
[5]: https://buildroot.org/downloads/manual/manual.html

