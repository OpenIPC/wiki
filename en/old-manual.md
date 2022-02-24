# OpenIPC Wiki
[Table of Content](index.md)

Introduction
------------

This page describes OpenWRT-based firmware variant.


### Firmware features

* RTSP, ONVIF, NETIP
* Native ipeye service support
* Support squashfs, jffs2, overlayfs, vfat
* Vlan and bridges support
* Standard OPKG package system
* Tiny SNMP daemon
* Curl with SSL for upload/download files
* Run arbitrary command from u-boot ENV (linux_cmd=)
* Simple L2/L3 VPN with traffic shaping and compression (vtun)
* Simply sender Telegram bot (estgb)
* Low cost  3G USB modems support in hilink and ppp modes
* µVPN tunnel service
* and more ...


### Supported devices

We aim to develop **universal**, portable firmware supporting wide range of
manufacturers and delivering updates and fixes which vendors oftentimes
unable to deliver.

The list is constantly updated, please visit often and/or follow our Telegram
groups for new release notifications.


#### OpenIPC 1.0 (OpenWRT based)

| Processor   | Sensor          | Vendor     | SKU          | Board                           | Status |
|-------------|-----------------|------------|--------------|---------------------------------|--------|
| Hi3516Cv100 | IMX222_spi_dc   | XM         |              | [BLK18C-0222-38X38_S-V1.03][1]  | test   |
| Hi3518Ev100 | OV9712_i2c_dc   | CamHi/Xin  |              | IPC18E_9712_V2.0/V3.1           | test   |
|             |                 |            |              |                                 |        |
| Hi3516Cv200 | IMX323_i2c_dc   | XM         |              | BLK16CV-0323-38X38-V1.01        | yes    |
| Hi3516Cv200 | IMX323_i2c_dc   | JVT        | S323H16VF    | IPS323-H16V-38X38-V2            | yes    |
| Hi3516Cv200 | IMX323_i2c_mipi | XM         |              |                                 | ?      |
| Hi3518Ev200 | AR0130_i2c_dc   | XM         |              | BLK18EV-0732-0035-38X38-V1.01   | yes    |
| Hi3518Ev200 | JXF22_i2c_dc    | XM         |              | BLK18EV-0002-2035-38X38-V1.01   | yes    |
| Hi3518Ev200 | JXF22_i2c_dc    | XM         |              | BLK18EV-0022-0130-38X38-V1.01   | yes    |
| Hi3518Ev200 | OV2735_i2c_dc   | Dahua      | DH-IPC-C22P  | E305654 JX02 94V-0              | wip    |
| Hi3518Ev200 | OV9732_         | XM         |              | BLK18EV-0732-0035-38X38-V1.01   | yes    |
| Hi3518Ev200 | OV9732_i2c_dc   | Longse/HS  | LS-IP100/40  | 3518EV200-OV9732-V1.0           | yes    |
| Hi3518Ev200 | OV9732_i2c_dc   | Rostelecom | QVC-IPC-136W | E305654 JX02 94V-0              | wip    |
| Hi3518Ev200 | SC2135_i2c_dc   | XM         |              | BLK18EV-0035-0042-38X38_S-V1.01 | yes    |
| Hi3518Ev200 | SC2235_i2c_dc   | XM         |              | BLK18EV-0235-38X38-B-V1.01      | yes    |
|             |                 |            |              |                                 |        |
| Hi3516Cv300 | AR0237_i2c_dc   | XM         |              | BLK16CV3-0237P-38X38-S-V1.01    | yes    |
| Hi3516Cv300 | IMX307_i2c_lvds | Raysharp   |              | RS-CM-188D 2018-03-16 E150111   | yes    |
| Hi3516Cv300 | IMX323_i2c_dc   | Longse/HS  |              | HI3516CV300-IMX323-POE-TF V1.1  | yes    |
| Hi3516Cv300 | IMX323_i2c_dc   | Sunywo     | ZB6323       | IPG5020A-T-N6-V0.1              | yes    |
| Hi3516Cv300 | IMX323_i2c_dc   | XM         |              | [IVG-HP201Y-AE][2]              | yes    |
| Hi3516Cv300 | IMX291_i2c_lvds | XM         |              | [IVG-HP203Y-AE][3]              | yes    |
| Hi3516Cv300 | IMX323_spi_dc   | JVT        | S323H16XF    | IPS323-H16X-38X38-V2/V3         | yes    |
| Hi3516Cv300 | JXF22_i2c_dc    | XM         |              | BLK16CV3-0022-38X38-S-V1.01     | yes    |
| Hi3516Ev100 | IMX323_i2c_dc   | XM         |              | BLK16E-0323-38X38-B-V1.01       | yes    |
| Hi3516Ev100 | SC2235P_i2c_dc  | XM         | 80HE20PS-S   | BLK16E-0235-38X38-S-V2.03       | yes    |


