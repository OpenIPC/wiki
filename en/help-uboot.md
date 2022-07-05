# OpenIPC Wiki
[Table of Content](../index.md)

Help: U-boot
------------

### Environment

If you get `Too many args` error while trying to set an environment variable,
try to do that from within Linux using `fw_setenv` instead of `setenv` in U-boot.

__U-boot console:__
```
hisilicon # setenv uk 'mw.b 0x82000000 ff 1000000; tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
** Too many args (max. 16) **
```

__OpenIPC Linux:__
```
root@openipc-hi3518ev100:~# fw_setenv uk 'mw.b 0x82000000 ff 1000000; tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
root@openipc-hi3518ev100:~#
```

### Saving original firmware without using tftp.

In the terminal program you use connect to UART port with, enable saving a log
file of the session. I like to use `screen` for that, and my command to connect
to the UART adapter with logging of the active session into a file would look
like this:
```
$ screen -L -Logfile fulldump.log /dev/ttyUSB0 115200
```

After connecting to the bootloader console, run a set of commands for reading
whole amount of data from flash memory chip into RAM, and then dumping it as
hexadecimal values into terminal window.

Use hexadecimal notation for addresses, where 0 is 0x0, 8 MB is 8x00000, and
16 MB is 0x1000000. 

For reading whole 8 MB flash memory run 

```
mw.b 0x82000000 ff 0x800000
sf probe 0
sf read 0x82000000 0x0 0x800000
md.b 0x82000000 0x800000
```

and for 16 MB flash memory run

```
mw.b 0x82000000 ff 0x1000000
sf probe 0
sf read 0x82000000 0x0 0x1000000
md.b 0x82000000 0x1000000
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
xxd -r fulldump.log > fulldump.bin
```

Use [binwalk](https://github.com/ReFirmLabs/binwalk) to unpack the binary file.

#### Saving firmware via SD card.

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

```
mmc dev 0
mmc erase 0x10 0x8000
```

Now you need to copy the contents of the firmware from the flash memory chip to
the RAM of the camera. To do that, clear a section of RAM (0x800000 bytes for a
8MB chip or 0x1000000 bytes for a 16MB chip), read the flash memory and copy
the entire contents to the prepared space in RAM. Then export the copied data
from RAM to the card.

NB! In the example below we use the starting address 0x2000000, but it varies
for different cameras. Please consult SoC data sheet, or seek help on
[our Telegram channel][telegram].

```
mw.b 0x2000000 ff 0x1000000
sf probe 0
sf read 0x2000000 0x0 0x1000000
mmc write 0x2000000 0x10 0x8000
```

Remove the card from the camera and insert it into a computer running Linux.
Use `dd` command to copy data from the card to a binary file on the computer.

```
dd bs=512 skip=16 count=32768 if=/dev/sdc of=./fulldump.bin
```

### Bypassing password-protected bootloader.

Changing the bootloader is a risky operation. There's a high probability of
turning your camera into a paperweight if something goes wrong. So before you
flash a new bootloader you have to weigh up all the risks and benefits. In most
cases the original bootloader plus new kernel and new operating system should
work just fine. But there are exceptions.

Today, we see more and more cameras where access to bootloader console is
protected with a password. Thus, even if you connect to the camera's UART port,
all you will see after interrupting the standard boot cycle is a prompt for
password. In that case, a relatively safe solution is to downgrade the firmware
to a version where the password protection was not yet implemented. For example,
for Xiongmai cameras the bootloader password protection started popping up
somewhere around July 2021, hence you need a firmware for your camera from an
earlier date. After you successfully downgrade your camera to a password-free
bootloader, you could install the OpenIPC firmware in a regular way.
