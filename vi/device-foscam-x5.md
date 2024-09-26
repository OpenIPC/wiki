# OpenIPC Wiki
[Mục lục](../README.md)

Foscam X5 / Acculenz R5 / Assark X3E
---

#### Chuẩn bị
Định dạng thẻ nhớ SD sang FAT32 và sao chép nội dung của kho lưu trữ sau vào thẻ:
- [foscam-openipc.zip][1]

Cập nhật thông tin xác thực không dây của bạn trên autostart.sh:
```diff
#!/bin/sh
+WLAN_SSID="Router"
+WLAN_PASS="12345678"
```

#### Cài đặt
- Đảm bảo camera đã tắt nguồn, đặt thẻ nhớ SD đã chuẩn bị vào thiết bị.
- Bật nguồn thiết bị và đợi ít nhất 4 phút.
- Một camera OpenIPC sẽ xuất hiện trên mạng WLAN của bạn sau một thời gian ngắn.

---

### GPIO
IRLed | IRCut | Loa | Đặt lại | Cảm biến IR
-|-|-|-|-
GPIO0 | GPIO3 | GPIO14 | GPIO66 | GPIO80

```
cli -s .nightMode.irSensorPin 80
cli -s .nightMode.irCutPin1 3
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 0
cli -s .audio.speakerPin 14
cli -s .audio.speakerPinInvert true
```

---

### Không dây
```
fw_setenv wlandev rtl8188fu-ssc337de-foscam
fw_setenv wlanssid Router
fw_setenv wlanpass 12345678
```

---

### Tháo rời camera
<details>
<summary>Mở rộng hình ảnh</summary>
<img src="../images/device-foscam-01.webp" width=50% height=50%>
<img src="../images/device-foscam-02.webp" width=50% height=50%>
<img src="../images/device-foscam-03.webp" width=50% height=50%>
<img src="../images/device-foscam-04.webp" width=50% height=50%>
<img src="../images/device-foscam-05.webp" width=50% height=50%>
<img src="../images/device-foscam-06.webp" width=50% height=50%>
<img src="../images/device-foscam-07.webp" width=50% height=50%>
<img src="../images/device-foscam-08.webp" width=80% height=80%>
<img src="../images/device-foscam-09.webp" width=80% height=80%>
</details>

---

### Khác
- Nhãn: X3/R3/R5/X3E
- https://fccid.io/ZDER3

[1]: https://github.com/openipc/wiki/files/13301107/foscam-openipc.zip
