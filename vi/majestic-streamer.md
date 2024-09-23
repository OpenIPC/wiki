# Wiki OpenIPC
[Mục lục](../README.md)

Trình phát trực tiếp Majestic
-----------------

### Lời mở đầu

Majestic là một ứng dụng phát trực tiếp video, trái tim của firmware của chúng tôi (liên quan đến chức năng camera / giám sát video). Majestic có thể cấu hình thông qua tệp /etc/majestic.yaml và có nhiều tính năng / dịch vụ được bật theo mặc định. Các tùy chọn không cần thiết có thể được tắt để bảo mật và hiệu suất tốt hơn. Xem /etc/majestic.full để biết các tùy chọn cấu hình.

### Tín hiệu điều khiển

```
-HUP khởi động lại Majestic (Ngoại trừ Ingenic T21).
-SIGUSR2 Tắt SDK (Cho tất cả các nền tảng).
```

### URL liên quan đến camera trong firmware

Majestic hỗ trợ nhiều định dạng âm thanh, video và hình ảnh tĩnh, v.v.
Bạn có thể tìm thấy danh sách đầy đủ các điểm cuối khả dụng trên [trang này](https://openipc.org/majestic-endpoints).

Tham số điều khiển JPEG dài không phù hợp với ví dụ trên trang web và chúng tôi xuất bản nó tại đây:

`/image.jpg?width=640&height=360&qfactor=73&color2gray=1`

### Thay đổi tham số thông qua cli

Hiện tại, có thể thay đổi các tham số trong tệp cấu hình thông qua tiện ích CLI.

Điều này cho phép các tham số được thay đổi bằng một dòng duy nhất ở chế độ giả động trên một số nền tảng
đơn giản bằng cách buộc đọc lại tệp cấu hình.
```
cli -s .video0.codec h264 ; cli -s .video0.fps 10 ; killall -HUP majestic 
```

### Tính năng điều khiển thử nghiệm (chưa được mô tả trong các điểm cuối)

```
/metrics/isp
/metrics/venc
/metrics/motion
```
```
/night/ircut
/night/light
```


### Tự động phát hiện ngày / đêm

Nếu các biến này được sử dụng, có thể thay thế các tập lệnh sandbox đã sử dụng.
Chỉ hoạt động cho các lược đồ ngày / đêm đơn giản với cấu hình tối thiểu và trong trường hợp không có đề cập đến irSensorPin trong tệp cấu hình majestic.yaml.
Nếu gpio cảm biến ánh sáng được đặt, nó sẽ sử dụng chế độ mặc định.

Cài đặt hoạt động như sau:
```ngày < [minThreshold] | hysteresis | [maxThreshold] < đêm```

Nếu mức khuếch đại của cảm biến là 1024 vào một ngày sáng, minThreshold có thể được đặt thành 2000,
nếu mức khuếch đại của cảm biến là 32000 vào đêm tối, maxThreshold có thể được đặt thành 10000.

```
cli -s .nightMode.minThreshold 10
cli -s .nightMode.maxThreshold 50
```

### Phát hiện chuyển động

Phát hiện chuyển động được hỗ trợ cho Hisilion/Goke, Ingenic và Sigmastar.
Khi phát hiện sự kiện chuyển động, `majestic` sẽ gọi một tập lệnh được xác định trước `/usr/sbin/motion.sh` với một tham số chỉ định số lượng đối tượng:

```
/usr/sbin/motion.sh [count]
```

Bật phát hiện chuyển động trong cấu hình `majestic`:

```
cli -s .motionDetect.enabled true
cli -s .motionDetect.debug true
```

Khởi động lại camera và khởi động lại `majestic` ở nền trước:

```
killall majestic; sleep 3; majestic
```

Bạn sẽ thấy tập lệnh chạy sau các sự kiện phát hiện chuyển động:

```
20:37:02  <SED_IVE_DETCTOR> [  motion] motion_update@155             Phát hiện chuyển động: [1163x0] -> [690x475]
20:37:02  <SED_IVE_DETCTOR> [   tools] motion_event@615              Thực thi tập lệnh chuyển động: /usr/sbin/motion.sh
```

### Phát sóng bằng RTMP

Để khởi chạy phát sóng YouTube ngay lập tức, hãy chạy các lệnh sau trong bảng điều khiển:
```
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .outgoing.enabled true
cli -s .outgoing.server rtmp://a.rtmp.youtube.com/live2/you-key-here
reboot
```

Ví dụ về các địa chỉ khác cho các dịch vụ khác nhau:
- YouTube
    - rtmp://a.rtmp.youtube.com/live2/---KEY---
- Telegram
    - rtmps://dc4-1.rtmp.t.me/s/---KEY---
- RuTube
    - rtmp://upload.rutube.ru/live_push/---KEY---
- OK và VK
    - rtmp://ovsu.mycdn.me/input/---KEY---

Chúng tôi yêu cầu bạn thêm thông tin về các dịch vụ phổ biến khác tại đây, xin cảm ơn.

Logic kết nối lại và hết thời gian của RTMP hoạt động như sau:

```
    0-200 lần thử = hết thời gian 10 giây
  200-500 lần thử = hết thời gian 60 giây
 500-1000 lần thử = hết thời gian 300 giây
    1000+ lần thử = hết thời gian 600 giây
```

### Các tùy chọn đầu ra khác

```
outgoing:
  enabled: true
  server: udp://192.168.1.10:5600
  naluSize: 1200
  - udp://IP-1:cổng
  - udp://IP-2:cổng
  - unix:/tmp/rtpstream.sock
  - rtmps://dc4-1.rtmp.t.me/s/mykey
```

### ONVIF

Để ONVIF cơ bản hoạt động chính xác, bạn cần bật nó và thêm người dùng vào hệ thống như trong ví dụ:

```
cli -s .onvif.enabled true
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
```

### JPEG và MJPEG

Nhằm mục đích thống nhất và tiêu chuẩn hóa cho tất cả các nền tảng, cũng như tăng tính ổn định của trình phát trực tiếp, kích thước hình ảnh sẽ luôn bằng kích thước trên kênh Video0 và không có cài đặt riêng biệt.

### ROI

Vùng phát hiện có hai loại:

`motionDetect.roi: 1854x1304x216x606,1586x1540x482x622`

`motionDetect.skipIn: 960x540x1920x1080`

**roi** - vùng quan tâm, khi chúng ta chỉ định một hoặc nhiều vùng mà chúng ta quan tâm đến chuyển động của chúng.

**skipIn** - ngược lại, nếu chúng ta quan tâm đến chuyển động trên toàn bộ màn hình, ngoại trừ một số khu vực (ví dụ: có một cái cây trong khung hình đang lắc lư trong gió).

Định dạng tọa độ giống như trong osd.privacyMasks: x, y của điểm trên cùng bên trái, chiều dài và chiều rộng tính bằng pixel.

### Cách chuyển đổi hình ảnh YUV sang định dạng hình ảnh phổ biến hơn

Sử dụng lệnh `convert` từ phần mềm ImageMagick. Chạy nó như thế này:
```
convert -verbose -sampling-factor 4:2:0 -size 1920x1080 -depth 8 image.yuv image.png
```
trong đó `1920x1080` là độ phân giải hình ảnh của video0 và `.png` là định dạng hình ảnh đích.

### Cách phát luồng âm thanh

Sử dụng tiện ích [ffplay][ffplay] từ gói [ffmpeg][ffmpeg].
```
ffplay -ar 48000 -ac 1 -f s16le http://192.168.1.10/audio.pcm
ffplay -ar 48000 -ac 1 -f alaw http://192.168.1.10/audio.alaw
ffplay -ar 48000 -ac 1 -f mulaw http://192.168.1.10/audio.ulaw
ffplay -ar 8000 -ac 1 -f alaw http://192.168.1.10/audio.g711a
```

### Cách tạo tệp âm thanh để phát trên loa của camera qua mạng

Sử dụng chương trình [sox][sox] chuyển đổi bất kỳ tệp âm thanh nguồn nào thành âm thanh [PCM][pcm] 8kbps:
```
sox speech.mp3 -t raw -r 8000 -e signed -b 16 -c 1 test.pcm
```

### Cách phát tệp âm thanh trên loa của camera qua mạng

```
curl -u root:12345 --data-binary @test.pcm http://192.168.1.10/play_audio
```

[aac]: https://en.wikipedia.org/wiki/Advanced_Audio_Coding
[alaw]: https://en.wikipedia.org/wiki/A-law_algorithm
[dng]: https://en.wikipedia.org/wiki/Digital_Negative
[g711]: https://en.wikipedia.org/wiki/G.711
[heif]: https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format
[hls]: https://en.wikipedia.org/wiki/HTTP_Live_Streaming
[jpeg]: https://en.wikipedia.org/wiki/JPEG
[mjpeg]: https://en.wikipedia.org/wiki/Motion_JPEG
[mp3]: https://en.wikipedia.org/wiki/MP3
[mp4]: https://en.wikipedia.org/wiki/MPEG-4_Part_14
[opus]: https://en.wikipedia.org/wiki/Opus_(audio_format)
[pcm]: https://en.wikipedia.org/wiki/Pulse-code_modulation
[raw]: https://en.wikipedia.org/wiki/Raw_image_format
[rtsp]: https://en.wikipedia.org/wiki/RTSP
[ulaw]: https://en.wikipedia.org/wiki/%CE%9C-law_algorithm
[yuv]: https://en.wikipedia.org/wiki/YUV
[ffplay]: https://ffmpeg.org/ffplay.html
[ffmpeg]: https://ffmpeg.org/
[sox]: https://en.wikipedia.org/wiki/SoX

