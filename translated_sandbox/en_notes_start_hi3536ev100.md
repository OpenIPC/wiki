### Notes on NVR hi3536ev100 firmware on OpenIPC for FPV purposes
[RU](notes_start_hi3536ev100.md)

<details>
  <summary>How memory works</summary>
To begin with, you need to figure out how the memory of the recorder (and the camera too) works and what needs to be flashed. Data is stored on spi-flash 16mb in the form of mtd blocks:

```
cat /proc/cmdline
mem=150M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),8192k(rootfs),-(rootfs_data)
ls /dev/mtdb*
/dev/mtdblock0  /dev/mtdblock1  /dev/mtdblock2  /dev/mtdblock3  /dev/mtdblock4
```
As follows from the output, block zero is the u-boot bootloader; Next comes a block for storing environment variables (`printenv`, `setenv` commands are written to RAM, and `saveenv` saves it in this block); next is the uImage core; then rootfs.squashfs (immutable file system image); and finally rootfs_data or also overlay - a changeable part where differences from rootfs are written if you change any files. Thus, by clearing the overlay, we will reset the file system to default:
```
sf probe 0 #select a device
sf erase 0xA50000 0x500000 #we clean
reset #reboot nvr
```
It's even easier to reset the firmware to factory defaults using the `firstboot` command.

An address calculator for commands is available [here](https://openipc.org/tools/firmware-partitions-calculation). In our case, the rootfs partition: 8192kB, which means the start address of the overlay will be 0xA50000. For a camera with a flash of 8mB and a rootfs size of 5120kB, the addresses will be different, including environment variables!
</details>

The bootloader of this recorder does not have a password, and you can access it via uart/115200 baud by pressing Ctrl+C several times at startup while connected to the debug-uart port of the recorder via a usb-uart 3v3 adapter (ftdi, ch340). Debug uart is located opposite the VGA connector on the opposite edge of the board and is labeled gnd/tx/rx. We don't need to flash the bootloader, we don't need burn. Our ENVs (environment variables) are different from the factory ones, but they are easier to install directly from the bootloader line by line:
```
setenv ipaddr '192.168.0.222' #here is the ip in your subnet from the free ones
setenv serverip '192.168.0.107' #PC address with tftp server
setenv netmask '255.255.255.0'
setenv bootcmd 'sf probe 0; sf read 0x82000000 0x50000 0x200000; bootm 0x82000000'
setenv uk 'mw.b 0x82000000 ff 1000000;tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x82000000 ff 1000000;tftp 0x82000000 rootfs.squashfs.${soc}; sf probe 0; sf erase 0x250000 0x800000; sf write 0x82000000 0x250000 ${filesize}'
setenv bootargs 'mem=192M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel),8192k(rootfs) ,-(rootfs_data)'
setenv osmem '192M'
setenv totalmem '256M'
setenv soc 'hi3536dv100'
#here we clear variables that are no longer needed
setenvda; setenv du; setenv dr; setenv dw; setenv dl; setenv dc; setenv up; setenv tk; setenvdd; setenv de; setenv jpeg_addr; setenv jpeg_size; setenv vobuf; setenv loadlogo; setenv appVideoStandard; setenv appSystemLanguage; setenv appCloudExAbility
saveenv #save the new variable environment
printenv #see if everything is ok
```
The original env and full dump of the chip (16mb backup of factory firmware in case of recovery) are available [here](https://github.com/OpenIPC/sandbox-fpv/tree/master/hi3536dv100/original_firmware).

As you may have noticed, the uk and ur variables store macros for the uImage and rootfs downloading them from [tftp server](https://pjo2.github.io/tftpd64/) specified in serverip variable. All addresses correspond to the bootargs variable, the contents of which specify the file system layout for the kernel at boot. The layout is different from the usual for goke/hisilicone cameras, our core is the same as lite/fpv, 2MB in size, but the file system is 8MB in size, like ultimate. The remaining ~5MB are used by the overlay (your changes to the files relative to the original rootfs). For firmware, use official builds from the releases page [openipc/firmware](https://github.com/OpenIPC/firmware/releases/download/latest/openipc.hi3536dv100-nor-fpv.tgz). The archive contains the kernel and file system.

So, after setting the variables, you can start flashing the remaining part. Start the tftpd server, put uImage.hi3536dv100 and rootfs.squashfs.hi3536dv100 in its root, select the appropriate network interface and run the macro in the bootloader: `run uk`. A series of commands must be executed, the output of which should indicate that the uImage file has been downloaded and flashed into flash. Similarly, run `run ur` to flash rootfs. If the addresses are set correctly, but the download is stuck at "Downloading", change the registrar address to a nearby free one: `setenv ipaddr '192.168.0.223'`.
If everything went without errors, do a `reset` and boot into the operating system, login root, password 12345.

The configs from the hi3536dv100 catalog are not relevant, but they may be of interest regarding connecting the tablet via usb/wifi/ethernet hotspot; you can transfer them, by analogy, to the configs of the official firmware or use separate bash scripts. Usually the essence of these changes is to determine the address of the connected tablet (which is the gateway for the registrar in cases where the tablet has a dhcp server) and specifying this address in an additional instance of wfb_rx for the video stream and for telemetry streams.

The firmware is updated via the Internet using the command `sysupgrade -r -k -n`.

<details>
   <summary>Update without internet from /tmp</summary>
In the future, you can update the recorder's firmware by uploading the kernel and rootfs into the `/tmp` directory via WinSCP and running `sysupgrade --kernel=/tmp/uImage.hi3536dv100 --rootfs=/tmp/rootfs.squashfs.hi3536dv100 -z` . The `-z` parameter is needed if you do not have an Internet connection (does not update the sysupgrade script), `-n` will clear the user fs (overlay).
</details>
