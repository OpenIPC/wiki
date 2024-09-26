# OpenIPC Wiki
[Mục lục](../README.md)

Smartwares CIP-37210
--------------------

### Thông tin thiết bị

| Hệ thống | Mô tả                          |
|--------|--------------------------------------|
| SoC    | HI3518EV200                          |
| Cảm biến | OmniVision OV9732                    |
| Flash  | 16Mb (Winbond 25Q128JVSQ)            |
| WiFi   | RTL8188FU                            |

### Hướng dẫn flashing từng bước

Bên cạnh camera, bạn sẽ cần các công cụ sau:
- Tuốc nơ vít hoặc đầu vít PH0
- Tuốc nơ vít đầu dẹt nhỏ, ví dụ: 0,6 × 3,5 mm
- Bộ chuyển đổi USB sang TTL để giao tiếp UART. (Tôi đã sử dụng thiết bị dựa trên CP2102, nhưng có [nhiều lựa chọn tốt khác](https://github.com/OpenIPC/wiki/blob/master/en/equipment-flashing.md))
- Thẻ nhớ microSD (Tôi đã sử dụng thẻ 2 GB cũ)
- Một số dây nhảy
- Đồng hồ vạn năng
- Máy tính chạy GNU/Linux

Phương pháp ưa thích để flash camera OpenIPC là thông qua tftp, nhưng CIP-37210 không có cổng ethernet. Một vấn đề khác là u-boot gốc được bảo vệ bằng mật khẩu và fatload (quyền truy cập đọc vào hệ thống tệp FAT) không hoạt động.

Do đó, chúng ta sẽ cần kết hợp hai phương pháp lệch khỏi quy trình tiêu chuẩn để flash Smartwares CIP-37210: [Tiện ích burn](https://github.com/OpenIPC/burn) để khởi động trực tiếp vào bộ nạp khởi động u-boot được biên dịch bởi dự án OpenIPC có thể flash từ thẻ nhớ microSD và tất nhiên là [flash từ thẻ nhớ microSD](https://paulphilippov.com/articles/flashing-ip-camera-with-full-openipc-binary-firmware-from-sd-card).

#### Mở thiết bị

Tháo vít Phillips có thể nhìn thấy ở mặt sau của đế camera bằng tuốc nơ vít PH0.
![unscrew](/images/cip-37210_open_001.jpg "Tháo vít Phillips")

Sử dụng tuốc nơ vít đầu dẹt để cạy mở vỏ camera, nơi gắn đế:
![pry_open](/images/cip-37210_open_002.jpg "Cạy mở camera")

#### Thiết lập kết nối UART

Sau khi mở thiết bị, đã đến lúc thiết lập kết nối UART. Bật nguồn cho camera đang mở bằng bộ nguồn micro USB đi kèm. Bây giờ là lúc kiểm tra 4 lỗ chân có vẻ khả nghi trên đầu PCB: Đo điện áp của các lỗ chân bằng đồng hồ vạn năng của bạn, bằng cách kết nối chúng với GND (Tôi đã sử dụng một trong các miếng đệm xung quanh các vít ở giữa).

Tôi tìm thấy hai lỗ chân có 3,3 V, một lỗ chân có điện áp hơi thấp hơn 3,3 V và một lỗ chân có 0 V. Bây giờ là lúc theo dõi các chân 3,3 V trong quá trình khởi động – chân có điện áp dao động là chân TX và chân 3,3 V ổn định là Vcc.

**Tóm lại:** Lỗ chân gần vít đen nhất là RX, lỗ chân bên cạnh là TX, lỗ chân bên cạnh là GND. Kết nối GND với GND, TX với RX và RX với TX.

![uart_cip-37210](/images/uart_cip-37210_cropped.jpg "Các lỗ chân UART được đánh dấu trên PCB CIP-37210")

Tôi đã sử dụng dây nhảy DuPont male-to-female đơn giản để kết nối với các lỗ chân. Tất nhiên, có những giải pháp tốt hơn như hàn đầu nối vào các lỗ chân hoặc sử dụng móc kiểm tra, nhưng miễn là dây nhảy không chạm vào nhau, nó sẽ hoạt động tốt.

![uart_cip-37210_action](/images/uart_cip-37210_action.jpg "Kết nối UART đã được thiết lập.")

#### Lưu firmware gốc

Trước khi flash OpenIPC, bạn nên lưu firmware gốc, trong trường hợp bạn không thích OpenIPC và muốn quay trở lại hoặc vô tình làm hỏng ("brick") thiết bị. Vì tftp là không thể nên chúng ta sẽ lưu nội dung của flash vào thẻ nhớ microSD. Vì thiết bị chạy Linux nên bạn không cần phải lo lắng về việc định dạng thẻ nhớ microSD bây giờ. Khởi động camera trong khi kết nối với bộ chuyển đổi USB sang TTL của bạn và khởi động screen:

```sh
sudo screen -L /dev/ttyUSB0 115200
```

Bây giờ là lúc đăng nhập với tư cách root với mật khẩu `I81ou812` mà tôi tìm thấy [trên internet](https://gist.github.com/gabonator/74cdd6ab4f733ff047356198c781f27d). Thẻ nhớ microSD đã được gắn tự động vào điểm gắn kết `/mnt/sd/`, vì vậy hãy tạo một thư mục mới trên thẻ SD và dump nội dung của flash:

```sh
mkdir /mnt/sd/image
for mtd in $(ls /dev/mtdblock*); do dd if=${mtd} of=/mnt/sd/image/${mtd##/*/}.bin; done
```
Bạn có thể muốn lặp lại bước này với một thư mục khác và so sánh tổng kiểm tra md5 của các tệp nhị phân để đảm bảo rằng việc dump đã thành công. Thoát khỏi screen bằng `C-a` theo sau là `d`, lắp thẻ nhớ microSD trở lại máy tính của bạn và sao lưu các tệp nhị phân.

#### Flash OpenIPC

Đã đến lúc định dạng thẻ nhớ microSD để u-boot có thể fatload hình ảnh. Những bước này có thể thay đổi tùy thuộc vào bản phân phối Linux của bạn. [Đã có một tập lệnh hoạt động trên Debian Sid](https://gist.github.com/themactep/d0b72f4c5d5f246e2551622e95bc9987), nhưng thật đáng buồn là nó không hoạt động trên máy của tôi. (Phiên bản fdisk khác nhau và cách đặt tên khác nhau của thiết bị và phân vùng). Đây là những lệnh tôi đã chạy:

```sh
# tạo bảng phân vùng
sudo parted /dev/mmcblk0 mklabel msdos
# tạo phân vùng đầu tiên
sudo parted /dev/mmcblk0 mkpart primary fat32 1MB 64MB
sudo mkfs.vfat -F32 /dev/mmcblk0p1
# tạo phân vùng thứ hai
sudo parted /dev/mmcblk0 mkpart primary fat32 64MB 128MB
sudo mkfs.vfat -F32 /dev/mmcblk0p2
```

Bây giờ là lúc gắn kết phân vùng đầu tiên và [tải xuống firmware chính xác](https://openipc.org/cameras/vendors/hisilicon/socs/hi3518ev200/download_full_image?flash_size=16&flash_type=nor&fw_release=ultimate) và sao chép nó vào phân vùng đã gắn kết. Hủy gắn kết phân vùng và lắp thẻ nhớ microSD vào camera.

Tiếp theo, cần thiết lập tiện ích burn:
```sh
git clone https://github.com/OpenIPC/burn
cd burn
sudo pip install -r requirements.txt
```
Bây giờ chúng ta cần tải xuống tệp nhị phân uboot chính xác
```sh
wget -P ./u-boot/ https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-hi3518ev200-universal.bin
```

Hãy chắc chắn rằng không có tiến trình nào đang chặn bộ chuyển đổi USB sang TTL của bạn:
```sh
sudo lsof /dev/ttyUSB0
```
Kết thúc tiến trình nếu cần thiết:
```sh
sudo kill 230002
```
Tắt nguồn camera và cũng ngắt kết nối và kết nối lại bộ chuyển đổi USB sang TTL của bạn. Bây giờ hãy nhập lệnh sau và bật nguồn camera:
```sh
./burn --chip hi3518ev200 --file=./u-boot/u-boot-hi3518ev200-universal.bin --break && screen -L /dev/ttyUSB0 115200
```
Nhấn bất kỳ phím nào để dừng tự động khởi động và bạn sẽ được chào đón bởi shell OpenIPC u-boot!
```sh
OpenIPC #
```
Đầu tiên, chúng ta cần kiểm tra xem thẻ nhớ microSD của chúng ta đã sẵn sàng để sử dụng chưa:
```sh
fatls mmc 0
```
Đầu ra sau đây được mong đợi:
```text
 16777216   openipc-hi3518ev200-ultimate-16mb.bin

1 file(s), 0 dir(s)
```
Tuyệt vời! Bây giờ là lúc tải tệp nhị phân vào bộ nhớ. Các biến là biến môi trường mà OpenIPC u-boot biết để phân giải, vì vậy bạn chỉ cần sao chép và dán:
```sh
mw.b ${baseaddr} 0xff 0x1000000; fatload mmc 0:1 ${baseaddr} openipc-${soc}-ultimate-16mb.bin
```
Điều này sẽ dẫn đến đầu ra sau:
```text
reading openipc-hi3518ev200-ultimate-16mb.bin

16777216 bytes read
```
Bây giờ là lúc để ghi và cầu nguyện:
```sh
sf probe 0; sf erase 0x0 0x1000000; sf write ${baseaddr} 0x0 ${filesize}
```
Đầu ra mong đợi trông như thế này:
```text
16384 KiB hi_fmc at 0:0 is now current device
Erasing at 0x1000000 -- 100% complete.
Writing at 0x1000000 -- 100% complete.
```

Nếu có bất cứ điều gì sai sót ở đây, đừng tắt nguồn thiết bị và hãy yêu cầu [nhóm Telegram](https://t.me/openipc) trợ giúp! Nếu không, hãy nhập `reset` và vào u-boot mới flash bằng cách nhấn bất kỳ phím nào để dừng tự động khởi động. Chạy lệnh sau và bạn đã hoàn tất:
```sh
run setnor16m
```
Bây giờ hãy tháo thẻ SD và khởi động lại bằng cách nhập `reset` một lần nữa và bạn sẽ được chào đón như thế này:
```text
Welcome to OpenIPC
openipc-hi3518ev200 login: root

    /######                                    /######  /#######    /######
   /##__  ##                                  |_  ##_/ | ##__  ##  /##__  ##
  | ##  \ ##   /######    /######   /#######    | ##   | ##  \ ## | ##  \__/
  | ##  | ##  /##__  ##  /##__  ## | ##__  ##   | ##   | #######/ | ##
  | ##  | ## | ##  \ ## | ######## | ##  \ ##   | ##   | ##____/  | ##
  | ##  | ## | ##  | ## | ##_____/ | ##  | ##   | ##   | ##       | ##    ##
  |  ######/ | #######/ |  ####### | ##  | ##  /###### | ##       |  ######/
   \______/  | ##____/   \_______/ |__/  |__/ |______/ |__/        \______/
             | ##
             | ##                              build
             |__/                             master+01a1348a, 2023-03-05

 Please help the OpenIPC Project to cover the cost of development and
 long-term maintenance of what we believe is going to become a stable,
 flexible Open IP Network Camera Framework for users worldwide.

 Your contributions could help us to advance the development and keep
 you updated on improvements and new features more regularly.

 Please visit https://openipc.org/sponsor/ to learn more. Thank you.
```

Mật khẩu root là `12345`. Đừng quên thay đổi nó bằng `passwd` sau lần đăng nhập đầu tiên!

Nếu bạn đang gặp khó khăn với hướng dẫn này và vẫn muốn thử OpenIPC trên Smartwares CIP-37210, bạn có thể [mua nó với firmware OpenIPC v2.2 được cài đặt sẵn tại open collective](https://opencollective.com/openipc/contribute/wifi-camera-showme-by-openipc-44355).

## Kết nối với wifi
Bây giờ là lúc kết nối camera với mạng Wi-Fi 2,4 GHz của bạn. Trước hết, hãy đảm bảo rằng các biến môi trường firmware được đặt chính xác.

Đầu tiên, hãy đặt trình điều khiển mạng:

```sh
fw_setenv wlandev rtl8188fu-generic
```

Sau đó, các giá trị chính xác theo nhu cầu của bạn, ví dụ:
```sh
fw_setenv wlanssid guest
fw_setenv wlanpass guest-password
```

Bạn có thể kiểm tra cài đặt như sau:
```sh
fw_printenv wlandev
fw_printenv wlanssid
fw_printenv wlanpass
```

Bước cuối cùng là cấu hình giao diện wlan0:
```sh
cat <<EOF > /etc/network/interfaces.d/wlan0
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 3 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio3/direction
    pre-up echo 1 > /sys/class/gpio/gpio3/value  # GPIO3 là nguồn cấp cho WIFI
    pre-up modprobe mac80211
    pre-up sleep 1
    pre-up modprobe 8188fu
    pre-up sleep 1
    pre-up wpa_passphrase "\$(fw_printenv -n wlanssid)" "\$(fw_printenv -n wlanpass)" > /tmp/wpa_supplicant.conf
    pre-up sed -i 's/#psk.*/scan_ssid=1/g' /tmp/wpa_supplicant.conf
    pre-up ifconfig wlan0 up
    pre-up wpa_supplicant -B -i wlan0 -D nl80211,wext -c /tmp/wpa_supplicant.conf
    pre-up sleep 3
    post-down killall -q wpa_supplicant
    post-down echo 0 > /sys/class/gpio/gpio3/value
    post-down echo 3 > /sys/class/gpio/unexport
EOF
```

Bây giờ là lúc kiểm tra xem nó có hoạt động không:
```sh
ifup wlan0
ip addr
```
Kiểm tra xem bạn có thể ping và ssh vào camera hay không. Khởi động lại và kiểm tra xem camera có tự động kết nối với mạng wifi của bạn không. Lắp ráp lại camera, bây giờ là lúc tạm biệt UART và sử dụng ssh và giao diện web. (Thông tin đăng nhập là root và mật khẩu bạn đã đặt trước đó.)

Cuối cùng, bạn nên xem `/etc/majestic.yaml` và đặc biệt đặt các phần này như sau để có ánh xạ GPIO chính xác cho chế độ ban đêm và âm thanh.

```yaml
audio:
  enabled: true
  volume: 70
  srate: 8000
  codec: alaw
  outputEnabled: true
  outputVolume: 30
  speakerPin: 51
  speakerPinInvert: true
nightMode:
  enabled: true
  irSensorPin: 62
  irSensorPinInvert: true
  irCutPin1: 64
  backlightPin: 63
  dncDelay: 30
  nightAPI: true
  irCutSingleInvert: false
```
