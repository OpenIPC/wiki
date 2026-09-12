### Camera spec

<img width="400" height="400" alt="camera-stock" src="https://github.com/user-attachments/assets/2a57c65e-f27a-44bf-b07a-b74b147d47a3" />

Feature	Specification  
Model	RH-PD10  
Display	4.3-inch Color LCD  
Camera Resolution	1080P  
Connection Type	Wireless (2.4GHz Wi-Fi only)  
View Angle	Diagonal 150°, Horizontal 122°, Vertical 92°  
Power Source	Built-in 5000mAh Rechargeable Battery  
Intercom	One-Way (Mic on door camera, no speaker)  
Night Vision	HD Night Version (No red night exposure)  
Storage	Max 128GB TF Card (not included), Cloud Storage (30-day trial)  
Smart Home Platform	Tuya, Alexa, Google Assistant  
APP Name	Tuya Smart or Smart Life APP  
Door Thickness Requirement	35-160mm  
Peephole Hole Diameter	15-35mm  

### OpenIPC status

| Component       | Status                                                   |
|-----------------|----------------------------------------------------------|
| WiFi            | Built-in one - not working. Needs secondary NIC          |
| Screen          | Not working due to software limitations and HW challenge |
| SD Card         | Built-in one - removed from the board. May use external reader over USB hub |
| Everything else | WORKING                                                  |

### PCB overview

<img width="1000" height="700" alt="board_bottom_markings" src="https://github.com/user-attachments/assets/55e41551-8ed1-4d26-8f83-01a17062f0ae" />
<img width="1000" height="700" alt="board_top_markings" src="https://github.com/user-attachments/assets/4a1cb246-d0bd-4023-bf35-71e38287bec3" />

### Notes

1. GOKE SoC by default uses Tuya RTOS. It cannot be used in this state for local RTSP. UART gives some local control over RTOS but nothing useful.
2. Hi3861 uses some locked-down Huawei RTOS.
3. Both MCU and SoC are connected using some proprietary protocol. Cannot be reused in OpenIPC.
4. Hi3861 MCU is the main controller of the board. Only one with WiFi capability.
5. MCU cuts power to GOKE SoC if it doesn't respond (for example, enters u-boot) and after 30 seconds of inactivity

### Plan

1. Cut MCU control over SoC power
2. Flash SoC SPI with OpenIPC
3. Add network capability to SoC

### Force SoC to be always powered on

Basically, connect the NPN transistor's collector pin to its emitter pin. Base (control pin) of this transistor is connected to MCU's GPIO. It can stay this way, as regardless of it's state it won't impact SoC power.

<img width="700" height="500" alt="pins to bridge" src="https://github.com/user-attachments/assets/b6cdd089-5688-4c3e-9f60-58fe6ff9ef96" />

### Flash SoC

GOKE UART is configured to use 1.8V, hence standard CH340 operating at 3.3V/5V will fry the SoC.
Personally I used CH343G by WaveShare (SKU 21442) and just took 1.8V from camera board as VCC.
Important: remember to remove voltage selection jumper from UART adapter for this to work.
Based on the picture below: 1.8V goes to VCC pin of CH343G adapter, RX goes to TX pin, TX to RX pin, GND to GND. Again, remember about removing the jumper from CH343G.
<img width="1132" height="210" alt="uart" src="https://github.com/user-attachments/assets/ab1095ef-e6d6-4796-840e-f97728f8241d" />

This setup creates a problem - UART adapter connected over USB to your PC will not show up until you supply camera board with power. On top of that SoC does not power on without battery connected. Clearly this product was not designed to remove battery and have it running on usb-c power.
On top of that - you will not be able to interrupt boot and enter stock u-boot because it uses "quickboot" option to skip the 1s window and boot straight to RTOS.
Hence, we need to glitch SPI on power-on and use openipc's defib program.

