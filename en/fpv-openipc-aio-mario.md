# OpenIPC Wiki
[Table of Content](../README.md)

OpenIPC AIO "Mario"
-------------------

https://store.openipc.org/OpenIPC-AIO-Mario-v1-0-p633320808

![image](https://github.com/user-attachments/assets/ad675599-61ce-4cec-a9bf-5933d907c53a)

Remove the lens cover film befor use

![image](https://github.com/user-attachments/assets/9ead08a6-f4eb-45a0-bc63-19d3abd3ec1e)



The Mario camera case with 4x M1.2 screws.

Side mount holes are M2 x2 screw thread.

Install atennas for AIO.

![image](https://github.com/user-attachments/assets/e10e6671-553f-4840-aacd-16816be0813b)



### LED function

Red glimmering	Power on with Battery

Red 	Wired linked

Blue flash	RF transmitter

Green	TBD

Board Size 30mmx32mm with 4*M2 mount holes.

Heat Sink with 20mmx20mm mount holes.

![image](https://github.com/user-attachments/assets/1c7e34c1-76a9-45ee-9caf-ffd33261e154)




### Power Section

Power input:

2S-6S

The on board dualway BEC Capacity:

RF BEC on board is up to 3A 5V output

MSIC BEC on board is up to 2A 5V output

enter uboot use  uart device connect to top of AIO board(R0,T0)pad.


### Connect usb debug port

Plug USB cable to connect AIO and PC first, then power on DC, or usb power only.

If there are unknown USB devices in the computer, the following drivers need to be installed.
[corechip-sr9900-usb20-to-fast-ethernet-adapter-1750095.zip](https://github.com/user-attachments/files/16829005/corechip-sr9900-usb20-to-fast-ethernet-adapter-1750095.zip)

in windows:

go to control panel- internet -network:

find a usb2.0 to fast Ethernet Adapter

set this card ipv4 address to 192.168.1.11 mask:255.255.255.0

apply

then open ssh to connect AIO address:192.168.1.10

user:root password:12345


### Upgrade firmware

Update firmware possible via SD card or just use win scp drug the rootfs and kernel files to /tmp

```
sysupgrade -n -z --kernel=/tmp/uImage.ssc338q --rootfs=/tmp/rootfs.squashfs.ssc338q
```

You can [download](https://github.com/OpenIPC/wiki/blob/master/en/fpv-openipc-aio-ultrasight.md#software) firmware via the link that is used for online updates.

You can also read the current discussions and suggestions here:

- https://t.me/c/1809358416/98818/103632
- https://t.me/c/1809358416/98818/108052

Or just use the configurator - https://github.com/OpenIPC/configurator


### RF section

RF antenna characteristics

![image](https://github.com/user-attachments/assets/d54050b4-2769-4942-95d7-8aad3b5e2e21)

![image](https://github.com/user-attachments/assets/0a709f70-ac8b-4880-93f5-49e1d958eb1b)


Default Antenna is ANT1 for 1T1R, ANT0+ANT1 is 2T2R

Reconmand RF setting 
  
  RF Power max 18dbm for onbard PA. For 1T1R rf setting range: 1-63 firmware update to latest!
  
  MCS index 1,3(0-7 is 1T1R, 8+ is 2T2R)
  
  stbc=1,ldpc=1
  
  Video biterate:4096 /8192/12688(mcs 3+)

  Keep RF poweroff or power=1 when on bench test(when only usb connect)


### SD solt for Air camera record

on bench test or debug is disable the record function defaultly

To enable the recording function set (record value)true in majestic.yaml


On board heat sink and cooling fan:

cooling fan out put power up to 500mA max

all heat sink mount holes are M2 screws thread.


### Extend connector**

![image](https://github.com/user-attachments/assets/af8124e3-539f-42c6-a757-a560eb93e3fe)


**NOTE**

USB only for debug mode, when DC power only, the cdc ethernet works in sleep mode to save energy.

USB power only mode Power limited 5W input.