#### OpenIPC 2.1 (Buildroot based)

| Processor   | Sensor           | Vendor | SKU | Board                | Status |
|-------------|------------------|--------|-----|----------------------|--------|
| Hi3516Ev200 | IMX307_i2c_mipi  | XM     |     | [IVG-85HF20PY-S][4]  | yes    |
| Hi3516Ev200 | SC4239P_i2c_mipi | XM     |     | [IVG-85HF30PS-S][5]  | yes    |
| Hi3516Ev300 | IMX335_i2c_mipi  | XM     |     | [IVG-85HG50PYA-S][6] | yes    |
| SSC335      | SC3335           |        |     | [Uniview][7]         | yes    |

More information about sensors: [https://cctvsp.ru][8] (translated from Russian
with Google Translate).


### Web interface

* <http://192.168.1.10/> - Standard system interface based on OpenWrt Luci


### Majestic streamer

Majestic is a video streaming application, the heart of our firmware (in
relation to camera/video surveillance functionality). It's configurable via
file `/etc/majestic.yaml` and by default has many features/services enabled.
Unneeded options can be turned off for better security and performance.

To run `majestic` in debug mode:

```
killall -sigint majestic; export SENSOR=$(ipctool --sensor_id); majestic
```

To run `majestic` in production mode restart the camera or run command:

```
killall -sigint majestic; export SENSOR=$(ipctool --sensor_id); majestic 2>&1 | logger -p daemon.info -t majestic &
```


### Camera related URLs in firmware

Information on streamer URLs and their description can be found in the [Wiki][9].


### Statistical data

Software might do product usage data collection including SoC and sensor model
name to gather statistics used in QA process.

We guaranty that the data is fully anonymized, and does not contain anything
that can arguably be considered data about an individual, that could be
considered end-user data; or that could be sensitive or confidential to users.


Getting firmware
----------------

### Downloads (latest dev)

| Building status            | SoC         | U-Boot      | Kernel        | Rootfs        |
|----------------------------|-------------|-------------|---------------|---------------|
| ![Hi3516Cv100 images][b1]  | Hi3516CV100 | [uboot][u1] | [kernel][k1]  | [rootfs][r1]  |
| ![Hi3516Cv200 images][b2]  | Hi3516CV200 | [uboot][u2] | [kernel][k2]  | [rootfs][r2]  |
| ![Hi3516Cv300 images][b3]  | Hi3516CV300 | [uboot][u3] | [kernel][k3]  | [rootfs][r3]  |
| ![Hi3516Ev100 images][b4]  | Hi3516EV100 | [uboot][u4] | [kernel][k4]  | [rootfs][r4]  |
| ![Hi3518Av100 images][b5]  | Hi3518AV100 | [uboot][u5] | [kernel][k5]  | [rootfs][r5]  |
| ![Hi3518Cv100 images][b6]  | Hi3518CV100 | [uboot][u6] | [kernel][k6]  | [rootfs][r6]  |
| ![Hi3518Ev100 images][b7]  | Hi3518EV100 | [uboot][u7] | [kernel][k7]  | [rootfs][r7]  |
| ![Hi3518Ev200 images][b8]  | Hi3518EV200 | [uboot][u8] | [kernel][k8]  | [rootfs][r8]  |
| ![Hi3518Ev201 images][b9]  | Hi3518EV201 | [uboot][u9] | [kernel][k9]  | [rootfs][r9]  |
| ![Hi3520Dv100 images][b10] | Hi3520DV100 | !           | [kernel][k10] | [rootfs][r10] |
| ![Hi3520Dv200 images][b11] | Hi3520DV200 | !           | [kernel][k11] | [rootfs][r11] |


### Releases

The **releases** of the OpenIPC firmware are hosted at <https://github.com/OpenIPC/chaos_calmer/releases>.


### Source code

The **source code** of the OpenIPC firmware is hosted at <https://github.com/openipc/chaos_calmer>.


Building from source
--------------------

### Build on Linux machine

Usage example for Debian 8/9

