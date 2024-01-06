# OpenIPC Wiki
[Table of Content](../README.md)

Flash Chip Interfacing
--------------------

This is an advanced topic regarding identifying, reading, writing, verifying and 
erasing flash chips by interfacing directly with the flash chip using a programmer.
This is not the preferred method of flashing the firmware, but it certainly can be useful
when other methods fail.

If you are just getting started, you are probably in the wrong place: check out
[Installation](installation.md) and [Burn Example](burn-example.md) for better starting points.


SOIC8 Chips
--------------------
SOIC8 is a common package for flash chips. It is a small package with 8 pins, and
the pins are spaced 1.27mm apart. The pins are numbered counter-clockwise starting
from the top left corner with the dot marking. The top left pin is pin 1, the top right pin is pin 2,

As mentioned in [Help: U-Boot](help-uboot.md) the SOIC8 flash chip can sometimes be tricked 
into going straight to u-boot mode, and the following diagram is shown:
![](../images/flash-pins.webp)
![](../images/flash-pins-2.webp)


SOIC8 Clips
--------------------

SOIC8 clips are a convenient way to interface with SOIC8 chips. They are cheap and somewhat easy to use.
Remember though, that the clip requires a programmer to act as interface between the clip and your computer.

Here is an example of a SOIC8 clip wired to a Raspberry Pi Pico:

![](../images/soic8-clip-programmer-example.png)


Picking a Programmer
--------------------


### CH341A
There are many programmers available, and they all have their pros and cons.  The most popular
programmers are boards leveraging the CH341A, which is a cheap and easy to use chipset.  For more details about the CH341A, 
see [CH341A Hardware Programmer](hardware-programmer.md).


