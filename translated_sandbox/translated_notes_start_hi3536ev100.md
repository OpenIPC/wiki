### Notes on NVR hi3536ev100 firmware on OpenIPC for FPV purposes
[EN](en_notes_start_hi3536ev100.md)

This article is not relevant in terms of firmware, use https://github.com/OpenIPC/wiki/blob/master/en/fpv-nvr.md, this article may be useful in some aspects.


<details>
  <summary>How memory works</summary>
First, you should understand how the recorder's memory is arranged (and the camera's too) and what needs to be flashed. The data is stored on a 16mb spi-flash in the form of mtd blocks:

```
cat /proc/cmdline
mem=150M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),8192k(rootfs),-(rootfs_data)
ls /dev/mtdb*
/dev/mtdblock0  /dev/mtdblock1  /dev/mtdblock2  /dev/mtdblock3  /dev/mtdblock4
```
As follows from the output, the zero block is the u-boot bootloader; then comes the block for storing environment variables (`printenv`, `setenv` commands write to RAM, and `saveenv` saves exactly to this block); then the uImage kernel; then rootfs.squashfs (an immutable file system image); and finally rootfs_data or overlay - a variable part where differences from rootfs are written if you change any files. Thus, by clearing the overlay, we "reset" the file system to the "default":
```
sf probe 0 #select device
sf erase 0xA50000 0x500000 #perform cleaning
reset #reboot
```
It's even easier to reset to factory firmware using the `firstboot` command.

The address calculator for commands is available [here](https://openipc.org/tools/firmware-partitions-calculation). In our case, the rootfs partition is 8192kB, so the overlay start address will be 0xA50000. For a camera with 8mB flash, the rootfs size is 5120kB, the addresses will be different, including environment variables!
</details>

The bootloader of this recorder does not have a password, and you can get into it via uart/115200 baud, pressing Ctrl+C several times at startup while connected to the debug-uart port of the recorder via a usb-uart 3v3 adapter (ftdi, ch340). Debug uart is located opposite the VGA connector on the opposite edge of the board and is signed as gnd/tx/rx. We do not need to flash the bootloader, burn is not needed. ENV (environment variables) are different from the factory ones, but it is easier to install them directly from the bootloader line by line:
```
setenv ipaddr '192.168.0.222' #here is the ip in your subnet from free ones
setenv serverip '192.168.0.107' #address of PC with tftp server
setenv netmask '255.255.255.0'
setenv bootcmd 'sf probe 0; sf read 0x82000000 0x50000 0x200000; bootm 0x82000000'
setenv uk 'mw.b 0x82000000 ff 1000000;tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x82000000 ff 1000000;tftp 0x82000000 rootfs.squashfs.${soc}; sf probe 0; sf erase 0x250000 0x800000; sf write 0x82000000 0x250000 ${filesize}'
setenv bootargs 'mem=192M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),8192k(rootfs),-(rootfs_data)'
setenv eighth '192M'
setenv totalmem '256M'
setenv soc 'hi3536dv100'
#here we clear variables that are no longer needed
setenv da; setenv du; setenv dr; setenv dw; setenv dl; setenv dc; setenv up; setenv tk; setenv dd; setenv de; setenv jpeg_addr; setenv jpeg_size; setenv vobuf; setenv loadlogo; setenv appVideoStandard; setenv appSystemLanguage; setenv appCloudExAbility
saveenv #save the new environment of variables
printenv #check if everything is ok
```
Original env and full chip dump (16mb factory firmware backup in case of recovery) are available [here](https://github.com/OpenIPC/sandbox-fpv/tree/master/hi3536dv100/original_firmware).

As you may have noticed, the uk and ur variables store macros for flashing uImage and rootfs with loading them from the [tftp server](https://pjo2.github.io/tftpd64/), specified in the serverip variable. All addresses correspond to the bootargs variable, the contents of which specify the file system layout for the kernel during boot. The layout differs from that usual for goke/hisilicone cameras, our kernel is like lite/fpv, 2 MB in size, but the file system is 8 MB, like ultimate. The remaining ~5 MB are used by the overlay (your changes to the files relative to the original rootfs). For flashing, use the official builds from the [openipc/firmware](https://github.com/OpenIPC/firmware/releases/download/latest/openipc.hi3536dv100-nor-fpv.tgz) release page. The archive contains the kernel and file system.

So, after setting the variables, you can start flashing the rest of the firmware. Start the tftpd server, put uImage.hi3536dv100 and rootfs.squashfs.hi3536dv100 in its root, select the appropriate network interface and run the macro in the bootloader: `run uk`. A number of commands should be executed, from the output of which it should follow that the uImage file has been downloaded and flashed to the flash. Similarly, run `run ur` to flash the rootfs. If the addresses are set correctly, but the download is stuck on "Downloading", change the registrar address to a nearby free one: `setenv ipaddr '192.168.0.223'`.
If everything went without errors, do a `reset` and boot into the operating system, login root, password 12345.

The configs from the hi3536dv100 directory are not relevant, but they may be of interest regarding connecting the tablet via USB/WiFi/Ethernet hotspot, you can transfer them by analogy to the official firmware configs or format them as separate bash scripts. Usually, the essence of these changes is to determine the address of the connected tablet (which is the gateway for the recorder in cases where the tablet is a dhcp server) and specify this address in an additional instance of wfb_rx for the video stream and for telemetry streams.

The firmware update is performed via the Internet using the command `sysupgrade -r -k -n`.

<details>
  <summary>Update without Internet from /tmp</summary>
In the future, you can update the firmware of the recorder by uploading the kernel and rootfs to the directory `/tmp` via WinSCP and executing `sysupgrade --kernel=/tmp/uImage.hi3536dv100 --rootfs=/tmp/rootfs.squashfs.hi3536dv100 -z`. ​​The `-z` parameter is needed if you do not have an Internet connection (does not update the sysupgrade script), `-n` will clear the user fs (overlay).
</details>