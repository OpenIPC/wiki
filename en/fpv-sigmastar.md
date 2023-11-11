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
* [The files for this experiment are temporarily available here](https://github.com/OpenIPC/sandbox-fpv/tree/master/sigmastar)

#### Explanations
The Sigmastar IPL (pre-bootloader) allows to boot a custom U-Boot from the sdcard.
The provided UBOOT + uImage.ssc338q is a fully working openipc firmware, that you can connect to via SSH / WEB over the ethernet connection.

With this temporary openipc firmware you can create a backup of the internal NAND and flash the permanent openipc firmware to the NAND.

#### Prepare
Here is the sdcard firmware to install openipc to the nand flash.

- Connect your SD card to your computer, create a 1 GB partition on it, format it as FAT32 / VFAT.
- In Linux you just need to use the commands fdisk and mkfs.vfat
- Mount disk and unpack ssc338q_initramfs.zip and copy both files to the root directory.
- The UBOOT and uImage.ssc338q is used for the temporary sdcard system and to gain access to the NAND flash.
- Reboot the device and let it start from the SD card
- $\color{red}{\texttt{Do not stop the bootloader under any circumstances!}}$

#### Backup 
- The /dev/mtd0 uses the complete partition size of the nand flash, so this can also be used for a backup.
- But this might take some time, the backup to the sdcard is very slow.
```
nanddump -f /mnt/mmcblk0p1/backup-nand.bin /dev/mtd0
```

#### Install
The ssc338q-nand.bin includes the current distributor bootloader and nand ultimate firmware.
```
flash_eraseall /dev/mtd0
nandwrite /dev/mtd0 /mnt/mmcblk0p1/ssc338q-nand.bin
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
