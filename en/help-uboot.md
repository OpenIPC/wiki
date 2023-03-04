# OpenIPC Wiki
[Table of Content](../index.md)

Help: U-Boot
------------

### Prepare the enviroment
In booloader shell, check if `baseaddr` variable is already defined.
```
printenv baseaddr
```
If it is not there, set it yourself.
```
# Look up address for your SoC at https://openipc.org/supported-hardware/
setenv baseaddr 0x80600000
```
Assign the hex size of your flash chip to a variable called `flashsize`.
```
# Use 0x800000 for an 8MB flash chip, 0x1000000 for 16MB.
setenv flashsize 0x800000
```
Save these values into the environment afterwards.
```
saveenv
```

### Saving original firmware without using TFTP.

Before you start, [prepare the enviroment](#prepare-the-enviroment).

In the terminal program that you use to connect to the UART port, enable saving
log file of the session. I like to use `screen` for this and my command for
connect to the UART adapter with logging the active session to a file would look
like this:
```
$ screen -L -Logfile fulldump.log /dev/ttyUSB0 115200
```

After connecting to the bootloader console, run a set of commands for reading
whole amount of data from flash memory chip into RAM, and then dumping it as
hexadecimal values into terminal window.

```
mw.b ${baseaddr} 0xff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}
md.b ${baseaddr} ${flashsize}
```

Since the process of reading is going to take a considerable amount of time
(literally hours), you might want to disconnect from the terminal session to
avoid accidental keystrokes contaminating the output. Press `Ctrl-a` followed
by `d` to detach the session from active terminal. Run `screen -r` when you
need to reconnect it later, after the size of the log file will stop growing.
Reading of an 8 MB flash memory should result in a ~40 MB log file, and for a
16 MB chip the file should be twice that size.

Convert the hex dump into a binary firmware file and use it for further research
or restoring camera to its pristine state.

```
cat fulldump.log | sed -E "s/^[0-9a-f]{8}\b: //i" | sed -E "s/ {4}.{16}\r?$//" > fulldump.hex
xxd -revert -plain fulldump.hex fulldump.bin
```

Use [binwalk](https://github.com/ReFirmLabs/binwalk) to unpack the binary file.

### Saving firmware via SD card.

Before you start, [prepare the enviroment](#prepare-the-enviroment).

Sometimes your camera only has a wireless connection, which does not work
directly from the bootloader. Very often such cameras have a microSD card slot.
In this case you can try to save a copy of the original firmware using an
SD card as an intermediary medium.

Since you're going to save firmware in its binary form, the amount of data will
be either 8 MB or 16 MB, depending on the size of camera's flash memory chip.
So any SD card will do, even the smallest one.

Insert the card into the card slot on the camera, connect the serial adapter to
the UART port, supply power to the camera and stop the boot process to get into
the bootloader console.

Initialize access to the card, and clear some space to save firmware on.
Data is written onto card in blocks of 512 bytes. You need to erase 16384 blocks
to clear 8 MB, 32768 blocks for 16 MB, which are 0x4000 and 0x8000 hexadecimal,
respectively.

Note that we are going to write directly to the card registers, bypassing the
partition table. To avoid conflicts when accessing card data later from your PC,
offset 8 kilobytes from the beginning of the card (8 * 1024 = 8192 bytes or 16
blocks of 512 bytes, or 0x10 blocks in hexadecimal representation).

Example for 8MB:

```
mmc dev 0
mmc erase 0x10 0x4000
```

Example for a 16MB:

```
mmc dev 0
mmc erase 0x10 0x8000
```

Now you need to copy the contents of the firmware from the flash memory chip to
the RAM of the camera. To do that, clear a section of RAM (0x800000 bytes for a
8MB chip or 0x1000000 bytes for a 16MB chip), read the flash memory and copy
the entire contents to the prepared space in RAM. Then export the copied data
from RAM to the card.

Example for 8MB:
```
mw.b ${baseaddr} ff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}

mmc write ${baseaddr} 0x10 0x4000
```

Another example, for 16MB:
```
mw.b ${baseaddr} ff ${flashsize}
sf probe 0
sf read ${baseaddr} 0x0 ${flashsize}

mmc write ${baseaddr} 0x10 0x8000
```

Remove the card from the camera and insert it into a computer running Linux.
Use `dd` command to copy data from the card to a binary file on the computer.

Example for 8MB:
```
sudo dd bs=512 skip=16 count=16384 if=/dev/sdc of=./fulldump.bin
```

Example for 16MB:
```
sudo dd bs=512 skip=16 count=32768 if=/dev/sdc of=./fulldump.bin
```

### Uploading binary image via serial connection.

There are cameras that only have wireless connection unavailable directly from
bootloader. Most of such cameras also have SD card slot but some don't, or it
does not work for some reason, or you don't have a card, or something. Anyway,
you still can upload a binary image onto camera and either run it, or save it
into the flash memory. Here's how.

First of all, you'll need to install `lrzsz` package on your desktop computer.
I presume it runs Linux and preferrably of a Debian family, that'll be easier
on examples. So, run this command to satisfy prerequisites:
```
apt install lrzsz
```
Now you are ready.

Place the binary file you are going to upload into the same directory where you
will be starting a `screen` session to your camera from. Start the session and
boot into the bootloader console interrupting booting routine with a key combo.

Now you can run `help` and check what data transfer protocols are supported by
your version of bootloader. If you see `loady` in the list of commands, then
you can use ymodem protocol. Run `loady` on you camera, then press `Ctrl-a`
followed by `:` (semi-colon). It will switch you into command line at the very
bottom of the screen.

Enter `exec !! sz --ymodem filename.bin` where _filename.bin_ and see your file
uploading via serial connection. At 115200 bps. Slow, very slow.

After the file is uploaded, you can do the usual magic. Either boot from the
memory image right away using `bootm`, or write it into the flash memory.

### Flashing full image via serial connection

Before you start, [prepare the enviroment](#prepare-the-enviroment).

Download the full firmware binary for your SoC and flash chip from
[OpenIPC web site](https://openipc.org/supported-hardware/) after submitting the
settings form and clicking the link hidden under "Alternative method" button.

![](../images/firmware-full-binary-link.webp)

Open `screen` and connect to UART port.
```
screen /dev/ttyUSB0 115200
```
Sign in into bootloader shell and run:
```
mw.b ${baseaddr} 0xff ${flashsize}
loady
```
press "Ctrl-a" followed by ":", then type
```
exec !! sz --ymodem fullimage.bin
```
after the image is loaded, continue
```
sf probe 0
sf erase 0x0 ${flashsize}
sf write ${baseaddr} 0x0 ${filesize}
```

### Reading binary image from SD card.

Before you start, [prepare the enviroment](#prepare-the-enviroment).

If your camera supports SD card and you have `fatload` command in bootloader,
then you can read firmware binary files from an SD card.

First, prepage the card: format it into FAT filesystem and place bootloader,
kernel, and rootsf binary files there. Insert the card into camera and boot
into bootloader console.

Check that you have access to the card.
```
mmc rescan
```
Then unlock access to flash memory and start writing content of the files from
the card into the flash memory.

NB! Please note that load address and names of files used in this example not
necessarily match those for your particular camera. Consult documentation, or
seek help on [our Telegram channel][telegram].

Flash bootloader.
```
mw.b ${baseaddr} 0xff 0x50000
sf probe 0
sf erase 0x0 0x50000
fatload mmc 0:1 ${baseaddr} u-boot-with-spl.bin
sf write ${baseaddr} 0x0 ${filesize}
```

Flash kernel.
```
mw.b ${baseaddr} 0xff 0x200000
sf probe 0
sf erase 0x50000 0x200000
fatload mmc 0:1 ${baseaddr} uimage.${soc}
sf write ${baseaddr} 0x50000 ${filesize}
```

Flash root filesystem.
```
mw.b ${baseaddr} 0xff 0x500000
sf probe 0
sf erase 0x250000 0x500000
fatload mmc 0:1 ${baseaddr} rootfs.squashfs.${soc}
sf write ${baseaddr} 0x250000 ${filesize}
```

### Bypassing password-protected bootloader.

Changing the bootloader is a risky operation. There's a high probability of
turning your camera into a paperweight if something goes wrong. So before you
flash a new bootloader you have to weigh up all the risks and benefits. In most
cases the original bootloader plus new kernel and new operating system should
work just fine. But there are exceptions.

#### Shorting pins on flash chip

If you can't interrupt the boot sequence with a key combination, or if your
camera requires a bootloader password that you don't know, you can still make
it stop the Linux kernel booting and throw you into the shell.

The first thing to do is locate the flash memory chip on the camera circuit
board. Typically this is a square chip with 8 pins labeled 25Q64 or 25Q128,
rarely 25L64 or 25L128. If you have trouble locating the chip, try taking 
some pictures of your board from both sides. Then ask for help 
[in our Telegram channel](https://t.me/openipc).
__Do not try to short-circuit any random chip! It will most likely burn your camera circuit.__

Short-circuit pins 5 and 6 of the flash chip with a small metal object,
a screwdriver or tweezers, right after the bootloader starts but before it
calls up the Linux kernel.

Pins 5 and 6 of the SOIC8 chip are on the opposite corner of pin 1, indicated
by the embossed or drawn dot next to it.

![](../images/flash-pins.webp)
![](../images/flash-pins-2.webp)

#### Downgrading stock firmware.

Today, we see more and more cameras where access to bootloader console is
protected with a password. Thus, even if you connect to the camera's UART port,
all you will see after interrupting the standard boot cycle is a prompt for
password. In that case, a relatively safe solution is to downgrade the firmware
to a version where the password protection was not yet implemented. For example,
for Xiongmai cameras the bootloader password protection started popping up
somewhere around July 2021, hence you need a firmware for your camera from an
earlier date. After you successfully downgrade your camera to a password-free
bootloader, you could install the OpenIPC firmware in a regular way.

#### Side-loading unlocked bootloader.

Many modern cameras utilize fastboot protocol that allows camera to load a
bootloader binary code directly into memory and then run it from there.
Check if our [burn utility][burn] supports your camera's SoC.

#### Modifying stock firmware.

One way to bypass the bootloader protection is to dump original firmware and
replace bootloader there with an unlocked alternative. Or you could flash the
entire OpenIPC firmware since you have the chip in the programmer, anyway.

__DO NOT FORGET TO MAKE A BACKUP OF YOUR ORIGINAL FIRMWARE!__

## Troubleshooting

Before you start, [prepare the enviroment](#prepare-the-enviroment).

If you get `Too many args` error while trying to set an environment variable,
try to do that from within Linux using `fw_setenv` instead of `setenv` in U-boot.

__U-boot console:__
```
hisilicon # setenv uk 'mw.b ${baseaddr} 0xff ${flashsize}; tftp ${baseaddr} uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}'
** Too many args (max. 16) **
```

__OpenIPC Linux:__
```
root@openipc-hi3518ev100:~# fw_setenv uk 'mw.b ${baseaddr} 0xff ${flashsize}; tftp ${baseaddr} uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write ${baseaddr} 0x50000 ${filesize}'
```



[burn]: https://github.com/OpenIPC/burn
[telegram]: https://t.me/OpenIPC
