## Notes on flashing the IVG-G2S camera with OpenIPC firmware.

ATTENTION! Most of the information in this article is hopelessly outdated, all additional steps besides firmware are no longer relevant - they are included in the firmware, and everything works out of the box, you only need to copy the gs.key from the camera to the ground station and specify the correct channels on both.


The purpose of this note is to help draw attention to the extremely promising topic of launching digital fpv on cheap cameras without a single-board computer on board.
Feedback is **VERY** important to developers; if the project is popular, it will develop much faster with their help.
Go to the [telegram chat](https://t.me/+BMyMoolVOpkzNWUy) specially created for this topic, ask questions that are not described here and at the links below, publish information about your successes and request help in solving problems.
Once again - feedback is extremely important, even if you have everything worked out and it works - please, do not be lazy to describe your setup and publish a review in the chat. This will allow the project to develop with the participation of developers.

* [Main page on OpenIPC + FPV topic, must read](https://github.com/OpenIPC/wiki/blob/master/ru/fpv.md)
* [Main project wiki](https://github.com/OpenIPC/wiki) (currently the EN version contains more information)
* [Online instruction generator](https://openipc.org/supported-hardware/featured)


### Terms

* Flash - in this context SPI flash, memory chip.
* U-Boot - bootloader. There is a "native" one, there is one from OpenIPC. The native one is password protected. We need the one downloaded from the instruction generator.
* uImage - Embedded Linux kernel, in the form of a bin file.
* Root-FS - file system of the selected version (lite, ultimate, fpv), in the form of a squash-fs file [https://ru.wikipedia.org/wiki/Squashfs]. uImage and rootfs must be obtained through the instruction constructor, separate firmware u-boot and root-fs.
* Shell - command line of the linux camera, accessible via uart and ssh (putty program). There is also a bootloader shell, only uart. Login root, no password.
* Majestic - utility - video streamer, from the OpenIPC firmware package.

The boards are usually equipped with spi-flash of 8 or 16 MB. The ultimate version requires 16, you can re-solder it. For fpv purposes, 8 MB is enough.

If you don't have an ethernet cable to connect the camera to your switch/router, you can make one from half of a regular patch cord and a jst xh1.25 8pin connector. These were used in Omnibus F4 flight decks and many other places.
The pinouts of the camera and connector are easy to google, you need to connect 4 lines: rx+, rx-, tx+, tx- on the cable and camera. The same connector supplies power from 5 to 12 V to pins 7 (gnd) and 8 (vcc).

I recommend flashing lite first, since it has the shell unlocked via uart (in the /etc/inittab file) and this will allow you to connect in emergency situations, such as when there is no network.

There are three ways to flash the ivg-g2s camera on OpenIPC. In order of complexity: coupler, burn, programmer.

 - Coupler [https://github.com/OpenIPC/coupler] - this is loading the kernel and rootfs with one file through the camera's native web interface. Cons - the native password does not change
bootloader, can only be done once, rollback or change of firmware only through other methods.
Algorithm: find out the version in the native web interface, download the firmware based on it, download it as an update in the native web interface. For ivg-g2s/659A7 there is [firmware with bootloader](gk7205v200/659A7_OpenIPC_FPV.bin).

 - Burn [https://github.com/OpenIPC/burn] - loading an unprotected u-boot bootloader from OpenIPC via the camera's uart and uart-usb adapter (for example, ch340) and further work in the bootloader, according to the OpenIPC instruction designer.
There are no downsides, the bootloader changes, which allows you to download the required image from the tftpf server [https://pjo2.github.io/tftpd64/] at any time and flash it into flash.
The algorithm is described in video instructions on the OpenIPC channel [https://www.youtube.com/@openipc/videos]. Next, having loaded the bootloader into RAM (only [choose your own](gk7205v200_u-boot-7502v200-for-telemetry.md) due to the nuances), we work through the instruction designer. Unpack uImage and root-fs and put them in the tftpd directory.
I tried to forward usb-uart to archlinux under virtualbox and use burn from there, but the loading did not work, the connection with uart was one-way, only for reading. From windows 7 everything went normally.
Use short wires both from the USB port to the adapter and from the adapter to the camera. The pinout of the uart on the camera is in the first article from the list above, you need to connect "crosswise" - tx adapter to rx camera and rx adapter to tx camera.
If everything is OK, but tftp does not download the file - try changing the camera address to a nearby free one, `setenv ipaddr '192.168.0.223'`.

 - Programmer - soldering out the flash or one leg and connecting to the programmer, flashing everything through the programmer.
The most difficult method, this is the only downside.

On first boot you need to run the firstboot command.
If the camera reboots cyclically, it is the watchdog from majestic (streamer). Most likely, you need to remove the lens cap and turn on the light. It is disabled in /etc/majestic.yaml, kill the process quickly: `killall majestic`.

You can manage the config parameters with saving via the cli shell utility:
```
cli -s .image.contrast 50
cli -s .image.luminance 50
cli -s .video0.codec h264
cli -s .hls.enabled false
cli -s .isp.sensorConfig /etc/sensors/imx307_i2c_2l_1080p.ini
cli -s .video0.size 1920x1080
cli -s .video0.fps 30
```
I recommend running these commands, this will set up majestic for initial attempts.

Switch to FPV version with update. Attention! In FPV version shell via uart is disabled (freed for telemetry work), after loading, only network access remains. The bootloader itself, of course, works via uart.
```
    sed -i 's/BUILD_OPTION=lite/BUILD_OPTION=fpv/' /etc/os-release
    sysupgrade --force_ver -k -r -n
```
If you don't plan to use telemetry through this video link, you can turn it back on:
```
     sed -i 's/#console::respawn:\/sbin\/getty/console::respawn:\/sbin\/getty/' /etc/inittab
     reboot
```
If the flash is locked (you somehow flashed the kernel of previous versions that cannot unlock the flash), then this and any other commands will not be executed.

Example output of `dmesg | grep bsp-sfc` to determine if a flash drive is locked:

Unlocked
```
bsp-sfc bsp_spi_nor.0: SR1:[02]->[00]
bsp-sfc bsp_spi_nor.0: SR2:[02]->[00]
bsp-sfc bsp_spi_nor.0: all blocks are unlocked.
bsp-sfc bsp_spi_nor.0: Winbond: SR1 [], SR2 [QE], SR3 [DRV0,DRV1]
```

Blocked
```
bsp-sfc bsp_spi_nor.0: SR1:[02]->[00]
bsp-sfc bsp_spi_nor.0: SR2:[02]->[00]
bsp-sfc bsp_spi_nor.0: all blocks are unlocked.
bsp-sfc bsp_spi_nor.0: Winbond: SR1 [TB], SR2 [QE], SR3 [WPS,DRV0,DRV1]
```

Trying to unlock flash from shell (didn't help me)
```
devmem 0x10010024 32 0x06;devmem 0x10010030 32 0;devmem 0x1001003C 32 0x81;devmem 0x14000000 16 0x0000;devmem 0x10010024 32 0x01;devmem 0x10010030 32 0;devmem 0x10010038 32 2;devmem 0x1001003C 32 0xA1
#
sysupgrade --force_ver -k -r -n
```

The way to unlock flash is through loading a fresh kernel, unpacked by the archiver from a tgz file with the kernel and rootfs, taken from the instruction designer. After loading, it automatically unlocks flash. It is made from the bootloader, poured into RAM via burn.

```
# Set the camera address and the tftpd server address
setenv ipaddr 192.168.0.222; setenv serverip 192.168.0.107

# Set environment arguments (env)
setenv bootargs 'mem=32M console=ttyAMA0,115200 panic=20 rootfstype=squashfs root=/dev/mtdblock3 init=/init mtdparts=sfc:256k(boot),64k(env),2048k(kernel),5120k(rootfs) ,-(rootfs_data)'

# Clear the RAM area for kernel download
mw.b 0x42000000 ff 1000000

# Loading the uImage.gk7205v200 kernel from the tftpd server
tftpboot 0x42000000 uImage.${soc}

# Launch the kernel
bootm 0x42000000
```