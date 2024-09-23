## Wiki OpenIPC
[Mục lục](../README.md)


## Camera chung Home Assistant
#### Lựa chọn 1
Vào Cài đặt -> Thiết bị và dịch vụ -> Thêm tích hợp --> Camera chung

#### Lựa chọn 2
[HomeAssistan_Chung](https://my.home-assistant.io/redirect/config_flow_start/?domain=generic)

#### Lựa chọn 3
<"IP-HomeAsisstantServer">/config/integrations/dashboard

Thêm tích hợp --> Camera chung

### Tham số cấu hình

<div style="display: flex;">
  <div style="max-width: 80%; overflow-x: auto;">
    <img src="../images/howto-streaming-homeassistant.png" alt="Ví dụ cấu hình camera chung home assistant (IP_Camera 192.168.1.29)" width="300"/>
  </div> 
  <div style="max-width: 80%; overflow-x: auto;">
    <pre>
      <code>
URL hình ảnh tĩnh -> http://<"IP-OIPC_Camera">/image.jpg
URL nguồn luồng -> rtsp://<"User">:<"PASS">@<"IP-OIPC_Camera">:554/stream=0
Giao thức vận chuyển RTSP -> TCP
Xác thực -> cơ bản
Tên người dùng -> <"User">
Mật khẩu -> <"PASS">
Tốc độ khung hình -> 15
Xác minh chứng chỉ SSL -> trống
Giới hạn tải lại khi thay đổi url -> trống
      </code>
    </pre>
  </div>
</div>

**Lưu ý:** Người dùng và Mật khẩu mặc định OpenIPC -> ("root" & ¨12345¨)

**Lưu ý:** Cẩn thận với tốc độ khung hình (Hiện tại, home assistant không hỗ trợ quá 20 khung hình/giây, nếu vượt quá sẽ gặp vấn đề nhấp nháy)

## Ví dụ Lovelace
Thêm đoạn trích này vào một thẻ mới theo cách thủ công (định dạng yaml)
```
camera_view: live
type: picture-glance
image: http://192.168.1.29/image.jpg
entities: []
entity: camera.192_168_1_29
view_layout:
  position: main
camera_image: camera.192_168_1_29
```
**Lưu ý KHÁC:**
## Cấu hình Camera
![](../images/HA_CameraConfig.png)

## Cài đặt Router
Hãy nhớ đặt địa chỉ IP cố định cho camera của bạn từ router, nếu không, nó có thể thay đổi khi khởi động lại.


# Tận hưởng luồng.


**Giải thích thuật ngữ:**

* **Home Assistant:** Là một nền tảng tự động hóa nhà mã nguồn mở.
* **Generic camera:** Camera chung, là một loại tích hợp trong Home Assistant cho phép bạn thêm bất kỳ camera IP nào hỗ trợ RTSP.
* **RTSP:** Real Time Streaming Protocol, là một giao thức mạng được sử dụng để truyền phát video và âm thanh trực tiếp.
* **TCP:** Transmission Control Protocol, là một giao thức mạng đáng tin cậy được sử dụng để truyền dữ liệu.
* **Authentication:** Xác thực, là quá trình xác minh danh tính của người dùng.
* **SSL:** Secure Sockets Layer, là một giao thức bảo mật được sử dụng để mã hóa dữ liệu được truyền qua mạng.
* **Lovelace:** Là giao diện người dùng dựa trên web cho Home Assistant.
* **YAML:** Là một ngôn ngữ đánh dấu dữ liệu được sử dụng trong các tệp cấu hình.
* **Picture-glance card:** Là một loại thẻ trong Lovelace cho phép bạn hiển thị hình ảnh từ camera.
* **Router:** Bộ định tuyến, là một thiết bị mạng được sử dụng để kết nối các mạng với nhau.
* **Fixed IP address:** Địa chỉ IP cố định, là một địa chỉ IP không thay đổi.




