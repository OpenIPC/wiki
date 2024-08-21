# Wiki OpenIPC
[Mục lục](../README.md)

## Thông tin cơ bản

OpenIPC là một [firmware](https://github.com/OpenIPC) thay thế cho
camera IP và là một loại ô che cho các dự án khác là thành phần của
hệ thống của chúng tôi.

OpenIPC là một hệ điều hành Linux dựa trên các dự án Buildroot/OpenWrt và
nhắm đến camera IP với chipset từ các nhà cung cấp khác nhau, bắt đầu
với Goke GK72xx, HiSilicon Hi35xx, SigmaStar SSC33x, và XiongmaiTech XM5xx.

Mọi người đều được chào đón sử dụng/đóng góp cho dự án theo bất kỳ cách nào họ thấy hữu ích!

Chúng tôi sẽ rất biết ơn bất kỳ phản hồi và đề xuất nào.


## Liên kết chính thức

* [OpenIPC trên Wiki](https://github.com/openipc/wiki) - Bộ sưu tập các tài liệu và hướng dẫn khác nhau.
* [OpenIPC trên GitHub](https://github.com/OpenIPC/) - Tổ chức GitHub, hầu hết các dự án được lưu trữ ở đây.
* [OpenIPC trên OpenCollective](https://opencollective.com/openipc) - Cộng đồng OpenCollective.
* [OpenIPC trên Twitter](https://twitter.com/openipc) - Tin tức chính của chúng tôi.
* [OpenIPC trên YouTube](https://www.youtube.com/channel/UCaXlbR2uGTRFh8jQ2lCFd2g) - Hướng dẫn và phát trực tiếp của chúng tôi (trong kế hoạch).


## Nhóm chat Telegram

* [OpenIPC](https://t.me/openipc) (EN) - Kênh quốc tế để thảo luận về việc phát triển dự án của chúng tôi, [*](https://combot.org/c/1166652144)
* [OpenIPC modding](https://t.me/openipc_modding) (RU) - vấn đề chung về việc sửa đổi firmware thiết bị IPCam, [*](https://combot.org/c/-1001247643198)
* [OpenIPC development](https://t.me/openipc_software) (RU) - HiSilicon, XM porting in OpenWrt và vấn đề lập trình, [*](https://combot.org/c/-1001196905312)
* [OpenIPC advice](https://t.me/openipc_advice) (RU) - vấn đề, tìm giải pháp, cuộc trò chuyện dài, [*](https://combot.org/c/1385065634)
* [OpenIPC Iranian](https://t.me/joinchat/T_GwQUBTJdfXJrFb) (IR) - nhóm đặc biệt cho người dùng Iran / تیم OpenIPC برای کاربران ایرانی, [*](https://combot.org/c/-1001341239361)
* [OpenIPC demo](https://t.me/openipc_demo)  (EN/RU) - bot thử nghiệm với các nút, sau khi kết nối, đưa ra "/menu", [*](https://combot.org/c/1414887196)
* [OpenIPC ExIPCam](https://t.me/ExIPCam) (RU) - Chương trình ExIPCam và sửa chữa phần cứng/phần mềm thiết bị, [*](https://combot.org/c/1213889378)
* [OpenIPC updates](https://t.me/s/openipc_updates) (RU) - Kênh thông tin cập nhật Firmware & Software
* [OpenIPC dev](https://t.me/s/openipc_dev) - Kênh phát triển Firmware & Software

## Phát triển của nhóm

### Firmware

* [openipc-2.x](https://github.com/openipc/firmware) - Hệ thống phát triển và tạo Firmware dựa trên Buildroot.
* [openipc-1.0][chaos_calmer] - Hệ thống phát triển và tạo Firmware dựa trên OpenWrt 15.05.
* [coupler][coupler] - Chuyển đổi mượt mà giữa các firmware của camera video.

### Streamers

* [majestic](https://openipc.org/majestic-endpoints) - Streamer IPCam phổ quát.
* [mini][mini] - Streamer camera IP Mini mã nguồn mở.

### Công cụ

* [ipctool](https://github.com/openipc/ipctool) - Công cụ (và thư viện) để kiểm tra phần cứng camera IP.
* [yaml-cli][yaml-cli] - Công cụ để thay đổi cài đặt trong CLI.
* [glutinium](https://github.com/ZigFisher/Glutinium) - Gói OpenWRT bổ sung.

### Phần mềm Windows

* [exipcam](http://team.openipc.org/exipcam) - Tiện ích tuyệt vời để sửa chữa IPCam (Dành cho Windows, hoạt động trên Linux qua Wine).
* [ipcam_dms](http://team.openipc.org/ipcam_dms) - Hệ thống quản lý thiết bị IPCam (Dành cho Windows, hoạt động trên Linux qua Wine).

## Nhà phát triển

| Tên                                                             | Vai trò                                                 | Tham gia                                                               |
|------------------------------------------------------------------|--------------------------------------------------------|--------------------------------------------------------------------------|
| [Dmitry Ilyin](https://web.telegram.org/#/im?p=@widgetii)        | đồng sáng lập và thành viên chính của dự án OpenIPC    | [ipctool][ipctool], [majestic][majestic], [mini][mini], [motors][motors] |
| [Dmitry Ermakov](https://web.telegram.org/#/im?p=@dimerrr)       | thành viên chính                                       | [coupler][coupler], [firmware][firmware], [ipctool][ipctool]             |
| [Igor Zalatov](https://web.telegram.org/#/im?p=@FlyRouter)       | **người sáng lập dự án và điều phối phát triển**       | [chaos_calmer][chaos_calmer], [firmware][firmware], [wiki][wiki]         |
| [Ivan Pozdeev](https://web.telegram.org/#/im?p=@John)            | nhà phát triển                                         | [microbe-web][webui], [yaml-cli][yaml-cli]                               |
| [Konstantin](#)                                                  | nhà phát triển                                         | [hisi-trace][hisi-trace], [yaml-cli][yaml-cli]                           |
| [Maksim Patrushev](https://web.telegram.org/#/im?p=@maxi380)     | nhà phát triển                                         | [motors][motors]                                                         |
| [Maxim Chertov](https://web.telegram.org/#/im?p=@mAX3773)        | đồng sáng lập dự án OpenIPC                            | [chaos_calmer][chaos_calmer], [ipctool][ipctool], [mini][mini]           |
| [Paul Philippov](https://web.telegram.org/#/im?p=@themactep)     | thành viên chính                                       | [microbe-web][webui]                                                     |
| [Sergey Sharshunov](https://web.telegram.org/#/im?p=@USSSSSH)    | đồng sáng lập dự án OpenIPC                            | [chaos_calmer][chaos_calmer], [burn][burn]                               |
| [Temirkhan Myrzamadi](https://web.telegram.org/#/im?p=@hirrolot) | thành viên chính                                       | [smolrtsp][smolrtsp]                                                     |
| [Vasiliy Yakovlev](https://web.telegram.org/#/im?p=@#)           | người hỗ trợ chung                                     |                                                                          |

### Hỗ trợ

OpenIPC cung cấp hai mức độ hỗ trợ.

- Hỗ trợ miễn phí thông qua cộng đồng (qua [chat](https://openipc.org/#telegram-chat-groups) và [danh sách thư](https://github.com/OpenIPC/firmware/discussions)).
- Hỗ trợ thương mại có phí (từ nhóm các nhà phát triển).

Hãy xem xét việc đăng ký hỗ trợ thương mại có phí nếu bạn định sử dụng sản phẩm của chúng tôi cho kinh doanh.
Là khách hàng trả phí, bạn sẽ nhận được dịch vụ hỗ trợ kỹ thuật và bảo dưỡng trực tiếp từ đội ngũ kỹ thuật của chúng tôi.
Báo cáo lỗi và yêu cầu tính năng của bạn sẽ nhận được sự chú ý ưu tiên và giải pháp nhanh chóng. Đây là chiến lược đôi bên cùng thắng,
đóng góp vào sự ổn định kinh doanh của bạn, và giúp các nhà phát triển cốt lõi
làm việc toàn thời gian trên dự án.

Nếu bạn có bất kỳ câu hỏi cụ thể nào liên quan đến dự án của chúng tôi, đừng ngần ngại [liên hệ với chúng tôi](mailto:flyrouter@gmail.com).
### Tham gia và Đóng góp

Nếu bạn thích những gì chúng tôi đang làm, và muốn tăng cường sự phát triển, hãy xem xét việc tham gia.

Bạn có thể cải thiện mã nguồn hiện tại và gửi cho chúng tôi các bản vá. Bạn có thể thêm vào các tính năng mới mà mã nguồn của chúng tôi đang thiếu.

Bạn có thể giúp chúng tôi viết tài liệu tốt hơn, đọc và sửa lại các trang web của chúng tôi.

Bạn chỉ cần quyên góp một số tiền để bao phủ chi phí phát triển và duy trì lâu dài cho những gì chúng tôi tin rằng sẽ trở thành Khung Camera Mạng IP ổn định, linh hoạt và mở nhất cho người dùng như bạn.

Bạn có thể đóng góp tài chính cho dự án tại [Open Collective](https://opencollective.com/openipc/contribute/backer-14335/checkout).

Cảm ơn bạn.

<p style="text-align:center">
<a href="https://opencollective.com/openipc/contribute/backer-14335/checkout" target="_blank"><img src="https://opencollective.com/webpack/donate/button@2x.png?color=blue" width="375" alt="Nút quyên góp Open Collective"></a>
</p>


[burn]: https://github.com/OpenIPC/burn
[chaos_calmer]: https://github.com/OpenIPC/chaos_calmer
[coupler]: https://github.com/OpenIPC/coupler
[firmware]: https://github.com/OpenIPC/firmware
[hisi-trace]: https://github.com/OpenIPC/hisi-trace
[ipctool]: https://github.com/OpenIPC/ipctool
[majestic]: https://github.com/OpenIPC/majestic
[mini]: https://github.com/OpenIPC/mini
[motors]: https://github.com/OpenIPC/motors
[smolrtsp]: https://github.com/OpenIPC/smolrtsp
[webui]: https://github.com/OpenIPC/microbe-web
[wiki]: https://github.com/wiki
[yaml-cli]: https://github.com/OpenIPC/yaml-cli
