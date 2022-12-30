# OpenIPC Wiki
[Table of Content](../index.md)

Adding Huge-IC AH WiFi HaLow drivers for Ingenic T31
----------------------------------------------------
For basic users like myself, advanced users can ignore this document altogether.

This document describes how to add a Huge-IC's AH [WiFi HaLow](https://iot4beginners.com/wi-fi-halow/) drivers to OpenIPC firmware.

### Obtain driver source and edit Makefile

Obtain source file of the drivers so you can compile those drivers and upload to your camera system. So that when the hardware is connected, camera (host) can identify the hardware and connect with it. Its like, when you connect an USB dongle to your computer, it loads the driver. Your microprocessor does not load drivers like your PC, so you need to do it yourself.

First thing, locate Makefile. The file includes compilation instructions and failing to do it right will mean no wifi for your camera board. In the Makefile, edit values for ARCH, COMPILER and LINUX_KERNEL_PATH.

Ingenic uses MIPS architecture so use it for ARCH ‘ARCH := mips’ 

For COMPILER and Kernel Path, it is will be a cross compilation – kind of dependent on what you got in the OpenIPC. To enlighten yourself further, read this: https://blukat.me/2017/12/cross-compile-arm-kernel-module/

We can now move onto download and extract OpenIPC firmware, its extracted file will provide us the paths for Compiler and Kernel.

### Download OpenIPC Firmware

```
cd
git clone git@github.com:OpenIPC/firmware.git
cd firmware
./building.sh t31_ultimate
```
(t31_ultimate because ultimate comes with support for wireless devices. lite is stripped of those to save space.)

Now you can change the Compiler and Kernel path in driver source Makefile:

```
#Driver Compilation for Ingenic T31
ARCH := mips
COMPILER := ~/firmware/output/host/bin/mipsel-linux-
LINUX_KERNEL_PATH := ~/firmware/output/build/linux-3.10.14
```

### Now run ‘make fmac’

(here FMAC or any other relevant name for your drivers)

If all went to plan, you should have one script file and one or more .ko extension files. Those .ko extension files are your drivers and the script file includes instructions for your host microcontroller to find and activate the drivers.

###	Time to upload the drivers to camera system

If the files are small and Ingenic having extra space available, you can sideload the drivers.

Upload the .ko (drivers) and `fmac` (your script file can have a different name) script file to the folder of your choosing. Please make sure to edit the corresponding paths in the fmac script file, if required.

###	Test

Test it with your WiFi hardware to ensure that it works. 

###	Next, create a package

Once you have learned how to create a package, please share it with the OpenIPC admin team members. They may agree to include your driver package to the repo. Once included as a package, next time you can use it by simply uncommenting and activating the package within the OpenIPC config file.
