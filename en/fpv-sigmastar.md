# OpenIPC Wiki
[Table of Content](../README.md)

Instructions for installing OpenIPC firmware on SigmaStar devices
-----------------------------------------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

$\color{red}{\texttt{Please click on the arrow on the left to expand the menu}}$

<details>
<summary><h3>SSC338Q + IMX415 + NAND flash, board from CamHi vendor</h3></summary>

#### Quick note on experiments, will be revised and updated

* [The files for this experiment are temporarily available here](https://github.com/OpenIPC/sandbox-fpv/tree/master/sigmastar)

#### Prepare

Here is the sdcard firmware to install openipc to the nand flash.

- Connect your SD card to your computer, create a 1 GB partition on it, format it as FAT32 / VFAT.
- In Linux you just need to use the commands fdisk and mkfs.vfat
- Mount disk and unpack ssc338q_initramfs.zip and copy both files to the root directory.
- The UBOOT and uImage.ssc338q is used for the temporary sdcard system and to gain access to the nand flash.

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
</details>


<details>
<summary><h3>SSC338Q + IMX415 + NOR flash, board from Anjoy vendor</h3></summary>

#### Information collection continues

Information collection continues

#### Buying a device (Anjoy vendor)

- https://aliexpress.com/item/1005003738087454.html
</details>


### Other notes

For testing please use the [MPV](https://mpv.io/) player, in which the Shift+I key combination can be used to get debugging information.