```bash
git clone --depth=1 https://github.com/OpenIPC/chaos_calmer.git OpenIPC
cd OpenIPC
./Project_OpenIPC.sh update
./Project_OpenIPC.sh 16cv300_DEFAULT
```


### Use Docker for building

**Default Dockerfile.openipc**

```docker
FROM debian:stretch

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get --no-install-recommends -y install bc bison build-essential \
    ca-certificates cmake cpio curl dos2unix file flex gawk gcc-multilib \
    gettext gettext-base git intltool libc6-dev liblocale-gettext-perl \
    libncurses-dev libssl-dev locales mc openssl python rsync subversion \
    time tofrodos unzip upx wget zlib1g-dev \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias \
    en_US.UTF-8 && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.utf8

WORKDIR /src/openipc

RUN git clone --depth=1 https://github.com/OpenIPC/chaos_calmer.git /src/openipc
RUN ./Project_OpenIPC.sh update
RUN ./Project_OpenIPC.sh 18ev200_DEFAULT  # <= Change this ID to you profile
```

**Start building**

```bash
#!/bin/bash

docker build -t openipc -f Dockerfile.openipc .
```


Preparing to install
--------------------

### Get access to U-boot

Serial (UART) connection to your camera device is required.

* CamHi | Press **Ctrl+C** in U-boot start and access password - HI2105CHIP
* Dahua | Press **Shift 8** in U-boot start
* JVT | Press **Ctrl+Q** in U-boot start
* XM | Press **Ctrl+C** in U-boot start
* SigmaStar | Press **Ctrl+B** (UNIV) or **Enter** (Anjvision) in U-boot start


### Backup original MAC

You should definitely write the original MAC of your device on the eth0 port.

This is **important** and will be necessary at the final stage of device configuration.


### Backup original firmware

#### 8M Flash

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 1000000
sf read 0x82000000 0x0 0x800000
tftp 0x82000000 fullflash.img 0x800000
```

#### 16M Flash

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 1000000
sf read 0x82000000 0x0 0x1000000
tftp 0x82000000 fullflash.img 0x1000000
```

#### 32M Flash

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b 0x82000000 ff 2000000
sf read 0x82000000 0x0 0x2000000
tftp 0x82000000 fullflash.img 0x2000000
```


### Flash and memory layout

We have developed a universal partition system for camera flash chips,
and it is now available as standard for all types of devices. (Note
that it means it likely doesn't match vendor flash layout.)

#### OpenIPC flash layout

```txt
0x000000000000-0x000000040000 : "boot"
0x000000040000-0x000000050000 : "env"
0x000000050000-0x000000250000 : "kernel"
0x000000250000-0x000000750000 : "rootfs"
0x000000750000-0x000001000000 : "rootfs_data"
```

#### Kernel Memory Load Addresses

```txt
loadaddr-$(CONFIG_TARGET_hi35xx_16cv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16cv200) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16cv300) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16dv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16ev100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_16ev200) := 0x40008000
loadaddr-$(CONFIG_TARGET_hi35xx_16ev300) := 0x40008000
loadaddr-$(CONFIG_TARGET_hi35xx_18cv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev200) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev201) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_18ev300) := 0x40008000
loadaddr-$(CONFIG_TARGET_hi35xx_20dv100) := 0x80008000
loadaddr-$(CONFIG_TARGET_hi35xx_20dv200) := 0x80008000
```


Flashing new firmware
---------------------

**Attention!**

All examples indicate the download of firmware components via the TFTP server. 
If your device does not have an Ethernet port, replace all `tftp` commands with
`fatload mmc 0:1`. For example:

```txt
tftp 0x82000000 openwrt-hi35xx-XXXXX-u-boot.bin
#
fatload mmc 0:1 0x82000000 openwrt-hi35xx-XXXXX-u-boot.bin
```

### Hi3516Cv100

**This type of board has additional Ethernet control systems via GPIO and
registers. Consult with experts!**

**Experimental devices:**

* 00:12:16:FA:F3:52
* 00:12:12:10:31:54 - BLK18C_0222_38x38_S_v1.03

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3516Cv200

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv200-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv200-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv200-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3516Cv300

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3516Ev100

**Experimental devices:**

* 00:12:13:02:d7:2c

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16ev100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv300-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3518Cv100

**This type of board has additional Ethernet control systems via GPIO and
registers. Consult with experts!**

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18cv100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-16cv100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3518Ev100

**This type of board has additional Ethernet control systems via GPIO and
registers. Consult with experts!**

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev100-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3518Ev200

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev200-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev200-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-18ev200-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3520Dv100

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv100-experimental-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv100-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv100-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```

