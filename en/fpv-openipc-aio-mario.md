# OpenIPC Wiki
[Table of Content](../README.md)

OpenIPC AIO "Mario"
-------------------

https://store.openipc.org/OpenIPC-AIO-Mario-v1-0-p633320808

**Power Section**
2S-6S
enter uboot use  uart device connect to top of AIO board(R0,T0)pad.

**connect usb debug port:**

power on AIO with Battery connector, after the blue LED flashing, plug in usb cable and connect to PC
in windows:
go to control panel- internet -network:
find a usb2.0 to fast Ethernet Adapter
set this card ipv4 address to 192.168.1.11 mask:255.255.255.0
apply
then open ssh to connect AIO address:192.168.1.10
user:root password:12345


**RF section**
Default Antenna is ANT1 for 1T1R, ANT0+ANT1 is 2T2R
Reconmand RF setting 
  RF Power 1~30dbm
  MCS index 1,3(0-7 is 1T1R, 8+ is 2T2R)
  stbc=1,ldpc=1
  Video biterate:4096 /12688(mcs 3+)
  