### Raspberry Pi Pico
The Raspberry Pi Pico is a microcontroller board with a USB port and a several GPIO pins.  It is also cheap and easy to use,
and maybe you already have one lying around.   Doesn't matter if it is a wireless version or not, they both work the same.
In order to use the Pico as a programmer, you will need to put the pico into bootloader mode by holding down the BOOTSEL button
while plugging it into your computer.  The Pico will show up as a USB drive, and you can drag and drop the uf2 file onto the drive.
Currently, the best pico-serprog library to use is a fork of [pico-serprog](https://github.com/opensensor/pico-serprog) 
which fixed a number of issues encountered with the original.

There are more instructions the pico-serprog Github, however pico-serprog firmware will grant you 
an extra USB COM port that maps to the following GPIOs.

| Pin | Function |
|-----|----------|
| 7   | CS       |
| 6   | MISO     |
| 5   | MOSI     |
| 4   | SCK      |

Since most SOIC8 flash chips are 3.3v, you will need to connect to the 3.3 V rail of the PICO which is pin 36, 
and remember to connect the GND pin as well, there are many GND pins on the pico, such as pin 38.
* Note: if for some reason your chip needs 5V, you can use VSYS which is pin 40 instead of 3.3V, but make sure you read the specification of your specific flash chip.



Flashrom program
--------------------
Flashrom is a program that can be used to read, write, erase, and verify flash chips.  It is available for Linux, Windows, and Mac.
Generally these days, you need to compile it for the platform that you intend to use it on.  It is a command line program, and
there are many options available.  The following are some examples of how to use flashrom.

This guide focusing on using flashrom and does not currently explain building flashrom, but you can find instructions on the [flashrom website](https://flashrom.org/).

### Determine your COM port

For windows, you can use the device manager to determine the COM port that your programmer is connected to.

For Linux, you can use the `dmesg` command to determine the COM port that your programmer is connected to.

### Reading a flash chip

To read a flash chip, you sometimes need to know the type of flash chip that you are reading.

Try running simple probe to verify you get connectivity with the programmer.   pico-serprog is a serprog (or serial programmer) and that needs to be specified to flashrom.
In this example, the programmer is connected to COM23, and the baud rate is 2000000 which is known to work well and can read a 16MB flash chip in 2-3 minutes.
```bash
./flashrom.exe -p serprog:dev=COM23:2000000 -V
```

Here is an example of reading a flash chip.   In this example, flashrom had told us we had to pick between three different chips, and we picked the "GD25B128B/GD25Q128B".
```bash
# ./flashrom.exe -p serprog:dev=COM23:2000000 -c "GD25B128B/GD25Q128B" -r gokev300-camera-12242023.bin -VV --force
flashrom 1.4.0-devel (git:v1.2-1386-g5106287e) on Windows 10.0 (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Using clock_gettime for delay loops (clk_id: 1, resolution: 100ns).
flashrom was built with GCC 13.2.0, little endian
Command line (8 args): C:\msys64\home\matte\flashrom\flashrom.exe -p serprog:dev=COM23:2000000 -c GD25B128B/GD25Q128B -r gokev300-camera-12242023.bin -VV --force
Initializing serprog programmer
Baud rate is 2000000.
serprog: connected - attempting to synchronize
.
serprog: Synchronized
serprog: Interface version ok.
serprog: Bus support: parallel=off, LPC=off, FWH=off, SPI=on
serprog: Maximum write-n length is 32
serprog: Maximum read-n length is 32
serprog: Programmer name is "pico-serprog"
serprog: Serial buffer size is 64
Warning: Automatic command availability check failed for cmd 0x07 - won't execute cmd
Warning: NAK to query operation buffer size
serprog: operation buffer size is 300
serprog: Warning: Programmer does not support toggling its output drivers
The following protocols are supported: SPI.
Probing for GigaDevice GD25B128B/GD25Q128B, 16384 kB: compare_id: id1 0xc8, id2 0x4018
Added layout entry 00000000 - 00ffffff named complete flash
Found GigaDevice flash chip "GD25B128B/GD25Q128B" (16384 kB, SPI) on serprog.
Chip status register is 0x00.
Chip status register: Status Register Write Disable (SRWD, SRP, ...) is not set
Chip status register: Block Protect 4 (BP4) is not set
Chip status register: Block Protect 3 (BP3) is not set
Chip status register: Block Protect 2 (BP2) is not set
Chip status register: Block Protect 1 (BP1) is not set
Chip status register: Block Protect 0 (BP0) is not set
Chip status register: Write Enable Latch (WEL) is not set
Chip status register: Write In Progress (WIP/BUSY) is not set
This chip may contain one-time programmable memory. flashrom cannot read
and may never be able to write it, hence it may not be able to completely
clone the contents of this chip (see man page for details).
===
This flash part has status UNTESTED for operations: WP
The test status of this chip may have been updated in the latest development
version of flashrom. If you are running the latest development version,
please email a report to flashrom@flashrom.org if any of the above operations
work correctly for you with this flash chip. Please include the flashrom log
file for all operations you tested (see the man page for details), and mention
which mainboard or programmer you tested in the subject line.
Thanks for your help!
serprog_delay used, but programmer doesn't support delays natively - emulating
Block protection is disabled.
Reading flash... read_flash:  region (00000000..0xffffff) is readable, reading range (00000000..0xffffff).
done.
```

### Writing a flash chip

Writing a flash chip is quite similar to reading it.  You need to specify the COM port, the baud rate, and possibly the chip type.
Simply change your arguments to flashrom to include the -w option and the file that you want to write to the flash chip.

```bash
./flashrom.exe -p serprog:dev=COM23:2000000 -c "GD25B128B/GD25Q128B" -w openipc-hi3516ev300-ultimate-16mb.bin -VV --force
```

During a write operation, flashrom will first read the entire chip, then erase and write the chip, and then re-read it to verify.
Always make sure you successfully back up and complete a read cycle before attempting to write to a chip.


### Conclusion
This guide is not meant to be a complete guide to using flashrom, but rather a starting point for those who are interested in using it,
and also inspiration for those who have raspberry picos lying around and want to use them for something useful.

If you liked the pico-serprog example, you probably will also really like the [pico-uart-bridge](https://github.com/Noltari/pico-uart-bridge)
which gives multiple COM ports over a single USB connection, for the purpose of connecting UART terminals.

