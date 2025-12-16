# OpenIPC Wiki
[Table of Content](../README.md)

Installation: how to make OpenIPC running on certain hardware
-------------------------------------------------------------

Supported hardware and installation procedures are given on [openipc.org](https://openipc.org/firmware/) site.

Please follow on site instructions for your CPU and video chip!

Here are some examples:

[Hi3516cv300 with IMX291](https://openwrt.org/docs/techref/hardware/soc/soc.hisilicon.hi35xx/ivg-hp203y-ay)

[[Hi3516Ev300-IMX335]]

## How to upgrade OpenIPC

Currently, full automatic system upgrade like [sysupgrade][openwrtsysupgrade]
in OpenWRT is not supported. Use partial manual update instead.

### Partial manual update

**NB!** _Partial upgrade of U-boot and kernel are recommended only in special cases and should be done with caution._

The process is described on the main site on [firmware page](https://openipc.org/firmware/#update-parts-of-the-firmware).

## Frequently Asked Questions

* Can OpenIPC be installed on Raspberry Pi or other hardware?

No. Currently,For other hardware, refer to the [Supported Hardware](https://openipc.org/supported-hardware/full-list). But theoretically it is
possible to support other architectures and boards. Though it will require a lot
of efforts, and thus it is not a near time focus of the project.

* Can I flash OpenIPC image without using UART console and TFTP?

No. Currently, it is not possible, though we are working on this.

* What the difference between OpenIPC based on BuildRoot and based on OpenWRT?

Buildroot is faster for initial development for new platforms as it is
minimalistic and has no dependencies. OpenWRT is convenient for users as a final
product, but there are a lot of complexities, dependencies, and there is no
point in developing without a community.

### Other FAQs

* [OpenIPC Wiki (ru)](https://github.com/OpenIPC/camerasrnd/blob/master/docs/FAQ-ru.md)


## Network related stuff

Common network configuration can be done in Luci GUI:

`http://<your camera IP>`

[[3G_modems]] USB modems support in hilink and ppp modes

## Graphical User Interfaces

There are two branches of OpenIPC currently:

### OpenWRT  based

GUI is based on Luci. There are menu sections for camera specific setup.

### Buildroot based

There is a different interface planned... Still under development.

## Hardware related recommendations

### Power Over Internet PoE

It is advised to use 48V power adapters with RJ-45 connectors instead of 12V.
With 12V adapters the current will be 4 times higher. High current can burn
RJ-45 connectors and wires.

## How to stream video to Internet

* __MiniHttp__ ➤ main audio/video streamer of the OpenIPC based system.

* __Мajestic__ ➤ new (in development)  audio/video streamer of the OpenIPC based system.

* __YouTube Streaming__

### MiniHttp is the main streamer of the OpenIPC based system

It is important to tune configuration of MiniHttp by turning off unneeded
protocols and features for better security and performance.

Config file is located in `/etc/minihttp.ini`

### Debug mode:

```killall -sigint minihttp; sleep 1; export SENSOR=`ipctool --sensor_id`; minihttp```

### Production mode:

```killall -sigint minihttp; sleep 1; export SENSOR=`ipctool --sensor_id`; minihttp 2>&1 | logger -p daemon.info -t minihttp &```


## Custom build tools used in OpenIPC OS

[Tools repository](https://github.com/OpenIPC/packages/tree/main/utils)

[ipctool](https://github.com/OpenIPC/ipctool) - gets information about hardware
and outputs it in common format. Can also be used to make backup and restore of
the camera software (still experimental feature).

## Integration examples with Digital Video Recording systems

Recording stream locally with various utilities.

YouTube as DVR hack.

## Tips and tricks on monitoring OpenIPC system

### How to get temperature from chip's internal sensor (where supported):

`ipctool --temp`

other commands to [[monitor temperature]]

[[snmp]]

### Prometheus monitoring

[[prometheus-node]]

### Monitoring templates

* [[Zabbix monitoring templates]]

## Prometheus node configuration

[Prometheus](https://prometheus.io/) is an open-source systems monitoring and
alerting toolkit.

OpenIPC has prometheus node exporter as a package. The result output can be
viewed as plain text on http://192.168.1.10:9100/metrics

Or visualized if you install [proemetheus server and graphana](https://prometheus.io/docs/visualization/grafana/):

[[images/preometheus_node_graphana_example.jpg]]

You can configure the node in `/etc/config/prometheus-node-exporter-lua`.

### Meta package

<https://github.com/ZigFisher/Glutinium/tree/master/prometheus-node-exporter-lua>

## Experiments with I2C on Hi3518EV200

### Setting up i2c-x via device tree

The standard i2c-hisilicon driver does not give an option to set pins to i2c
mode if they were previously set to dts. To automatically set the required pins
to i2c mode you just need to add the following code to the beginning of
hi_i2c_hw_init (linux/drivers/i2c/busses/i2c-hisilicon.c)

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

## R&D related information

### How to [[login inside]] original firmware

### [[Majestic Log]] comments

### [[DevTools]]

### [[Docs on different IP cameras]]

### Groups in Telegram related to development:


## Tools used in Research and Development

[hisi-trace](https://github.com/OpenIPC/hisi-trace) --> tool to run Sofia inside
the OpenIPC. Allows porting stock Sofia functions to the target system without
loading in the original firmware.

[some tools for dissassembling](https://github.com/TekuConcept/ArmElfDisassembler)

## Docs on currently unsupported SoC:

[Novatek NV98515 SoC](https://github.com/hn/reolink-camera)

Different hack & mod related to IP Cameras forums:

<https://www.goprawn.com/>

Below are some examples how to record video streams with various utilities.

### gstreamer

* rtsp h264 stream:

`gst-launch-1.0 rtspsrc location=rtsp://192.168.1.10:554/stream=0 ! rtpjitterbuffer ! rtph264depay ! h264parse ! mp4mux ! filesink location=stream0_h264.mp4 -e`

* rtsp h265 stream:

`gst-launch-1.0 rtspsrc location=rtsp://192.168.1.10:554/stream=0 ! rtpjitterbuffer ! rtph265depay ! h265parse ! mp4mux ! filesink location=stream0_h265.mp4 -e`

### ffmpeg

### vlc

## How to login inside original firmware

Information applicable only for XM-based camera firmware.

### Enable telnet server

In U-Boot console:

```
setenv telnetctrl 1; saveenv
```

### Connect with telnet

```
LocalHost login: root
Password: xmhdipc
Welcome to HiLinux.
```

Also, can try [other pairs](https://gist.github.com/gabonator/74cdd6ab4f733ff047356198c781f27d)

### Optional: enable Linux kernel verbose boot (where armbenv exists)

```
# armbenv -s xmuart 0
# reboot
```

Or in case where XmEnv exists:

```
# XmEnv -s xmuart 0
# reboot
```

### Enable telnet without even open your camera (remotely)

* Find proper zip with recent firmware update using [link](https://translate.google.com/translate?hl=en&sl=ru&tl=en&u=https%3A%2F%2Fwww.cctvsp.ru%2Farticles%2Fobnovlenie-proshivok-dlya-ip-kamer-ot-xiong-mai) and download it.

* Unzip it and choose proper `bin` file from several options.

* It's recommended update your camera using this stock firmware without
    modifying it. It will help understand possible issues. Use `General...` if
    not sure which option you want.

* Unzip `bin` file as it would be ordinary zip archive.

* Copy `add_xmuart.sh` from `utils` directory of the repository inside directory
    with unpacked files.

* Run `./add_xmaurt.sh` and then ensure that `u-boot.env.img` has
    `xmuart=1telnetctrl=1` near the end of file.

* Repack `bin` file adding changed `u-boot.env.img` there like this:
  `zip -u General_IPC_HI3516EV200_85H30AI_S38.Nat.dss.OnvifS.HIK_V5.00.R02.20200507_all.bin u-boot.env.img`

* Upgrade camera using new `bin` file.

Document origin is [here](https://github.com/OpenIPC/camerasrnd/blob/master/get_telnet.md)

## Commands to measure chip temperature on various SoCs

`Hi3516CV200 / Hi3518EV200 / Hi3518EV201`
```sh
devmem 0x20270110 32 0x60FA0000 ; devmem 0x20270114 8  | awk '{print "CPU temperature: " ((($1)*180)/256)-40}'
```

`Hi3516CV300 / Hi3518EV100`
```sh
devmem 0x1203009C 32 0x60FA0000 ; devmem 0x120300A4 16 | awk '{print "CPU temperature: " (((($1)-125.0)/806)*165)-40}'
```

`Hi3516EV200 / Hi3516EV300`
```sh
devmem 0x120280B4 32 0xC3200000 ; devmem 0x120280BC 16 | awk '{print "CPU temperature: " (((($1)-117)/798)*165)-40}'
```

`Hi3536D`
```sh
himm 0x0120E0110 0x60320000 > /dev/null; himm 0x120E0118 | awk '{print $4}' | dd skip=1 bs=7 2>/dev/null | awk '{print "0x"$1}' | awk '{print "CPU temperature: " (($1*180)/256)-40}'
```

`Hi3536C`
```sh
himm 0x0120E0110 0x60320000 > /dev/null; himm 0x120E0118 | awk '{print $4}' | dd skip=1 bs=7 2>/dev/null | awk '{print "0x"$1}' | awk '{print "CPU temperature: " (($1-125)/806)*165-40}'
```

`HI3520DV200`
```sh
devmem 20060020 32
```

`Hi3516AV200`
```sh
#PERI_PMC68 0x120a0110 (disable-->enable)
himm 0x120a0110 0 > /dev/null;
himm 0x120a0110 0x40000000 > /dev/null;

usleep 100000
#PERI_PMC70 0x120a0118 read temperature
DATA0=$(himm 0x120a0118 0 | grep 0x120a0118)
DATA1=$(printf "$DATA0" | sed 's/0x120a0118: //')
DATA2=$(printf "$DATA1" | sed 's/ --> 0x00000000//')

let "var=$DATA2&0x3ff"
if [ $var -ge 125 -a $var -le 931 ];then
    echo `awk -v x="$var" 'BEGIN{printf "chip temperature: %f\n",(x-125)*10000/806*165/10000-40}'`
else
    echo "$var ---> invalid. [125,931]"
fi
```

## Direct streaming to YouTube

YouTube offers not only LiveStreaming but also can record this stream.

Up to 12 hours of LiveStream can be recorded.

Direct streaming to YouTube is possible but not currently supported by OpenIPC.

### Direct streaming can be done with MiniHttp

Direct streaming to YouTube could be done with the help of RTMP but there are
currently no plans add this protocol to the main streamer MiniHttp.

### Direct streaming can be done with FFMPEG

There are two modes available: the old one, supporting H264 over RTMP,
and the new one, with H265 over HLS.

Both methods were not tested in production and still are in development mode.
See following links for details:

### H264 over RTMP

Navigate to the compiled package [H264 over RTMP](https://github.com/ZigFisher/Glutinium/tree/master/hi35xx-ffmpeg/files)

Copy file `silence.aac` to `/usr/lib/` and file `ffmpeg` to `/usr/sbin/`

Also set execution permission:

`chmod +x /usr/sbin/ffmpeg`

Run `ffmpeg` with the following parameters:

`ffmpeg -stream_loop -1 -i /usr/lib/silence.aac -rtsp_transport udp -thread_queue_size 64 -i rtsp://127.0.0.1:554/stream=0 -c:v copy -c:a copy -f flv rtmp://a.rtmp.youtube.com/live2/<your key>`

[H265 over HLS](https://gist.github.com/widgetii/ec275524dd621cd55774c952bee4c622)

Some build instructions:

<https://github.com/ZigFisher/Glutinium/blob/master/hi35xx-ffmpeg/0_Build.sh>

[openwrtsysupgrade]: https://github.com/openwrt/openwrt/blob/master/package/base-files/files/sbin/sysupgrade
