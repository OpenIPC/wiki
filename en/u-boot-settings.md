# OpenIPC Wiki
[Table of Content](../README.md)

U-Boot settings
---------------

### bootdelay
Use this to set the delay before we start the kernel, This is the time where you can get into the bootloader.

### bootnfs
To be continued...

### ethaddr
Mandatory setting, available in all OpenIPC bootloaders

### gatewayip
This is the camera's gateway IP address, Mostly used for when you are flasing using TFTP in U-Boot.

### ipaddr
This is the camera's IP address, Mostly used for when you are flasing using TFTP in U-Boot.

### netaddr_fallback
The Ethernet port's address when it cannot get one by DHCP while Wi-Fi is configured.
It is used as the cable's fixed service address with `netmode wifi`, and otherwise
only when no DHCP server answers on the cable. The default is 192.168.2.10. See
[Cable and Wi-Fi together](../en/wireless-settings.md#cable-and-wi-fi-together).

### netmode
Firmware built after [OpenIPC/firmware#2573](https://github.com/OpenIPC/firmware/pull/2573).
Set to `wifi` to make Wi-Fi the only network path on a camera with both a cable port
and a configured Wi-Fi: the cable stays on `netaddr_fallback` with no DHCP. Unset,
the cable is preferred and Wi-Fi takes over when it is unplugged. It takes effect at
the next boot. Older firmware always behaves as `wifi` does.

### osmem
Mandatory setting, available in all OpenIPC bootloaders

### sensor
The type of sensor used on the device is set automatically in most cases

### upgrade
Specify the full path to the archive with custom OpenIPC firmware in .tgz format

### wlandev
The Wi-Fi Driver to use for the Wi-Fi interface. ([Learn how to use it here](../en/wireless-settings.md))

### wlanmac
The MAC for the Wi-Fi Interface.


