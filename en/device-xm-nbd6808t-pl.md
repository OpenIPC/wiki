# XiongMai NBD6808T-PL NVR (Hi3520DV200)
[Table of Content](../README.md)

An 8-channel network video recorder from XiongMai, built on the Hi3520DV200.
The PCB is marked MBD0157. It runs the `hi3520dv200` lite firmware, and its
VGA and HDMI outputs and SATA bay can be brought up under OpenIPC.

## Hardware

| System   | Description                                   |
|----------|-----------------------------------------------|
| SoC      | Hi3520DV200 (single Cortex-A9)                |
| RAM      | 256 MB DDR                                    |
| Flash    | 8 MB SPI NOR (MX25L6406E)                     |
| Video    | VGA and HDMI outputs                          |
| Storage  | one SATA port (on-chip AHCI controller)       |
| Network  | 10/100 Ethernet                               |
| Other    | USB 2.0 host                                  |

The stock firmware identifies the board as `NBD6808T-PL`. As an NVR it records
and displays streams from network cameras; the stock firmware loads no
video-input driver.

The bootloader reports 256 MB of DDR to the kernel (0x80000000-0x8FFFFFFF).
OpenIPC splits it with `mem=` on the kernel command line: Linux gets that much,
and `load_hisilicon` gives the rest to the media memory zone (MMZ) that the
video hardware uses, taking the total from the `totalmem` U-Boot variable, or
256 MB when it is not set. `mem=128M`, the value OpenIPC's own U-Boot uses
(`osmem=128M`), therefore gives Linux and the MMZ 128 MB each. The stock
firmware uses `mem=132M`.

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
mw.b 0x82000000 0xff 0x800000
sf read 0x82000000 0x0 0x800000
crc32 0x82000000 0x800000
tftp 0x82000000 nbd6808t-pl-stock.bin 0x800000
```

This is the [U-Boot over TFTP](backup-stock-firmware.md#c-u-boot-over-tftp)
method with this board's values. `mw.b` fills the buffer with `0xFF` first, so
a read that silently comes up short leaves bytes that are recognisably not
flash contents instead of leftover RAM.

Before relying on the file:

- Compare its CRC32 with the value `crc32` printed.
- Take a second, independent read (fill, read and upload again under another
  name) and check that the two files are identical.
- Check that each partition in the table below starts with its filesystem's
  signature: `hsqs` at 0x30000, 0x220000 and 0x5D0000 (squashfs), the cramfs
  magic `45 3d cd 28` at 0x770000, and the jffs2 magic `85 19` at 0x780000.
  A dump that is `0xFF` where one of these should be was not read in full.

See also [Check the dump before you trust it](backup-stock-firmware.md#check-the-dump-before-you-trust-it).

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

This boots to a login prompt, with Ethernet and USB up and dropbear started, so
it proves the image runs on the board. On its own it gives no way in. The lite
image has no majestic, so there is no browser setup page. The first-login
password prompt on the serial console or over SSH cannot save a password,
because the root filesystem is read-only, so it keeps asking. `/init` only
puts a writable overlay over a flash root or a read-only NFS root.

To explore further, the initrd can be given a RAM overlay of its own. This is a
change to `/init` for testing only, not part of OpenIPC: unpack the rootfs,
patch `/init` as below, and pack it again with `mksquashfs` (xz) before wrapping
it with `mkimage`. Everything written then lives in RAM and is gone after a
power cycle.

```diff
 grep -qE 'root=[^ ]*nfs' /proc/cmdline && is_nfs_root=true
+is_ram_root=false
+grep -qE 'root=/dev/ram' /proc/cmdline && is_ram_root=true
 ...
+elif $is_ram_root; then
+	mount -t tmpfs -o mode=0755,size=16M tmpfs /overlay || exit 1
 elif $is_nfs_root && grep -q ' ro ' /proc/cmdline; then
 ...
-if $is_flash_root || $is_nfs_root; then
+if $is_flash_root || $is_nfs_root || $is_ram_root; then
```

With that, the first login sets a password, and SSH works.

## SATA

Images built before OpenIPC/firmware#2579 (merged on 13 October 2026) have
SCSI and the on-chip SATA controller turned off in the `hi3520dv200` kernel
configuration. That also leaves out the USB mass storage driver, so neither a
disk nor a USB stick is detected. Images built since then include both, and a
2.5" SATA disk is detected and mounted automatically.

One setting matters on this board: with HiSilicon's Hi3520D reference PHY
value (`CONFIG_HI_SATA_PHY_CONFIG=0x0e276756`) the link keeps dropping and
resetting, and may take minutes to come up or never come up at all. The stock
XiongMai kernel uses `0x0e262709`, which is also what #2579 sets, and with that
value the link comes up on the first attempt. The link runs at 1.5 Gbps; the
stock kernel does not use 3 Gbps either.

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