Steps:
1. Install defib (if you use debian: pip3 install git+https://github.com/OpenIPC/defib --break-system-packages). If installation fails due to broken dependencies do it in python virtual environment).
2. Hook up UART adapter to your PC. In my case it registers as /dev/ttyACM0. Again - it will not register till you supply 1.8V from the board. Don't do that yet.
3. Prepare defib command. You can run it to confirm it won't fail due to missing packages or something. It should at this point complain about unaccessible /dev/ttyACM0. 
In my case the command is: defib burn -p /dev/ttyACM0 -c gk7202v300 -b
4. Connect battery to the board. Make sure it is charged enough to last for 30 minutes.
5. Bridge CLK and DI pins of the SoC SPI memory. Use picture as reference and do it using some metallic tool like tweezers, tiny knife or tiny screwdriver. Whatever gives you best control over the tool. DO NOT short anything else by mistake.
6. While keeping the short on SPI module with one hand, flip the board's power switch using another hand. While keeping the short quickly execute defib command. Remove short. Defib should pick up the SoC and continue uploading alternate u-boot to SoC RAM.
You have around 3-4 seconds to do this procedure. If you keep short for too long SoC will give up on SPI and become unresponsive, at which point you'll need to repeat.

Assuming defib worked and finished upload you should be now able to dump stock firmware and flash openipc.
Connect to the UART interface using picocom/minicom. Baud 115200. Check if you got the prompt by hitting enter.

My recommended way of doing the flashing part is utilizing sd card reader. SD chip connected to SoC USB root port is fully supported under both stock u-boot and the u-boot defib uploaded to RAM.  
[TODO I promise]

### Add network card to SoC
Unfortunately SoC has just one USB port and it's internally wired to SD card controller. USB-C on the board has just 6 pins (VCC, GND and CC). Hence you have two choices - either use some tiny wifi usb card or drill a hole in the case and wire external network card to internal pins. My choice is ethernet, specifically RTL8152 100/10 card.
In any case, you need to remove the SDHC iC and steal USB D+ and D- pins from it. Easiest way is to use hot air or propane-butane soldering iron without tip (basically a ghetto hot air station).
After exposing pins solder usb card cable cores to D- and D+ for data and VCC and GND, I hooked up VCC and GND to USB-C connector directly. If you ever want to use this camera with internal battery don't solder to USB-C, use SDHC iC slot VCC and VSS pins instead, as on the picture below:
gl823k hc10b04y04:
<img width="895" height="388" alt="image" src="https://github.com/user-attachments/assets/c552390b-fcff-4777-b62a-213398fadc3c" />
Just make sure network card of your choice is not super power hungry, otherwise you will overload voltage booster connected to GL823K pads. It's not an issue when utilizing USB-C connector, aside from the fact it won't work without external cable sticking to the camera.
What massively helps with soldering to these piny pads is $50 digital microscope and UV solder mask. Just cover unused pads with it, cure with UV light and you have less chance of bridging with nearby pads.

If you do this correctly you should be able to find the device in lsusb output:
```
root@gk7202v300-unknown:~# lsusb
Bus 001 Device 001: ID 1d6b:0002
Bus 001 Device 002: ID 0bda:8152
Bus 002 Device 001: ID 1d6b:0003
```

Ignore 1d6b:000x lines. This is an effect of GOKE usb controller having it's dual role mode enabled in openipc-firmware build config for generic gk7202v300 board. And just as a side note, this SoC does not have USB 3.0 controller despite the XHCI driver loading.  
Now, last thing is to add relevant drivers to the filesystem. You can either build your own openipc firmware with relevant drivers or add them manually to the already flashed generic one.  
Build drivers from OpenIPC/firmware repo and upload them to /lib/modules/4.9.37/kernel/net. In my case (RTL8152) I needed these 3: mii.ko, r8152.ko and usbnet.ko. Load them using insmod in the order: mii.io -> usbnet.ko -> r8152.ko  
Assuming you didn't get segfault as an output (indicating wrong build options) you can proceed with setting up network. My insmod+setup startup script looks like this:   
```
insmod /lib/modules/4.9.37/kernel/net/mii.ko
insmod /lib/modules/4.9.37/kernel/net/usbnet.ko
insmod /lib/modules/4.9.37/kernel/net/r8152.ko
sleep 2
ifconfig eth0 192.168.1.251 netmask 255.255.255.0 up
route add default gw 192.168.1.1 eth0
```
Located under: /etc/init.d/S99user (remember about chmod +x)

### Majestic config
Configure sensor type via ssh (gc2053 in my case):  
```
fw_setenv SENSOR gc2053
fw_setenv sensor gc2053
```
(not sure which one is correct, doesn't hurt to add both)
Thankfully the sensor uses typical GPIOs for photocell and IR lights:
Night Illuminator: Pin 8 (Lamp on = HIGH)
Daylight sensor: Pin 9 (dark = HIGH)

### Side notes
Due to OpenIPC limitations for this platform screen is not supported and won't be supported anytime soon. By doing this mod you're losing this function. Best to just disconnect screen's ribbon cable and secure it with eletrical tape.  
Screen is wired directly to GOKE SoC power rail anyway, so it'd be on all the time. You could technically replace OpenIPC's kernel modules with stock ones from GOKE SDK but then you run into issues with broken Majestic, etc. Missing libraries for framebuffer are osal.ko, gk7205v200_sys.ko, gk7205v200_base.ko, gk7205v200_vo.ko, gfbg.ko and ssp_st7796_ex.ko. Not an easy job. Then you need some kind of daemon displaying local rtsp stream onto /dev/fb0 which is going to be a challenge considering available SPI memory (below 1MB, some already taken by network modules). Not an easy job.  
MCU at this point can be just removed. 

### Final look
<img width="800" height="640" alt="20260911_211641" src="https://github.com/user-attachments/assets/5d640174-9e4f-4d27-bdaa-c63d87c92b4e" />
<img width="800" height="640" alt="20260912_002303" src="https://github.com/user-attachments/assets/edfd67ef-3d96-4d61-bf96-91e811c38818" />
