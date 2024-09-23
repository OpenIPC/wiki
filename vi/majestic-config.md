```
system:
  webPort: 80
  httpsPort: 443
  #httpsCertificate: /etc/ssl/certs/www.example.com.crt
  #httpsCertificateKey: /etc/ssl/private/www.example.com.key
  logLevel: debug
  buffer: 1024
  plugins: false

isp:
  #sensorConfig: /etc/sensors/imx222_1080p_line.ini
  antiFlicker: disabled
  #blkCnt: 4
  #drc: 300
  #rawMode: slow
  #iqProfile: <đường dẫn/tới/tệp>
  #lowDelay: false
  #awbMode: auto

image:
  mirror: false
  flip: false
  rotate: 0
  contrast: 50
  hue: 50
  saturation: 50
  luminance: 50

video0:
  enabled: true
  codec: h264
  #size: 1920x1080
  fps: 20
  bitrate: 4096
  rcMode: vbr
  gopSize: 1
  #gopMode: normal
  #crop: 0x0x960x540
  #sliceUnits: 4
  #minQp: 12
  #maxQp: 42

video1:
  enabled: false
  codec: h264
  size: 704x576
  fps: 15

jpeg:
  enabled: true
  qfactor: 50
  fps: 5
  #size: 1920x1080

#mjpeg:
  #size: 1280x720
  #fps: 5
  #bitrate: 1024

osd:
  enabled: false
  font: /usr/share/fonts/truetype/UbuntuMono-Regular.ttf
  template: "%d.%m.%Y %H:%M:%S"
  posX: 16
  posY: 16
  #privacyMasks: 0x0x234x640,2124x0x468x1300

audio:
  enabled: false
  volume: 30
  srate: 8000
  codec: opus
  outputEnabled: false
  outputVolume: 30
  #speakerPin: 32
  #speakerPinInvert: false

rtsp:
  enabled: true
  port: 554

nightMode:
  enabled: false
  #irCutPin1: 1
  #irCutPin2: 2
  irCutSingleInvert: false
  #backlightPin: 65
  colorToGray: true
  #overrideDrc: 300
  #minThreshold: 2000
  #maxThreshold: 5000
  #irSensorPin: 62
  irSensorPinInvert: false
  #dncDelay: 30

motionDetect:
  enabled: false
  visualize: false
  debug: false
  #roi: 1854x1304x216x606,1586x1540x482x622
  #skipIn: 960x540x1920x1080
  #sensitivity: 3

records:
  enabled: false
  path: /mnt/mmcblk0p1/%F/%H.mp4
  maxUsage: 95
  #splitRecord: 10

outgoing:
  enabled: false
  #server: udp://192.168.1.10:5600
  #naluSize: 1200
  #- udp://IP:cổng                                        # Gửi dữ liệu đa cổng chỉ được cấu hình trong tệp /etc/majestic.yaml và không khả dụng để điều khiển từ WebUI
  #- unix:/tmp/rtpstream.sock
  #- rtmps://dc4-1.rtmp.t.me/s/mykey

watchdog:
  enabled: true
  timeout: 300

hls:
  enabled: false

onvif:
  enabled: false

ipeye:
  enabled: false

youtube:                                                  # Chức năng này chỉ hoạt động với plugin daemon bên ngoài cho Majestic
  enabled: false
  #key: xxxx-xxxx-xxxx-xxxx-xxxx

netip:
  enabled: false
  #user: admin
  #password: 6V0Y4HLF
  #port: 34567
  #snapshots: true
  #ignoreSetTime: false

cloud:
  enabled: false

#webrtc:
  # https://www.w3.org/TR/webrtc/#rtciceserver-dictionary với tùy chọn
  # '?transport=udp' hoặc '?transport=tcp'
  #iceServers: stun:stun.kinesisvideo.eu-north-1.amazonaws.com:443

```

**Giải thích các thuật ngữ:**

* **system:** Hệ thống, chứa các cài đặt chung cho camera.
    * **webPort:** Cổng web, cổng được sử dụng cho giao diện web.
    * **httpsPort:** Cổng HTTPS, cổng được sử dụng cho giao diện web bảo mật.
    * **httpsCertificate:** Chứng chỉ HTTPS, đường dẫn đến tệp chứng chỉ SSL.
    * **httpsCertificateKey:** Khóa chứng chỉ HTTPS, đường dẫn đến tệp khóa chứng chỉ SSL.
    * **logLevel:** Mức ghi nhật ký, mức độ chi tiết của nhật ký.
    * **buffer:** Bộ đệm, kích thước bộ đệm cho luồng.
    * **plugins:** Plugin, cho phép hoặc không cho phép plugin.
