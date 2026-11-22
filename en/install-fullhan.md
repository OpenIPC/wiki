# OpenIPC Wiki
[Table of Content](../README.md)

For Fullhan/Vatilon SOC
-----------------------------------------------------------------
## PB1 Board 

These SoCs can also run the [NOR split layout](nor-split-layout.md): kernel and
root filesystem in one partition, with no 2 MiB kernel slot to outgrow. Any
U-Boot that loads the kernel from `0x50000` boots it, the factory one with a
changed `bootcmd` included; the OpenIPC `u-boot-<soc>-nor.bin` adds the layout
scan, `fwupd` and recovery for it.

### Supported sensors

IF56N, FH8856 V100, GC4653, 8 MB NOR

### Backup of original firmware

Telnet to the camera (port 2360) from your computer using root/ipc@hs66
```
telnet <IP Address> 2360
IPCam login: root
Password: 


BusyBox v1.19.3 (2020-08-19 14:57:36 CST) built-in shell (ash)
Enter 'help' for a list of built-in commands.

Welcome to FHLinux.

```

On the camera (telnet just sets this up; the transfer is a separate TCP connection):

```
echo '#!/bin/sh' > /tmp/d.sh
echo 'exec cat /dev/mtd0 /dev/mtd1 /dev/mtd2 /dev/mtd3 /dev/mtd4 /dev/mtd5 2>/dev/null' >> /tmp/d.sh
echo '29000 stream tcp nowait root /bin/sh sh /tmp/d.sh' > /tmp/i.conf
busybox inetd /tmp/i.conf
```
Use netcat on your machine to download the data from the camera (expect 8388608 bytes)
```
nc <camera-ip> 29000 > flash_8M.bin 

```
When done:  kill the inetd you started on the camera, rm /tmp/i.conf /tmp/d.sh, and confirm the port is closed or reboot the camera

### TFTP Server
Only signed images can be installed from the OEM Camera software, therefore the UBoot startup code must be used to download and install the OpenIPC image. A TFTP server is required to supply UBoot with the image.

- Set up an TFTP server for your computer. [Instructions](installation-tftpd.md)
- Download the [Fullhan FH8856V100](https://openipc.org/cameras/vendors/fullhan/socs/fh8856v100) image
- Extract the boot files from the image and copy the individual files to the TFTP server directory. 

### Access to the UBoot prompt
UBoot must be interrupted before loading the camera software so low level access via a 3.3V USB/Serial converter is required and connected to the SOC UART. You will require a terminal emulator such as minicom set to 115200baud.
The camera must be opened up to access the UART on the board

The UART coonnector are the 3 small holes just above the blue square under the mounting hole in the picture.

Sewing pins can be poked into the holes for attachment to the USB/Serial converter. 
![PB1 Board](../images/vatilon-PB1.png)

From left to right in the picture
- 1 - Connect to TXD 
- 2 - Connect to RXD 
- 3 - Connect to GND 

Start the terminal emulator with the USB/Serial converter plugged into your computer and power the camera on.
UBoot and linux boot messages will scroll past. If not, check your connections and terminal settings and try again.

Power cycle the camera and watch for the Press any key message. Any key will halt the boot from a cold boot, only Ctrl H will halt a warm boot.

Once UBoot is halted the firmware install can proceed.

### Initial device firmware install
UBoot is used to download the files to RAM then copy the RAM to the NOR flash memory.

At U-Boot>, use your own addresses on the first line:
- ipaddr is the camera IP address
- serverip is the IP address of the TFTP server

Execute each line in turn and ensure that no errors occur and the the TFTP download was successful.
Check that each tftp ends with Bytes transferred = ... before running the sf erase and sf write after it. If a transfer fails, run it again. 

DANGER - Do not reset with a half-written partition.


```
setenv ipaddr 192.168.1.10; setenv serverip 192.168.1.2
setenv bootargs 'mem=29M console=ttyS0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=spi_flash:256k(boot),64k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'sf probe 0; sf read 0xa1000000 0x50000 0x200000; bootm 0xa1000000'
saveenv
sf probe 0
tftp 0xa1000000 uImage.fh8856v100
sf erase 0x50000 0x200000
sf write 0xa1000000 0x50000 ${filesize}
tftp 0xa1000000 rootfs.squashfs.fh8856v100
sf erase 0x250000 0x500000
sf write 0xa1000000 0x250000 ${filesize}
sf erase 0x750000 0xb0000
reset
```

The camera should boot to an OpenIPC login prompt. The root password will be set on first login.

Access the OpenIPC GUI via a web browser using the password set. The web GUI is accessed on port 80 by default. This can be changed via the GUI.

