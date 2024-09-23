# OpenIPC Wiki
[Mục lục](../README.md)

Cài đặt Cảm biến Hình ảnh
-----------------------

Nếu trình điều khiển cảm biến hình ảnh không được bao gồm trong image firmware, bạn có thể cài đặt thủ công.

Ví dụ: cảm biến hình ảnh "sc223a" sẽ được cài đặt trên bo mạch gk7205v210 (với openipc-gk7205v210-fpv-8mb.bin đã được flash).

Bạn cần một [thư viện cảm biến](https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/libsns_sc223a.so) và một [tệp cấu hình cảm biến](https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini).

Các tệp cần thiết cho các cảm biến khác có thể được tìm thấy theo [danh sách này](firmware-sensors.md).

Cài đặt các tệp bằng cách tải xuống trực tiếp từ github về thiết bị của bạn:
```sh
curl -s -L -o /usr/lib/sensors/libsns_sc223a.so https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/libsns_sc223a.so
curl -s -L -o /etc/sensors/sc223a_i2c_1080p.ini https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini
```

Điều chỉnh giá trị fps trong /etc/majestic.yaml theo thông số kỹ thuật của cảm biến của bạn.
Tìm kiếm "Isp_FrameRate" trong tệp cấu hình cảm biến của bạn [/etc/sensors/sc223a_i2c_1080p.ini](https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini).

```sh
cli -s .video0.fps 30
```

(Khởi động lại) trình phát trực tuyến:

```sh
killall majestic
majestic
```

[thêm thông tin về cảm biến `sc223a`](https://github.com/RoboSchmied/Documentation/blob/main/sc223a.md)