### Hi3520Dv200

```txt
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv200-experimental-u-boot.bin
sf erase 0x0 0x50000
sf write 0x82000000 0x0 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv200-default-uImage
sf erase 0x50000 0x200000
sf write 0x82000000 0x50000 ${filesize}

mw.b 0x82000000 ff 1000000
tftp 0x82000000 openwrt-hi35xx-20dv200-default-root.squashfs
sf erase 0x250000 0x500000
sf write 0x82000000 0x250000 ${filesize}
```


Updating parts of the firmware
------------------------------

If you already have OpenIPC firmware installed, you can update individual
flash partitions from shell command line:


### Update u-boot

```bash
flashcp -v openwrt-hi35xx-XXXXX-u-boot.bin boot
```

**or**

```bash
flashcp -v openwrt-hi35xx-XXXXX-u-boot.bin /dev/mtd0
```


### Update kernel

```bash
flashcp -v openwrt-hi35xx-XXXXX-default-uImage kernel
```


### Update rootfs

```bash
flashcp -v openwrt-hi35xx-XXXXX-default-root.squashfs rootfs
```


Configuring system after installation
--------------------------------------

### Format overlayfs partition

**Must be executed on the first run!**

```txt
flash_eraseall -j /dev/$(awk -F ':' '/rootfs_data/ {print $1}' /proc/mtd)
reboot
```


### Installing the original MAC

**U-boot ENV and Linux UCI**

```txt
fw_setenv ethaddr 00:01:02:03:04:05
uci set network.lan.macaddr=00:01:02:03:04:05
uci commit
```


### Installing the correct sensor

**Specify your correct sensor, control type, and data bus**

```txt
fw_setenv sensor imx291_i2c_lvds
```


Resetting configuration
-----------------------

If something went wrong, you can reset configuration to defaults.


### Clean overlayfs (reset)

**Restore to default Linux settings**

```txt
firstboot
reboot
```


### Clean u-boot env

**Restore to default u-boot env**

```txt
flash_eraseall -j /dev/$(awk -F ':' '/env/ {print $1}' /proc/mtd)
reboot
```


### Recover backup firmware

If something goes horribly wrong and you want back your backed up firmware

**Restore backup up firmware via serial**

