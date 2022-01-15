# Chacon IPCAM-RI01

![device_chacon_ipcam-ri01](https://user-images.githubusercontent.com/1659543/149517176-6803cc6d-600f-4841-ac9b-69eeea23d0a6.jpg)

[Product datasheet](https://chacon.com/datasharing/doc/IPCAM-RI01/ipcam-ri01_user_manual.pdf)

This camera is a rebrand of a manufacturing company identified by "PPStrong".
I'm sure there are other cameras out there that are using the same hardware (or similar with minor changes).

## Hardware

| System | Description       |
|--------|-------------------|
| SoC    | HI3518EV300       |
| Sensor | JXF23             |
| Flash  | 16Mb (XM25QH128A) or 8Mb (XM25QH64A) |
| WiFi   | RTL8188FU         |

#### OpenIPC status

| Component | Status |
|-----------|--------|
| WiFi | [Working](https://github.com/OpenIPC/firmware/issues/48) |
| Motors | [Working](#motor-driver) (patched driver) |
| Red/Blue leds | [Working](#leds) |
| IR Led | Working |
| IR Cut | Working |


#### Hardware details

The camera mainboard is identified by "SPEED5S-H1MB_F23".

![device_chacon_ipcam-ri01_board_top](https://user-images.githubusercontent.com/1659543/149513254-d326f57f-902b-4c58-98e6-73bfe7fa33d2.jpg)
At the top of the mainboard:
- a micro sdcard slot on the right
- connector labeled "IR" powers the IR led, a red led and a blue led
- connector "ICR" powers the IR cut filter
- non-identified connector is an input for the microphone
- SPI NOR flash chip (QH128A)


![device_chacon_ipcam-ri01_board_bot](https://user-images.githubusercontent.com/1659543/149514958-1bb4c576-6190-48e1-860c-7c3ebe00b204.jpg)
At the bottom of the mainboard:
- SoC Hi3518EV300
- WiFi module RTL8188FTV
- Reset switch
- Connectors (top to bottom):
  - Power (5V from a micro usb connector)
  - Tilt/vertical stepper motor
  - Pan/horizontal stepper motor
  - Speaker
- UART pins at the lower left

### SoC
[Hi35218EV300](https://www.hisilicon.com/en/products/smart-vision/consumer-camera/IOTVision/Hi3518EV300)
- ARM Cortex-A7@ 900 MHz
- 64Mb DDR2

![device_chacon_ipcam-ri01_soc](https://user-images.githubusercontent.com/1659543/149517468-169ebcc9-76b4-4dcf-ad8c-5be2db5aafa4.jpg)


### Wifi
[RTL8188FTV](https://www.realtek.com/en/products/communications-network-ics/item/rtl8188ftv)
- 802.11b/g/n 2.4G
- USB interface

![device_chacon_ipcam-ri01_rtl8188ftv](https://user-images.githubusercontent.com/1659543/149518487-d18066b5-94fe-4b72-95f9-5ca198047bab.jpg)


### SPI NOR flash
[XM25QH128A](https://www.xmcwh.com/en/site/product_con/200)
- 16Mb SPI NOR Flash

![device_chacon_ipcam-ri01_flash](https://user-images.githubusercontent.com/1659543/149519439-7ac8f1c0-4d00-495f-94ab-82ba9c552822.jpg)


### UART pins (serial port)

![device_chacon_ipcam-ri01_uart](https://user-images.githubusercontent.com/1659543/149518771-a33ab23f-a4f0-44db-83a6-873bd1802056.jpg)



### GPIOs

| nr  | Description |
|-----|-------------|
| 0x0f (15) | irCut_1 |
| 0x0c (12) | irCut_2 |
| 0x28 (40) | IR Led |
| 0x33 (51) | Red Led |
| 0x32 (50) | Blue Led |
| 0x0d (13) | wlan power |
| 0x00 (0)  | AcShdn |
| 0x09 (9)  | Reset button |
| 0x3b (59) | Tilt motor A1 |
| 0x3a (58) | Tilt motor A2 |
| 0x39 (57) | Tilt motor B1 |
| 0x38 (56) | Tilt motor B2 |
| 0x47 (71) | Pan motor A1 |
| 0x45 (69) | Pan motor A2 |
| 0x46 (70) | Pan motor B1 |
| 0x44 (68) | Pan motor B2 |

### Mods
#### USB Serial port

There is a micro usb connector to power the camera and with some soldering this connector can be also be used for a serial to usb converter.
If you find it hard to solder the wires on the camera micro usb connector get a [micro usb breakout board](https://www.google.com/search?q=micro+usb+breakout+board&tbm=isch).

![device_chacon_ipcam-ri01_usbmod](https://user-images.githubusercontent.com/1659543/149561868-f991f75e-e766-4b71-920e-ea2918182796.jpg)

1. Get a 3.3V TTL to USB converter (using a cheap pl2303hx one)
2. Remove the USB-A connector and pins
3. Connect the camera micro usb port to the converter
4. Connect the camera uart to the converter


## Original firmware

The camera uBoot is password protected with "pps_password".

### Creating a backup
To backup the original firmware you need a usb serial adapter connected to the board and a mmc card.

uBoot commands to backup the entire flash memory on the mmc card (**mmc card contents will be destroyed**).
Depending on your camera flash memory size replace \<size1\>/\<size2\> with: (size2 = size1 / 512)
- 0x800000/0x4000 for 8M flash
- 0x1000000/0x8000 for a 16Mb flash

```
sf probe
sf read 0x40000000 0 <size1>
mmc write 0 0x40000000 0 <size2>
```

Example output (8Mb flash):
```
pps # sf probe
pps # sf read 0x40000000 0 0x800000
device 0 whole chip

SF: 8388608 bytes @ 0x0 Read: OK
pps # mmc write 0 0x40000000 0 0x4000
had init

MMC write: dev # 0, block # 0, count 16384 ... had init
16384 blocks written: OK
pps # 
```

This will write the entire flash to the mmc card in "raw mode" (no filesystem).

NOTE: if you leave the card inserted in the camera and boot the original FW it will format and backup is lost!
  
To get the dump into a file insert the card in a system running linux and:
```
dd if=/dev/mmcblk0 of=./flash_backup.bin bs=512 count=<size2>
```


### cat /proc/mtd

16Mb flash version
```
dev:    size   erasesize  name
mtd0: 00060000 00010000 "bld"     393216        0
mtd1: 00010000 00010000 "env"     65536         393216
mtd2: 00010000 00010000 "enc"     65536         458752
mtd3: 00010000 00010000 "sysflg"  65536         524288
mtd4: 00380000 00010000 "sys"     3670016       589824
mtd5: 00680000 00010000 "app"     6815744       4259840
mtd6: 00180000 00010000 "cfg"     1572864       11075584
mtd7: 00100000 00010000 "recove"  1048576       12648448
mtd8: 002d0000 00010000 "user"    2949120       13697024
mtd9: 00020000 00010000 "oeminfo" 131072        16646144 - 16777216
```

8Mb flash version
```
dev:    size   erasesize  name
mtd0: 00030000 00010000 "bld"     196608        0
mtd1: 00010000 00010000 "env"     65536         196608
mtd2: 00010000 00010000 "enc"     65536         262144
mtd3: 00010000 00010000 "sysflg"  65536         327680
mtd4: 00310000 00010000 "sys"     3211264       393216
mtd5: 00420000 00010000 "app"     4325376       3604480
mtd6: 00070000 00010000 "cfg"     458752        7929856 - 8388608
```


### dmesg
```
Booting Linux on physical CPU 0x0
Linux version 4.9.37
CPU: ARMv7 Processor [410fc075] revision 5 (ARMv7), cr=10c53c7d
CPU: div instructions available: patching division code
CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
OF: fdt:Machine model: Hisilicon HI3518EV300 DEMO Board
Memory policy: Data cache writeback
On node 0 totalpages: 9472
free_area_init_node: node 0, pgdat c0565e98, node_mem_map c24a9000
  Normal zone: 74 pages used for memmap
  Normal zone: 0 pages reserved
  Normal zone: 9472 pages, LIFO batch:1
CPU: All CPU(s) started in SVC mode.
pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
pcpu-alloc: [0] 0
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 9398
Kernel command line: mem=37M console=ttyAMA0,115200n8 mtdparts=hi_sfc:192k(bld)ro,64k(env)ro,64k(enc)ro,64k(sysflg)ro,3136k(sys),4224k(app),448k(cfg) ppsAppParts=5 ppsWatchInitEnd
PID hash table entries: 256 (order: -2, 1024 bytes)
Dentry cache hash table entries: 8192 (order: 3, 32768 bytes)
Inode-cache hash table entries: 4096 (order: 2, 16384 bytes)
Memory: 31728K/37888K available (3575K kernel code, 121K rwdata, 904K rodata, 888K init, 146K bss, 6160K reserved, 0K cma-reserved)
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
    vmalloc : 0xc2800000 - 0xff800000   ( 976 MB)
    lowmem  : 0xc0000000 - 0xc2500000   (  37 MB)
    modules : 0xbf000000 - 0xc0000000   (  16 MB)
      .text : 0xc0008000 - 0xc0386068   (3577 kB)
      .init : 0xc046a000 - 0xc0548000   ( 888 kB)
      .data : 0xc0548000 - 0xc05664e0   ( 122 kB)
       .bss : 0xc0568000 - 0xc058ca60   ( 147 kB)
SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS:16 nr_irqs:16 16
Gic dist init...
arm_arch_timer: Architected cp15 timer(s) running at 50.00MHz (phys).
clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0xb8812736b, max_idle_ns: 440795202655 ns
sched_clock: 56 bits at 50MHz, resolution 20ns, wraps every 4398046511100ns
Switching to timer-based delay loop, resolution 20ns
clocksource: arm,sp804: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 637086815595 ns
Console: colour dummy device 80x30
Calibrating delay loop (skipped), value calculated using timer frequency.. 100.00 BogoMIPS (lpj=500000)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
CPU: Testing write buffer coherency: ok
Setting up static identity map for 0x40008240 - 0x40008298
VFP support v0.3: implementor 41 architecture 2 part 30 variant 7 rev 5
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
futex hash table entries: 256 (order: -1, 3072 bytes)
pinctrl core: initialized pinctrl subsystem
NET: Registered protocol family 16
DMA: preallocated 256 KiB pool for atomic coherent allocations
Serial: AMBA PL011 UART driver
watchdo uboot init end
12040000.uart: ttyAMA0 at MMIO 0x12040000 (irq = 21, base_baud = 0) is a PL011 rev2
console [ttyAMA0] enabled
12041000.uart: ttyAMA1 at MMIO 0x12041000 (irq = 22, base_baud = 0) is a PL011 rev2
12042000.uart: ttyAMA2 at MMIO 0x12042000 (irq = 23, base_baud = 0) is a PL011 rev2
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
clocksource: Switched to clocksource arch_sys_counter
NET: Registered protocol family 2
TCP established hash table entries: 1024 (order: 0, 4096 bytes)
TCP bind hash table entries: 1024 (order: 0, 4096 bytes)
TCP: Hash tables configured (established 1024 bind 1024)
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
workingset: timestamp_bits=30 max_order=13 bucket_order=0
jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
io scheduler noop registered
io scheduler deadline registered (default)
io scheduler cfq registered
hisi-sfc hisi_spi_nor.0: SPI Nor ID Table Version 1.2
hisi-sfc hisi_spi_nor.0: The ID: 0x20 isn't in the BP table, Current device can't not protect
hisi-sfc hisi_spi_nor.0: xm25qh64a (Chipsize 8 Mbytes, Blocksize 64KiB)
7 cmdlinepart partitions found on MTD device hi_sfc
7 cmdlinepart partitions found on MTD device hi_sfc
Creating 7 MTD partitions on "hi_sfc":
0x000000000000-0x000000030000 : "bld"
0x000000030000-0x000000040000 : "env"
0x000000040000-0x000000050000 : "enc"
0x000000050000-0x000000060000 : "sysflg"
0x000000060000-0x000000370000 : "sys"
0x000000370000-0x000000790000 : "app"
0x000000790000-0x000000800000 : "cfg"
dwc3 10030000.hidwc3: Configuration mismatch. dr_mode forced to host
xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 1
xhci-hcd xhci-hcd.0.auto: hcc params 0x0220fe6c hci version 0x110 quirks 0x20010010
xhci-hcd xhci-hcd.0.auto: irq 54, io mem 0x10030000
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 1 port detected
xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 2
usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
hub 2-0:1.0: USB hub found
hub 2-0:1.0: hub can't support USB3.0
i2c /dev entries driver
hibvt-i2c 12060000.i2c: hibvt-i2c0@100000hz registered
hibvt-i2c 12061000.i2c: hibvt-i2c1@100000hz registered
hibvt-i2c 12062000.i2c: hibvt-i2c2@100000hz registered
sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
sdhci-pltfm: SDHCI platform and OF driver helper
mmc0: SDHCI controller on 10010000.sdhci [10010000.sdhci] using ADMA in legacy mode
mmc1: SDHCI controller on 10020000.sdhci [10020000.sdhci] using ADMA in legacy mode
Initializing XFRM netlink socket
NET: Registered protocol family 17
NET: Registered protocol family 15
Key type dns_resolver registered
PM: Hibernation image not present or could not be loaded.
uart-pl011 12040000.uart: no DMA platform data
Freeing unused kernel memory: 888K (c046a000 - c0548000)
This architecture does not have kernel memory protection.
random: S80network: uninitialized urandom read (4 bytes read)
Strnio: loading out-of-tree module taints kernel.
pcbversion:,S4S_H1_V10
pcb____S4S_H1_V10
sensor:,soif23mipi
pcbname:,S5S_H1_V10_F23
factoryname:,PPSTRONG
platform:,C5
viewmirrow:,vertical_horizontal
mem:,37
flash:,8
mmz:,27
 ###cfg gpio OK name:redLed
 cfg gpio err name:syncRedLed
 cfg gpio err name:syncBlueLed
==============led init finished
 ###cfg gpio OK name:irRed
 ###cfg gpio OK name:irCut_1
 ###cfg gpio OK name:irCut_2
 ###cfg gpio OK name:Restbutton
 cfg gpio err name:doorbell_key
 ###cfg gpio OK name:wlanPwr
 cfg gpio err name:4GPwr
wlanPwr,open pwr
 ###cfg gpio OK name:AcShdn
AcShdn,close pwr
 cfg gpio err name:MicShdn
 cfg gpio err name:4GPowOn
 cfg gpio err name:4GCheck
 cfg gpio err name:4GReset
 cfg gpio err name:Uart1Rxd
 cfg gpio err name:Uart1Txd
 cfg gpio err name:GarageDoorOpen
 cfg gpio err name:GarageDoorClose
 cfg gpio err name:GarageDoorStop
 ###cfg gpio OK name:si7020_SDA
 ###cfg gpio OK name:si7020_SCL
usb 1-1: new high-speed USB device number 2 using xhci-hcd
 ###cfg gpio OK name:4wir_Tain1
 ###cfg gpio OK name:4wir_Tain2
 ###cfg gpio OK name:4wir_Tbin1
 ###cfg gpio OK name:4wir_Tbin2
 cfg gpio err name:motor_shared
 ###cfg gpio OK name:4wir_Pain1
 ###cfg gpio OK name:4wir_Pain2
 ###cfg gpio OK name:4wir_Pbin1
 ###cfg gpio OK name:4wir_Pbin2
 rtw_pps_set_runsta ok
USB_SPEED_HIGH
random: fast init done
usbcore: registered new interface driver rtl8188fu
======online_flag = 0, cmos_yuv_flag = 0, sensor=soif23mipi, chip=hi3518ev300, board=meari======
meari init success!
Module himedia: init ok
Hisilicon Media Memory Zone Manager
hi_osal 1.0 init success!
hi3516ev200_base: module license 'Proprietary' taints kernel.
Disabling lock debugging due to kernel taint
load sys.ko for Hi3516EV200...OK!
load tde.ko for HI3516EV200...OK!
load region.ko for Hi3516EV200...OK!
load vgs.ko for Hi3516EV200...OK!
load vi.ko for Hi3516EV200...OK !
ISP Mod init!
load vpss.ko for Hi3516EV200...OK!
load rc.ko for Hi3516EV200...OK!
load venc.ko for Hi3516EV200...OK!
load chnl.ko for Hi3516EV200...OK!
load vedu.ko for Hi3516EV200...OK!
load h264e.ko for Hi3516EV200...OK!
load h265e.ko for Hi3516EV200...OK!
load jpege.ko for Hi3516EV200...OK!
load ive.ko for Hi3516EV200...OK!
load mipi_rx driver successful!
close app check
 ###cfg gpio OK name:blueLed
 Strnio_ioctl
 recfgcodec
start recfgcodec
 0xCC----ff031a00
 0xCC----aa031a00
packets in tx buffer - 0x204=e9000c, 0x200=e9000c
sys irq:30
 cfg gpio err name:PirInput
____set essid
____set essid
```

### Starting telnetd

The camera original FW runs a REST server with authentication (user: PpStRoNg, password: #%&wL1@\*tU123zv).

One of the most interesting features is the "runcmd" function (replace \<your_cam_ip\> with your camera IP address):

Send request (note the \\ escaping the & for the password):
```
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://\<your_cam_ip\>:80/devices/runcmd --request POST --data '{"cmd":"ls"}'
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 0
```

Get output (json format):
```
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://\<your_cam_ip\>:80/devices/runcmd
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 129
{
        "value":        "usr\nsys\netc\nmnt\nlib\nproc\nboot\nopt\nlinuxrc\nbin\ndev\ninit\nhome\nsbin\nnfsroot\nroot\ntmp\nvar\ndevinfo\n"
}
```

In the latest FW they have removed the "telnetd" binary so you need to place it on the sdcard:
[telnetd.zip](https://github.com/ljalves/wiki/files/7875319/telnetd.zip)


To start the server copy the telnetd binary to the sdcard and run:
```
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://\<your_cam_ip\>:80/devices/runcmd --request POST --data '{"cmd":"echo 'anyone::0:0:root:/:/bin/sh' >> /etc/passwd"}'
curl -u PpStRoNg:#%\&wL1@*tU123zv -i http://\<your_cam_ip\>:80/devices/runcmd --request POST --data '{"cmd":"/mnt/mmc01/telnetd &"}'
```

At this point you should be able to telnet to the camera:
```
$ telnet \<your_cam_ip\>
Trying \<your_cam_ip\>...
Connected to \<your_cam_ip\>.
Escape character is '^]'.
(none) login: anyone


BusyBox v1.26.2 (2019-04-16 05:35:27 PDT) built-in shell (ash)

/ #
```


### [ipctool](https://github.com/OpenIPC/ipctool) output (8Mb flash output):

```
/mnt/mmc01 # ./ipctool
---
chip:
  vendor: HiSilicon
  model: 3518EV300
  id: 022c40074e0038f1ee70030a0d73b5d32549ab0c81a025e3
mdio busy
mdio busy
ethernet:
  mac: "c4:3a:35:75:bf:71"
  u-mdio-phyaddr: 0
  phy-id: 0x00000000
  d-mdio-phyaddr: 0
rom:
  - type: nor
    block: 64K
    partitions:
      - name: sys
        size: 0x310000
        sha1: c890f4a1
      - name: app
        size: 0x420000
        sha1: 32c12243
      - name: cfg
        size: 0x70000
        path: /home/cfg,jffs2,rw
    size: 7M
    addr-mode: 3-byte
ram:
  total: 64M
  media: 27M
firmware:
  kernel: "4.9.37 (Mon Jul 22 00:51:54 PDT 2019)"
  libc: uClibc 0.9.33.2
  sdk: "Hi3516EV200_MPP_V1.0.1.0 B050 Release (May  9 2019, 22:51:50)"
  main-app: ./ppsapp
sensors:
- vendor: Silicon Optronics
  model: JXF23
  control:
    bus: 0
    type: i2c
    addr: 0x80
  data:
    type: MIPI
    input-data-type: DATA_TYPE_RAW_10BIT
    lane-id:
    - 0
    - 1
    image: 1920x1080
  clock: 27MHz
/mnt/mmc01 #
```


## OpenIPC firmware

## Flashing OpenIPC
(soon...)

#### Boot dump
```
Uncompress Ok!

U-Boot 2016.11-g059901b-dirty (Oct 13 2021 - 20:14:30 +0300)hi3518ev300

Relocation Offset is: 0374a000
Relocating to 43f4a000, new gd at 43f09ef0, sp at 43f09ed0
SPI Nor:  hifmc_ip_ver_check(44): Check Flash Memory Controller v100 ...hifmc_ip_ver_check(50):  Found
hifmc_spi_nor_probe(1709): SPI Nor ID Table Version 1.0
hifmc_spi_nor_probe(1734): SPI Nor(cs 0) ID: 0x20 0x70 0x18
hifmc_spi_nor_probe(1799): Block:64KB hifmc_spi_nor_probe(1800): Chip:16MB hifmc_spi_nor_probe(1801): Name:"XM25QH128A"
hifmc100_spi_nor_probe(147): SPI Nor total size: 16MB
NAND:  0 MiB
MMC:   hisi-sdhci: 0 (SD)
In:    serial
Out:   serial
Err:   serial
Net:   eth0
Warning: eth0 (eth0) using random MAC address - 6e:9f:f3:d7:33:35

Hit any key to stop autoboot:  0
device 0 offset 0x50000, size 0x200000

SF: 2097152 bytes @ 0x50000 Read: OK
## Booting kernel from Legacy Image at 42000000 ...
   Image Name:   Linux-4.9.37-hi3518ev300
   Image Type:   ARM Linux Kernel Image (uncompressed)
   Data Size:    1891696 Bytes = 1.8 MiB
   Load Address: 40008000
   Entry Point:  40008000
   Loading Kernel Image ... OK

Starting kernel ...

Booting Linux on physical CPU 0x0
Linux version 4.9.37 (runner@fv-az241-255) (gcc version 7.5.0 (Buildroot -g29dde73) ) #1 Sun Jan 9 03:44:04 UTC 2022
CPU: ARMv7 Processor [410fc075] revision 5 (ARMv7), cr=10c53c7d
CPU: div instructions available: patching division code
CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
OF: fdt:Machine model: Hisilicon HI3518EV300 DEMO Board
cmz zone is not set!
Memory policy: Data cache writeback
CPU: All CPU(s) started in SVC mode.
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 8128
Kernel command line: mem=32M console=ttyAMA0,115200 panic=20 rootfstype=squashfs root=/dev/mtdblock3 init=/init mtdparts=hi_sfc:256k(boot),64k(env),2048k(kernel
),5120k(rootfs),-(rootfs_data) mmz_allocator=hisi
PID hash table entries: 128 (order: -3, 512 bytes)
Dentry cache hash table entries: 4096 (order: 2, 16384 bytes)
Inode-cache hash table entries: 2048 (order: 1, 8192 bytes)
Memory: 27104K/32768K available (3861K kernel code, 141K rwdata, 872K rodata, 188K init, 179K bss, 5664K reserved, 0K cma-reserved)
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
    vmalloc : 0xc2800000 - 0xff800000   ( 976 MB)
    lowmem  : 0xc0000000 - 0xc2000000   (  32 MB)
    modules : 0xbf000000 - 0xc0000000   (  16 MB)
      .text : 0xc0008000 - 0xc03cd778   (3862 kB)
      .init : 0xc04a9000 - 0xc04d8000   ( 188 kB)
      .data : 0xc04d8000 - 0xc04fb520   ( 142 kB)
       .bss : 0xc04fd000 - 0xc0529fe4   ( 180 kB)
SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS:16 nr_irqs:16 16
Gic dist init...
arm_arch_timer: Architected cp15 timer(s) running at 50.00MHz (phys).
clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0xb8812736b, max_idle_ns: 440795202655 ns
sched_clock: 56 bits at 50MHz, resolution 20ns, wraps every 4398046511100ns
Switching to timer-based delay loop, resolution 20ns
clocksource: arm,sp804: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 637086815595 ns
Console: colour dummy device 80x30
Calibrating delay loop (skipped), value calculated using timer frequency.. 100.00 BogoMIPS (lpj=500000)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
CPU: Testing write buffer coherency: ok
Setting up static identity map for 0x40008200 - 0x40008258
devtmpfs: initialized
VFP support v0.3: implementor 41 architecture 2 part 30 variant 7 rev 5
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
futex hash table entries: 256 (order: -1, 3072 bytes)
pinctrl core: initialized pinctrl subsystem
NET: Registered protocol family 16
DMA: preallocated 256 KiB pool for atomic coherent allocations
Serial: AMBA PL011 UART driver
12040000.uart: ttyAMA0 at MMIO 0x12040000 (irq = 21, base_baud = 0) is a PL011 rev2
console [ttyAMA0] enabled
12041000.uart: ttyAMA1 at MMIO 0x12041000 (irq = 22, base_baud = 0) is a PL011 rev2                                                                             
ssp-pl022 12070000.spi: ARM PL022 driver, device ID: 0x00800022
ssp-pl022 12070000.spi: mapped registers from 0x12070000 to c286b000
ssp-pl022 12071000.spi: ARM PL022 driver, device ID: 0x00800022
ssp-pl022 12071000.spi: mapped registers from 0x12071000 to c286f000
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
clocksource: Switched to clocksource arch_sys_counter
NET: Registered protocol family 2
TCP established hash table entries: 1024 (order: 0, 4096 bytes)
TCP bind hash table entries: 1024 (order: 0, 4096 bytes)
TCP: Hash tables configured (established 1024 bind 1024)
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
workingset: timestamp_bits=30 max_order=13 bucket_order=0
squashfs: version 4.0 (2009/01/31) Phillip Lougher
jffs2: version 2.2 (NAND) (ZLIB) (RTIME) (c) 2001-2006 Red Hat, Inc.
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler deadline registered (default)
pl061_gpio 120b0000.gpio_chip: PL061 GPIO chip @0x120b0000 registered
pl061_gpio 120b1000.gpio_chip: PL061 GPIO chip @0x120b1000 registered
pl061_gpio 120b2000.gpio_chip: PL061 GPIO chip @0x120b2000 registered
pl061_gpio 120b4000.gpio_chip: PL061 GPIO chip @0x120b4000 registered
pl061_gpio 120b5000.gpio_chip: PL061 GPIO chip @0x120b5000 registered
pl061_gpio 120b6000.gpio_chip: PL061 GPIO chip @0x120b6000 registered
pl061_gpio 120b7000.gpio_chip: PL061 GPIO chip @0x120b7000 registered
pl061_gpio 120b8000.gpio_chip: PL061 GPIO chip @0x120b8000 registered
brd: module loaded
loop: module loaded
hisi-sfc hisi_spi_nor.0: SPI Nor ID Table Version 1.2
hisi-sfc hisi_spi_nor.0: The ID: 0x20 isn't in the BP table, Current device can't not protect
@spi_nor_scan(), no "m25p,fast-read".
@spi_nor_scan(), modes->rd_modes:0xd.
hisi-sfc hisi_spi_nor.0: (Fast) Read:  opcode=BBh, protocol=122, mode=0, wait=8
hisi-sfc hisi_spi_nor.0: nor->read_opcode[3: Read; 0B: Fast Read; 3B: Dual; BB: Dual IO; 6B: Quad; EB: Quad IO]: 0xbb.
hisi-sfc hisi_spi_nor.0: xm25qh128a (Chipsize 16 Mbytes, Blocksize 64KiB)
5 cmdlinepart partitions found on MTD device hi_sfc
5 cmdlinepart partitions found on MTD device hi_sfc
Creating 5 MTD partitions on "hi_sfc":
0x000000000000-0x000000040000 : "boot"
0x000000040000-0x000000050000 : "env"
0x000000050000-0x000000250000 : "kernel"
0x000000250000-0x000000750000 : "rootfs"
0x000000750000-0x000001000000 : "rootfs_data"
SPI Nand ID Table Version 2.7
Cannot found a valid SPI Nand Device
hisi_spi_nand_probe(175): Error: driver probe, result: -19
No OTP data, festa PHY use default ATE parameters!
festa PHY wait autotrim done timeout!
libphy: hisi_femac_mii_bus: probed
libphy: Fixed MDIO Bus: probed
hisi-femac 10040000.ethernet: connect to PHY failed!
xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 1
xhci-hcd xhci-hcd.0.auto: hcc params 0x0220fe6c hci version 0x110 quirks 0x20010010
xhci-hcd xhci-hcd.0.auto: irq 116, io mem 0x10030000
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 1 port detected
xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 2
usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
hub 2-0:1.0: USB hub found
hub 2-0:1.0: hub can't support USB3.0
hibvt_rtc 120e0000.rtc: rtc core: registered 120e0000.rtc as rtc0
hibvt_rtc 120e0000.rtc: RTC driver for hibvt enabled
i2c /dev entries driver
hibvt-i2c 12060000.i2c: hibvt-i2c0@100000hz registered
hibvt-i2c 12061000.i2c: hibvt-i2c1@100000hz registered
hibvt-i2c 12062000.i2c: hibvt-i2c2@100000hz registered
sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
sdhci-pltfm: SDHCI platform and OF driver helper
mmc0: SDHCI controller on 10010000.sdhci [10010000.sdhci] using ADMA in legacy mode
mmc1: SDHCI controller on 10020000.sdhci [10020000.sdhci] using ADMA in legacy mode
NET: Registered protocol family 10
NET: Registered protocol family 17
hibvt_rtc 120e0000.rtc: setting system clock to 1970-01-01 00:00:00 UTC (0)
VFS: Mounted root (squashfs filesystem) readonly on device 31:3.
devtmpfs: mounted
Freeing unused kernel memory: 188K (c04a9000 - c04d8000)
This architecture does not have kernel memory protection.
mmc0: new high speed SDHC card at address 1234
mmcblk0: mmc0:1234 SA08G 7.21 GiB
 mmcblk0: p1
Starting syslogd: OK
Starting klogd: OK
Running sysctl: OK
Loading modules:Initializing random number generator: OK
Saving random seed: OK
Starting rngd: OK
Starting mdev...
F2FS-fs (mmcblk0p1): Can't find valid F2FS filesystem in 1th superblock
F2FS-fs (mmcblk0p1): Can't find valid F2FS filesystem in 2th superblock
F2FS-fs (mmcblk0p1): Can't find valid F2FS filesystem in 1th superblock
F2FS-fs (mmcblk0p1): Can't find valid F2FS filesystem in 2th superblock
Starting network: OK
Starting ntpd: OK
Starting dropbear sshd: OK
Starting httpd: OK
Starting mini-snmpd: DISABLED, OK
Starting telnetd: DISABLED, OK
Starting crond: OK
mmz_start: 0x42000000, mmz_size: 32M
hisilicon: Get data from environment and set SENSOR as jxf23
insert audio
Bringing wlan0 up...
Successfully initialized wpa_supplicant
rfkill: Cannot open RFKILL control device
udhcpc: started, v1.31.1
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending select for 192.168.1.112
udhcpc: lease of 192.168.1.112 obtained, lease time 86400
deleting routers
adding dns 8.8.8.8
adding dns 8.8.4.4
hisilicon: Check MAC for Xiongmai devices
hisilicon: The eth0 interface has a correct MAC - 
hisilicon: Loading of kernel modules and initialization of the video system has started
Starting majestic: OK

Welcome to OpenIPC v2.1
openipc-hi3518ev300 login: 
```


(soon...)

### rtl8188fu
(soon...)

### Motor driver

The camera has 2 stepper motors to control the tilt (up/down) and pan (left/right).

Replace the motor driver at /lib/modules/4.9.37/hisilicon/camhi-motor.ko with the one included below.

The .zip file also includes a slightly modified build of the [sample control code](https://github.com/OpenIPC/motors) that you can copy to /bin.

[camhi-motor.zip](https://github.com/ljalves/wiki/files/7873614/camhi-motor.zip)

Usage:
```
motor_ctrl -d u        # move/tile up (by default 20 steps)
motor_ctrl -d d        # move/tilt down
motor_ctrl -d l        # move/pan left
motor_ctrl -d r -s 50  # move/pan right by 50 steps
```

### Majestic sensor/pin configuration

```
image:
  mirror: true
  flip: true
(...)
nightMode:
  irCutPin1: 15
  irCutPin2: 12
  backlightPin: 40

```

### LEDs
The camera has a dual color led (red/blue) connected to gpio's 50 and 51.
To control those leds you can use the /sys api:
```
# make the gpios accessible
echo 50 > /sys/class/gpio/export
# and set direction (only need to do once)
echo out > /sys/class/gpio50/direction
echo out > /sys/class/gpio51/direction

# turn on blue led
echo 1 > /sys/class/gpio50/value
# turn off blue led
echo 0 > /sys/class/gpio50/value

# turn on red led
echo 1 > /sys/class/gpio51/value
# turn off red led
echo 0 > /sys/class/gpio51/value
```

