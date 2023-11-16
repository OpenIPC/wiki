# OpenIPC Wiki
[Table of Content](../README.md)

Instructions for installing OpenIPC firmware on SigmaStar devices
---

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

---

### SSC338Q + IMX415 + NAND flash, board from CamHi vendor
#### Quick note on experiments, will be revised and updated

#### Summary
The Sigmastar IPL (pre-bootloader) allows to boot a custom U-Boot from the sdcard.
With this temporary OpenIPC firmware you can create a backup of the nand and flash the permanent firmware afterwards.

#### Prepare
- Connect your sdcard to your computer, create a 1 GB partition and format it as FAT32 / VFAT.
- [Download and unpack ssc338q-initramfs.zip][1]
- Copy all files to the root directory of the sdcard, update your wireless credentials on autoconfig.sh:
```diff
#!/bin/sh
+WLAN_SSID="Router"
+WLAN_PASS="12345678"
```
- Put the sdcard into the camera module, start it and wait until it connects to your router.
- Use ssh to connect to the camera:
```
ssh root@192.168.1.100
root
12345
```

#### Backup 
- /dev/mtd0 uses the complete partition size of the nand flash.
- This might take some time, the backup to the sdcard is rather slow.
```
nanddump -f /mnt/mmcblk0p1/backup-nand.bin /dev/mtd0
```

#### Install
```
flash_eraseall /dev/mtd0
nandwrite /dev/mtd0 /mnt/mmcblk0p1/ssc338q-fpv.bin
```

#### Buying a device (CamHi vendor)
- https://aliexpress.com/item/1005002879158570.html
- https://aliexpress.com/item/1005005750013595.html

---

### SSC338Q + IMX415 + NOR flash, board from Anjoy vendor
#### Information collection continues
Information collection continues

#### Buying a device (Anjoy vendor)
- https://aliexpress.com/item/1005003738087454.html

---

### Other notes
For testing please use the [MPV](https://mpv.io/) player, in which the Shift+I key combination can be used to get debugging information.

[1]: https://github.com/OpenIPC/wiki/files/13379877/ssc338q-initramfs.zip
