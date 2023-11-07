# OpenIPC Wiki
[Table of Content](../README.md)

Notes on installing OpenIPC using Burn
--------------------------------------

Guideline flash GK7205V210 with locked bootloader

Before starting work, watch the video on our [YouTube](https://www.youtube.com/@openipc/playlists) channel

- Download [Burn](https://github.com/OpenIPC/burn)
- Install [PUTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) and [TFTP](https://pjo2.github.io/tftpd64/) server
- Turn off camera power, Connect USB com FTDI to your camera, specify which COM port on your PC
- Enter burn folder and run the following cmd (Focus only serial port, in my case it is COM4, other params dont care, it worked with my GK7205V210):
```
python burn --chip hi3516ev200 --file=u-boot/gk7205v200.bin -p COM4 --break && putty.exe -serial COM4 -sercfg 115200,8,n,1,N
```
- Power on your camera with power supply, and wait putty throw out with console
- Press enter, then you will see "goke" in the console
- Run TFTP server, specify bin file's path
- Now follow up as generated instruction which from OpenIPC site:

```
# Enter commands line by line! Do not copy and paste multiple lines at once!
setenv ipaddr 192.168.0.10; setenv serverip 192.168.0.40
mw.b 0x42000000 0xff 0x800000
tftpboot 0x42000000 openipc-gk7205v210-fpv-8mb.bin
sf probe 0; sf lock 0;
sf erase 0x0 0x800000; sf write 0x42000000 0x0 0x800000
reset
Ctrl + c quickly during booting
# Enter commands line by line! Do not copy and paste multiple lines at once!run setnor8m
```
