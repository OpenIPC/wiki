## Âm thanh trên FPV

### Tổng quan
Mọi thứ đã được thử nghiệm bằng Steam Deck (PC x86) và bảng mạch ssc338q-imx415 Anjoy và lựa chọn bộ giải mã và tương tự có thể phản ánh điều này.
Hiện tại có độ trễ ~50-100ms, được cải thiện nhiều so với các thử nghiệm đầu tiên ~200ms. Sự cải thiện chủ yếu đến từ việc sử dụng "pipewiresink" ở phía máy khách, nhưng điều này yêu cầu bạn phải có backend âm thanh pipewire hoạt động trên GS của mình. Cũng có thể sử dụng backend âm thanh JACK để có kết quả tương tự hoặc tốt hơn.
Cũng có một bản cập nhật để sử dụng luồng video/âm thanh RTP hỗn hợp trên cổng đầu ra (tiêu chuẩn 5600) yêu cầu cách tiếp cận khác cho pipeline gst (xem bên dưới). Các pipeline cần được ngắt kết nối để không chặn lẫn nhau.
Một cảnh báo nhỏ; nếu bật âm thanh và không điều chỉnh pipeline của bạn để sắp xếp tải trọng=97 (H265) thì tải trọng RTP=98 sẽ gây ra hiện tượng nhiễu hình ảnh trong video của bạn. `rtpjitterbuffer` sẽ giúp quản lý các gói không theo thứ tự (sẽ không hoạt động nếu không có nó).
Video sử dụng tốc độ lấy mẫu OPUS 16000 OPUS: https://youtu.be/Z0KxSS24j7o

### Majestic và cài đặt chung
Cài đặt âm thanh (majestic.yaml):
```
cli -s .audio.enabled true
cli -s .audio.srate 8000 (8000 khá tệ, 16000 có thể sử dụng và 48000 thực sự tốt)
```

### Âm thanh, video hoạt động và lưu vào tệp
```
gst-launch-1.0 udpsrc port=5600 ! tee name=videoTee ! queue ! tee name=t t. ! queue ! application/x-rtp,payload=97, clock-rate=90000, encoding-name=H265 ! rtpjitterbuffer latency=20 ! rtph265depay ! mpegtsmux name=ts ! filesink location=/run/media/deck/170a3e7f-325f-4567-8580-0e01dda76973/video/record-$(date +%y%m%d_%H%M%S).tsn sync=false t. ! queue leaky=1 ! tee name=audioTee ! queue ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpjitterbuffer latency=22 do-lost=true drop-on-latency=true ! rtpopusdepay ! ts. audioTee. ! queue leaky=1 ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpjitterbuffer latency=22 ! rtpopusdepay ! opusdec ! audioconvert ! audioresample ! pipewiresink blocksize=128 mode=render processing-deadline=0 sync=false async=false videoTee. ! queue ! application/x-rtp,payload=97, clock-rate=90000, encoding-name=H265 ! rtpjitterbuffer latency=20 ! rtph265depay ! vaapih265dec ! fpsdisplaysink fps-update-interval=200 video-sink=xvimagesink sync=false
```
Không cần làm gì thêm, nó chỉ hoạt động :-)

Changes:
 -  "luồng video/âm thanh RTP"  -> "luồng video/âm thanh RTP hỗn hợp"
 - "đường ống gst" -> "pipeline gst"
 -  "phần phụ trợ âm thanh" -> "backend âm thanh"
 - "rtpjitterbuffer" -> `rtpjitterbuffer`
 - "Steamdeck" -> "Steam Deck"
 - "JACK" -> "JACK" 


