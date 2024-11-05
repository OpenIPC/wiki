# OpenIPC Wiki
[Table of Content](../README.md)

Foscam X5 / Acculenz R5 / Assark X3E
---

#### Caution

Make sure you have a device with label stating [FCC ID: ZDER3Version 1.0]. There are now devices on the market still marked as Foscam X5, which probably have different internals and do not support following flashing procedure/image. You will end up with bricked device! The label on those newer models contain designation like: [Device Name: MPS50501 FCC ID: ZDEX5 Version 6.0][3]

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
- Power the device on and wait at least 4 minutes.
- Shortly after an OpenIPC camera should appear on your wlan.

---

### GPIO
IRLed | IRCut | Speaker | Reset | IRSensor
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

### Wireless
```
fw_setenv wlandev rtl8188fu-ssc337de-foscam
fw_setenv wlanssid Router
fw_setenv wlanpass 12345678
```

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

[1]: https://github.com/openipc/wiki/files/13301107/foscam-openipc.zip
[2]: https://fccid.io/ZDER3/Label/Label-Location-5529099
[3]: https://fccid.io/ZDEX5/Label/Label-Info-7719960
