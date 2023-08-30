[Table of Content](../README.md)

Unbrick Ingenic T31 with SD Card
---

## Ingenic T31 boot squence

<img src="../images/t31_boot_sequence.png" width=70% height=70%>

If failed to boot from uboot on flash memory, T31 will then try to boot from SD card, no matter what bootsel pin is set. So if the uboot on flash chip is somehow broken, we can burn uboot to a SD card and boot from it. The uboot file should be specially compiled for SD card boot, you can't use the one for normal flash boot.

## Compile uboot for SD card boot

```
mkdir /opt/t31
cd /opt/t31
git clone https://github.com/cgrrty/Ingenic-SDK-T31-1.1.1-20200508.git
cd Ingenic-SDK-T31-1.1.1-20200508/toolchain
unrar e toolchain.part1.rar
7z x mips-gcc472-glibc216-64bit-r2.3.3.7z
export PATH="$PATH:/opt/t31/Ingenic-SDK-T31-1.1.1-20200508/toolchain/mips-gcc472-glibc216-64bit/bin"
cd ../opensource/uboot/
make distclean
```
Now choose the final `make` command according to your T31 chip type

SoC | Command
------------ | ------------
T31N | make isvp_t31_msc0 
T31L | make isvp_t31_msc0_lite
T31X | make isvp_t31_msc0_ddr128M
T31A | make isvp_t31a_msc0_ddr128M

Now you will get the compiled uboot file `u-boot-with-spl.bin`

## Burn uboot to SD card

Insert SD card to your PC, run `fdisk -l` to check, you should see the device like in my case `Disk /dev/sdb: 29.72 GiB, 31914983424 bytes, 62333952 sectors`. Pay attention to the physical sector size, in my case it's 512 bytes

```
dd if=./u-boot-with-spl.bin of=/dev/sdb seek=34
```
This will burn the uboot file to SD card at 34*512bytes=17KBytes offset from 0x0, where 512 is my SD card's block size. If yours is 1024, change `seek=34` to `seek=17`, to make the offset to be 17KBytes

## Boot from SD card

If the original uboot on flash chip is broken or empty, it will choose to boot from SD card automatically, but if you just want to sideload your own uboot when there's working uboot on flash chip and camera PCB board's `bootsel` pin is set to 1, it will still boot from uboot on flash chip. To force booting from SD card, you can short circut pin 5 and 6 of the SOIC8 flash chip when powering up camera to block reading of the flash memory, details [here](https://github.com/gitgayhub/wiki/blob/master/en/help-uboot.md#shorting-pins-on-flash-chip).
