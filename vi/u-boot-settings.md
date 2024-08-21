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
Sets the fallback address on the Ethernet interface if WiFi is enabled

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


