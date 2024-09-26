# OpenIPC Wiki
[Mục lục](../README.md)

So sánh các trình phát trực tuyến
-----------------------

### Mục lục

- [Các loại trình phát trực tuyến chính và sự hiện diện của chúng](/en/streamer-comparison.md#main-types-of-streamers-and-their-presence)
- [Bảng chức năng của trình phát trực tuyến](/en/streamer-comparison.md#table-of-streamer-functionality)
- [Bảng các nền tảng và nhóm được hỗ trợ](/en/streamer-comparison.md#table-of-supported-platforms-and-groups)


### Các loại trình phát trực tuyến chính và sự hiện diện của chúng

- [Divinus](https://github.com/OpenIPC/divinus) - trình phát trực tuyến mới, mã nguồn mở và đang được phát triển tích cực với hỗ trợ cho nhiều nền tảng
- [Majestic](https://github.com/OpenIPC/majestic) - trình phát trực tuyến dẫn đầu về chức năng và hỗ trợ cho nhiều nền tảng khác nhau
- [Mini](https://github.com/OpenIPC/mini) - trình phát trực tuyến lâu đời nhất, ông tổ của tất cả các trình phát trực tuyến khác
- [Venc](https://github.com/OpenIPC/silicon_research/tree/master/venc) - trình phát trực tuyến thu nhỏ dành cho FPV/URLLC cho hai nền tảng


### Bảng chức năng của trình phát trực tuyến

| Tính năng và khả năng                                   | Divinus  | Majestic | Mini     | Venc     |
|:--------------------------------------------------------|:--------:|:--------:|:--------:|:--------:|
| Phát triển dự án đang trong giai đoạn tích cực          | Có      | Có      | Không     | Không     |
| Dự án mã nguồn mở                                       | Có      | Không     | Có      | Có      |
| Số lượng nền tảng được hỗ trợ hạn chế                    | Không     | Không     | Có      | Có      |
| Điều khiển bộ lọc IR và đèn nền                          | Có      | Có      | Có      | Không     |
| Hỗ trợ phát hiện đóng băng và Watchdog                    | Có      | Có      | Không     | Không     |
| Ghi video vào thẻ SD ở định dạng MP4                    | ?        | Có      | Có      | Không     |
| Chụp ảnh nhanh JPEG                                    | Có      | Có      | Có      | Không     |
| Gửi ảnh chụp nhanh JPEG đến máy chủ từ xa                | ?        | Không     | Có      | Không     |
| Hỗ trợ OSD cơ bản                                        | Có      | Có      | Không     | Không     |
| Hỗ trợ OSD mở rộng và dữ liệu động                      | Có      | Không     | Không     | Không     |
| Hỗ trợ MJPEG                                            | Có      | Có      | Có      | Không     |
| Hỗ trợ RTSP cơ bản, H264 UDP                             | Có      | Có      | Có      | Không     |
| Hỗ trợ RTSP mở rộng, H264/H265 và TCP/UDP               | ?        | Có      | Không     | Không     |
| Hai luồng video RTSP độc lập                             | Không     | Có      | Không     | Không     |
| Hỗ trợ RTMP H264/H265                                   | Không     | Có      | Không     | Không     |
| Hỗ trợ âm thanh trong tất cả các luồng                     | Không     | Có      | Không     | Không     |
| Hỗ trợ cho các cấu hình điều chỉnh cảm biến               | Không     | Có      | Không     | Không     |
| Phát hiện chuyển động và khởi chạy tập lệnh               | Không     | Có      | Không     | Không     |
| Hỗ trợ giám sát video đám mây [ipeye.ae](https://ipeye.ae) | Không     | Có      | Không     | Không     |
| Gửi luồng đến YouTube, Facebook, Telegram, v.v.        | Không     | Có      | Không     | Không     |
| Hỗ trợ HLS                                              | Không     | Có      | Không     | Không     |
| Hỗ trợ WebRTC                                           | Không     | Có      | Không     | Không     |
| Hỗ trợ giao thức NetIP cho DVR                          | Không     | Có      | Không     | Không     |
| Hỗ trợ ONVIF cơ bản, tìm kiếm tài nguyên                   | Không     | Có      | Không     | Không     |
| Hỗ trợ cho plugin tùy chỉnh                               | Không     | Có      | Không     | Không     |
| Cài đặt qua WebUI                                          | Không     | Có      | Không     | Không     |
| Cài đặt ISP tùy chỉnh, số lượng lớn                     | Không     | Có      | Không     | Không     |
| Luồng RTP tùy chỉnh, thông qua UDP post hoặc socket                | Không     | Có      | Không     | Có      |
| Gửi thông tin từ xa đến nhà phát triển                          | Không     | Có      | Không     | Không     |
|                                                         |          |          |          |          |
| Sẽ được tiếp tục, tài liệu đang được viết               |          |          |          |          |


### Bảng các nền tảng và nhóm được hỗ trợ

| Tính năng và khả năng                                  | Divinus  | Majestic | Mini     | Venc     |
|:--------------------------------------------------------|:--------:|:--------:|:--------:|:--------:|
| Nhóm HiSilicon HS3516AV100                              | Không     | Có      | Không     | Không     |
| Nhóm HiSilicon HS3516CV100                              | ?        | Có      | Một phần  | Không     |
| Nhóm HiSilicon HS3516CV200                              | ?        | Có      | Có      | Không     |
| Nhóm HiSilicon HS3516CV300                              | Có      | Có      | Có      | Không     |
| Nhóm HiSilicon HS3516CV500                              | ?        | Có      | Không     | Không     |
| Nhóm HiSilicon HS3516EV200                              | Có      | Có      | Không     | Có      |
| Nhóm HiSilicon HS3519V101                               | Không     | Có      | Không     | Không     |
|                                                         |          |          |          |          |
| Sẽ được tiếp tục, tài liệu đang được viết               |          |          |          |          |



