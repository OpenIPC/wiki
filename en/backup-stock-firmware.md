# Backing up your stock firmware
[Table of Content](../README.md)

Take a full copy of the flash chip **before** you write anything to it. Not a
copy of the partitions you think matter — the whole chip, first byte to last.

This is the step people skip, and the issue tracker is where they end up. A
camera whose bootloader has been overwritten shows no link light and no serial
output, and without a dump there is nothing to put back: the MAC address, the
per-device calibration and the vendor bootloader that knows how to bring the
board up all lived in flash and nowhere else. With a dump, almost every one of
those cameras is recoverable.

A dump is worth keeping even if the install goes perfectly. It carries the
sensor driver and its register tables, the partition layout and the board's own
identity, and those are what let someone add support for a board later — long
after the camera itself has been reflashed or thrown away.

Pick the first route below that your camera allows. They all produce the same
thing: one binary file the size of the flash chip.

## Which route

| Your situation | Route |
| --- | --- |
| Stock firmware runs and you have a shell on it | [A, from the running system](#a-from-the-running-system) |
| You have OpenIPC's `ipctool` on it | [B, ipctool](#b-with-ipctool) |
| Bootloader console, and the camera is on the network | [C, U-Boot over TFTP](#c-u-boot-over-tftp) |
| Bootloader console, no working network | [D, U-Boot to an SD card](#d-u-boot-to-an-sd-card), or [E, over the serial line](#e-u-boot-over-the-serial-line) |
| No console at all, or the camera is already dead | [F, an external programmer](#f-an-external-programmer) |

## A. From the running system

If you can get a shell on the stock firmware, this is the least risky route —
nothing is written anywhere near the flash.

Every `mtdblock` device concatenated in order is the whole chip:

```bash
cat /dev/mtdblock* > /path/to/somewhere/fulldump.bin
```

The awkward part is *somewhere*. The camera's own filesystems are far too small,
so the destination has to be off-box — an SD card if the camera has a slot, or
an NFS share:

```bash
fw=$(mktemp -t)
nfs=$(dirname $fw)/nfs
mkdir -p $nfs
mount -t nfs -o tcp,nolock 192.168.1.123:/path/to/nfs/share $nfs
cat /dev/mtdblock? > $fw
mv $fw ${nfs}/fulldump.bin
```

Record the layout as well, because the dump alone does not say where the
partitions began:

```bash
cat /proc/mtd
```

> Note that `/dev/mtdblock?` with a single `?` only matches the first ten
> partitions. Use `*` if `cat /proc/mtd` shows more.

## B. With ipctool

[ipctool](https://github.com/OpenIPC/ipctool) can take the backup itself, with
the hardware metadata recorded alongside it:

```console
# ipctool backup /path/to/mybackup-00:12:17:83:d6:39
# sync
```

It can also push the backup to OpenIPC's storage, keyed on the camera's MAC
address, and fetch it back later:

```console
# ipctool upload
# ipctool restore                 # by MAC, from the cloud
# ipctool restore <filename>      # from a local file
```

Keep a local copy regardless. A backup you cannot reach without a working
network is not a recovery plan.

See [Run ipctool](example-ipctool.md) for getting the binary onto a camera,
including onto stock firmware that has no package manager.

## C. U-Boot over TFTP

First [prepare the environment](help-uboot.md#prepare-the-environment) —
`baseaddr` depends on where DRAM starts on your SoC, and the wrong value gives
`data abort` and a reset.

Set up a [TFTP server](installation-tftpd.md), then, in the bootloader console:

```shell
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
sf probe 0
mw.b ${baseaddr} 0xff ${flashsize}
sf read ${baseaddr} 0x0 ${flashsize}
tftp ${baseaddr} fulldump.bin ${flashsize}
```

`mw.b` fills the buffer with `0xFF` first. That is not decoration: if `sf read`
silently comes up short, a byte that is still `0xFF` is recognisably *not* flash
contents, whereas whatever happened to be in RAM is not.

Some bootloaders spell the upload `tftpput` instead:

```shell
sf read 0x42000000 0x0 0x800000
tftpput 0x42000000 0x800000 backup.bin
```

> **The three-argument trap.** On HiSilicon's combined `tftp`, the three-argument
> form `tftp <addr> <file> <len>` is an **upload** — which is exactly what the
> backup command above needs. Two arguments is a download. Carry the
> three-argument shape over to the *flashing* step by habit and U-Boot sends
> your RAM buffer to the TFTP server and writes nothing to the camera, leaving
> you convinced the image is installed when it is not. Check the file on the
> server afterwards: if it is all `0xFF`, that is what happened.

## D. U-Boot to an SD card

For a camera with an SD slot but no usable network from the bootloader. This
writes to raw card blocks, past the partition table, so use a card you do not
mind clearing — and offset the start so a PC can still read the card afterwards.

First [prepare the environment](help-uboot.md#prepare-the-environment), then
erase room for the image. Blocks are 512 bytes, so 8 MB is `0x4000` blocks and
16 MB is `0x8000`:

```shell
mmc dev 0
mmc erase 0x10 0x4000
```

Read the flash into RAM and write it out to the card:

```shell
mw.b ${baseaddr} ff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
mmc write ${baseaddr} 0x10 0x4000
```

Then, with the card in a Linux PC — `skip=16` steps over the 8 KB offset:

```bash
sudo dd bs=512 skip=16 count=16384 if=/dev/sdc of=./fulldump.bin
```

Use `count=32768` for a 16 MB chip. Check `lsblk` for the right device before
running that; `/dev/sdc` is an example, not an answer.

## E. U-Boot over the serial line

The last resort when there is no network and no card slot. It works on anything
with a console, and it is slow — hours, and a log file roughly five times the
size of the chip.

Start your terminal program with logging on:

```bash
screen -L -Logfile fulldump.log /dev/ttyUSB0 115200
```

Then dump the flash to the console as hex:

```shell
mw.b ${baseaddr} 0xff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
md.b ${baseaddr} ${flashsize}
```

Detach the session (`Ctrl-a` then `d`) so a stray keystroke cannot corrupt the
output, and reattach with `screen -r` once the log file stops growing. An 8 MB
chip gives roughly a 40 MB log.

Turn the log back into a binary:

```bash
cat fulldump.log | sed -E "s/^[0-9a-f]{8}\b: //i" | sed -E "s/ {4}.{16}\r?$//" > fulldump.hex
xxd -revert -plain fulldump.hex fulldump.bin
```

## F. An external programmer

If the camera will not boot at all, or you would rather not trust its own
bootloader, read the chip directly with a CH341A and a SOIC-8 clip. This also
works on a camera that is already bricked, which is the one case where every
other route is closed.

See [Equipment for flashing](equipment-flashing.md) for what to buy,
[CH341A programmer voltage fix](hardware-programmer-ch341a-voltage-fix.md)
before you connect one to a 3.3 V camera, and
[Flash Chip Interfacing](flash-chip-interfacing.md) for the reading itself.

For SigmaStar parts, [Sigmastar unbrick](sigmastar-unbrick.md) covers the
CH341A-as-UART wiring those need instead.

## Check the dump before you trust it

A truncated or all-`0xFF` dump looks like a file and is worth nothing. Three
quick checks:

**The size is exactly the chip size** — 8388608 bytes for 8 MB, 16777216 for
16 MB. Not approximately.

```bash
ls -l fulldump.bin
```

**It is not mostly padding.** A real image compresses, but not to nothing; a
dump that shrinks to a few kilobytes was never read.

```bash
gzip -c fulldump.bin | wc -c
```

**The MAC address is in there.** If this prints your camera's MAC, the
bootloader environment survived the trip:

```bash
strings fulldump.bin | grep ^ethaddr
```

[binwalk](https://github.com/ReFirmLabs/binwalk) will unpack the rest and is the
fastest way to confirm a kernel and a root filesystem are really present.

## Keeping it, and sharing it

Store the file somewhere that is not the camera and not the SD card that is
going back into the camera. Name it for the board, not for the day —
`fulldump.bin` on its own tells you nothing in a year's time.

If you are reporting a board OpenIPC does not support yet, the dump is the most
useful thing in the report. Attach it to the
[new board or SoC issue form](https://github.com/OpenIPC/firmware/issues/new/choose):

- **Compress it first.** `.bin` is not an accepted attachment type; `.zip`,
  `.gz` and `.tar.gz` are.
- The limit is **25 MB**, which an 8 or 16 MB NOR image fits comfortably once
  compressed.
- A 128 MB SPI NAND image will not fit. Host it somewhere and put the link in a
  comment instead.

Include `cat /proc/mtd` or the `mtdparts=` line from the stock kernel command
line alongside it. The dump says what the bytes are; the layout says where the
partitions started, and nothing in the dump itself will tell you that.
