## Connecting a smartphone or tablet on android for FPV-VR and other GS programs to NVR via USB

USB Tethering, also known as USB Ethernet, is an Android OS function for using a phone as a USB modem, which appears as a network card. This allows us to connect the phone and NVR with a regular USB cable and get a fast network between them. Unfortunately, in most cases, USB terhering is only available on tablets with a SIM card module. If you do not have one, and the USB modem is not activated, you will have to connect via [usb-ethernet](usb-eth-modem.md) or [wifi](note-nvr-tab-ap.md).

You need to [install](notes_start_hi3536ev100.md#L47) [kernel](hi3536dv100/uImage.hi3536dv100) and [rootfs](hi3536dv100/rootfs.squashfs.hi3536dv100) with rndis_host support and upload [`/usr/bin/wifibroadcast`](hi3536dv100/usr/bin/wifibroadcast), [`/usr/bin/telemetry`](hi3536dv100/usr/bin/telemetry), and add the following to [`interfaces`](hi3536dv100/etc/network/interfaces):
```
#USB Tethering
auto usb0
iface usb0 inet dhcp
    pre-up modprobe rndis_host
    pre-up sleep 4
```

To enable you need to:
* Connect your smartphone or tablet with a cable to the disconnected recorder
* Go to settings - Network and Internet - Access point and modem
* Turn on the recorder
* As soon as the USB modem item appears active in the Android menu, enable it.
* Launch FPV-VR, select the Manually (stream) section in the settings, set the video settings to the codec used (rtp/264, rtp/265) and telemetry settings to mavlink.
* Exit settings and run "Start video and osd".

Alternatively, you can use the QOpenHD application with similar functionality.

Also available [option without restarting](nvr_gpio.md) of the recorder.
