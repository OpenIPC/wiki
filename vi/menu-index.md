## OpenIPC Wiki
[Mục lục](../README.md)

## Thông tin cơ bản

OpenIPC là một [firmware](https://github.com/OpenIPC) thay thế cho camera IP và là một dự án bao gồm các dự án thành phần khác trong hệ thống của chúng tôi.

OpenIPC là một hệ điều hành Linux dựa trên các dự án Buildroot/OpenWrt và nhắm mục tiêu đến các camera IP với chipset từ các nhà cung cấp khác nhau, bắt đầu với Goke GK72xx, HiSilicon Hi35xx, SigmaStar SSC33x và XiongmaiTech XM5xx.

Tất cả mọi người đều được chào đón để sử dụng/đóng góp cho dự án theo bất kỳ cách nào họ thấy hữu ích!

Chúng tôi sẽ rất biết ơn mọi phản hồi và đề xuất.


## Liên kết chính thức

* [OpenIPC trên Wiki](https://github.com/openipc/wiki) - Bộ sưu tập các tài liệu và hướng dẫn khác nhau.
* [OpenIPC trên GitHub](https://github.com/OpenIPC/) - Tổ chức GitHub, hầu hết các dự án được lưu trữ tại đây.
* [OpenIPC trên OpenCollective](https://opencollective.com/openipc) - Cộng đồng OpenCollective.
* [OpenIPC trên Twitter](https://twitter.com/openipc) - Tin tức chính của chúng tôi.
* [OpenIPC trên YouTube](https://www.youtube.com/channel/UCaXlbR2uGTRFh8jQ2lCFd2g) - Hướng dẫn và luồng của chúng tôi (đang trong kế hoạch).


## Các nhóm trò chuyện Telegram

* [OpenIPC](https://t.me/openipc) (EN) - Kênh quốc tế để thảo luận về sự phát triển của dự án, [*](https://combot.org/c/1166652144)
* [OpenIPC modding](https://t.me/openipc_modding) (RU) - các vấn đề chung về sửa đổi firmware thiết bị IPCam, [*](https://combot.org/c/-1001247643198)
* [OpenIPC development](https://t.me/openipc_software) (RU) - HiSilicon, XM porting trong OpenWrt và các vấn đề về lập trình, [*](https://combot.org/c/-1001196905312)
* [OpenIPC advice](https://t.me/openipc_advice) (RU) - các vấn đề, tìm kiếm giải pháp, các cuộc trò chuyện dài, [*](https://combot.org/c/1385065634)
* [OpenIPC Iranian](https://t.me/joinchat/T_GwQUBTJdfXJrFb) (IR) - nhóm đặc biệt dành cho người dùng Iran / OpenIPC Team dành cho người dùng Iran, [*](https://combot.org/c/-1001341239361)
* [OpenIPC demo](https://t.me/openipc_demo)  (EN/RU) - bot thử nghiệm với các nút, sau khi kết nối, hãy nhập "/menu", [*](https://combot.org/c/1414887196)
* [OpenIPC ExIPCam](https://t.me/ExIPCam) (RU) - Chương trình ExIPCam và sửa chữa phần cứng/phần mềm thiết bị, [*](https://combot.org/c/1213889378)
* [OpenIPC updates](https://t.me/s/openipc_updates) (RU) - Kênh thông tin cập nhật Firmware & Phần mềm
* [OpenIPC dev](https://t.me/s/openipc_dev) - Kênh phát triển Firmware & Phần mềm


## Các phát triển của nhóm

### Firmware

* [openipc-2.x](https://github.com/openipc/firmware) - Hệ thống phát triển và tạo firmware dựa trên Buildroot.
* [openipc-1.0][chaos_calmer] - Hệ thống phát triển và tạo firmware dựa trên OpenWrt 15.05.
* [coupler][coupler] - Chuyển đổi liền mạch giữa firmware camera video.

### Trình phát trực tuyến

* [majestic](https://openipc.org/majestic-endpoints) - Trình phát trực tuyến IPCam phổ dụng.
* [mini][mini] - Trình phát trực tuyến camera IP Mini mã nguồn mở.

### Công cụ

* [ipctool](https://github.com/openipc/ipctool) - Công cụ (và thư viện) để kiểm tra phần cứng camera IP.
* [yaml-cli][yaml-cli] - Công cụ để thay đổi cài đặt trong CLI.
* [glutinium](https://github.com/ZigFisher/Glutinium) - Các gói OpenWRT bổ sung.

### Phần mềm Windows

* [exipcam](http://team.openipc.org/exipcam) - Tiện ích tuyệt vời để sửa chữa IPCam (Dành cho Windows, hoạt động trong Linux thông qua Wine).
* [ipcam_dms](http://team.openipc.org/ipcam_dms) - Hệ thống quản lý thiết bị IPCam (Dành cho Windows, hoạt động trong Linux thông qua Wine).


## Các nhà phát triển

| Tên                                                             | Vai trò                                                  | Tham gia                                                            |
|------------------------------------------------------------------|--------------------------------------------------------|--------------------------------------------------------------------------|
| [Dmitry Ilyin](https://web.telegram.org/#/im?p=@widgetii)        | đồng sáng lập và người tham gia chính của dự án OpenIPC  | [ipctool][ipctool], [majestic][majestic], [mini][mini], [motors][motors] |
| [Dmitry Ermakov](https://web.telegram.org/#/im?p=@dimerrr)       | người tham gia chính                                      | [coupler][coupler], [firmware][firmware], [ipctool][ipctool]             |
| [Igor Zalatov](https://web.telegram.org/#/im?p=@FlyRouter)       | **người sáng lập dự án và điều phối viên phát triển**       | [chaos_calmer][chaos_calmer], [firmware][firmware], [wiki][wiki]         |
| [Ivan Pozdeev](https://web.telegram.org/#/im?p=@John)            | nhà phát triển                                             | [microbe-web][webui], [yaml-cli][yaml-cli]                               |
| [Konstantin](#)                                                  | nhà phát triển                                             | [hisi-trace][hisi-trace], [yaml-cli][yaml-cli]                           |
| [Maksim Patrushev](https://web.telegram.org/#/im?p=@maxi380)     | nhà phát triển                                             | [motors][motors]                                                         |
| [Maxim Chertov](https://web.telegram.org/#/im?p=@mAX3773)        | đồng sáng lập dự án OpenIPC                       | [chaos_calmer][chaos_calmer], [ipctool][ipctool], [mini][mini]           |
| [Paul Philippov](https://web.telegram.org/#/im?p=@themactep)     | người tham gia chính                                      | [microbe-web][webui]                                                     |
| [Sergey Sharshunov](https://web.telegram.org/#/im?p=@USSSSSH)    | đồng sáng lập dự án OpenIPC                       | [chaos_calmer][chaos_calmer], [burn][burn]                               |
| [Temirkhan Myrzamadi](https://web.telegram.org/#/im?p=@hirrolot) | người tham gia chính                                      | [smolrtsp][smolrtsp]                                                     |
| [Vasiliy Yakovlev](https://web.telegram.org/#/im?p=@#)           | người hỗ trợ chung                                     |                                                                          |


### Hỗ trợ

OpenIPC cung cấp hai cấp độ hỗ trợ.

- Hỗ trợ miễn phí thông qua cộng đồng (thông qua [trò chuyện](https://openipc.org/#telegram-chat-groups) và [danh sách gửi thư](https://github.com/OpenIPC/firmware/discussions)).
- Hỗ trợ thương mại có trả phí (từ nhóm các nhà phát triển).

Vui lòng cân nhắc đăng ký hỗ trợ thương mại có trả phí nếu bạn định sử dụng sản phẩm của chúng tôi cho doanh nghiệp.
Là khách hàng trả phí, bạn sẽ nhận được dịch vụ hỗ trợ kỹ thuật và bảo trì trực tiếp từ nhóm kỹ thuật lành nghề của chúng tôi.
Các báo cáo lỗi và yêu cầu tính năng của bạn sẽ được ưu tiên chú ý và giải quyết nhanh chóng. Đó là một chiến lược đôi bên cùng có lợi,
góp phần vào sự ổn định của doanh nghiệp bạn và giúp các nhà phát triển cốt lõi làm việc toàn thời gian cho dự án.

Nếu bạn có bất kỳ câu hỏi cụ thể nào liên quan đến dự án của chúng tôi, vui lòng [liên hệ với chúng tôi](mailto:flyrouter@gmail.com).

### Tham gia và Đóng góp

Nếu bạn thích những gì chúng tôi làm và sẵn sàng đẩy mạnh sự phát triển, vui lòng cân nhắc tham gia.

Bạn có thể cải thiện mã hiện có và gửi cho chúng tôi các bản vá. Bạn có thể thêm các tính năng mới còn thiếu trong mã của chúng tôi.

Bạn có thể giúp chúng tôi viết tài liệu tốt hơn, hiệu đính và sửa chữa các trang web của chúng tôi.

Bạn chỉ cần quyên góp một số tiền để trang trải chi phí phát triển và duy trì lâu dài những gì chúng tôi tin
sẽ là Khuôn khổ Camera Mạng IP ổn định, linh hoạt và mở nhất dành cho người dùng như bạn.

Bạn có thể đóng góp tài chính cho dự án tại [Open Collective](https://opencollective.com/openipc/contribute/backer-14335/checkout).

Cảm ơn bạn.

<p style="text-align:center">
<a href="https://opencollective.com/openipc/contribute/backer-14335/checkout" target="_blank"><img src="https://opencollective.com/webpack/donate/button@2x.png?color=blue" width="375" alt="Open Collective donate button"></a>
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