* **isp:** Bộ xử lý tín hiệu hình ảnh (Image Signal Processor), chứa các cài đặt liên quan đến cảm biến hình ảnh.
    * **sensorConfig:** Cấu hình cảm biến, đường dẫn đến tệp cấu hình cảm biến.
    * **antiFlicker:** Chống nhấp nháy, tắt hoặc bật tính năng chống nhấp nháy.
    * **blkCnt:** Số lượng khối, số lượng khối được sử dụng cho xử lý hình ảnh.
    * **drc:** Dải động rộng (Dynamic Range Control), cường độ của DRC.
    * **rawMode:** Chế độ thô, chế độ chụp ảnh thô.
    * **iqProfile:** Hồ sơ IQ, đường dẫn đến tệp hồ sơ IQ.
    * **lowDelay:** Độ trễ thấp, bật hoặc tắt chế độ độ trễ thấp.
    * **awbMode:** Chế độ cân bằng trắng, chế độ cân bằng trắng tự động hoặc thủ công.
* **image:** Hình ảnh, chứa các cài đặt liên quan đến hình ảnh.
    * **mirror:** Lật gương, lật hình ảnh theo chiều ngang.
    * **flip:** Lật dọc, lật hình ảnh theo chiều dọc.
    * **rotate:** Xoay, xoay hình ảnh theo một góc cụ thể.
    * **contrast:** Độ tương phản, mức độ tương phản của hình ảnh.
    * **hue:** Sắc độ, sắc độ của hình ảnh.
    * **saturation:** Độ bão hòa, mức độ bão hòa màu của hình ảnh.
    * **luminance:** Độ sáng, độ sáng của hình ảnh.
* **video0:** Luồng video chính, chứa các cài đặt cho luồng video chính.
    * **enabled:** Bật, bật hoặc tắt luồng video.
    * **codec:** Codec, codec được sử dụng cho luồng video.
    * **size:** Kích thước, kích thước của luồng video.
    * **fps:** Khung hình trên giây (Frames Per Second), tốc độ khung hình của luồng video.
    * **bitrate:** Tốc độ bit, tốc độ bit của luồng video.
    * **rcMode:** Chế độ điều khiển tốc độ (Rate Control Mode), chế độ điều khiển tốc độ bit.
    * **gopSize:** Kích thước GOP, kích thước của Nhóm hình ảnh (Group of Pictures).
    * **gopMode:** Chế độ GOP, chế độ mã hóa GOP.
    * **crop:** Cắt, cắt hình ảnh.
    * **sliceUnits:** Đơn vị lát, số lượng đơn vị lát cho mỗi khung hình.
    * **minQp:** QP tối thiểu, giá trị lượng tử hóa tối thiểu.
    * **maxQp:** QP tối đa, giá trị lượng tử hóa tối đa.
* **video1:** Luồng video phụ, chứa các cài đặt cho luồng video phụ.
* **jpeg:** JPEG, chứa các cài đặt cho ảnh chụp nhanh JPEG.
    * **enabled:** Bật, bật hoặc tắt ảnh chụp nhanh JPEG.
    * **qfactor:** Hệ số chất lượng, hệ số chất lượng của ảnh chụp nhanh JPEG.
    * **fps:** Khung hình trên giây (Frames Per Second), tốc độ khung hình của ảnh chụp nhanh JPEG.
    * **size:** Kích thước, kích thước của ảnh chụp nhanh JPEG.
* **mjpeg:** MJPEG, chứa các cài đặt cho luồng MJPEG.
* **osd:** Hiển thị trên màn hình (On-Screen Display), chứa các cài đặt cho OSD.
    * **enabled:** Bật, bật hoặc tắt OSD.
    * **font:** Phông chữ, phông chữ được sử dụng cho OSD.
    * **template:** Mẫu, mẫu được sử dụng cho OSD.
    * **posX:** Vị trí X, vị trí ngang của OSD.
    * **posY:** Vị trí Y, vị trí dọc của OSD.
    * **privacyMasks:** Mặt nạ riêng tư, các khu vực bị che trên hình ảnh.
* **audio:** Âm thanh, chứa các cài đặt cho âm thanh.
    * **enabled:** Bật, bật hoặc tắt âm thanh.
    * **volume:** Âm lượng, âm lượng của âm thanh.
    * **srate:** Tốc độ lấy mẫu, tốc độ lấy mẫu của âm thanh.
    * **codec:** Codec, codec được sử dụng cho âm thanh.
    * **outputEnabled:** Bật đầu ra, bật hoặc tắt đầu ra âm thanh.
    * **outputVolume:** Âm lượng đầu ra, âm lượng của đầu ra âm thanh.
    * **speakerPin:** Chân loa, chân GPIO được sử dụng cho loa.
    * **speakerPinInvert:** Đảo ngược chân loa, đảo ngược cực tính của chân loa.
* **rtsp:** RTSP, chứa các cài đặt cho RTSP.
    * **enabled:** Bật, bật hoặc tắt RTSP.
    * **port:** Cổng, cổng được sử dụng cho RTSP.
