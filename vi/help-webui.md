## Wiki OpenIPC
[Mục lục](../README.md)

Trợ giúp: Giao diện người dùng Web
------------

### Cập nhật giao diện người dùng Web từ giao diện người dùng Web.

Trong một số trường hợp, đặc biệt nếu bạn nghĩ rằng có điều gì đó không hoạt động như bình thường, hãy thử cập nhật giao diện người dùng Web một lần nữa, ghi đè kiểm tra phiên bản cho lần cập nhật thứ hai. Điều này có thể được yêu cầu do một số thay đổi mà chúng tôi có thể đã thực hiện đối với quy trình cập nhật, do đó bạn sẽ phải truy xuất mã quy trình cập nhật bằng bản cập nhật đầu tiên, sau đó sử dụng nó cho bản cập nhật tiếp theo.

### Phát triển giao diện người dùng Web.

Nếu bạn muốn giúp chúng tôi phát triển giao diện web cho firmware của chúng tôi, đây là những gì bạn cần biết trước. Camera rất hạn chế về không gian và hiệu suất. Tùy chọn duy nhất hiện có trong firmware mà ít nhiều phù hợp để tạo động các trang HTML là `haserl`, một biến thể thú vị của `ash` được uốn cong để phục vụ như một trình bao bọc CGI. Tôi đã nói `ash`? Đúng vậy, vì chúng tôi không có `bash`, `tcsh`, `zsh` trong Linux của chúng tôi. Ash là vậy. Như trong A shell, tên đầy đủ là Almquist shell. Nhỏ gọn, nhẹ và có phần hạn chế. Hệ thống cũng bị hạn chế - trong hầu hết các phần, nó là `busybox`. Vì vậy, nếu bạn vẫn cảm thấy thoải mái khi làm bẩn tay với phong cách phát triển web rất thập niên 80 thì xin chào mừng bạn đến với chúng tôi.

Giao diện gần đây được xây dựng dựa trên framework CSS [Bootstrap](https://getbootstrap.com/), hơi quá mức cần thiết cho mục đích này nhưng cho phép chúng tôi theo dõi nhanh từ web vi khuẩn ban đầu đến những gì chúng tôi có bây giờ. Chúng tôi muốn thu gọn gói Bootstrap ban đầu và tạo một gói tùy chỉnh chỉ với các tính năng chúng tôi sử dụng. Nếu bạn sở hữu một kỹ năng như vậy, hãy đến và làm việc với chúng tôi.

Ngoài ra, chúng tôi đang xem xét khả năng chuyển sang trình tạo giao diện web phía máy khách, chỉ để lại việc truyền dữ liệu cho máy chủ. Vue.js hoặc tương tự. Bạn có muốn thêm điều gì ở đây không? Hãy nói ra.

Bất kỳ ý tưởng nào khác? Chúng tôi cũng muốn lắng nghe chúng.

### Chạy phiên bản phát triển của giao diện người dùng Web.

Để bắt đầu cải thiện giao diện web, hãy nhân bản kho lưu trữ GitHub của nó cục bộ và thiết lập NFS mount trên camera của bạn đến thư mục gốc của bản sao cục bộ:

```bash
mkdir -p /tmp/dev
mount -t nfs -o nolock,tcp 192.168.1.123:/full/path/to/web/files /tmp/dev
```

> _(thay thế 192.168.1.123 và /full/path/to/web/files bằng IP và đường dẫn của riêng bạn)_

Sau đó, khởi động một phiên bản khác của daemon httpd để phục vụ phiên bản giao diện người dùng Web của bạn trên một cổng khác của camera, chẳng hạn như cổng 86:

```bash
httpd -p 86 -h "/tmp/dev/var/www" -c /dev/null
```

Bây giờ bạn có thể làm việc trên mã nguồn giao diện người dùng Web trong IDE hoặc trình soạn thảo văn bản yêu thích của mình trên máy trạm và kiểm tra ngay lập tức các thay đổi bằng trình duyệt web tr ínhỏ đến cổng 86 trên camera. _(Ví dụ: http://192.168.1.10:86/)_

Hãy nhớ rằng bạn chỉ thay thế nội dung máy chủ web, nhưng cũng có các tập lệnh hỗ trợ nằm bên ngoài thư mục web. Các tập lệnh này cũng có thể yêu cầu cập nhật trên camera trong trường hợp bạn cũng thực hiện các thay đổi đối với chúng. Để cập nhật tập lệnh trên camera, hãy mở phiên ssh đến camera và sao chép phiên bản cập nhật của tập lệnh từ `/tmp/dev/usr/sbin/` sang `/usr/sbin/`.



**Giải thích thuật ngữ:**

* **Web UI:** Giao diện người dùng Web.
* **Firmware:** Phần mềm được nhúng vào bộ nhớ ROM của thiết bị phần cứng.
* **CGI:** Common Gateway Interface, là một tiêu chuẩn cho phép máy chủ web tương tác với các chương trình bên ngoài.
* **Ash:** Almquist shell, là một trình bao lệnh đơn giản và nhẹ.
* **Busybox:** Là một tập hợp các tiện ích Unix được thiết kế cho các hệ thống nhúng.
* **Bootstrap:** Là một framework CSS phổ biến được sử dụng để xây dựng giao diện web.
* **Client-side:** Phía máy khách.
* **Server-side:** Phía máy chủ.
* **Vue.js:** Là một framework JavaScript được sử dụng để xây dựng giao diện người dùng.
* **NFS:** Network File System, là một giao thức chia sẻ tệp qua mạng.
* **Mount:** Gắn kết, là quá trình kết nối một hệ thống tệp với một thư mục.
* **httpd:** Là một daemon máy chủ web.
* **IDE:** Integrated Development Environment, là một môi trường phát triển tích hợp cung cấp các công cụ cho việc lập trình.
* **ssh:** Secure Shell, là một giao thức kết nối an toàn đến máy chủ từ xa.





