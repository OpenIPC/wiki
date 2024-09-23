## Wiki OpenIPC
[Mục lục](../README.md)

Chạy máy chủ TFTP trong Docker
-------------------------------

Cách dễ nhất để chạy máy chủ TFTP là thực hiện điều đó bên trong môi trường container. Không quan trọng bạn chạy Linux, Windows hay Mac, chỉ cần thực hiện các bước sau:

### Cài đặt Docker Composer
Làm theo [hướng dẫn cài đặt Docker][1].

### Tạo tệp ảnh Docker
Tạo một tệp có tên `Dockerfile` với nội dung sau:
```dockerfile
FROM debian:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install tftpd-hpa -y -qq && \
apt-get clean && rm -rf /var/lib/apt/lists/*

CMD echo -n "Starting $(in.tftpd --version)" && \
in.tftpd --foreground --create --secure --ipv4 --verbose --user tftp \
--address 0.0.0.0:69 --blocksize 1468 /srv/tftp
```

Trong cùng thư mục, tạo một tệp có tên `docker-compose.yml` với nội dung sau:
```yaml
version: '3.9'
services:
  tftpd-hpa:
    build: .
    container_name: tftp
    network_mode: 'host'
    restart: unless-stopped
    volumes:
      - ./tftp:/srv/tftp
```

### Khởi động container
```bash
docker-compose up -d
```
Docker sẽ tạo một ảnh nếu cần và khởi chạy nó trong nền. Trong quá trình tạo container, Docker cũng sẽ tạo thư mục con `tftp/` từ đó các tệp của bạn sẽ được phục vụ. Docker hoạt động với tư cách là người dùng `systemd-network` từ nhóm
`input` để truy cập thư mục đó. Nếu bạn muốn cho phép lưu các tệp được gửi qua
TFTP vào máy của bạn, bạn sẽ cần thay đổi quyền sở hữu trên thư mục đó:
```bash
sudo chown systemd-network:input ./tftp
```
Ngoài ra, bạn có thể nới lỏng quyền trên thư mục đó:
```bash
sudo chmod 777 ./tftp
```
Sử dụng địa chỉ IP máy tính của bạn để truy cập máy chủ TFTP từ các máy khác trên mạng cục bộ của bạn.

### Dừng container
Để dừng container và giải phóng bộ nhớ, chỉ cần chạy
```bash
docker-compose stop
```
Container sẽ được lưu trên máy tính của bạn cho đến lần tiếp theo bạn cần khởi động nó.


[1]: https://docs.docker.com/compose/install/


**Giải thích thuật ngữ:**

* **TFTP (Trivial File Transfer Protocol):** Giao thức truyền tệp đơn giản, là một giao thức mạng được sử dụng để truyền tệp giữa máy khách và máy chủ.
* **Docker:** Là một nền tảng ảo hóa container.
* **Container:** Là một môi trường biệt lập để chạy ứng dụng.
* **Docker Composer:** Là một công cụ để định nghĩa và quản lý các ứng dụng đa container với Docker.
* **Dockerfile:** Là một tệp văn bản chứa các hướng dẫn để tạo ảnh Docker.
* **docker-compose.yml:** Là một tệp YAML chứa các cấu hình cho Docker Compose.
* **Image:** Ảnh, là một khuôn mẫu để tạo container.
* **Container name:** Tên container, là tên được sử dụng để nhận dạng container.
* **Network mode:** Chế độ mạng, là cách container kết nối với mạng.
* **Restart:** Khởi động lại, là một tùy chọn để tự động khởi động lại container khi nó dừng.
* **Volumes:** Khối lượng, là một cách để chia sẻ dữ liệu giữa máy chủ và container.
* **IP address:** Địa chỉ IP, là một địa chỉ định danh duy nhất cho một thiết bị trên mạng.
* **Ownership:** Quyền sở hữu, là thông tin xác định người dùng và nhóm có quyền truy cập vào tệp hoặc thư mục.
* **Permissions:** Quyền, là các quy tắc xác định ai có thể đọc, ghi và thực thi tệp hoặc thư mục.






