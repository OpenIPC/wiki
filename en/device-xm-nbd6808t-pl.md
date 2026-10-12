# XiongMai NBD6808T-PL NVR (Hi3520DV200)
[Table of Content](../README.md)

An 8-channel network video recorder from XiongMai, built on the Hi3520DV200.
The PCB is marked MBD0157. It runs the `hi3520dv200` lite firmware, and its
VGA and HDMI outputs and SATA bay can be brought up under OpenIPC.

## Hardware

| System   | Description                                   |
|----------|-----------------------------------------------|
| SoC      | Hi3520DV200 (single Cortex-A9)                |
| Flash    | 8 MB SPI NOR (MX25L6406E)                     |
| Video    | VGA and HDMI outputs                          |
| Storage  | one SATA port (on-chip AHCI controller)       |
| Network  | 10/100 Ethernet                               |
| Other    | USB 2.0 host                                  |

The stock firmware identifies the board as `NBD6808T-PL` (in
`/usr/bin/ProductDefinition`). As an NVR it records and displays streams from
network cameras; the stock firmware loads no video-input driver.

## Serial console and the stock bootloader

The console runs at 115200 8N1. The stock U-Boot (2010.06) prints its banner and
the boot logo, but the stock kernel prints nothing after
`Uncompressing Linux... done, booting the kernel.`. This is normal for this
firmware and does not mean the boot failed.

The boot delay is set so low that there is effectively no window to stop it.
Holding Ctrl+C in the terminal while the board powers on drops you to the
`hisilicon #` prompt.

Several stock environment variables (`da`, `du`, `dr`, `dw`, `dl`, `dc`, `up`,
`dd`) download a file over TFTP and **write it to flash**. Do not `run` any of
them while exploring.

## Backing up the stock firmware

The stock U-Boot's `tftp` command can also **upload**: given a third argument
(a size), it sends that much RAM to the TFTP server instead of downloading.
That makes a full backup of the 8 MB flash take a few seconds. The factory
defaults are `ipaddr=192.168.1.10` and `serverip=192.168.1.1`, so a PC on
`192.168.1.1` with a TFTP server that accepts new files (e.g. `tftpd-hpa` with
`--create`) works without changing anything:

```
sf probe 0
sf read 0x82000000 0x0 0x800000
crc32 0x82000000 0x800000
tftp 0x82000000 nbd6808t-pl-stock.bin 0x800000
```

Compare the CRC32 of the uploaded file with the value `crc32` printed, and take
a second read for comparison before relying on it. See also
[backup-stock-firmware](backup-stock-firmware.md).

Stock flash layout (from the stock `bootargs`):

| Partition | Offset   | Size  | Contents                              |
|-----------|----------|-------|---------------------------------------|
| boot      | 0x000000 | 192K  | U-Boot, environment at 0x20000        |
| romfs     | 0x030000 | 1984K | squashfs root, kernel inside it       |
| usr       | 0x220000 | 3776K | squashfs, vendor application          |
| custom    | 0x5D0000 | 1664K | squashfs                              |
| logo      | 0x770000 | 64K   | cramfs, boot logo                     |
| mtd       | 0x780000 | 512K  | jffs2, settings                       |

## Trying OpenIPC without flashing

The stock U-Boot can boot the OpenIPC kernel and root filesystem from RAM, which
leaves the flash untouched. A power cycle returns to the stock firmware:

```
tftp 0x82000000 uImage.hi3520dv200
tftp 0x83000000 rootfs-initrd.img
setenv bootargs mem=128M console=ttyAMA0,115200 panic=20 root=/dev/ram0 rootfstype=squashfs ramdisk_size=16384 init=/init mtdparts=hi_sfc:8192k(stock)ro
bootm 0x82000000 0x83000000
```

`rootfs-initrd.img` is `rootfs.squashfs.hi3520dv200` wrapped as a U-Boot
ramdisk image (`mkimage -A arm -O linux -T ramdisk -C none -d rootfs.squashfs.hi3520dv200 rootfs-initrd.img`).
Marking the whole flash read-only in `mtdparts` keeps anything from writing to
it during the test.

This boots to a login prompt, with Ethernet and USB up and dropbear started.
In this mode the root filesystem is read-only, so the first-login password
prompt cannot save a password and keeps asking, and there is no way in yet.
Exploring further needs a writable overlay on the root, which `/init` only sets
up for a flash root or a read-only NFS root.

## SATA

The on-chip SATA controller and the SCSI layer it needs are not enabled in the
`hi3520dv200` kernel configuration. That also leaves out the USB mass storage
driver, so USB sticks are not detected either. With them enabled, a 2.5" SATA
disk is detected and mounted automatically.

One setting matters on this board: with the SoC's default SATA PHY value
(`CONFIG_HI_SATA_PHY_CONFIG=0x0e276756`) the link keeps dropping and resetting,
and may take minutes to come up or never come up at all. The stock XiongMai
kernel uses `0x0e262709`, and with that value the link comes up on the first
attempt. The link runs at 1.5 Gbps; the stock kernel does not use 3 Gbps
either.

Measured with a 2.5" 320 GB disk on ext4: about 64 MB/s writing and 73 MB/s
reading with `dd` and 1 MB blocks.

The kernel is 3.0, so recent `mke2fs` defaults produce an ext4 filesystem it
cannot mount. Turn off the newer features when formatting:

```
mke2fs -t ext4 -O ^metadata_csum,^metadata_csum_seed,^orphan_file /dev/sda1
```

The lite image does not include `mke2fs`, but `mkfs.vfat` is available.

## VGA and HDMI output

Both outputs work at 1920x1080 at 60 Hz under OpenIPC, driven by the vendor
media libraries the image already ships, with a picture shown through the
framebuffer (`/dev/fb0`). Things that are not obvious when writing a program
for them:

- The HDMI library is not in the image. It is a static library,
  `libhdmi.a`, in the firmware repository's `hisilicon-osdrv-hi3520dv200`
  package, and has to be linked into your program.
- `libmpi.so` uses functions from other libraries in the image without
  declaring them as dependencies, so a program linked against it alone fails
  to start under musl with `Error relocating /usr/lib/libmpi.so: ... symbol not
  found`. Link these explicitly as well: `-ljpeg6b -lresampler -laec -lanr
  -lvqev2 -lVoiceEngine -lglibc-compat`.
- The framebuffer picture disappears as soon as the last program holding
  `/dev/fb0` open exits, so a program that draws and quits shows only a
  brief flash. Keep a process holding it open.
- Set the HDMI output colour space to RGB 4:4:4. With YCbCr 4:4:4, white came
  out light green on the monitor used for testing; RGB showed every colour
  correctly. The same picture on VGA was correct either way.
