## Using the hardware as a joystick to transmit RC channels via mavlink

### Theory
Ground station programs such as Mission Planner or QGroundControl are able to recognize connected joysticks or hardware in USB joystick mode and
transmit axis values ​​to the flight controller in the RC_CHANNELS_OVERRIDE packet (#70). However, QGC only transmits the first 4 channels (two axes), the rest can only be assigned to buttons,
and MP can do it only under Windows, which is not always convenient. I wrote a simple application for the recorder, which recognizes the connected joystick and sends [RC_CHANNELS_OVERRIDE](https://mavlink.io/en/messages/common.html#RC_CHANNELS_OVERRIDE) packets in the mavlink protocol version 2 for supporting 18 channels directly to the telemetry_tx port, which is usually published on 127.0.0.1:14650 of the recorder. The port, address, time between sending packets, the number of axes and the device in the system can be reassigned, see `rcjoystick -h`.

```
Usage:
 [-v] verbose;
 [-d device] default '/dev/input/js0';
 [-a addr] ip address send to, default 127.0.0.1;
 [-p port] udp port send to, default 14650;
 [-t time] update RC_CHANNEL_OVERRIDE time in ms, default 50;
 [-x axes_count] 2..9 axes, default 5, other channels mapping to js buttons from button 0;
 [-r rssi_channel] store rx packets per second value to this channel, default 0 (disabled);
 [-i interface] wlan interface for rx packets statistics, default wlan0;

```

For example, you can send not to telemetry_tx, but to mavlink_routerd, if you need it that way. Package for building in buildroot from OpenIPC [here](rcjoystick).

### Let's launch
We need a kernel and rootfs with usb-hid support on the recorder. To do this, [flash](notes_start_hi3536ev100) them from the [`/hi3536dv100`](hi3536dv100) directory.
~~You need to ensure that the `hid-generic.ko` module is running, to do this, add `modprobe hid-generic.ko` to [`S95hisilicon`](hi3536dv100/etc/init.d/S95hisilicon).~~ In a freshly built kernel, the `hid-generic.ko` module is loaded automatically.

Next, you need to copy the binary [`rcjoystick`](hi3536dv100/usr/bin/rcjoystick) to the /usr/bin registrar, via WinSCP and assign execution rights: `chmod +x /usr/bin/rcjoystick`.
Reboot, connect the equipment to the recorder via USB and try to run `rcjoystick -v` in the console. If everything went well, then on the screen we should see the values ​​of the axes when changing the position of the sticks and switches, and in the telemetry program, for example in QGC (analyse tools > Mavlink inspector > RC_CHANNELS_RAW) the channels should change. To run it permanently, you can register it in a separate service [`S99rcjoystick`](hi3536dv100/etc/init.d/S99rcjoystick), the main thing is that it starts after wifibroadcast.

### RSSI

Also in rcjoystick was added the function of injection of the analog of rssi (number of received from the air part of packets per second) for at least some indicator of reception quality, since there is no desire and sense to start a separate service for this, considering the low level of the registrar. In rcjoystick there is already most of what is necessary for injection.

We specify `-r 16` and, if the wfb interface is not wlan0, then its `-i wlanX` and the number of packets received by the ground per second will fall into the specified channel. For me it is around 800, you can see yours by using the verbose key (`-v`). Then we specify on the flight controller:
```
RSSI_TYPE 2
RSSI_CHANNEL 16
RSSI_CHAN_LOW 0
RSSI_CHAN_HIGH 800 //your normal value, roughly average, not maximum or minimum.
```
The value will be sent to the flight controller, where it will process it and set 0..99 in rssi.

The project is still in the testing stage, so [send](https://t.me/+BMyMoolVOpkzNWUy) your feedback on attempts and wishes.

### Current issues
Sometimes short freezes are observed if you actively hammer both sticks in all directions. Debug says that the driver does not receive any movement events at this time. This effect is not observed if you use a joystick "radio extender" (sbus-to-usb-joystick) in the form of an arduino pro micro, which parses SBUS from your receiver and translates it into a usb-hid-joystick.