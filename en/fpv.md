# OpenIPC Wiki
[Table of Content](../README.md)

Using OpenIPC as a budget video link for FPV system
---------------------------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

In 2015, German enthusiast Befi [pitched the idea of an OpenSource drone](https://befinitiv.wordpress.com/wifibroadcast-analog-like-transmission-of-live-video-data/), where he proposed to use ordinary WiFi adapters, the number of which has already reached several billion pieces worldwide, and the price has dropped so much that they have become the most affordable types of digital transceivers.

The key idea was not the WiFi adapters themselves, but an unconventional method of using them: refusing to establish a network connection and switching to broadcast mode, when one adapter acts as a transmitter of a digital signal, while the second one is a receiver.

It was suggested to take a budget SBC Raspberry Pi, connect a camera to it via MIPI interface and a USB WiFi dongle from among the recommended ones, and on the other side on the receiver - a similar WiFi module with HDMI monitor. In this case, instead of the traditional UDP protocol for low-latency video transmission, a lower-level protocol was used for flexible data management: bandwidth control, transmitter power, and the ability to recover data if the packet was [partially corrupted](https://en.wikipedia.org/wiki/Error_detection_and_correction) during transmission. One of the technical problems is that not every WiFi adapter is able to work in this low-level mode, moreover: you almost always have to install special drivers that exist only for Linux.

The receiver in this mode operates in the so-called `monitor mode`, where it receives and transmits to the operating system each packet of a given WiFi channel, where it decides whether to decode or discard it. The WiFi transmitter adapter must operate in `injection mode`, where the operating system kernel does not actually participate in the network packet generation prescribed by the ISO network model. Some adapters support both modes, some support only some one, so may only stand on the transmitter or receiver side.

<p align="center">
  <img src="https://befinitiv.files.wordpress.com/2015/04/dscf11161.jpg" alt="The first ever drone controlled by Wifibroadcast" />
</p>

## Revolution from OpenIPC

The classic set-up in the [OpenHD](https://openhdfpv.org/) project (and other similar projects) consists of a MIPI or USB camera connected to a Raspberry Pi and a Jetson Nano, which act as a video encoder and router for the airborne system and in turn are connected to a WiFi adapter via USB and to the flight controller via UART. The ground station usually consists of the same WiFi adapter, router and a high-contrast monitor or goggles.

Sometimes a MIPI or USB camera is swapped for an IP camera, which is both more powerful (has its own hardware encoder) and cheaper with similar characteristics. Most modern video cameras are typical devices with Linux on board (but much more modest in RAM and flash memory size compared to Raspberry and Jetson), which allows you to recompile and run almost any portable software on them.

While working with this technology, the idea of simplifying the flight system and porting all the necessary software directly to the IP camera came up. Technically FPV firmware of OpenIPC project is a special assembly with two types of drivers of popular WiFi adapters, Majestic streamer (which performs the role of GStreamer in the classical scheme on the transmitter system) and [WFB-ng](https://github.com/svpcom/wifibroadcast).

### Benefits

* Reduces system cost (H.265 IP camera vs. analog on Jetson Nano with MIPI camera)
* Reduces overall consumption and increases system reliability by simplifying the circuitry
* Reduces video latency: in our Glass-to-Glass tests, we got about 80ms latency for 1080p@60 (on mid-budget cameras), and about 60 ms for 720p@60 and about 100 ms for 1080p@30 (for the most budget cameras).
* There is a possibility of tuning hardware encoder, for example, more frequent formation of I frame (the specifics depends on the vendor of IP camera)
* The community has accumulated a lot of experience in [repairing IP cameras](https://t.me/ExIPCam), which makes it possible to further reduce the cost of operation of the system.

### Disadvantages

* Due to limited resources (installed RAM and permanent memory), most of the trendy programming languages (such as Java, Python, NodeJS) will not be supported by the camera. If you like to write in these languages (or want to port software written in these languages to the camera), you will have to look for solutions.
Replacing flash memory with a larger one will bring joy to the house of Golang and Rust developers.
* You'll have to do some soldering to get the super-budget boards up to snuff, but I'm sure nobody in the FPV world will be intimidated by this
* In most systems the Linux kernel version is limited by the IP camera vendor due to the fact that some modules are shipped in binary form. Developing kernel drivers for new WiFi adapters or specific peripherals can be time-consuming.
* On budget cameras (for which FPV firmware was primarily developed) very limited resources, so at the time of writing this text there are no possibilities to run neural networks. The situation should change in the near future.

### Ingredients

* IP Camera. Considering the popularity among FPV community of [VEYE 307](http://www.veye.cc/en/product/cs-mipi-imx307/) model, we recommend you to buy the board IVG-G2S IP camera manufactured by XiongMai company with exactly the same sensor IMX307, but [at a more pleasant price](https://aliexpress.com/item/1005003386137528.html) (or even [more pleasant](https://item.taobao.com/item.htm?id=660122799616), if there is a possibility to buy on Taobao, for example, [through an intermediary](https://www.youcanbuy.ru/)). When ordering the board, specify the focal length of the lens that the seller will set for your order (more focal length - more magnification, but less angle of view).
In the future, the lens can be changed to another with the same thread, or immediately buy several models to choose from (the standard in the world of video surveillance is considered 3.6mm).
IP-camera board is powered from 12V (actually 5V is enough, if you do not use it as a video camera with backlight) and for initial tests it is desirable to take a combined power-Ethernet cable, which is of two types: 12V with [power supply via jack](https://aliexpress.com/item/32961238897.html) and active PoE 48V (choose depending on the capabilities of your network switch).

* WiFi adapter. At the moment FPV firmware supports two types of drivers for RT8812au and AR9271 chips (but in principle nobody prevents to add other adapters). It is highly recommended to use the same adapters on both sides of the link (moreover, take them from the same batch in pairs) and use only 5GHz frequencies due to the complete overload of 2.4GHz. The firmware is tested with two adapters on [RT8812au](https://aliexpress.ru/item/32664378094.html) and [AR9271](https://aliexpress.co/item/32884675724.html) (the last mentioned chip works only on 2.4GHz frequency).

* [UART-USB adapter](https://aliexpress.com/item/1005001625391776.html) at 3.3V. Note that using a 5V adapter can burn your camera. Do not buy/use adapters based on [PL2303](https://aliexpress.com/item/704553060.html), although they are cheaper, they will not work with this SoC. The programmer mentioned in the previous paragraph can work with UART adapter, so if you have one, you don't need to buy a separate one.

* [Connectors with JST 1.25 type connectors](https://aliexpress.com/item/32863841787.html) in `3 Pin` and `8 Pin` configuration to connect to the UART port of the camera and replace the standard power-Ethernet cable in the flight version.

Optional:

* SPI NOR flash memory chip of 16 megabytes or more to replace the standard 8 megabyte one. We recommend [W25Q128FVIQ](https://www.aliexpress.com/item/1005003093500630.html) or [any other](https://www.winbond.com/hq/product/code-storage-flash-memory/serial-nor-flash/?__locale=en&selected=128Mb#Density) compatible with the firmware (new modules can also be added to the project by chip ID). Please note that there are a lot of Winbond knockoffs on the market and you should choose your seller carefully.

* [SPI NOR programmer for flash memory](https://aliexpress.com/item/32902635911.html). In principle you can do without it by means of the project [burn](https://github.com/OpenIPC/burn), which allows you to pour the system into an empty/killed flash (see the section [Fill image to empty/killed flash](https://github.com/OpenIPC/burn). section [Pouring image to empty flash with burn](#openipc-wiki <b>// change me</b>)). Note that although many programmers have a "clothespin" in the kit, it is absolutely impossible to dump/program flash memory directly on the board, because of the fact that the programmer besides the chip will also power the rest of the board (there is an option to cut the VCC leg).

* [SoC radiators](https://aliexpress.com/item/32859349038.html) are welcome (as usual not installed by the manufacturer due to cheapening).

* [F0.95 fast lens](https://aliexpress.com/item/32876034491.html) (other options are [one](https://aliexpress.com/item/32957334039.html) and [two](https://aliexpress.com/item/4000142214594.html)) to fully utilize the Sony IMX307 sensor and enjoy flying at night.

* [Zoom Lens 2.8-12mm](https://aliexpress.com/item/32809397197.html). Please note that the kit comes with an outdated HiSilicon 3516EV100 based IP camera board, which can also be reflashed to OpenIPC. Since the board controlling the motors communicates with the main board via UART, you will have to creatively solve the issue with multiplexing the two UART ports or outputting unsoldered pins.

* [16 pin FPC connector](https://aliexpress.com/item/33013766973.html) for better soldering of connection to USB adapter and corresponding [cable](https://aliexpress.com/item/32958943450.html).

There are two variants of using OpenIPC firmware on the board under consideration: with replacement of flash memory with a higher capacity one (for installing your own programs) and without replacement (it is easier, but in this case further expansion possibilities of the new system will be very limited). Both of these options will be discussed step by step below:

### Installation on the camera (common start)

* Connect the cable to the camera and check that it works (default IP address is 192.168.1.10, link for VLC `"rtsp://192.168.1.10/user=admin&password=&channel=0&stream=0"`).
* Solder the three-wire UART connector to the free pads on the camera board

<p align="center">
<img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-imx307-uart.jpg?raw=true" alt="Logo"/>
</p>

* Connect the UART-USB adapter to the computer (port speed 115200N1, flow control disabled, adapter should be set to 3.3V, not 5V) and check that when the camera is turned on, data is being output and you can abort the download via `Ctrl-C` (both RX and TX lines are working).

### Installation on the camera (option without soldering flash)

* Download, unzip the archive and run the [IP Cam DMS](https://team.openipc.org/ipcam_dms/IPCam_DMS_20201121_EN.zip) program, which allows you to control the camera using the camera manufacturer's protocol.
* Download the [special archive](https://github.com/OpenIPC/coupler/releases/download/latest/000659A7_fpv_IPC_GK7205V200_50H20AI_S38.bin) and perform a firmware upgrade, which will effectively make a seamless transition from the original firmware to OpenIPC.

### Installation on camera (flash replacement option)

* Turn off the camera, unsolder the original 8 megabyte SPI NOR flash chip and dump it with a programmer just in case. It is desirable to unsolder the chip with [hair dryer](https://aliexpress.com/item/32980690787.html), but if you really want you can use a regular soldering iron [as Alexey Tolstov suggests](https://www.youtube.com/watch?v=M69JiBtuqq8) or [like this](https://www.youtube.com/watch?v=dspjVDv7hck). After unsoldering of the chip, the pads should be well cleaned from solder residue with a piece of copper cable.
When working with a hair dryer it is desirable to remove the lens and insulate the other components, especially the plastic connectors with [kapton tape](https://aliexpress.com/item/1005003563721341.html) (in extreme case with chocolate bar foil). Never [use Rose alloy](https://habr.com/ru/post/437778/). If you're not very good with a finger, it's easier to go to the nearest cell phone repair service and show the master a part of this manual.

<p align="center">
<img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-imx307-spinor.jpg?raw=true" alt="Logo"/>
</p>

* Fill [U-Boot](https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-gk7205v200-universal.bin) into a new 16 megabyte flash (at the beginning of the memory) and solder it to the board. Verify that U-Boot starts and you get to the prompt.
* On the workstation, install a TFTP server, download and unzip to the [archive](https://github.com/OpenIPC/firmware/releases/download/latest/openipc.gk7205v200-nor-fpv.tgz) directory with the FPV firmware
* Give commands in U-Boot (where `192.168.1.17` is your TFTP server and `192.168.1.33` is the temporarily assigned address to the camera):

```
  setenv ipaddr 192.168.1.33; setenv serverip 192.168.1.17; saveenv
  run setnor16m
  #
  run uknor16m; run urnor16m
```

### Installation on the camera (general termination)

* After booting the system, verify that it has obtained an IP address via Ethernet (it can be accessed via SSH via root@<IP address of the camera> without a password). Using a modern operating system and the name `openipc.local` you can find the camera within the local network without knowing its IP address. 
* Solder GND, DP and DM to the USB pads (USB 5V power supply should not be connected to the board due to the high power consumption of the adapter), and separately 5V and GND to power the WiFi adapter (possibly via an additional DC-DC converter depending on your circuit). The USB wire that comes to the board should be secured with a cable tie to avoid breaking off the pins on the contact pad:

<p align="center">
<img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-pinout.jpg?raw=true" width="50%/">  
<img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-usb-colors.jpg?raw=true" width="50%/">
</p>

* Check that a new device has appeared after booting via `lsusb` command
* Check that the `free -m` command gives __at least__ 34 megabytes of system RAM (the rest is video memory), otherwise you may get an OOM killer on the fly (fixable via `fw_printenv bootargs / fw_setenv` with osmem=40M correction):

```
root@openipc-gk7205v200:~# free -m
              total        used        free      shared  buff/cache   available
Mem:             34          21           2           0           9           9
Swap:             0           0           0
```

### Check the ground station operation (on the desktop)

* Connect the second adapter to the desktop and compile a driver that works in monitoring mode (see the relevant project documentation) and load it via `insmod` if necessary.
* Activate the interface (in this example `wlan0` and specify [channel](https://en.wikipedia.org/wiki/List_of_WLAN_channels)) (in this example `14`):
```
sudo ip link set wlan0 down
sudo iw wlan0 set monitor control
sudo iwconfig wlan0 channel 14
sudo ip link set wlan0 up
```
* Make sure that the same frequency is set on the camera and desktop WiFi adapters via `iwconfig` command, if necessary change the frequency by editing `/etc/wfb.conf` on the camera (`channel` parameter) or `sudo iwconfig <adapter name> channel <number>` on the desktop.
* Compile from source [WFB-ng](https://github.com/svpcom/wifibroadcast), __must use brunch stable__, copy the `./etc/gs.key` from the IP camera to the desktop and run receive `sudo ./wfb_rx -p 0 -u 5600 -K gs.key -i 7669206 wlan0`.
* Check that the console output
```
32168228	PKT	0:0:0:0:0:0
32169229	PKT	0:0:0:0:0:0
32170230	PKT	0:0:0:0:0:0
32171231	PKT	0:0:0:0:0:0
32172232	PKT	0:0:0:0:0:0
32173233	PKT	0:0:0:0:0:0
```
change to
```
32178236	ANT	1	282:-54:-52:-50
32178236	ANT	0	282:-48:-46:-44
32178236	PKT	283:0:283:2:0:0
32179236	ANT	1	244:-54:-52:-50
32179236	ANT	0	244:-48:-45:-44
32179236	PKT	245:0:245:0:0:0
32180236	ANT	1	250:-54:-52:-50
32180236	ANT	0	250:-48:-45:-44
```
* Run Gstreamer `gst-launch-1.0 -vvvv udpsrc port=5600 ! application/x-rtp,encoding-name=H264,payload=96 ! rtph264depay ! h264parse ! queue ! avdec_h264 ! autovideosink sync=false -e` and check the image quality


### Quick insertion of some links

**Please use the translator, there is a lot of interesting stuff on FPV here:**

- https://github.com/OpenIPC/wiki/blob/master/ru/fpv.md
- https://github.com/openipc/sandbox-fpv
- https://github.com/OpenIPC/silicon_research
- [OpenIPC for building FPV systems, chat in telegram messenger](https://t.me/+BMyMoolVOpkzNWUy)

**And our general resources:**

- https://OpenIPC.org
- https://github.com/OpenIPC


### YouTube videos from friends

- [Introducing OpenIPC, the cheapest digital long range FPV system in the world](https://youtu.be/Z_41Dko-Iok?si=cdGWDcFss9WrvPPN)
- [OpenIPC Latency and Range Test with ExpressLRS and INAV 6.1](https://www.youtube.com/watch?v=4tlPJSQA6HA)
- [DIY FPV FullHD with OpenIPC, wfb-ng, qOpenHD](https://www.youtube.com/watch?v=MwcEvywzslA)
- [25km with OpenIPC+wfb-ng, qOpenHD. goke7205v200+imx307,3.6mm. H265 7Mbit/s. ARWing900](https://www.youtube.com/watch?v=c7XtKujrzSg)
