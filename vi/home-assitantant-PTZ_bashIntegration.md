# Wiki OpenIPC
[Mục lục](../README.md)

## Tích hợp PTZ với Home Assistant

Tích hợp này dựa trên lệnh SSH tới firmware OpenIPC để tích hợp các điều khiển PTZ, dành cho các camera không hỗ trợ ONVIF.

## Cấu hình Camera
Tải các mô-đun với các tham số (bạn có thể cần thử nghiệm với các giá trị hmaxstep và vmaxstep cho camera cụ thể của mình).

Sao chép motor_sample.ko ---> bộ nhớ trong (sao chép qua SSH)
```
scp "C:\Users\Downloads\sample_motor.ko" root@192.168.1.29:/sample_motor.ko
```
Chỉnh sửa tập lệnh tự động khởi động mới trên camera của bạn
```
  $ vi /etc/rc.local
```
Thêm các dòng này
```
# addmod
insmod /sample_motor.ko vstep_offset=0 hmaxstep=2130 vmaxstep=1600
# di chuyển đến vị trí 0 
t31-kmotor -d   h -r
```
Thay đổi quyền truy cập tệp (thêm quyền thực thi)
```
 $ chmod +x /etc/rc.local
```

## Cấu hình Home Assistant
```
 docker ps
 docker exec -it <"ID_HA_container"> /bin/bash
```
cài đặt sshpass
```
apk add sshpass
```

**Lưu ý:** Bạn có thể kiểm tra sshpass bằng

```
sshpass -p '123456' ssh root@192.168.1.29
```


Thêm các dòng đó vào configuration.yaml
```
shell_command:
  c101_x_down: /bin/bash c101_x_down.sh
  c101_x_up: /bin/bash c101_x_up.sh
  c101_y_down: /bin/bash c101_y_down.sh
  c101_y_up: /bin/bash c101_y_up.sh
  c101_r: /bin/bash c101_r.sh
```
Thêm các dòng đó vào scripts.yaml
```
c101_x_down:
  alias: c101_x_down
  sequence:
  - service: shell_command.c101_x_down
    data: {}
  mode: single
c101_x_up:
  alias: c101_x_up
  sequence:
  - service: shell_command.c101_x_up
    data: {}
  mode: single
c101_y_down:
  alias: c101_y_down
  sequence:
  - service: shell_command.c101_y_down
    data: {}
  mode: single
c101_y_up:
  alias: c101_y_up
  sequence:
  - service: shell_command.c101_y_up
    data: {}
  mode: single
c101_r:
  alias: c101_r
  sequence:
  - service: shell_command.c101_r
    data: {}
  mode: single
```

**TẬP LỆNH**
Bạn có thể tìm thấy tập lệnh này trong kho lưu trữ này
https://github.com/OpenIPC/motors/tree/4c7dc45e5e877f38c076343f361159844374920a/t31-kmotor

Tạo tập lệnh này trong thư mục /config

```
vi camara_scrip.sh
```
Dán nội dung sau
```
#!/bin/bash

echo "Nhập tên người dùng camera:"
read user
echo "Nhập mật khẩu camera:"
read password
echo "Nhập IP camera:"
read ip
echo "Tên_Camera_"
read name

echo "#!/bin/bash
# Kết nối với máy chủ từ xa bằng sshpass và mật khẩu
sshpass -p '"$password"'  ssh -o StrictHostKeyChecking=accept-new  "$user"@"$ip" <<EOF
# Bên trong máy chủ từ xa, thực thi lệnh t31-kmotor với các đối số
t31-kmotor -d   h -r
EOF 
"> "$name"_r.sh
echo "#!/bin/bash
# Kết nối với máy chủ 
sshpass -p '"$password"'  ssh -o StrictHostKeyChecking=accept-new  "$user"@"$ip" <<EOF
# Bên trong máy chủ từ xa, thực thi lệnh t31-kmotor
t31-kmotor -d g -x -300 -y 0
EOF 
"> "$name"_x_down.sh
echo "#!/bin/bash
# Kết nối với máy chủ 
sshpass -p '"$password"'  ssh -o StrictHostKeyChecking=accept-new "$user"@"$ip" <<EOF
# Bên trong máy chủ từ xa, thực thi lệnh t31-kmotor
t31-kmotor -d g -x 300 -y 0
EOF 
"> "$name"_x_up.sh
echo "#!/bin/bash
# Kết nối với máy chủ 
sshpass -p '"$password"'  ssh -o StrictHostKeyChecking=accept-new  "$user"@"$ip" <<EOF
# Bên trong máy chủ từ xa, thực thi lệnh t31-kmotor
t31-kmotor -d g -x 0 -y -300
EOF 
"> "$name"_y_down.sh
echo "#!/bin/bash
# Kết nối với máy chủ 
sshpass -p '"$password"'  ssh -o StrictHostKeyChecking=accept-new  "$user"@"$ip" <<EOF
# Bên trong máy chủ từ xa, thực thi lệnh t31-kmotor
t31-kmotor -d g -x 0 -y 300
EOF 
"> "$name"_y_up.sh

# Thay đổi chế độ 
chmod +x "$name"_r.sh "$name"_x_down.sh "$name"_x_up.sh "$name"_y_down.sh "$name"_y_up.sh

```
Thực thi các dòng sau
```
chmod +x camara_scrip.sh
./camara_scrip.sh
```
Nhập dữ liệu camera của bạn (tên trước ví dụ c101)

**Lưu ý:** cần tạo tập lệnh cho các tệp khác (configuration.yml và scripts.yml)



## Ví dụ Lovelace
Thêm đoạn mã này vào một thẻ mới theo cách thủ công (định dạng YAML)
```
camera_view: live
type: picture-elements
image: http://192.168.1.29/image.jpg
entities:
  - entity: script.c1_r
  - entity: script.c1_x_down
  - entity: script.c1_x_up
  - entity: script.c1_y_down
  - entity: script.c1_y_up
camera_image: camera.192_168_1_29
elements:
  - type: icon
    icon: mdi:arrow-left-drop-circle
    tap_action:
      action: call-service
      service: script.c1_x_down
    style:
      bottom: 45%
      left: 5%
      color: white
      opacity: 0.5
      transform: scale(1.5, 1.5)
  - type: icon
    icon: mdi:arrow-right-drop-circle
    tap_action:
      action: call-service
      service: script.c1_x_up
    style:
      bottom: 45%
      right: 5%
      color: white
      opacity: 0.5
      transform: scale(1.5, 1.5)
  - type: icon
    icon: mdi:arrow-up-drop-circle
    tap_action:
      action: call-service
      service: script.c1_y_up
    style:
      top: 10%
      left: 46%
      color: white
      opacity: 0.5
      transform: scale(1.5, 1.5)
  - type: icon
    icon: mdi:arrow-down-drop-circle
    tap_action:
      action: call-service
      service: script.c1_y_down
    style:
      bottom: 10%
      left: 46%
      color: white
      opacity: 0.5
      transform: scale(1.5, 1.5)
  - type: icon
    icon: mdi:arrow-expand-all
    tap_action:
      action: more-info
    entity: camera.192_168_1_29
    style:
      top: 5%
      right: 5%
      color: white
      opacity: 0.5
      transform: scale(1.5, 1.5)

```

Ví dụ về chế độ xem

![Giao diện GUI](../images/GUI_Interface.png)
# Tận hưởng luồng.