Install kermit using [this instruction](https://glasstty.com/?p=662) or similar.
Here are the sample commands for 8MB Flash.

```
kermit
Linux Kermit> CONNECT
Connecting to /dev/ttyUSB0, speed 115200
 Escape character: Ctrl-\ (ASCII 28, FS): enabled
Type the escape character followed by C to get back, 
or followed by ? to see other options.
----------------------------------------------------
## Total Size      = 0x002fb3f1 = 3126257 Bytes
## Start Addr      = 0x82000000
OpenIPC # sf probe 0
8192 KiB hi_sfc at 0:0 is now current device
OpenIPC # mw.b 0x82000000 ff 1000000
OpenIPC # loadb 0x82000000
## Ready for binary (kermit) download to 0x82000000 at 115200 bps...

(Back at alex-B85M-D3H)
----------------------------------------------------
Linux Kermit> SEND /srv/tftp/fullflash.img
Linux Kermit> CONNECT
Connecting to /dev/ttyUSB0, speed 115200
 Escape character: Ctrl-\ (ASCII 28, FS): enabled
Type the escape character followed by C to get back,
or followed by ? to see other options.
----------------------------------------------------
## Total Size      = 0x00800000 = 8388608 Bytes
## Start Addr      = 0x82000000
OpenIPC # sf erase 0x0 0x00800000
Erasing at 0x800000 -- 100% complete.
OpenIPC # sf write 0x82000000 0x0 ${filesize}
Writing at 0x800000 -- 100% complete.
OpenIPC # 
```
**Restore backup up firmware via TFTP**

Here are the commands for 8MB Flash.

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0; sf lock 0

mw.b 0x82000000 ff 1000000
tftp 0x82000000 fullflash.img
sf erase 0x0 0x00800000
sf write 0x82000000 0x0 ${filesize}
```


## Reference Book

To be written...

### Vendors

* [ACTi](https://www.acti.com/)
* [Anjvision](http://www.anjvision.com/), <http://icamra.cn/>
* [Ansjer](https://www.ansjer.com/)
* [Anviz](http://www.anviz.com/)
* [Brovotech](https://brovotech.com/)
* [Cantonk](http://cantonk.com/)
* [CCDCAM](http://www.ccdcam.com/) th?
* [Filsion/Camasmart](http://www.camasmart.com/)
* [FSAN](http://www.fsan.cn/)
* [GeoVision](https://www.geovision.com.tw/)
* [Herospeed](http://www.herospeed.net/en/)
* [Huatu](http://huatudigital.com/)
* [IPCAM](http://www.ipcam.xin/)
* [Jovision](http://www.jovision.com/)
* [JVT](http://www.jvt.cc/)
* [LENOTEL](http://www.lenoteltechnology.com/) th?
* [Longse](http://www.longse.com/)
* [Milesight](http://www.milesight.com/)
* [Raysharp](http://raysharp.cn/en/)
* [Ruision](http://www.ruision.com/?lang=en)
* [Safer](http://www.safer.net.cn/) th?
* [Synuwo](http://www.sunywo.com/)
* [Tiandy](http://en.tiandy.com/)
* [Topsee](http://www.en.tpsee.com/)
* [TVT](http://www.tvt.net.cn/)
* [UNIVIEW](http://uniview.com/)
* [VandSec/Yoosee](http://vandsec.com/) th?
* [VStarcam](http://www.vstarcam.com/) th?
* [Wansview](http://wansview.com/)
* [XM](http://www.xiongmaitech.com/en/)
* [Z-BEN](http://www.z-ben.cn/) th?
* [ZOSI](https://www.zositech.com/)

_th? -- possibly a trading house_

[1]: https://aliexpress.com/item/32493067946.html
[2]: https://aliexpress.com/item/32851596596.html
[3]: https://aliexpress.com/item/1005002315913099.html
[4]: https://aliexpress.com/item/1005002298832047.html
[5]: https://aliexpress.com/item/4000119561119.html
[6]: https://aliexpress.com/item/4000054902736.html
[7]: https://aliexpress.com/item/1005001933429701.html
[8]: https://translate.google.com/translate?sl=ru&tl=en&u=https://www.cctvsp.ru/articles/obzor-i-sravnenie-matrits-dlya-kamer-videonablyudeniya
[9]: majestic-streamer.md

[b1]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv100_images.yml/badge.svg?branch=master
[b2]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv200_images.yml/badge.svg?branch=master
[b3]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv300_images.yml/badge.svg?branch=master
[b4]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv300_images.yml/badge.svg?branch=master
[b5]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv100_images.yml/badge.svg?branch=master
[b6]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv100_images.yml/badge.svg?branch=master
[b7]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv100_images.yml/badge.svg?branch=master
[b8]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv200_images.yml/badge.svg?branch=master
[b9]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3516cv200_images.yml/badge.svg?branch=master
[b10]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3520dv200_images.yml/badge.svg?branch=master
[b11]: https://github.com/openipc/chaos_calmer/actions/workflows/hi3520dv200_images.yml/badge.svg?branch=master

[u1]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv100-u-boot.bin
[u2]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv200-u-boot.bin
[u3]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-u-boot.bin
[u4]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16ev100-u-boot.bin
[u5]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18av100-u-boot.bin
[u6]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18cv100-u-boot.bin
[u7]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev100-u-boot.bin
[u8]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev200-u-boot.bin
[u9]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev201-u-boot.bin

[k1]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv100-default-uImage
[k2]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv200-default-uImage
[k3]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-default-uImage
[k4]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16ev100-default-uImage
[k5]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18av100-default-uImage
[k6]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18cv100-default-uImage
[k7]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev100-default-uImage
[k8]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev200-default-uImage
[k9]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev201-default-uImage
[k10]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-20dv100-default-uImage
[k11]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-20dv200-default-uImage

[r1]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv100-default-root.squashfs
[r2]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv200-default-root.squashfs
[r3]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16cv300-default-root.squashfs
[r4]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-16ev100-default-root.squashfs
[r5]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18av100-default-root.squashfs
[r6]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18cv100-default-root.squashfs
[r7]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev100-default-root.squashfs
[r8]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev200-default-root.squashfs
[r9]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-18ev201-default-root.squashfs
[r10]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-20dv100-default-root.squashfs
[r11]: https://github.com/OpenIPC/chaos_calmer/releases/download/latest/openwrt-hi35xx-20dv200-default-root.squashfs
