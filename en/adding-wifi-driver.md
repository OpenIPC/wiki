# OpenIPC Wiki
[Table of Content](../README.md)

Adding a wifi driver to your firmware
---
Since most cameras have very little flash memory, openipc images don't contain many wifi drivers, as they can easily be 1.5MB+ per driver.
This means that in many cases, you will have to add the appropriate wifi driver to your firmware image.

### Step 1: preparing the build environment
You will need a Linux environment. First download the openipc firmware repository:

```
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
```

Install packages required for building:

```
sudo make deps
```

### Step 2: determine the driver package
Here are some of the most common wifi driver packages:
```
# AIC:
BR2_PACKAGE_AIC8800_OPENIPC

# Altobeam:
BR2_PACKAGE_ATBM60XX
BR2_PACKAGE_ATBM6441

# iComm:
BR2_PACKAGE_SSV6X5X_OPENIPC

# MediaTek:
BR2_PACKAGE_MT7601U_OPENIPC

# SigmaStar:
BR2_PACKAGE_SSW101B

# Realtek:
BR2_PACKAGE_RTL8188EUS_OPENIPC
BR2_PACKAGE_RTL8188FU_OPENIPC
BR2_PACKAGE_RTL8189ES_OPENIPC
BR2_PACKAGE_RTL8189FS_OPENIPC
BR2_PACKAGE_RTL8192EU_OPENIPC
BR2_PACKAGE_RTL8733BU_OPENIPC
BR2_PACKAGE_RTL8812AU_OPENIPC
```

Take note of the `BR2_PACKAGE` variable for the driver you need.

### Step 3: add BR2_PACKAGE variable to your firmware configuration
The firmware configuration files are ordered per chipset in the `br-ext-chip-*`directories. Move into the directory for the chipset you are building for, then move into the `/configs/` directory.

Example: you have a hisilicon chipset:

`cd br-ext-chip-hisilicon/configs/`

Inside you will see a number of `_defconfig` files. Open the file for your desired chip and firmware flavor in a text editor.
Add the appropriate `BR2_PACKAGE` variable to this file, adding `=y` to the end of the variable. 

Example: you want to add the RTL8188EUS driver:

`BR2_PACKAGE_RTL8188EUS_OPENIPC=y`

### Step 4: Build your firmware
Return to the root directory of the openipc firmware directory `openipc-firmware/`.
Run `./building.sh` and select the configuration you have edited in the previous step.

Alternatively, you can run `./building.sh <your_config>`, where `<your_config>` is the name of the config file you have just edited, minus the `_defconfig`

Example: you want to build `ultimate` for `hi3516ev200`:

`./building.sh hi3516ev200_ultimate`

When the build is complete, you will find the output in the `output/images/` directory:

```
./rootfs.hi3516ev200.cpio
./openipc.hi3516ev200-nor-ultimate.tgz
./rootfs.squashfs.hi3516ev200
./rootfs.hi3516ev200.tar
./uImage.hi3516ev200
```

You can then use `rootfs.squashfs.* and uImage.*` with [sysupgrade](./sysupgrade.md).