* **nightMode:** Chế độ ban đêm, chứa các cài đặt cho chế độ ban đêm.
    * **enabled:** Bật, bật hoặc tắt chế độ ban đêm.
    * **irCutPin1:** Chân cắt IR 1, chân GPIO được sử dụng cho bộ lọc cắt IR.
    * **irCutPin2:** Chân cắt IR 2, chân GPIO thứ hai được sử dụng cho bộ lọc cắt IR.
    * **irCutSingleInvert:** Đảo ngược chân cắt IR đơn, đảo ngược cực tính của chân cắt IR đơn.
    * **backlightPin:** Chân đèn nền, chân GPIO được sử dụng cho đèn nền.
    * **colorToGray:** Chuyển đổi màu sang xám, chuyển đổi hình ảnh sang màu xám trong chế độ ban đêm.
    * **overrideDrc:** Ghi đè DRC, ghi đè cài đặt DRC trong chế độ ban đêm.
    * **minThreshold:** Ngưỡng tối thiểu, ngưỡng tối thiểu để chuyển sang chế độ ban đêm.
    * **maxThreshold:** Ngưỡng tối đa, ngưỡng tối đa để chuyển sang chế độ ban đêm.
    * **irSensorPin:** Chân cảm biến IR, chân GPIO được sử dụng cho cảm biến IR.
    * **irSensorPinInvert:** Đảo ngược chân cảm biến IR, đảo ngược cực tính của chân cảm biến IR.
    * **dncDelay:** Độ trễ DNC, độ trễ để chuyển sang chế độ ban đêm.
* **motionDetect:** Phát hiện chuyển động, chứa các cài đặt cho phát hiện chuyển động.
    * **enabled:** Bật, bật hoặc tắt phát hiện chuyển động.
    * **visualize:** Trực quan hóa, hiển thị các khu vực phát hiện chuyển động trên hình ảnh.
    * **debug:** Gỡ lỗi, bật hoặc tắt gỡ lỗi phát hiện chuyển động.
    * **roi:** Vùng quan tâm (Region of Interest), các khu vực được sử dụng để phát hiện chuyển động.
    * **skipIn:** Bỏ qua trong, bỏ qua các khu vực trên hình ảnh khi phát hiện chuyển động.
    * **sensitivity:** Độ nhạy, độ nhạy của phát hiện chuyển động.
* **records:** Bản ghi, chứa các cài đặt cho bản ghi.
    * **enabled:** Bật, bật hoặc tắt bản ghi.
    * **path:** Đường dẫn, đường dẫn đến thư mục lưu trữ bản ghi.
    * **maxUsage:** Sử dụng tối đa, tỷ lệ phần trăm dung lượng lưu trữ tối đa được sử dụng cho bản ghi.
    * **splitRecord:** Chia bản ghi, thời lượng tối đa của mỗi tệp bản ghi.
* **outgoing:** Đầu ra, chứa các cài đặt cho luồng đầu ra.
    * **enabled:** Bật, bật hoặc tắt luồng đầu ra.
    * **server:** Máy chủ, địa chỉ của máy chủ để gửi luồng đầu ra.
    * **naluSize:** Kích thước NALU, kích thước của Đơn vị truy cập lớp mạng (Network Abstraction Layer Unit).
* **watchdog:** Chó canh, chứa các cài đặt cho chó canh.
    * **enabled:** Bật, bật hoặc tắt chó canh.
    * **timeout:** Hết thời gian, thời gian chờ cho chó canh.
* **hls:** HLS, chứa các cài đặt cho HLS.
    * **enabled:** Bật, bật hoặc tắt HLS.
* **onvif:** ONVIF, chứa các cài đặt cho ONVIF.
    * **enabled:** Bật, bật hoặc tắt ONVIF.
* **ipeye:** ipeye, chứa các cài đặt cho ipeye.
    * **enabled:** Bật, bật hoặc tắt ipeye.
* **youtube:** YouTube, chứa các cài đặt cho YouTube.
    * **enabled:** Bật, bật hoặc tắt YouTube.
    * **key:** Khóa, khóa API YouTube.
* **netip:** NetIP, chứa các cài đặt cho NetIP.
    * **enabled:** Bật, bật hoặc tắt NetIP.
    * **user:** Người dùng, tên người dùng cho NetIP.
    * **password:** Mật khẩu, mật khẩu cho NetIP.
    * **port:** Cổng, cổng được sử dụng cho NetIP.
    * **snapshots:** Ảnh chụp nhanh, bật hoặc tắt ảnh chụp nhanh.
    * **ignoreSetTime:** Bỏ qua cài đặt thời gian, bỏ qua cài đặt thời gian từ NetIP.
* **cloud:** Đám mây, chứa các cài đặt cho đám mây.
    * **enabled:** Bật, bật hoặc tắt đám mây.
* **webrtc:** WebRTC, chứa các cài đặt cho WebRTC.
    * **iceServers:** Máy chủ ICE, địa chỉ của máy chủ ICE để sử dụng cho WebRTC.

