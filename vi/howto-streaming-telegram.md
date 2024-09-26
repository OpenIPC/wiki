# Wiki OpenIPC
[Mục lục](../README.md)

## Phát trực tiếp lên Telegram

Mở kênh mà bạn muốn phát trực tiếp. Bắt đầu phiên phát trực tiếp.

![](../images/howto-streaming-telegram-1.webp)

Sao chép URL Máy chủ và Khóa luồng từ Cài đặt.

![](../images/howto-streaming-telegram-2.webp)

Mở `/etc/majestic.yaml` trên camera và thêm URL và khóa vào phần `outgoing` của tệp cấu hình.

**Lưu ý:** Nó sẽ phát trực tiếp luồng `video0`. Luồng này **phải** được cấu hình với codec video là: `h264`.

**Lưu ý:** Đừng quên thêm dấu `-` trước các tham số!

**Lưu ý:** Phần `outgoing` có thể ảnh hưởng đến việc thêm các phần khác. Hãy nhớ điều đó!

![](../images/howto-streaming-telegram-3.webp)
![](../images/howto-streaming-telegram-4.webp)

Khởi động lại trình phát trực tiếp Majestic.

![](../images/howto-streaming-telegram-5.webp)

Tận hưởng luồng phát.

![](../images/howto-streaming-telegram-6.webp)

