# OpenIPC Wiki
[Table of Content](../README.md)

Adding a wifi driver to your firmware
---
Since most cameras have very little flash memory, OpenIPC firmware images don't contain many wifi drivers, as they can easily be 1.5MB+ per driver.
This means that in many cases, you will have to add the appropriate wifi driver to your firmware image.

### Step 1: preparing the build environment
You will need a Linux environment. First download the OpenIPC firmware repository:

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

#### AIC:
```
BR2_PACKAGE_AIC8800_OPENIPC
```

#### Altobeam:
*1. Select general ATBM driver:*
```
BR2_PACKAGE_ATBM60XX
```
*2. Enable the driver for your specific card:*
```
BR2_PACKAGE_ATBM60XX_MODEL_601X
BR2_PACKAGE_ATBM60XX_MODEL_602X
BR2_PACKAGE_ATBM60XX_MODEL_603X
BR2_PACKAGE_ATBM60XX_MODEL_6041
```

*3. Set usb or sdio:*
```
BR2_PACKAGE_ATBM60XX_INTERFACE_USB
BR2_PACKAGE_ATBM60XX_INTERFACE_SDIO
```

*Example: to build atbm603x_wifi_usb:*
```
BR2_PACKAGE_ATBM60XX=y
BR2_PACKAGE_ATBM60XX_MODEL_603X=y
BR2_PACKAGE_ATBM60XX_INTERFACE_USB=y
```

#### iComm:
*SSV615X/SSV625X, USB ID 0x6000:*

```
BR2_PACKAGE_SSV615X_OPENIPC
```

*SSV635X, USB ID 0x6011:*

```
BR2_PACKAGE_SSV635X_OPENIPC
```

#### MediaTek:
```
BR2_PACKAGE_MT7601U_OPENIPC
```

#### SigmaStar:
```
BR2_PACKAGE_SSW101B
```

#### Realtek:
```
BR2_PACKAGE_RTL8188EUS_OPENIPC
BR2_PACKAGE_RTL8188FU_OPENIPC
BR2_PACKAGE_RTL8189ES_OPENIPC
BR2_PACKAGE_RTL8189FS_OPENIPC
BR2_PACKAGE_RTL8192EU_OPENIPC
BR2_PACKAGE_RTL8733BU_OPENIPC
BR2_PACKAGE_RTL8812AU_OPENIPC
```

Take note of the `BR2_PACKAGE` variable for the driver you need. It may
be useful to observe the boot messages from the original firmware to
determine the network device and interface type since it may not be
obvious from looking at the board. Seeing `atbm603x_wifi_usb` in the
boot messages suggests that this camera has an `atbm603x` wifi device
connected internally over USB.

### Step 3: add BR2_PACKAGE variable to your firmware configuration
The firmware configuration files are ordered per chipset in the `br-ext-chip-*`directories. Navigate to the directory for the chipset you are building for, then navigate to the `/configs/` directory.

Example: you have a hisilicon chipset:

`cd br-ext-chip-hisilicon/configs/`

Inside you will see a number of `_defconfig` files. Open the file for your desired chip and firmware flavor in a text editor.
Add the appropriate `BR2_PACKAGE` variable to this file, adding `=y` to the end of the variable. 

Example: you want to add the RTL8188EUS driver:

`BR2_PACKAGE_RTL8188EUS_OPENIPC=y`

### Step 4: Build your firmware
Return to the root directory of the openipc firmware directory `openipc-firmware/`.
Run `make` and select the configuration you have edited in the previous step.

Alternatively, you can run `make BOARD=<your_config>`, where `<your_config>` is the name of the config file you have just edited, minus the `_defconfig`

Example: you want to build `ultimate` for `hi3516ev200`:

`make BOARD=hi3516ev200_ultimate`

When the build is complete, you will find the output in the `output/images/` directory:

```
./rootfs.hi3516ev200.cpio
./openipc.hi3516ev200-nor-ultimate.tgz
./rootfs.squashfs.hi3516ev200
./rootfs.hi3516ev200.tar
./uImage.hi3516ev200
```

You can now use `rootfs.squashfs.*` and `uImage.*` with [sysupgrade](./sysupgrade.md) or your preferred update mechanism.

*For additional wifi configuration, see [wireless settings](./wireless-settings.md).*

*For more information about building OpenIPC from source, see [Source code](./source-code.md).*
