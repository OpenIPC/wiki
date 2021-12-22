## Installation: how to make OpenIPC running on certain HW

Supported HW and installation procedures are given on [openipc.org](https://openipc.org/firmware/) site.

Please follow on site instructions for your CPU and video chip!

Here are some examples:

[Hi3516cv300 with IMX291](https://openwrt.org/docs/techref/hardware/soc/soc.hisilicon.hi35xx/ivg-hp203y-ay)

[[Hi3516Ev300-IMX335]]

## How to upgrade OpenIPC

Currently full automatic system upgrade like [sysupgrade](https://github.com/openwrt/openwrt/blob/master/package/base-files/files/sbin/sysupgrade) in OpenWRT is not supported. Use partial manual update instead.

### Partial manual update

**NB!** _Partial upgrade of U-boot and kernel are recommended only in special cases and should be done with caution._

The process is described on the main site on [firmware page](https://openipc.org/firmware/#update-parts-of-the-firmware).

## Frequently Asked Questions

* Can OpenIPC be installed on Raspberry Pi or other hardware?

No. Currently only HiSilicon HI35xx SoC are supported. But theoretically it is possible to support other architectures and boards. Though it will require a lot of efforts and thus it is not a near time focus of the project.

* Can I flash OpenIPC image without using UART console and TFTP?

No. Currently it is not possible, though we are working on this.

* What the difference between OpenIPC based on BuildRoot and based on OpenWRT?

Buildroot is faster for initial development for new platforms as it is minimalistic and has no dependencies. OpenWRT is convenient for users as a final product, but there are a lot of complexities, dependencies, and there is no point in developing without a community.

### Other FAQs

* https://github.com/OpenIPC/camerasrnd/blob/master/doc/FAQ-ru.md


## Network related stuff

Common network configuration can be done in Luci GUI: 

`http://<your camera IP>`

[[3G_modems]] USB modems support in hilink and ppp modes

## Graphical User Interfaces

There are two branches of OpenIPC currently:

### OpenWRT  based

GUI is based on Luci. There are menu sections for camera specific setup. 

### Buildroot based

Tere is a different interface planned... Still under development.

## Hardware related recommendations

### Power Over Internet PoE

It is advised to use 48V power adapters with RJ-45 connectors instead of 12V. With 12V adapters the current will be 4 times higher. High current can burn RJ-45 connectors and wires.

## How to stream video to Internet

* [[MiniHttp]] ➤ main audio/video streamer of the OpenIPC based system

* [[Мajestic]] ➤ new (in development)  audio/video streamer of the OpenIPC based system

* [[YouTube Sreaming]]
