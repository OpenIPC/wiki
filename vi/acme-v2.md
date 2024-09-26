## Hướng dẫn cài đặt chứng chỉ HTTPS trên camera OpenIPC

[Mục lục](../README.md)

### Cách cài đặt chứng chỉ HTTPS trên camera của bạn

Đảm bảo rằng camera của bạn có thể truy cập từ Internet trên cả cổng 80 (HTTP) và cổng 443 (HTTPS). Bạn có thể cần phải thiết lập **chuyển tiếp cổng** trên bộ định tuyến của mình cho việc này.

### Tạo tài khoản ACME:

__trên camera:__

```bash
uacme -y -v new
```

### Đặt FQDN cho camera của bạn

Giao thức HTTP bảo mật (HTTPS) không thể được cấp cho địa chỉ IP **đơn lẻ**, bạn cần một **Tên miền đầy đủ (FQDN)** cho camera của mình. Đó là cách camera của bạn sẽ được truy cập qua HTTPS.

Tạo một tài khoản với bất kỳ **Nhà đăng ký tên miền** nào và đăng ký một tên miền, ví dụ: _mysuperduperdomain.com_.

Thiết lập **vùng DNS** cho tên miền đó và tạo một **bản ghi** cho camera của bạn trong vùng miền đó.

```console
Bản ghi DNS
mysuperduperdomain.com
---------------------------------------
Loại    Host       Địa chỉ IP       TTL
A       ipc-001    75.123.45.555    600
```

trong đó `75.123.45.555` là địa chỉ IP công cộng của bạn.

### Thiết lập chuyển tiếp cổng nếu camera của bạn nằm sau NAT.

Thêm chuyển tiếp cổng từ cổng 80 của giao diện WAN đến cổng 80 của địa chỉ IP cục bộ của camera.

```console
75.123.45.555:80 => 192.168.1.10:80
```

Nếu bạn có một số thiết bị trên mạng của mình phục vụ các yêu cầu HTTP công khai, thì hãy thêm tên miền camera của bạn vào **máy chủ proxy HTTP**.


### Cấp chứng chỉ cho miền của bạn:

__trên camera__:

```bash
uacme -y -v -h /usr/share/uacme/uacme.sh -t EC issue ipc-001.mysuperduperdomain.com
```

### Thiết lập ghi đè bản ghi DNS cục bộ

Bạn có thể thêm bản ghi ghi đè vào tệp `/etc/hosts` trên máy của mình

```bash
echo "192.168.1.10  ipc-001.mysuperduperdomain.com" >> /etc/hosts
```

hoặc bạn có thể tạo một bản ghi trên máy chủ DNS cục bộ của mình như [pi.hole](https://pi-hole.net/) để bất kỳ ai sử dụng máy chủ DNS đó cũng có thể truy cập an toàn vào camera.

### Khởi động lại majestic và kiểm tra truy cập

Mở trình duyệt web yêu thích của bạn và truy cập <https://ipc-001.mysuperduperdomain.com/> 
