# OpenIPC Wiki
[Table of Content](../README.md)

Foscam X5 / Acculenz R5 / Assark X3E
---

#### Preparation
Format an sdcard to FAT32 and copy the content of the following archive to the card:
- [foscam-openipc.zip][1]

Update your wireless credentials on autostart.sh:
```diff
#!/bin/sh
+WLAN_SSID="Router"
+WLAN_PASS="12345678"
```

#### Flashing
- Make sure the camera is powered off, put the prepared sdcard into the device.
- Power the device on and wait for 2-3 minutes.
- Shortly after an OpenIPC camera should appear on your wlan.

---

### Camera disassembly
<details>
<summary>Expand pictures</summary>
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

### Other
- Labels: X3/R3/R5/X3E
- https://fccid.io/ZDER3

[1]: https://github.com/OpenIPC/wiki/files/13218168/foscam-openipc.zip
