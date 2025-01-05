## Connecting a tablet or phone via a USB-ethernet device.

The device is a network card connected via USB to the tablet and looks something like this:

![usb-ethernet.png](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/usb-ethernet.png)

It is connected to the recorder via an ethernet cable, after which in [`/etc/wfb.conf`](hi3536dv100/etc/wfb.conf) `udp_addr=auto` is specified instead of a fixed address. On the tablet itself, the "Ethernet-modem" function must be enabled
in the settings "Network and Internet > Access point and modem".

Then everything will be done by the services [`/usr/bin/wifibroadcast`](hi3536dv100/usr/bin/wifibroadcast) and [`/usr/bin/telemetry`](hi3536dv100/usr/bin/telemetry) when loading the recorder or restarting from the [front-panel](nvr_gpio.md).