# OpenIPC Wiki
[Table of Content](../index.md)

Wyze integration
----------------

This is where we'll be writing down our guide to flashing new devices and reports on our experiments.

### Current issues

* Exposure does not work well https://github.com/OpenIPC/majestic/issues/102
* SD card does not work in the U-Boot (power is available)
* Problem with loading u-boot from an microSD card. It doesn't reach the promt. Not only on wyze v3 (https://t.me/openipc_modding/179369), but also on another board T31L (https://t.me/openipc/47739). Most likely it will be IMPOSSIBLE, because in the camera there is a microSD power management MOSFET, which must be turned on BEFORE booting from the card (the experiment with not fully loaded u-boot was possible due to direct power supply to the microSD card, bypassing the transistor). Please confirm my version if it is not possible otherwise.

### Known camera modifications
* WYZE Cam v3

| MODEL | IC | FCC ID | PCB VER | SoC | WIFI | NOTES |
| --- | --- | --- | --- | --- | --- | --- |
| WYZEC3 | 25466-WYZEC3A | 2AUIUWYZEC3A | WYZEV3_T31GC2053 V1.2_20200715 | T31X | SDIO: Realtek 8189FTV | MAC: 7C:78:B2:99:6E:BA https://youtu.be/jm4wze_HY78 |
|  |  |  | WYZEV3_T31GC2053 V1.4_20201010 | T31 | SDIO: Realtek 8189FTV | MAC: 7C:78:B2:69:95:C9 https://youtu.be/t7Nzo-KXTH0 |
| WYZEC3 | 25466-WYZEC3B | 2AUIUWYZEC3B | WYZEV3_T31GC2053 V2.02_20210523 | T31ZX | SDIO: Realtek 8189FTV | https://t.me/openipc/38728 https://t.me/openipc/38753 |
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
Insert microSD card to camera
Issue commands line by line, not all together:

`dd if=/dev/mtd0 of=/media/mmc/mtd0.bin`

`dd if=/dev/mtd1 of=/media/mmc/mtd1.bin`

`dd if=/dev/mtd2 of=/media/mmc/mtd2.bin`

`dd if=/dev/mtd3 of=/media/mmc/mtd3.bin`

`dd if=/dev/mtd4 of=/media/mmc/mtd4.bin`

`dd if=/dev/mtd5 of=/media/mmc/mtd5.bin`

`dd if=/dev/mtd6 of=/media/mmc/mtd6.bin`


Output sample:
```
[root@WCV3:~]# dd if=/dev/mtd0 of=/media/mmc/mtd0.bin
512+0 records in
512+0 records out
262144 bytes (256.0KB) copied, 0.133246 seconds, 1.9MB/s
[root@WCV3:~]# dd if=/dev/mtd1 of=/media/mmc/mtd1.bin
3968+0 records in
3968+0 records out
2031616 bytes (1.9MB) copied, 1.039464 seconds, 1.9MB/s
[root@WCV3:~]# dd if=/dev/mtd2 of=/media/mmc/mtd2.bin
7808+0 records in
7808+0 records out
3997696 bytes (3.8MB) copied, 2.070890 seconds, 1.8MB/s
[root@WCV3:~]# dd if=/dev/mtd3 of=/media/mmc/mtd3.bin
7808+0 records in
7808+0 records out
3997696 bytes (3.8MB) copied, 2.459327 seconds, 1.5MB/s
[root@WCV3:~]# dd if=/dev/mtd4 of=/media/mmc/mtd4.bin
3968+0 records in
3968+0 records out
2031616 bytes (1.9MB) copied, 1.048184 seconds, 1.8MB/s
[root@WCV3:~]# dd if=/dev/mtd5 of=/media/mmc/mtd5.bin
7808+0 records in
7808+0 records out
3997696 bytes (3.8MB) copied, 2.703471 seconds, 1.4MB/s
[root@WCV3:~]# dd if=/dev/mtd6 of=/media/mmc/mtd6.bin
768+0 records in
768+0 records out
393216 bytes (384.0KB) copied, 0.201104 seconds, 1.9MB/s
[root@WCV3:~]# dd if=/dev/mtd7 of=/media/mmc/mtd7.bin
128+0 records in
128+0 records out
65536 bytes (64.0KB) copied, 0.029211 seconds, 2.1MB/s
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
So, next re/boot will load OpenIPC U-boot only (in cycling mode, until stop with `Ctrl-c` in UART console).
 
