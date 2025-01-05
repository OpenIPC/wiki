
### Notes on building a video link with two-way telemetry mavlink

The air part of the link is a [gk7205v200](https://sl.aliexpress.ru/p?key=e1sTwWg) camera with a connected USB wifi adapter on the rtl8812au chip, for example ASUS USB AC-56 or an [inexpensive weaker adapter from ali](https://sl.aliexpress.ru/p?key=8CsTwDB).
The ground part is a [video recorder](https://sl.aliexpress.ru/p?key=L1sTwWG) based on the hisilicon hi3536dv100 or ev100 chip, to which the rtl8812au or rtl8814au adapter is connected via USB in the same way. For the Russian Federation, it is cheaper and faster to order a camera and recorder from [@ser177](https://t.me/ser177).
This article describes the nuances of creating such a link, and is an addition to [this article](https://github.com/OpenIPC/wiki/blob/master/ru/fpv.md).

![link_hw](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/link_hw.png)

### Possibilities

This link is capable of transmitting video
[(youtube)](https://youtu.be/ldfQ9CLE86I) with the aerial part format (resolution@frame rate) 1920x1080@30 or 1280x720@50 codecs h264 or h265 and mavlink telemetry in both directions. The general scheme of processes for video transmission looks like this:

![video](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/video.png)

Video transmission is currently possible in two ways. The classic one is the `majestic` streamer via udp port 5600 sending an RTP/h264 or RTP/h265 stream to [wfb-ng](https://github.com/svpcom/wfb-ng) or [OpenHD-wfb](https://github.com/OpenHD/wifibroadcast) for transmission to the ground, where it is received by the wfb response part and sent for playback on a PC or tablet / smartphone via LAN or USB ethernet (tethering). The RTP format is freely played by programs for GS, such as [QGroundControl](https://github.com/mavlink/qgroundcontrol), [Mission Planner](https://ardupilot.org/planner/), [QOpenHD](https://openhdfpv.org/download/) or [FPV-VR](https://github.com/Consti10/FPV_VR_OS). But it is not yet possible to output it to the HDMI port of the recorder, since it is built on a specialized chip with its own SDK and in the usual ways, for example through GStreamer, as video is usually output in the case of Raspberry Pi, this cannot be done.

<sub>QGroundControl has a bug when playing h265, which manifests itself in the image freezing when entering the menu. This is treated before restarting the program by selecting the h264 video stream and back to h265.</sub>

Andrey Bezborodov from the OpenIPC team provided compiled examples of *vencoder* and *vdecoder* for testing, pulled from Hisilicon SDK and located in their original form [here](https://github.com/OpenIPC/silicon_research). `venc` runs on the camera and forms an h264 stream with HAL fragmentation instead of `majestic`, `vdec` on the recorder outputs this stream to HDMI. Everything works, but naturally there is no OSD and such a non-standard stream cannot be played by third-party players. This is a very promising way, since it has the ability to reduce video transmission delay. At the moment, it is from 110 to 130 ms. On the "classic scheme" delays are usually from 150 to 230 ms, [here is an example 133 ms](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/Screenshot_1.png), depending on the resolution and ground conditions of playback.

This issue can be solved by "teaching" `vdec` to recognize RTP/h26[4-5] using the *libavformat/avformat.h* library and still "streaming" on the camera via `majestic`. This requires the help of a C++ programmer, if you want to help the project with this - [contact](https://t.me/+BMyMoolVOpkzNWUy).

Example of configuring *GStreamer* on Mission Planner to play h265: `udpsrc port=5600 buffer-size=32768 ! application/x-rtp ! rtph265depay ! avdec_h265 ! videoconvert ! video/x-raw,format=BGRA ! appsink name=outsink`

Supported frequencies are from 5.2 GHz to 5.85 GHz, on atheros 2.3 - 2.4 GHz.

### How does everything start?

When booting Linux, the service `S98datalink` starts among the services from `init.d`, which is the starting point. It starts the script `/usr/bin/wifibroadcast`, which determines via lsusb which adapter is connected, loads its driver, switches to monitor mode, starts `wfb` for transmission or reception, for terrestrial it determines connections via USB, a second WiFi adapter or simply starts transmitting video to `udp_addr`. It takes data on the settings from `/etc/wfb.conf`. Also, when telemetry is enabled, it starts the script `/usr/bin/telemetry`, which does the same but for telemetry purposes, taking settings from `/etc/telemetry.conf`.

### Nuances on camera

There are two sensor drivers for this camera - "slow" 1080p@30fps and "fast" 720p@50fps. They can be switched on the fly using scripts from the examples in [root](https://github.com/OpenIPC/sandbox-fpv/tree/master/gk7205v200/root), if you upload the ["fast" driver](gk7205v200/lib/sensors/libsns_imx307_2l_720p.so) to the camera under a separate name and correct the path to it in its config [`imx307_i2c_2l_720p_50fps.ini`](gk7205v200/etc/sensors/imx307_i2c_2l_720p_50fps.ini#L15). All files for this camera are in the `gk7205v200` directory. If you run the camera with the "fast" driver in the majestic settings, the video transfer is jerky, so when you start the camera via `S95goke`, the "slow" driver settings are registered, after which you can turn on the "fast" one. At the moment, [work is underway](notes_cam_control.md) to control such camera settings via RC channels in mavlink.

### Nuances on the registrar
Since the recorder has a great 16MB of spi flash memory relative to the camera, of which we can use about 5MB, we have access to the [RTL adapter driver](https://github.com/OpenIPC/sandbox-fpv/tree/master/hi3536dv100/88XXau-ko) which supports rtl8814au in addition to the popular rtl8812au. To do this, you need to upload it over the regular one to `lib/modules/4.9.37/extra`, not forgetting to rename it.

Recompiled [`mavlink-router`](https://github.com/OpenIPC/sandbox-fpv/tree/master/hi3536dv100/usr/bin), since the complete one from the firmware is compiled on musl for the air part (where it is not used), and the recorder firmware is on glibc.

It is also necessary to [disable hisilicon watchdog](note_nvr_wdt.md).

### Nuances of telemetry
The current telemetry scheme looks like this:

![telemetry](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/telemetry.png)

~~Currently, using mavlink-routerd, only one-way telemetry via udp is possible, since it cannot use different rx/tx udp ports within one endpoint, as required by wfb, being launched by different processes `telemetry_rx` and `telemetry_tx`.~~
Being started by different processes, `telemetry_rx` and `telemetry_tx` use different ports for receiving and transmitting data (by the way, these are just symbolic links to wfb_rx and wfb_tx created by the [telemetry startup](hi3536dv100/usr/bin/telemetry) script), and mavlink-router requires in the [configuration](hi3536dv100/etc/mavlink.conf) two UDP endpoints, which must be grouped:
```
[UdpEndpoint telemetry_tx]
Group=wfb
Mode = Normal
Address = 127.0.0.1
Port = 14550

[UdpEndpoint telemetry_rx]
Group=wfb
Mode = Server
Address = 127.0.0.1
Port = 14551
```

The remaining endpoints are needed to communicate with the ground station, for example tcp:5760 to receive connections from Mission Planner. For the [attached config](hi3536dv100/etc/mavlink.conf) in the UDP link settings you need to specify the registrar address:

![udp-qgc](notes_files/qgc-udp-settings.png)

All that remains is to switch to /usr/bin/telemetry to use mavlink-routerd and there is no longer any need to connect the recorder's uart.

```
  /usr/bin/mavlink-routerd -c /etc/mavlink.conf &
  #/usr/sbin/mavfwd --master ${serial} --baudrate ${baud} --out 127.0.0.1:${port_tx} --in 127.0.0.1:${port_rx} &
```

If you want to use uart, you can set the endpoint to /dev/ttyAMA0 or switch to mavfwd.
In this case, you need to disable the ssh console from uart in /etc/inittab by commenting out the line:

```
#console::respawn:/sbin/getty -L console 0 vt100 # GENERIC_SERIAL
```
Then telemetry will be available on the uart of the recorder instead of or in addition to udp over the network, and it can be used via the usb-uart adapter as a serial port. On QGC, to connect to serial, you need to disable flow control in advanced, otherwise it loads about half of the parameters and gives an error.

I compiled `mavfwd` for the DVR, supporting b230400, b500000, b921600 and b1500000 baud rates, to support higher rates when working with Mission Planner, tested on b500000 at b115200 / b230400 on the camera. For the DVR it can be taken [here](hi3536dv100/usr/sbin). For the camera: [here](https://github.com/OpenIPC/sandbox-fpv/tree/master/gk7205v200/usr/sbin). [Source](https://github.com/OpenIPC/sandbox-fpv/tree/master/mavfwd). On the camera it was possible to get a stable connection with the flight planner at a rate of 230400, higher than stm32f4 it was not possible. Setting the flight controller speed for ardupilot is done by the `SERIALx_BAUD` parameter, in my case: "230". Also, don't forget to set the `TELEM_DELAY` parameter to 10 (seconds of delay before starting to output telemetry), otherwise telemetry may stop the bootloader. Unfortunately, if the camera is restarted for some reason during the flight separately from the flight controller, then telemetry ~~will not let it boot~~ may not let it boot. ~~It is necessary to modify the u-boot bootloader so that it does not stop booting on any character.~~ ~~With [new u-boot](gk7205v200_u-boot-7502v200-for-telemetry.md),~~ which is interrupted only by Ctrl+C, and `bootdelay=0` this problem is not present according to tests. This U-boot is already included in all OpenIPC FPV firmware.

I also [put in it](notes_cam_control.md) the basics for monitoring selected mavlink RC channels and passing their values ​​when changed in `/root/channels.sh` as parameters $1 (channel) and $2 (value).

### Current issues
If the "fast" 720p driver is selected when loading the camera in majestic, the video is jerky, so in S95goke (majestic autostart) the "normal" 1080p driver is installed before starting. If you want to use 720p@50 by default when loading the camera, insert a call to the switching script in [`/etc/init.d/S95majestic`](gk7205v200/etc/init.d/S95majestic#L35) in the `load_majestic` function after loading majestic:
```
yaml-cli -s .isp.sensorConfig /etc/sensors/imx307_i2c_2l_1080p.ini
yaml-cli -s .video0.size 1920x1080
yaml-cli -s .video0.fps 30

start-stop-daemon -b -m -S -q -p "$PIDFILE" -x "/usr/bin/$DAEMON" \
	-- $DAEMON_ARGS
status=$?
if [ "$status" -eq 0 ]; then
	echo "OK"
else
	echo "FAIL"
fi

sleep .5
/root/720.sh

return "$status"
```
