# OpenIPC Wiki
[Mục lục](../README.md)

Cài đặt: cách chạy OpenIPC trên phần cứng nhất định
-------------------------------------------------------------

Phần cứng được hỗ trợ và quy trình cài đặt được cung cấp trên trang web [openipc.org](https://openipc.org/firmware/).

Vui lòng làm theo hướng dẫn trên trang web cho CPU và chip video của bạn!

Dưới đây là một số ví dụ:

[Hi3516cv300 với IMX291](https://openwrt.org/docs/techref/hardware/soc/soc.hisilicon.hi35xx/ivg-hp203y-ay)

[[Hi3516Ev300-IMX335]]

## Cách nâng cấp OpenIPC

Hiện tại, nâng cấp hệ thống tự động hoàn toàn như [sysupgrade][openwrtsysupgrade]
trong OpenWRT không được hỗ trợ. Thay vào đó, hãy sử dụng cập nhật thủ công một phần.

### Cập nhật thủ công một phần

**Lưu ý!** _Nâng cấp một phần U-boot và kernel chỉ được khuyến nghị trong các trường hợp đặc biệt và nên được thực hiện cẩn thận._

Quá trình này được mô tả trên trang web chính trên [trang firmware](https://openipc.org/firmware/#update-parts-of-the-firmware).

## Câu hỏi thường gặp

* OpenIPC có thể được cài đặt trên Raspberry Pi hoặc phần cứng khác không?

Không. Hiện tại, chỉ hỗ trợ HiSilicon HI35xx SoC. Nhưng về mặt lý thuyết, có thể hỗ trợ các kiến trúc và bo mạch khác. Mặc dù điều đó sẽ đòi hỏi rất nhiều nỗ lực, và do đó, nó không phải là trọng tâm gần nhất của dự án.

* Tôi có thể flash ảnh OpenIPC mà không cần sử dụng bảng điều khiển UART và TFTP không?

Không. Hiện tại, điều đó là không thể, mặc dù chúng tôi đang nghiên cứu về vấn đề này.

* Sự khác biệt giữa OpenIPC dựa trên BuildRoot và dựa trên OpenWRT là gì?

Buildroot nhanh hơn cho việc phát triển ban đầu cho các nền tảng mới vì nó tối giản và không có phụ thuộc. OpenWRT thuận tiện cho người dùng như một sản phẩm cuối cùng, nhưng có rất nhiều phức tạp, phụ thuộc và không có ích gì khi phát triển mà không có cộng đồng.

### Các câu hỏi thường gặp khác

* [OpenIPC Wiki (ru)](https://github.com/OpenIPC/camerasrnd/blob/master/docs/FAQ-ru.md)


## Những thứ liên quan đến mạng

Cấu hình mạng phổ biến có thể được thực hiện trong Luci GUI:

`http://<địa chỉ IP camera của bạn>`

[[3G_modems]] Hỗ trợ modem USB ở chế độ hilink và ppp

## Giao diện người dùng đồ họa

Hiện tại có hai nhánh của OpenIPC:

### Dựa trên OpenWRT

GUI dựa trên Luci. Có các phần menu để thiết lập cụ thể cho camera.

### Dựa trên Buildroot

Có một giao diện khác được lên kế hoạch ... Vẫn đang được phát triển.

## Khuyến nghị liên quan đến phần cứng

### Power Over Internet PoE

Nên sử dụng bộ đổi nguồn 48V với đầu nối RJ-45 thay vì 12V.
Với bộ đổi nguồn 12V, dòng điện sẽ cao hơn 4 lần. Dòng điện cao có thể làm cháy
đầu nối và dây RJ-45.

## Cách truyền phát video lên Internet

* __MiniHttp__ ➤ bộ phát trực tuyến âm thanh/video chính của hệ thống dựa trên OpenIPC.

* __Мajestic__ ➤ bộ phát trực tuyến âm thanh/video mới (đang phát triển) của hệ thống dựa trên OpenIPC.

* __Phát trực tuyến YouTube__

### MiniHttp là bộ phát trực tuyến chính của hệ thống dựa trên OpenIPC

Điều quan trọng là điều chỉnh cấu hình của MiniHttp bằng cách tắt các giao thức và tính năng không cần thiết để bảo mật và hiệu suất tốt hơn.

Tệp cấu hình nằm trong `/etc/minihttp.ini`

### Chế độ gỡ lỗi:

```killall -sigint minihttp; sleep 1; export SENSOR=`ipctool --sensor_id`; minihttp```

### Chế độ sản xuất:

```killall -sigint minihttp; sleep 1; export SENSOR=`ipctool --sensor_id`; minihttp 2>&1 | logger -p daemon.info -t minihttp &```


## Công cụ xây dựng tùy chỉnh được sử dụng trong OpenIPC OS

[Kho lưu trữ công cụ](https://github.com/OpenIPC/packages/tree/main/utils)

[ipctool](https://github.com/OpenIPC/ipctool) - lấy thông tin về phần cứng
và xuất ra ở định dạng chung. Cũng có thể được sử dụng để sao lưu và khôi phục
phần mềm camera (tính năng vẫn đang thử nghiệm).

## Ví dụ tích hợp với hệ thống Ghi hình kỹ thuật số

Ghi lại luồng cục bộ bằng các tiện ích khác nhau.

YouTube như một bản hack DVR.

## Mẹo và thủ thuật về giám sát hệ thống OpenIPC

### Cách lấy nhiệt độ từ cảm biến bên trong của chip (nơi được hỗ trợ):

`ipctool --temp`

các lệnh khác để [[giám sát nhiệt độ]]

[[snmp]]

### Giám sát Prometheus

[[prometheus-node]]

### Mẫu giám sát

* [[Mẫu giám sát Zabbix]]

## Cấu hình nút Prometheus

[Prometheus](https://prometheus.io/) là một bộ công cụ giám sát và cảnh báo hệ thống mã nguồn mở.

OpenIPC có bộ xuất nút prometheus như một gói. Kết quả đầu ra có thể
được xem dưới dạng văn bản thuần túy trên http://192.168.1.10:9100/metrics

Hoặc được hiển thị nếu bạn cài đặt [máy chủ proemetheus và graphana](https://prometheus.io/docs/visualization/grafana/):

[[images/preometheus_node_graphana_example.jpg]]

Bạn có thể cấu hình nút trong `/etc/config/prometheus-node-exporter-lua`.

### Gói meta

<https://github.com/ZigFisher/Glutinium/tree/master/prometheus-node-exporter-lua>

## Thử nghiệm với I2C trên Hi3518EV200

### Thiết lập i2c-x thông qua cây thiết bị

Trình điều khiển i2c-hisilicon tiêu chuẩn không cung cấp tùy chọn để đặt chân thành chế độ i2c
nếu trước đó chúng được đặt thành dts. Để tự động đặt các chân bắt buộc
sang chế độ i2c, bạn chỉ cần thêm đoạn mã sau vào đầu
hi_i2c_hw_init (linux/drivers/i2c/busses/i2c-hisilicon.c)

```
#ifdef CONFIG_ARCH_HI3518EV200 // Có thể giống với các thiết bị phần cứng khác
if(pinfo->mem->start = 0x200d0000 /* địa chỉ i2c-0 */) {
    writel(0x2, 0x200f0040);
    writel(0x2, 0x200f0044);
}
if(pinfo->mem->start = 0x20240000 /* địa chỉ i2c-1 */) {
    writel(0x1, 0x200f0050);
    writel(0x1, 0x200f0054);
}
if(pinfo->mem->start = 0x20250000 /* địa chỉ i2c-2 */) {
    writel(0x1, 0x200f0060);
    writel(0x1, 0x200f0064);
}
#endif
```

## Thông tin liên quan đến R&D

### Cách [[đăng nhập bên trong]] firmware gốc

### Nhận xét [[Nhật ký Majestic]]

### [[DevTools]]

### [[Tài liệu trên các camera IP khác nhau]]

### Các nhóm trong Telegram liên quan đến phát triển:


## Công cụ được sử dụng trong Nghiên cứu và Phát triển

[hisi-trace](https://github.com/OpenIPC/hisi-trace) --> công cụ để chạy Sofia bên trong
OpenIPC. Cho phép chuyển các chức năng Sofia gốc sang hệ thống đích mà không cần
tải trong firmware gốc.

[một số công cụ để tháo rời](https://github.com/TekuConcept/ArmElfDisassembler)

## Tài liệu về SoC hiện không được hỗ trợ:

[Novatek NV98515 SoC](https://github.com/hn/reolink-camera)

Các diễn đàn liên quan đến hack & mod khác nhau của Camera IP:

<https://www.goprawn.com/>

Dưới đây là một số ví dụ về cách ghi lại luồng video bằng các tiện ích khác nhau.

### gstreamer

* luồng rtsp h264:

`gst-launch-1.0 rtspsrc location=rtsp://192.168.1.10:554/stream=0 ! rtpjitterbuffer ! rtph264depay ! h264parse ! mp4mux ! filesink location=stream0_h264.mp4 -e`

* luồng rtsp h265:

`gst-launch-1.0 rtspsrc location=rtsp://192.168.1.10:554/stream=0 ! rtpjitterbuffer ! rtph265depay ! h265parse ! mp4mux ! filesink location=stream0_h265.mp4 -e`

### ffmpeg

### vlc

## Cách đăng nhập bên trong firmware gốc

Thông tin chỉ áp dụng cho firmware camera dựa trên XM.

### Bật máy chủ telnet

Trong bảng điều khiển U-Boot:

```
setenv telnetctrl 1; saveenv
```

### Kết nối bằng telnet

```
LocalHost login: root
Password: xmhdipc
Welcome to HiLinux.
```

Ngoài ra, có thể thử [các cặp khác](https://gist.github.com/gabonator/74cdd6ab4f733ff047356198c781f27d)

### Tùy chọn: bật khởi động chi tiết kernel Linux (nơi tồn tại armbenv)

```
# armbenv -s xmuart 0
# reboot
```

Hoặc trong trường hợp tồn tại XmEnv:

```
# XmEnv -s xmuart 0
# reboot
```

### Bật telnet mà không cần mở camera (từ xa)

* Tìm tệp zip thích hợp với bản cập nhật firmware gần đây bằng cách sử dụng [liên kết](https://translate.google.com/translate?hl=en&sl=ru&tl=en&u=https%3A%2F%2Fwww.cctvsp.ru%2Farticles%2Fobnovlenie-proshivok-dlya-ip-kamer-ot-xiong-mai) và tải xuống.

* Giải nén nó và chọn tệp `bin` thích hợp từ một số tùy chọn.

* Nên cập nhật camera của bạn bằng cách sử dụng firmware gốc này mà không cần
    sửa đổi nó. Nó sẽ giúp hiểu các vấn đề có thể xảy ra. Sử dụng `General...` nếu
    không chắc chắn bạn muốn tùy chọn nào.

* Giải nén tệp `bin` như thể nó là kho lưu trữ zip thông thường.

* Sao chép `add_xmuart.sh` từ thư mục `utils` của kho lưu trữ vào bên trong thư mục
    với các tệp đã giải nén.

* Chạy `./add_xmaurt.sh` và sau đó đảm bảo rằng `u-boot.env.img` có
    `xmuart=1telnetctrl=1` gần cuối tệp.

* Đóng gói lại tệp `bin` bằng cách thêm `u-boot.env.img` đã thay đổi vào đó như thế này:
  `zip -u General_IPC_HI3516EV200_85H30AI_S38.Nat.dss.OnvifS.HIK_V5.00.R02.20200507_all.bin u-boot.env.img`

* Nâng cấp camera bằng cách sử dụng tệp `bin` mới.

Nguồn tài liệu gốc là [ở đây](https://github.com/OpenIPC/camerasrnd/blob/master/get_telnet.md)

## Lệnh để đo nhiệt độ chip trên các SoC khác nhau

`Hi3516CV200 / Hi3518EV200 / Hi3518EV201`
```sh
devmem 0x20270110 32 0x60FA0000 ; devmem 0x20270114 8  | awk '{print "Nhiệt độ CPU: " ((($1)*180)/256)-40}'
```

`Hi3516CV300 / Hi3518EV100`
```sh
devmem 0x1203009C 32 0x60FA0000 ; devmem 0x120300A4 16 | awk '{print "Nhiệt độ CPU: " (((($1)-125.0)/806)*165)-40}'
```

`Hi3516EV200 / Hi3516EV300`
```sh
devmem 0x120280B4 32 0xC3200000 ; devmem 0x120280BC 16 | awk '{print "Nhiệt độ CPU: " (((($1)-117)/798)*165)-40}'
```

`Hi3536D`
```sh
himm 0x0120E0110 0x60320000 > /dev/null; himm 0x120E0118 | awk '{print $4}' | dd skip=1 bs=7 2>/dev/null | awk '{print "0x"$1}' | awk '{print "Nhiệt độ CPU: " (($1*180)/256)-40}'
```

`Hi3536C`
```sh
himm 0x0120E0110 0x60320000 > /dev/null; himm 0x120E0118 | awk '{print $4}' | dd skip=1 bs=7 2>/dev/null | awk '{print "0x"$1}' | awk '{print "Nhiệt độ CPU: " (($1-125)/806)*165-40}'
```

`HI3520DV200`
```sh
devmem 20060020 32
```

`Hi3516AV200`
```sh
#PERI_PMC68 0x120a0110 (tắt-->bật)
himm 0x120a0110 0 > /dev/null;
himm 0x120a0110 0x40000000 > /dev/null;

usleep 100000
#PERI_PMC70 0x120a0118 đọc nhiệt độ
DATA0=$(himm 0x120a0118 0 | grep 0x120a0118)
DATA1=$(printf "$DATA0" | sed 's/0x120a0118: //')
DATA2=$(printf "$DATA1" | sed 's/ --> 0x00000000//')

let "var=$DATA2&0x3ff"
if [ $var -ge 125 -a $var -le 931 ];then
    echo `awk -v x="$var" 'BEGIN{printf "nhiệt độ chip: %f\n",(x-125)*10000/806*165/10000-40}'`
else
    echo "$var ---> không hợp lệ. [125,931]"
fi
```

## Phát trực tiếp lên YouTube

YouTube không chỉ cung cấp LiveStreaming mà còn có thể ghi lại luồng này.

Có thể ghi lại tối đa 12 giờ LiveStream.

Phát trực tiếp lên YouTube là có thể nhưng hiện tại OpenIPC không hỗ trợ.

### Phát trực tiếp có thể được thực hiện với MiniHttp

Phát trực tiếp lên YouTube có thể được thực hiện với sự trợ giúp của RTMP nhưng hiện tại
không có kế hoạch nào thêm giao thức này vào bộ phát trực tuyến chính MiniHttp.

### Phát trực tiếp có thể được thực hiện với FFMPEG

Có hai chế độ khả dụng: chế độ cũ, hỗ trợ H264 qua RTMP,
và chế độ mới, với H265 qua HLS.

Cả hai phương pháp đều chưa được thử nghiệm trong sản xuất và vẫn đang ở chế độ phát triển.
Xem các liên kết sau để biết chi tiết:

### H264 qua RTMP

Điều hướng đến gói đã biên dịch [H264 qua RTMP](https://github.com/ZigFisher/Glutinium/tree/master/hi35xx-ffmpeg/files)

Sao chép tệp `silence.aac` vào `/usr/lib/` và tệp `ffmpeg` vào `/usr/sbin/`

Ngoài ra, hãy đặt quyền thực thi:

`chmod +x /usr/sbin/ffmpeg`

Chạy `ffmpeg` với các thông số sau:

`ffmpeg -stream_loop -1 -i /usr/lib/silence.aac -rtsp_transport udp -thread_queue_size 64 -i rtsp://127.0.0.1:554/stream=0 -c:v copy -c:a copy -f flv rtmp://a.rtmp.youtube.com/live2/<khóa của bạn>`

[H265 qua HLS](https://gist.github.com/widgetii/ec275524dd621cd55774c952bee4c622)

Một số hướng dẫn xây dựng:

<https://github.com/ZigFisher/Glutinium/blob/master/hi35xx-ffmpeg/0_Build.sh>

[openwrtsysupgrade]: https://github.com/openwrt/openwrt/blob/master/package/base-files/files/sbin/sysupgrade

