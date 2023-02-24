# OpenIPC Wiki
[Table of Content](../index.md)

Wyze integration
----------------

This is where we'll be writing down our guide to flashing new devices and reports on our experiments.

### Current issues

* Exposure does not work well https://github.com/OpenIPC/majestic/issues/102
* ~~SD card does not work in the U-Boot (power is available)~~ fixed
* Problem with loading u-boot from an microSD card. It doesn't reach the promt. Not only on wyze v3 (https://t.me/openipc_modding/179369), but also on another board T31L (https://t.me/openipc/47739). Most likely it will be IMPOSSIBLE, because in the camera there is a microSD power management MOSFET, which must be turned on BEFORE booting from the card (the experiment with not fully loaded u-boot was possible due to direct power supply to the microSD card, bypassing the transistor). Please confirm my version if it is not possible otherwise.

### Known camera modifications
* WYZE Cam v3

| MODEL | IC | FCC ID | PCB VER | SoC | WIFI | NOTES |
| --- | --- | --- | --- | --- | --- | --- |
| WYZEC3 | 25466-WYZEC3A | 2AUIUWYZEC3A | WYZEV3_T31GC2053 V1.2_20200715 | T31X | SDIO: Realtek 8189FTV | MAC: 7C:78:B2:99:6E:BA https://youtu.be/jm4wze_HY78 |
| WYZEC3 | 25466-WYZEC3 | 2AUIUWYZEC3 | WYZEV3_T31GC2053 V1.4_20201010 | T31ZX | SDIO: Realtek 8189FTV | https://t.me/openipc/49957 MAC: 7C:78:B2:69:95:C9 https://youtu.be/t7Nzo-KXTH0 |
| WYZEC3 | 25466-WYZEC3B | 2AUIUWYZEC3B | WYZEV3_T31GC2053 V2.02_20210523 | T31ZX | SDIO: Realtek 8189FTV | MAC: D0:3F:27:46:A7:7B https://t.me/openipc/38728 https://t.me/openipc/38753 |
| WYZEC3 | 25466-WYZEC3A | 2AUIUWYZEC3A | WYZEV3_T31GC2053 V2.02_20210523 | T31ZX | SDIO: AltoBeam 6031 | https://t.me/openipc/49049 https://t.me/openipc/49050 |
| WYZEC3 | 25466-WYZEC3A | 2AUIUWYZEC3A | WYZEV3_T31GC2053 V2.03_20211206 | T31X | SDIO: AltoBeam 6031 | https://t.me/openipc/45444 https://t.me/openipc/48942|
| WYZEC3 | 25466-WYZEC3F | 2AUIUWYZEC3F | WYZEV3_T31AGC2053 V3.2_20210714 | T31A BGA | SDIO: AltoBeam 6031 | https://t.me/openipc/43299 https://t.me/openipc/38755 https://t.me/openipc/38757 |
| WYZEC3 | 25466-WYZEC3F | 2AUIUWYZEC3F | WYZEV3_T31AGC2053 V3.2_20210714 | T31A BGA | SDIO: AltoBeam 6031 | MAC:D0:3F:27:4F:23:19 https://youtu.be/VkqX9yg0odU |

### OpenIPC installation
* Disassemble camera and connect UART adapter
  or your camera should be already connected to network.

* Backup

