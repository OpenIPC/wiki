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

**First, which flash?** `cat /proc/mtd` on the running camera, or the bootloader's
own probe line, will say. It decides more than it looks: routes C, D and E are
U-Boot's `sf` commands, and `sf` is **SPI NOR only**. A NAND camera that follows
them gets no backup and no error worth reading.

| Your situation | Route |
| --- | --- |
| Stock firmware runs and you have a shell on it | [A, from the running system](#a-from-the-running-system) — NOR or NAND |
| You have OpenIPC's `ipctool` on it | [B, ipctool](#b-with-ipctool) |
| SPI NAND, and no shell on the stock firmware | [G, boot something that has one](#g-nand-without-a-stock-shell) |
| **SPI NOR**, bootloader console, camera on the network | [C, U-Boot over TFTP](#c-u-boot-over-tftp) |
| **SPI NOR**, bootloader console, no working network | [D, U-Boot to an SD card](#d-u-boot-to-an-sd-card), or [E, over the serial line](#e-u-boot-over-the-serial-line) |
| No console at all, or the camera is already dead | [F, an external programmer](#f-an-external-programmer) |

## A. From the running system

If you can get a shell on the stock firmware, this is the least risky route —
nothing is written anywhere near the flash.

The whole chip is every `mtdblock` device concatenated **in partition order**,
which is the order `/proc/mtd` lists them in — not the order a shell glob
produces. `/dev/mtdblock*` sorts `mtdblock10` ahead of `mtdblock2`, so on a
camera with ten or more partitions the glob silently scrambles the image. Read
the order from `/proc/mtd` instead:

```bash
out=/path/to/somewhere/fulldump.bin
: > $out
for m in $(sed -n 's/^mtd\([0-9]*\):.*/\1/p' /proc/mtd); do
    cat /dev/mtdblock$m >> $out
done
```

On SPI NAND use `nanddump` rather than `cat`, so that out-of-band data and bad
blocks are handled instead of read straight through:

```bash
nanddump -f /path/to/somewhere/fulldump.bin /dev/mtd0
```

The awkward part is *somewhere*. The camera's own filesystems are far too small,
so the destination has to be off-box — an SD card if the camera has a slot, or
an NFS share:

```bash
fw=$(mktemp -t)
nfs=$(dirname $fw)/nfs
mkdir -p $nfs
mount -t nfs -o tcp,nolock 192.168.1.123:/path/to/nfs/share $nfs || exit 1
grep -q " $nfs " /proc/mounts || { echo "not mounted, refusing"; exit 1; }
: > $fw
for m in $(sed -n 's/^mtd\([0-9]*\):.*/\1/p' /proc/mtd); do
    cat /dev/mtdblock$m >> $fw
done
mv $fw ${nfs}/fulldump.bin && sync && echo "saved off the camera"
```

The two guards are the point. Without them a failed `mount` leaves `$nfs` as an
ordinary directory **on the camera**, `mv` succeeds into it, the script looks
like it worked, and the only copy of the stock firmware is erased by the very
reflash it was taken for.

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
# ipctool backup /path/to/mybackup-02:00:00:00:00:01
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

Some bootloaders spell the upload `tftpput` instead. Use the same two variables,
not the literals you will find in older guides — `0x42000000` is RAM on the
0x40000000 family and **not** RAM on the 0x80000000 one, where it resets with a
data abort, and a hard-coded `0x800000` silently backs up half of a 16 MB chip:

```shell
mw.b ${baseaddr} 0xff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
tftpput ${baseaddr} ${flashsize} backup.bin
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

First [prepare the environment](help-uboot.md#prepare-the-environment). Card
blocks are 512 bytes, so the block count has to match the flash size in **all
three** steps — erase, write, and the `dd` that pulls it back off. Mixing them
is how you get 8 MB of flash followed by 8 MB of whatever was on the card
before, in a file the right size that looks fine until you try to restore it.

**8 MB flash** — `0x4000` blocks:

```shell
mmc dev 0
mmc erase 0x10 0x4000
mw.b ${baseaddr} 0xff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
mmc write ${baseaddr} 0x10 0x4000
```

**16 MB flash** — `0x8000` blocks:

```shell
mmc dev 0
mmc erase 0x10 0x8000
mw.b ${baseaddr} 0xff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
mmc write ${baseaddr} 0x10 0x8000
```

Then, with the card in a Linux PC — `skip=16` steps over the 8 KB offset, and
`count` matches the block count you just used:

```bash
sudo dd bs=512 skip=16 count=16384 if=/dev/sdc of=./fulldump.bin   # 8 MB
sudo dd bs=512 skip=16 count=32768 if=/dev/sdc of=./fulldump.bin   # 16 MB
```

Check `lsblk` for the right device before running that; `/dev/sdc` is an
example, not an answer.

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

## G. NAND without a stock shell

Routes C, D and E are `sf` commands, and `sf` drives SPI **NOR**. There is no
`sf` equivalent for NAND in these bootloaders, so on a NAND camera the way in is
to boot something that has a Linux shell and then use route A from there.

On SigmaStar parts the IPL will boot a U-Boot from an SD card before it touches
flash, which is enough to bring up an initramfs with `nanddump` in it. The
worked example — SD preparation, the image to write, and the backup itself — is
in [Sigmastar FPV devices](fpv-sigmastar.md), and its backup step is:

```bash
nanddump -f /mnt/mmcblk0p1/backup-nand.bin /dev/mtd0
```

`/dev/mtd0` there is the whole NAND, not the first partition of it. The same
page gives a TFTP alternative for when the card is too slow.

If no such route exists for your SoC, [route F](#f-an-external-programmer) still
works — but read the note there about NAND before you buy a clip.

## F. An external programmer

If the camera will not boot at all, or you would rather not trust its own
bootloader, read the chip directly with a CH341A and a SOIC-8 clip. This also
works on a camera that is already bricked, which is the one case where every
other route is closed.

See [Equipment for flashing](equipment-flashing.md) for what to buy,
[CH341A programmer voltage fix](hardware-programmer-ch341a-voltage-fix.md)
before you connect one to a 3.3 V camera, and
[Flash Chip Interfacing](flash-chip-interfacing.md) for the reading itself.

A CH341A reads SPI NOR happily. SPI **NAND** is a different matter — the part
speaks a different command set, needs out-of-band data and bad-block handling,
and plenty of cheap programmer software does not support it at all. Check that
your tool names your exact chip before assuming this route is open.

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

> **A dump is a credential store. Read this before you publish one.**
>
> A full flash image contains the camera's root password hash, and it very often
> contains the Wi-Fi SSID and passphrase the vendor firmware was last joined to,
> the cloud/P2P device key, the serial number and the MAC address. Hashes out of
> a firmware image are routinely cracked — this wiki's own
> [security research notes](research-security.md) list the tools for it — so
> "it's only a hash" is not protection.
>
> Attaching a dump to a public issue publishes all of that, permanently and to
> everyone. Before you do:
>
> - Change any Wi-Fi password the camera knew, or take the dump from a camera
>   that never joined your network.
> - Expect the MAC and serial to be public afterwards. They cannot be recalled.
> - If the camera is on your own network today, treat it as compromised once the
>   dump is public and reflash it.
>
> If you would rather not publish it, say so in the issue — a maintainer can
> arrange a private handover. Nobody will think less of a report that says "dump
> available on request".

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
