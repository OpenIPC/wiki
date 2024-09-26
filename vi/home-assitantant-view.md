# Wiki OpenIPC
[Mục lục](../README.md)


## Tích hợp camera chung Home Assistant
#### Tùy chọn 1
Vào Cài đặt -> Thiết bị và dịch vụ -> Thêm tích hợp --> Camera chung

#### Tùy chọn 2
[HomeAssistan_Chung](https://my.home-assistant.io/redirect/config_flow_start/?domain=generic)

#### Tùy chọn 3
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
Giao thức truyền tải RTSP -> TCP
Xác thực -> cơ bản
Tên người dùng -> <"User">
Mật khẩu -> <"PASS">
Tốc độ khung hình -> 15
Xác minh chứng chỉ SSL -> bỏ trống
Giới hạn tải lại khi thay đổi url -> bỏ trống
      </code>
    </pre>
  </div>
</div>

**Lưu ý:** Tên người dùng và Mật khẩu mặc định của OpenIPC -> ("root" & ¨12345¨)

**Lưu ý:** Cẩn thận với tốc độ khung hình (Hiện tại, Home Assistant không hỗ trợ quá 20 khung hình/giây, nếu vượt quá sẽ gặp vấn đề nhấp nháy)

## Ví dụ Lovelace
Thêm đoạn mã này vào thẻ mới theo cách thủ công (định dạng YAML)
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
**GHI CHÚ KHÁC:**
## Cấu hình Camera
![](../images/HA_CameraConfig.png)

## Cài đặt Router
Hãy nhớ đặt địa chỉ IP tĩnh cho camera của bạn từ router, nếu không, địa chỉ IP có thể thay đổi khi camera khởi động lại.


# Tận hưởng luồng.


