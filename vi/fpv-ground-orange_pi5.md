# OpenIPC Wiki

[Mục lục](../README.md)

## Hướng dẫn Cài đặt Nhanh Trạm Mặt đất cho OrangePi 5 Ubuntu 22.04

---

<p align="center">
  <img src="../images/pi5-plus.png?raw=true" alt="Logo" style="height:400px;"/> 
  <img src="../images/pi-5.png?raw=true" alt="Logo" style="height:400px;"/>
</p>

### Chuẩn bị

```
sudo apt update
sudo apt upgrade
```

### Tải xuống và cài đặt tiêu đề kernel Linux cho rockchip rk3588

[https://drive.google.com/drive/folders/1R7VmAeo3_LpFDQvYSEG9ymAC-DvaLt47](https://drive.google.com/drive/folders/1R7VmAeo3_LpFDQvYSEG9ymAC-DvaLt47)

```
sudo dpkg -i linux-headers-legacy-rockchip-rk3588_1.1.2_arm64.deb
sudo dpkg -i linux-image-legacy-rockchip-rk3588_1.1.2_arm64.deb
```

### Trình điều khiển card Wifi

Để vô hiệu hóa, hãy thêm nó vào danh sách đen:

```
sudo bash -c "cat > /etc/modprobe.d/wfb.conf <<EOF
# Danh sách đen mô-đun gốc
blacklist 88XXau
blacklist 8812au
blacklist rtl8812au
blacklist rtl88x2bs
EOF"
```

Biên dịch trình điều khiển từ mã nguồn:

```
git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git
cd rtl8812au/
sudo ./dkms-install.sh
```

### Cài đặt WFB-NG

Sử dụng lệnh "nmcli", chúng ta tìm ra tên của bộ chuyển đổi wifi của bạn và thay thế $WLAN vào vị trí

```
git clone -b stable https://github.com/svpcom/wfb-ng.git
cd wfb-ng
sudo ./scripts/install_gs.sh $WLAN
```

và bật tự động tải lên

```
sudo systemctl enable wifibroadcast
```

### Cấu hình kênh

```
sudo vi /etc/wifibroadcast.cfg
```

### Sao chép khóa mã hóa từ camera IP

```
sudo scp root@192.168.1.10:/etc/drone.key /etc/gs.key
```

và khởi động lại wfb-ng:

```
sudo systemctl restart wifibroadcast@gs
```

### Khởi động WFB CLI

```
wfb-cli gs
```

### Giải mã video

h265

```
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtph265depay ! h265parse ! mppvideodec ! xvimagesink sync=false
```

h264

```
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264' ! rtph264depay ! h264parse ! mppvideodec ! xvimagesink sync=false
```

###TRẠM MẶT ĐẤT ĐÃ SẴN SÀNG SỬ DỤNG###

### DVR (Máy ghi hình kỹ thuật số)

Tạo một tệp **gst_start** với nội dung sau và gán quyền thực thi **chmod +x gst_start**.

```
#!/bin/bash
current_date=$(date +'%Y%d%m_%H%M%S')
cd ~/Videos

if [[ $1 == "save" ]]
then
	gst-launch-1.0 -e udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtph265depay ! h265parse ! tee name=t ! queue ! mppvideodec ! xvimagesink sync=false t. ! queue ! matroskamux ! filesink location=record_${current_date}.mkv
else
	gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtph265depay ! h265parse ! mppvideodec ! xvimagesink sync=false
fi

```

Khi chạy với tùy chọn **save**, video sẽ được lưu vào **/thư mục home/Video/**

### Khởi động, dừng, khởi động lại dịch vụ

```
systemctl status wifibroadcast@gs
systemctl stop wifibroadcast@gs
systemctl start wifibroadcast@gs
```

### Lấy nhật ký mới nhất từ ​​dịch vụ

```
journalctl -u wifibroadcast@gs -f
journalctl -xu wifibroadcast@gs -n 100
```

### Lệnh hữu ích

```
# Kiểm tra hoạt động của wfb-ng
/usr/bin/wfb_rx -p 0 -c 127.0.0.1 -u 5600 -K /etc/gs.key -i 7669206 $WLAN

# Tìm ra tên của bộ chuyển đổi wifi
nmcli
ifconfig
iw

# Hiển thị các tham số có thể có của bộ chuyển đổi wifi
iw list

# Hiển thị cài đặt hiện tại của bộ chuyển đổi Wifi
iw dev

# Xuất ra các tham số tần số và công suất hiện tại
sudo iw reg get

# Đặt khu vực mới
sudo iw reg set RU
https://hackware.ru/?p=17978 - Giải quyết vấn đề lựa chọn kênh

# Xem các quy trình wfb-ng đang chạy
ps -aux | grep wfb

# Đặt công suất
sudo ip link set $WLAN down
sudo iw dev $WLAN set txpower fixed 30mBm
sudo ip link set $WLAN up

# Xem các plugin có sẵn để giải mã
gst-inspect-1.0 | grep 265

# Hiển thị danh sách các trình điều khiển/mô-đun đã tải xuống
lsmod

# Hiển thị danh sách các thiết bị USB được kết nối và các trình điều khiển liên quan
usb-devices
```