Downgrade original firmware version to (Jun 2021 w-o internet)demo_wcv3_4.36.2.5.bin 
[(WYom20200 Jun 2021 w-o internet)demo_wcv3_4.36.2.5.bin.zip](https://github.com/OpenIPC/wiki/files/10755387/WYom20200.Jun.2021.w-o.internet.demo_wcv3_4.36.2.5.bin.zip)

Login with user `root` password `WYom20200` via telnet or UART console.
Insert microSD card to camera and issue command:

`for mtd in $(ls /dev/mtdblock*); do dd if=${mtd} of=/media/mmc/${mtd##/*/}.bin; done`

Output sample:
```
[root@WCV3:~]# for mtd in $(ls /dev/mtdblock*); do dd if=${mtd} of=/media/mmc/${mtd##/*/}.bin; done
512+0 records in
512+0 records out
262144 bytes (256.0KB) copied, 0.122976 seconds, 2.0MB/s
3968+0 records in
3968+0 records out
2031616 bytes (1.9MB) copied, 0.975797 seconds, 2.0MB/s
7808+0 records in
7808+0 records out
3997696 bytes (3.8MB) copied, 1.955184 seconds, 1.9MB/s
7808+0 records in
7808+0 records out
3997696 bytes (3.8MB) copied, 2.808704 seconds, 1.4MB/s
3968+0 records in
3968+0 records out
2031616 bytes (1.9MB) copied, 0.972091 seconds, 2.0MB/s
7808+0 records in
7808+0 records out
3997696 bytes (3.8MB) copied, 2.299745 seconds, 1.7MB/s
768+0 records in
768+0 records out
393216 bytes (384.0KB) copied, 0.186963 seconds, 2.0MB/s
128+0 records in
128+0 records out
65536 bytes (64.0KB) copied, 0.027560 seconds, 2.3MB/s
```
If there wasn't errors, then you backed up such partitions:
```
[root@WCV3:~]# cat /proc/mtd 
dev:    size   erasesize  name
mtd0: 00040000 00008000 "boot"
mtd1: 001f0000 00008000 "kernel"
mtd2: 003d0000 00008000 "rootfs"
mtd3: 003d0000 00008000 "app"
mtd4: 001f0000 00008000 "kback"
mtd5: 003d0000 00008000 "aback"
mtd6: 00060000 00008000 "cfg"
mtd7: 00010000 00008000 "para"
```
Check if files on microSD card with command `ls -la /media/mmc/`

```
[root@WCV3:~]# ls -la /media/mmc/
drwxr-xr-x    7 root     root          8192 May 14 01:52 .
drwxrwxrwt    3 root     root            60 May 14 01:50 ..
-rwxr-xr-x    1 root     root        262144 May 14 01:52 mtdblock0.bin
-rwxr-xr-x    1 root     root       2031616 May 14 01:52 mtdblock1.bin
-rwxr-xr-x    1 root     root       3997696 May 14 01:52 mtdblock2.bin
-rwxr-xr-x    1 root     root       3997696 May 14 01:52 mtdblock3.bin
-rwxr-xr-x    1 root     root       2031616 May 14 01:52 mtdblock4.bin
-rwxr-xr-x    1 root     root       3997696 May 14 01:52 mtdblock5.bin
-rwxr-xr-x    1 root     root        393216 May 14 01:52 mtdblock6.bin
-rwxr-xr-x    1 root     root         65536 May 14 01:52 mtdblock7.bin
```
Save and keep this files in safe place.
In case of any errors you should perform this operation once again, probably with microSD card replacement.

* Determine SoC model

Download `ipctool-mips32` to microSD card (https://github.com/OpenIPC/ipctool/releases/download/latest/ipctool-mips32) and insert microSD card in camera.
Login to camera and issue command `/media/mmc/ipctool-mips32`
There should be something like `model: T31ZX` in console output. Important part is `ZX`
Output sample:
```
[root@WCV3:~]# /media/mmc/ipctool-mips32 
---
chip:
  vendor: Ingenic
  model: T31ZX
rom:
  - type: nor
    block: 32K
    partitions:
      - name: boot
        size: 0x40000
        sha1: 20776e92
      - name: kernel
        size: 0x1f0000
        sha1: 6887b828
      - name: rootfs
        size: 0x3d0000
        sha1: d368892a
      - name: app
        size: 0x3d0000
        path: /system,squashfs
        sha1: 04b813a8
      - name: kback
        size: 0x1f0000
        sha1: 83ccf23a
      - name: aback
        size: 0x3d0000
        sha1: 48bbe705
      - name: cfg
        size: 0x60000
        path: /configs,jffs2,rw
      - name: para
        size: 0x10000
        sha1: 472a55b0
    size: 16M
ram:
  total: 128M
  media: 32M
firmware:
  kernel: "3.10.14__isvp_swan_1.0__ (PREEMPT Wed Apr 14 17:44:51 CST 2021)"
  toolchain: gcc version 4.7.2 (Ingenic r2.3.3 2016.12) 
  libc: uClibc 0.9.33.2
  main-app: /system/bin/iCamera

```
* Flash OpenIPC U-boot

Open https://openipc.org/cameras/vendors/ingenic and choose appropriate SoC model from list.

In this case our choice Ingenic T31X.

In Downloads section find `OpenIPC Bootloader for Ingenic T31X` and download it.

https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-t31x-universal.bin

Copy `u-boot-t31x-universal.bin` to microSD card and insert microSD card in camera.

`telnet` would be unavailable after the command below (`flashcp`) !

Login to camera and issue command:
`flashcp -v /media/mmc/u-boot-t31x-universal.bin /dev/mtd0`

Output sample:
```
[root@WCV3:~]# flashcp -v /media/mmc/u-boot-t31x-universal.bin /dev/mtd0
Erasing block: 8/8 (100%) 
Writing kb: 242/242 (100%) 
Verifying kb: 242/242 (100%) 
```
Now your camera flashed with OpenIPC U-boot, but whole system is still stock. 
So, next re/boot will load OpenIPC U-boot only (in cycling mode, until stop with `Ctrl+C` in UART console).

* Flash kernel and rootfs

Since we identified our chip as Ingenic T31X open https://openipc.org/cameras/vendors/ingenic and choose T31X.

In Downloads section find `OpenIPC Linux (Lite) for Ingenic T31X` and download it.

https://github.com/OpenIPC/firmware/releases/download/latest/openipc.t31-nor-lite.tgz

Power off the camera.

Extract and copy `rootfs.squashfs.t31` `uImage.t31` to microSD card. Insert microSD card in camera. 

Power on the camera.

During power on the camera press `Ctrl+C` several times until it shows OpenIPC promt like this `OpenIPC # `

Then issue command `run setnor16m`

After you press the Enter key the camera will almost immediately restart and you will have to catch the prompt again.

Then issue command 

`mw.b ${baseaddr} ff 1000000; fatload mmc 0:1 ${baseaddr} uImage.${soc} ; sf probe 0; sf erase 0x50000 0x300000; sf write ${baseaddr} 0x50000 ${filesize}` 

and next 

`mw.b ${baseaddr} ff 1000000; fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc} ; sf probe 0; sf erase 0x350000 0xa00000; sf write ${baseaddr} 0x350000 ${filesize}`

Output sample:

```
OpenIPC # mw.b ${baseaddr} ff 1000000; fatload mmc 0:1 ${baseaddr} uImage.${soc} ; sf probe 0; sf erase 0x50000 0x300000; sf write ${baseaddr} 0x50000 ${filesize}
reading uImage.t31
1855437 bytes read in 89 ms (19.9 MiB/s)
the manufacturer 5e
SF: Detected ZB25VQ128

--->probe spend 5 ms
SF: 3145728 bytes @ 0x50000 Erased: OK
--->erase spend 9871 ms
SF: 1855437 bytes @ 0x50000 Written: OK
--->write spend 3286 ms

OpenIPC # mw.b ${baseaddr} ff 1000000; fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc} ; sf probe 0; sf erase 0x350000 0xa00000; sf write ${baseaddr} 0x350000 ${filesize}
reading rootfs.squashfs.t31
5079040 bytes read in 236 ms (20.5 MiB/s)
the manufacturer 5e
SF: Detected ZB25VQ128

--->probe spend 4 ms
SF: 10485760 bytes @ 0x350000 Erased: OK
--->erase spend 31730 ms
SF: 5079040 bytes @ 0x350000 Written: OK
--->write spend 8949 ms

```
If everything went well, issue the command `reset` and camera should start boot OpenIPC.

```
Welcome to OpenIPC
openipc-t31 login: root

    /######                                    /######  /#######    /######
   /##__  ##                                  |_  ##_/ | ##__  ##  /##__  ##
  | ##  \ ##   /######    /######   /#######    | ##   | ##  \ ## | ##  \__/
  | ##  | ##  /##__  ##  /##__  ## | ##__  ##   | ##   | #######/ | ##
  | ##  | ## | ##  \ ## | ######## | ##  \ ##   | ##   | ##____/  | ##
  | ##  | ## | ##  | ## | ##_____/ | ##  | ##   | ##   | ##       | ##    ##
  |  ######/ | #######/ |  ####### | ##  | ##  /###### | ##       |  ######/
   \______/  | ##____/   \_______/ |__/  |__/ |______/ |__/        \______/
             | ##
             | ##                              build
             |__/                             master+98e3bca7, 2023-02-11

 Please help the OpenIPC Project to cover the cost of development and
 long-term maintenance of what we believe is going to become a stable,
 flexible Open IP Network Camera Framework for users worldwide.

 Your contributions could help us to advance the development and keep
 you updated on improvements and new features more regularly.

 Please visit https://openipc.org/sponsor/ to learn more. Thank you.

root@openipc-t31:~# 

```
