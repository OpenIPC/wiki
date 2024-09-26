# OpenIPC Wiki
[Mục lục](../README.md)

Cài đặt Wireless
---

### Cấu hình ban đầu

- Cài đặt wireless được cung cấp dựa trên một biến uboot:

```diff
# HI3516EV300 CamHi
+if [ "$1" = "mt7601u-hi3516ev300-camhi" ]; then
	devmem 0x100C0080 32 0x530
```

> [!QUAN TRỌNG]  
> Một số trình điều khiển không được bao gồm trong các tệp nhị phân firmware OpenIPC được tạo sẵn, bạn có thể phải tự biên dịch nó.

- Các biến [được liệt kê ở đây][1] và có thể được đặt bằng:
```shell
fw_setenv wlandev mt7601u-hi3516ev300-camhi
```

### Nhập thông tin đăng nhập wireless

- Thông tin đăng nhập có thể được thêm bằng:

```shell
fw_setenv wlanssid MySSID
fw_setenv wlanpass MyPassword
```

---

### Áp dụng cài đặt tùy chỉnh

- Có thể chuyển đổi [cài đặt wlan0 hiện có](../en/network-settings.md) sang [cấu hình mới][1]:

```diff
auto wlan0
iface wlan0 inet dhcp
+	pre-up devmem 0x100C0080 32 0x530
+	pre-up echo 7 > /sys/class/gpio/export
+	pre-up echo out > /sys/class/gpio/gpio7/direction
+	pre-up echo 0 > /sys/class/gpio/gpio7/value
+	pre-up modprobe mt7601u
	pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
	pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
	pre-up sleep 3
	pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
	post-down killall -q wpa_supplicant
	post-down echo 1 > /sys/class/gpio/gpio7/value
	post-down echo 7 > /sys/class/gpio/unexport
```

```diff
# HI3516EV300 CamHi
if [ "$1" = "mt7601u-hi3516ev300-camhi" ]; then
+	devmem 0x100C0080 32 0x530
+	set_gpio 7 0
+	modprobe mt7601u
	exit 0
fi
```

[1]: https://github.com/OpenIPC/firmware/blob/master/general/overlay/etc/wireless

