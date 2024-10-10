# OpenIPC Wiki
[Table of Content](../README.md)

RunCam WiFiLink based on OpenIPC
--------------------------------

### Q&A with RunCam Dev

- What changes have you made compared to the original OpenIPC firmware ?
    - We optimized the IQ sensor and added the /etc/user_config.sh script to implement the WiFi card configuration function.
  
Runcam Setup 
--------------------------------

So you just bought a Runcam WiFi link? Great! This guide will help you to set it up. 
The Runcam WiFi link and OpenIPC is still under development, so it's
possible this guide will soon be outdated.

Issue date: 01 October 2024

## What you will need:

-   INAV 7.1.2

-   Flight Controller: In this example, Speedybee f405 WING APP was used.
-   Runcam WiFiLink + Android Ground station
-   A working PC/laptop computer with an ethernet port
-   USB C cable
-   A fairly modern Smartphone with Android 13 or 14 installed. The smartphone should have a good processor ie. Snapdragon
-   Internet connection

## 1. Hardware Setup

a)  Connect the antennas to Runcam.

b)  Connect the 4 cable to UART on Spedybee dedicated to connecting
     digital VTX's use the image below as a guide.\
     **Attention:** the cable color codes will match only on one end.
     Double check your wiring (gnd to gnd, vcc to vcc, etc)

c)  Insert a formatted micro SD card into the Runcam. The slot is on the
    bottom of the unit, when the fan faces up.

d)  Connect an Ethernet cable supplied with Runcam to the device.

## 2. INAV Setup.

a)  Connect your flight controller through a USB C to a computer that
    > has INAV configurator installed

b)  In the Ports tab, set up MSP Display port as per image below. 
Note:
if you are using a different FC then in this example, you might
need to chose a different
UART.
![msp DISPLAY PORT](https://github.com/wkumik/wiki/blob/master/images/RUNCAM%20SETUP%20GUIDE%20IMAGES/image6.png)

c)  In the configuration tab, make sure Telemetry and OSD are enabled

![Telemetry](https://github.com/wkumik/wiki/blob/master/images/RUNCAM%20SETUP%20GUIDE%20IMAGES/image5.png)

Set up OSD in OSD tab. Enable and arrange all the information as
you wish. Set Video Format to AVATAR.
![INAV SETUP](https://github.com/wkumik/wiki/blob/master/images/RUNCAM%20SETUP%20GUIDE%20IMAGES/image1.png)

## 3. Runcam Setup

a)  Insert an empty, formatted micro SD into the runcam device. The card
    > pads need to face the board. The slot for the micro SD can be on
    > the 'inside' of the board so you might need to disassemble it to
    > put the card in.

b)  When you first power up your runcam, the device will create a 'user'
    > file and a 'gs.key' file. Take the SD card out from your runcam
    > and copy the GS.key file into your android device. You can do it
    > easily using ie. google drive.

## 4. OpenIPC Configurator setup 

OpenIPC configurator is a useful tool to change many different settings
on your camera that runs OpenIPC firmware.

a)  Download and install the latest version of
   [PUTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/)

b)  Download the [OpenIPC
    configurator](https://github.com/OpenIPC/configurator/releases)
    and install it

c)  Setting up IP\
    > -Connect your runcam to your computer's Ethernet port with the
    > Ethernet cable provided by Runcam\
    > - Open up a windows file browser, scroll down on the left bar and
    > left click on Network, select properties.\
    > - Select change adapter settings\
    > - double click on Internet Protocol Version 4\
    > - Enter numbers as per image below\
![IP address](https://github.com/wkumik/wiki/blob/master/images/RUNCAM%20SETUP%20GUIDE%20IMAGES/image4.png)

d)  On the configurator, enter IP address: 192.168.1.10 and press
    > connect

e)  Refer to separate wiki document
    for setting up OSD

f)  Set up all the settings. There are too many to go through them all
    here.

## 5. Android Ground station 

a)  Download [Pixel Pilot
    Apk](https://github.com/OpenIPC/PixelPilot/releases)
     file from github, straight into your phone.

b)  Go into Android file browser, find that file and install it.

c)  Open the Pixel Pilot app, and tap at the gear icon in top left
    corner

d)  Set up: Channel: 161

e)  Connect the external wifi adapter with the phone through a USB to
    USB C adapter. The adapter from runcam can be faulty so if your
     WFB service doesn\'t start, try a different adapter. It needs to
     be OTG (on the go) adapter.

f)  Connect antennas to your external WiFi adapter.

g)  Press the gear icon, then press GS.key, then navigate to the GS.key
     file you have copied over from the sd card. Select that file.

## 6. Running the video stream

a)  Turn on the App

b)  Power on your aircraft. The Runcam should start by itself and the
     fan should be spinning.

c)  After 12-14 seconds you should see on your phone the video from your
aircraft.

## Mirroring the camera:

The default camera orientation is so that the top of the video is where
the cable is.

If you prefer the cable on the bottom, do the following steps:

1)  Take the micro SD card out from your Runcam

2)  Connect the micro SD card to your computer/laptop

3)  Use Notepad to open the file 'User'.

4)  Use the following settings:
    > Mirror = True
    > Flip = True

5)  Save the file

6)  Put the micro SD back into the camera

## Adding audio

1)  Make sure you have the latest [Pixel
    pilot installed](https://github.com/OpenIPC/PixelPilot/releases)
    

2)  Install Win SCP to connect to your camera

3)  Connect your camera with ethernet cable and power it on ( use a 3s
    > battery or a 12V power source

4)  Open WinSCP and connect to your camera
![WinSCP](https://github.com/wkumik/wiki/blob/master/images/RUNCAM%20SETUP%20GUIDE%20IMAGES/image2.png)

5)  Go to: etc folder

6)  Open majestic.yaml file with notepad

7)  Scroll down and make sure 'audio' section is as below. You can just
    edit it like a text file.
    
  ![AUDIO](https://github.com/wkumik/wiki/blob/master/images/RUNCAM%20SETUP%20GUIDE%20IMAGES/image3.png)

9)  Save the file and close the winscp

10)  Test if audio in pixel pilot app works.
At the time of writing this Audio works, but it's not being
 recorded in the mp4 file.

## Troubleshooting:

**There is no video on my android device.**

Make sure the GS.key file was properly set up. (see point 3 c))

There is still no video

Check if the WiFi card gets hot when Runcam is on. If it's cold, that
means the WiFi broadcast isn't running.


### Links

- https://shop.runcam.com/runcam-wifilink-based-on-openipc/
- https://store-m8o52p.mybigcommerce.com/product_images/img_runcma_wifilink/runcma-wifilink-manual-en.pdf
- https://www.runcam.com/download/runcamwifilink
-
- https://runcam.world.taobao.com
- https://item.taobao.com/item.htm?id=823103143737&skuId=5704904774133
- https://fr.aliexpress.com/item/1005007532941097.html?gatewayAdapt=glo2fra
