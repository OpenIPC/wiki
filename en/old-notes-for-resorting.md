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

#### MiniHttp is the main streamer of the OpenIPC based system

It is important to tune configuration of MiniHttp by turning off unneeded protocols and features for better security and performance.

Config file is located in
`/etc/minihttp.ini`

#### Debug mode:

```killall -sigint minihttp; sleep 1; export SENSOR=`ipctool --sensor_id`; minihttp```

#### Production mode:

```killall -sigint minihttp; sleep 1; export SENSOR=`ipctool --sensor_id`; minihttp 2>&1 | logger -p daemon.info -t minihttp &```


## Custom build tools used in OpenIPC OS

[Tools repository](https://github.com/OpenIPC/packages/tree/main/utils)

[ipctool](https://github.com/OpenIPC/ipctool) - gets information about hardware and outputs it in common format. Can also be used to make backup and restore of the camera software (still experimental feature).

## Integration examples with Digital Video Recording systems

[[Recording stream locally]] with various utilities.

[[YouTube as DVR]] hack

## Tips and trick on monitoring OpenIPC system

### How to get temperature from chip's internal sensor (not all devices supported):

`ipctool --temp`

other commands to [[monitor temperature]]

[[snmp]]

### Prometheus monitoring

[[prometheus-node]]

### Monitoring templates
* [[Zabbix monitoring templates]]

## Prometheus node configuration

[Prometheus](https://prometheus.io/) is an open-source systems monitoring and alerting toolkit.

OpenIPC has prometheus node exporter as a package. The result output can be viewed as a plaintext:

http://192.168.1.10:9100/metrics

Or visualized if you install [proemetheus server and graphana](https://prometheus.io/docs/visualization/grafana/):

[[images/preometheus_node_graphana_example.jpg]]

You can configure the node here

`/etc/config/prometheus-node-exporter-lua`

### Meta package

https://github.com/ZigFisher/Glutinium/tree/master/prometheus-node-exporter-lua

## Experiments with I2C on Hi3518EV200

### Setting up i2c-x via device tree

The standard i2c-hisilicon driver does not give an option to set pins to i2c mode if they were previously set to dts. To automatically set the required pins to i2c mode you just need to add the following code to the beginning of hi_i2c_hw_init (linux/drivers/i2c/busses/i2c-hisilicon.c)

```
#ifdef CONFIG_ARCH_HI3518EV200 // Might be the same for other hardware devices
if(pinfo->mem->start = 0x200d0000 /* address i2c-0 */) {
    writel(0x2, 0x200f0040);
    writel(0x2, 0x200f0044);
}
if(pinfo->mem->start = 0x20240000 /* address i2c-1 */) {
    writel(0x1, 0x200f0050);
    writel(0x1, 0x200f0054);
}
if(pinfo->mem->start = 0x20250000 /* address i2c-2 */) {
    writel(0x1, 0x200f0060);
    writel(0x1, 0x200f0064);
}
#endif
```

# R&D related information

##### How to [[login inside]] original firmware

##### [[Majestic Log]] comments

##### [[DevTools]]

##### [[Docs on different IP cameras]] 

#### Groups in Telegram related to development:

[Majestic Test Group](https://t.me/joinchat/YgHc5Bg4NOoxOTdi)
