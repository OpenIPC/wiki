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

How to get lower voltage input for DC input

AIO power supply from 2s-3S battery needed more current and required 4wires connected, but higher voltage 4S+ may works 2wire connection.

Remove two resistors then you can get input as low as 5.4V input available.

![image](https://github.com/user-attachments/assets/24218925-fca8-47e2-bc4a-1326dabeaa68)




### Connect usb debug port

Plug USB cable to connect AIO and PC first, then power on DC, or usb power only.

If there are unknown USB devices in the computer, the following [corechip-sr9900](https://github.com/user-attachments/files/16829005/corechip-sr9900-usb20-to-fast-ethernet-adapter-1750095.zip) drivers need to be installed.

Operations on Mac OS

<img width="686" alt="Screenshot 2024-09-21 at 10 07 24 AM" src="https://github.com/user-attachments/assets/15fde52d-8f14-4377-87ed-cec6e05dc70a">

<img width="714" alt="Screenshot 2024-09-21 at 10 09 18 AM" src="https://github.com/user-attachments/assets/ce029aab-7505-41f8-81fc-283e41dfe84a">

<img width="544" alt="Screenshot 2024-09-21 at 10 11 31 AM" src="https://github.com/user-attachments/assets/97aff8d8-1a1b-4682-a304-4af58a29e68a">



#### Autosetup in windows
Please download [Auto_Set_Mario_CDC.zip](https://github.com/user-attachments/files/17010487/Auto_Set_Mario_CDC.zip) file, unzip it and run as administrator.

or setting manually as follows:

go to control panel- internet -network:

find a usb2.0 to fast Ethernet Adapter

set this card ipv4 address to 192.168.1.11 mask:255.255.255.0

apply

then open ssh to connect AIO address:192.168.1.10

user:root password:12345

**How to get internet for AIO**

1.Open network connections on you windows, right click your main network adapter properties---Sharing: Allow other network users choose USB CDC


![image](https://github.com/user-attachments/assets/e3f41122-7601-4dff-b599-a325e0693b8c)

Apply,then the CDC ethernet will got a ip address 192.168.137.1 automaticlly


![image](https://github.com/user-attachments/assets/bac7350b-399e-419c-8a4a-557d4378cf79)

open admin terminal

![image](https://github.com/user-attachments/assets/7eaae7ca-16c6-4e59-a8de-9178c9e3b77c)

using arp -a to find AIO's IP

![image](https://github.com/user-attachments/assets/f6d2641e-a5e9-45cd-90cb-5328d423a6c7)

here 192.168.137.147 is my AIO's ip address.

open ssh connect to AIO,Done.

![5ed177f3dc690f9e70452e3e4c93b17](https://github.com/user-attachments/assets/48f44a3d-ae04-4780-aac7-b878a043c3e6)

Now you can use sysupgrade -r -k -n --force_ver to update your firmware.




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

RF Power max 18dbm for onbard PA input. 
 For 1T1R rf setting range: 1-63 firmware update to latest! 
 stbc=0,ldpc=0 Recommand RF power value < 45
  
  MCS index 1,3(0-7 is 1T1R, 8+ is 2T2R)
  
  Video bitrate:4096 /8192/12688(mcs 3+)

  when you use stbc=1,ldpc=1 we recommand RF power setting for MCS3 from 8-15 for test.

  Keep RF power < = 15 when on bench test(when only usb connect)


### SD solt for Air camera record

On bench test or debug the record function is disabled by default.

To enable the recording function set (record value)true in majestic.yaml

SD card must be inserted before Powering.


**On board heat sink and cooling fan:**

cooling fan out put power up to 500mA max

all heat sink mount holes are M2 screws thread.


### Extend connector**

![image](https://github.com/user-attachments/assets/af8124e3-539f-42c6-a757-a560eb93e3fe)


**NOTE**

USB only for debug mode, when DC power only, the cdc ethernet works in sleep mode to save energy.

 In USB power only mode, the Power is limited to 5W input.

**Upgrade Firmware to Ruby FPV**

plug usb cable and setting cdc ethernet ipv4: 192.168.1.11 255.255.255.0

use winscp drag unzip files to /tmp 

use ssh login and copy following command:

sysupgrade --kernel=/tmp/uImage.ssc338q --rootfs=/tmp/rootfs.squashfs.ssc338q -z -n

after update and reboot

use ssh login and set command: 

fw_setenv sensor imx335 && fw_setenv upgrade https://github.com/OpenIPC/firmware/releases/download/latest/openipc.ssc338q-nor-rubyfpv.tgz && reboot


