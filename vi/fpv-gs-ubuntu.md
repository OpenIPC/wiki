# OpenIPC Wiki
[Mục lục](../README.md)

Các lệnh từng bước để chạy Trạm Mặt đất trên Ubuntu 22.04
---------------------------------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

Phiên bản video: - [OpenIPC - Chuẩn bị Trạm Mặt đất: Ubuntu + QGroundControl](https://www.youtube.com/watch?v=JMtRAsOm0Dc)

### Chuẩn bị
```
sudo apt update
```
```
sudo apt install dkms git python3-all-dev net-tools virtualenv fakeroot debhelper python3-twisted
 libpcap-dev python3-pyroute2 python3-future python3-configparser python3-all libsodium-dev
```

### Libsodium
```
git clone https://github.com/jedisct1/libsodium --branch stable
cd libsodium
./configure
make && make check
sudo make install
```

### Trình điều khiển card Wifi
```
git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git
cd rtl8812au/
sudo ./dkms-install.sh
```

### WFB-NG
```
git clone -b stable https://github.com/svpcom/wfb-ng.git
cd wfb-ng
sudo ./scripts/install_gs.sh wlan0
```

### Cấu hình kênh
```
vi /etc/wifibroadcast.cfg
```

### Khởi động WFB CLI
```
wfb-cli gs
```
###TRẠM MẶT ĐẤT ĐÃ SẴN SÀNG SỬ DỤNG###

### Khởi động, dừng, khởi động lại dịch vụ
```
systemctl status wifibroadcast@gs
systemctl stop wifibroadcast@gs
systemctl start wifibroadcast@gs
```

### Hướng dẫn sử dụng Qground control

- https://docs.qgroundcontrol.com/master/en/getting_started/download_and_install.html

### Lấy nhật ký cuối cùng từ dịch vụ
```
journalctl -xu wifibroadcast@gs -n 100
```

### Các lệnh hữu ích
```
nmcli
ifconfig
iwconfig

```



