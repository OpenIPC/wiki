# OpenIPC Wiki
[Table of Content](../README.md)

Smartwares CIP-37210
--------------------

### Device info

| System | Description                          |
|--------|--------------------------------------|
| SoC    | HI3518EV200                          |
| Sensor | OmniVision OV9732                    |
| Flash  | 16Mb (Winbond 25Q128JVSQ)            |
| WiFi   | RTL8188FU                            |

### Step-by-step flashing guide

Beside the camera you'll need the following tools:
- PH0 screwdriver or bit
- Small blade screwdriver, e.g. 0.6 × 3.5 mm
- A USB to TTL adapter for UART communication. (I used a CP2102 based device, but there are [many other good options](https://github.com/OpenIPC/wiki/blob/master/en/equipment-flashing.md))
- A microSD card (I used an old 2 GB one)
- Some jumper wires
- A multimeter
- A computer running GNU/Linux

The preferred method to flash an OpenIPC camera is via tftp, but the CIP-37210 does not have an ethernet port. Another problem is that the stock u-boot is password protected and fatload (reading access to a FAT filesystem) does not work.

Because of that we will need to combine two methods deviating from the standard procedure to flash the Smartwares CIP-37210: [The burn utility](https://github.com/OpenIPC/burn) to directly boot into a u-boot bootloader compiled by the OpenIPC project to be able to flash from a microSD card and of course the [flashing from a microSD card](https://paulphilippov.com/articles/flashing-ip-camera-with-full-openipc-binary-firmware-from-sd-card).

#### Opening the device

Unscrew the visbile phillips screw on the back of the camera's stand with the PH0 screwdriver.
![unscrew](/images/cip-37210_open_001.jpg "Unscrewing the phillips screw")

Use the blade screwdriver to pry open the camera's case, where the stand was attached:
![pry_open](/images/cip-37210_open_002.jpg "Pry open the camera")

#### Establishing the UART connection

After opening the device, it's time to establish the UART connection. Power on the open camera with the included micro USB power supply. Now it's time to check the suspicious 4 pin holes on top of the pcb: Measure the voltage of the pin holes with your multimeter, by connecting them to GND (I used one of the pads around the screws in the middle).

I found two pin holes with 3.3 V, one pin hole with slightly less than 3.3 V and one pin hole with 0 V. Now it's time to watch the 3.3 V pins during boot – the one with oscillating voltage is the TX pin and the stable 3.3 V pin is the Vcc.

**In summary:** The pin hole closest to the black screw is RX, the one next to it is TX, the one next to it is GND. Connect GND to GND, TX to RX and RX to TX.

![uart_cip-37210](/images/uart_cip-37210_cropped.jpg "Marked UART pin holes on the CIP-37210 PCB")

I used simple male-to-female DuPont jumper wires to connect to the pin holes. There are of course better solutions like soldering a connector onto the pin holes or using test hooks, but as long the jumper wires don't touch, it will work fine.

![uart_cip-37210_action](/images/uart_cip-37210_action.jpg "Established UART connection.")

#### Saving the stock firmware

Before flashing OpenIPC it might be clever to save the stock firmware, in case you don't like OpenIPC and want to roll back or brick something. Since tftp is not possible we will save the contents of the flash to a microSD card. Since the device runs Linux you don't need to worry about formatting the microSD card now. Boot the camera while connected to your USB to TTL adapter and start screen:

```sh
sudo screen -L /dev/ttyUSB0 115200
```

Now it's time to login as root with the password `I81ou812` I found [on the internet](https://gist.github.com/gabonator/74cdd6ab4f733ff047356198c781f27d). The microSD card got mounted automatically to the mount point `/mnt/sd/`, so lets make a new directory on the sd card and dump the contents of the flash:

```sh
mkdir /mnt/sd/image
for mtd in $(ls /dev/mtdblock*); do dd if=${mtd} of=/mnt/sd/image/${mtd##/*/}.bin; done
```
You may want to repeat this step with another folder and compare the md5 checksums of the binary files to assure that the dump was successful. Exit screen with `C-a` followed by `d`, insert the microSD card back into your computer and backup the binaries.

#### Flashing OpenIPC

Time to format the microSD card, so u-boot will be able to fatload the image. Those steps may vary depending on your Linux distribution. [There is already a script which works on Debian Sid](https://gist.github.com/themactep/d0b72f4c5d5f246e2551622e95bc9987), but sadly not on my machine. (Different fdisk version and different naming of the device and partitions). Those are the commands I ran:

```sh
# create the partition table
sudo parted /dev/mmcblk0 mklabel msdos
# create first partition
sudo parted /dev/mmcblk0 mkpart primary fat32 1MB 64MB
sudo mkfs.vfat -F32 /dev/mmcblk0p1
# create second partition
sudo parted /dev/mmcblk0 mkpart primary fat32 64MB 128MB
sudo mkfs.vfat -F32 /dev/mmcblk0p2
```

Now it's time to mount the first partition and [download the correct firmware](https://openipc.org/cameras/vendors/hisilicon/socs/hi3518ev200/download_full_image?flash_size=16&flash_type=nor&fw_release=ultimate) and copy it on the mounted partition. Umount the partition and insert the microSD card into the camera.

Next, the burn utility needs to be set up:
```sh
git clone https://github.com/OpenIPC/burn
cd burn
sudo pip install -r requirements.txt
```
Now we need to download the correct uboot-binary
```sh
wget -P ./u-boot/ https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-hi3518ev200-universal.bin
```

Make sure, that no process is blocking your USB to TTL adapter:
```sh
sudo lsof /dev/ttyUSB0
```
Kill the process if necessary:
```sh
sudo kill 230002
```
Power off the camera and also disconnect and reconnect your USB to TTL adapter. Now enter the following command and power on the camera:
```sh
./burn --chip hi3518ev200 --file=./u-boot/u-boot-hi3518ev200-universal.bin --break && screen -L /dev/ttyUSB0 115200
```
Hit any key to stop autoboot and you are greeted by the OpenIPC u-boot shell!
```sh
OpenIPC #
```
First we need to check, if our microSD card is ready to use:
```sh
fatls mmc 0
```
The following output is expected:
```text
 16777216   openipc-hi3518ev200-ultimate-16mb.bin

1 file(s), 0 dir(s)
```
Nice! Now it's time to load the binary into the memory. The variables are environment variables the OpenIPC u-boot knows to resolve, so you just need to copy and paste:
```sh
mw.b ${baseaddr} 0xff 0x1000000; fatload mmc 0:1 ${baseaddr} openipc-${soc}-ultimate-16mb.bin
```
This should result in the following output:
```text
reading openipc-hi3518ev200-ultimate-16mb.bin

16777216 bytes read
```
Now it's time to write and keep your fingers crossed:
```sh
sf probe 0; sf erase 0x0 0x1000000; sf write ${baseaddr} 0x0 ${filesize}
```
The expected output looks like this:
```text
16384 KiB hi_fmc at 0:0 is now current device
Erasing at 0x1000000 -- 100% complete.
Writing at 0x1000000 -- 100% complete.
```

It anything goes wrong here, don't power off the device and ask the mentioned [Telegram group](https://t.me/openipc) for help! Otherwise enter `reset` and get into the freshly flashed u-boot by hitting any key to stop autoboot. Run the following command and you are done:
```sh
run setnor16m
```
Now remove the SD cards and reboot, by entering `reset` again and you'll be greeted like this:
```text
Welcome to OpenIPC
openipc-hi3518ev200 login: root

    /######                                    /######  /#######    /######
   /##__  ##                                  |_  ##_/ | ##__  ##  /##__  ##
  | ##  \ ##   /######    /######   /#######    | ##   | ##  \ ## | ##  \__/
  | ##  | ##  /##__  ##  /##__  ## | ##__  ##   | ##   | #######/ | ##
  | ##  | ## | ##  \ ## | ######## | ##  \ ##   | ##   | ##____/  | ##
  | ##  | ## | ##  | ## | ##_____/ | ##  | ##   | ##   | ##       | ##    ##
  |  ######/ | #######/ |  ####### | ##  | ##  /###### | ##       |  ######/
   \______/  | ##____/   \_______/ |__/  |__/ |______/ |__/        \______/
             | ##
             | ##                              build
             |__/                             master+01a1348a, 2023-03-05

 Please help the OpenIPC Project to cover the cost of development and
 long-term maintenance of what we believe is going to become a stable,
 flexible Open IP Network Camera Framework for users worldwide.

 Your contributions could help us to advance the development and keep
 you updated on improvements and new features more regularly.

 Please visit https://openipc.org/sponsor/ to learn more. Thank you.
```

The root password is `12345`. Don't forget to change it with `passwd` after the first login!

If you are struggling with this tutorial and still want to try OpenIPC on a Smartwares CIP-37210, you can [buy it with OpenIPC v2.2 firmware pre-installed at open collective](https://opencollective.com/openipc/contribute/wifi-camera-showme-by-openipc-44355).

## Connecting to wifi
Now it's time to connect the camera to your 2.4 GHz Wi-Fi network. First of all, make sure that the firmware environment variables are set correctly.

First set the network driver:

```sh
fw_setenv wlandev rtl8188fu-generic
```

Then the correct values according to your needs, for example:
```sh
fw_setenv wlanssid guest
fw_setenv wlanpass guest-password
```

You can check the settings as folows:
```sh
fw_printenv wlandev
fw_printenv wlanssid
fw_printenv wlanpass
```

The last step is to configure the wlan0 interface:
```sh
cat <<EOF > /etc/network/interfaces.d/wlan0
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 3 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio3/direction
    pre-up echo 1 > /sys/class/gpio/gpio3/value  # GPIO3 is the WIFI power
    pre-up modprobe mac80211
    pre-up sleep 1
    pre-up modprobe 8188fu
    pre-up sleep 1
    pre-up wpa_passphrase "\$(fw_printenv -n wlanssid)" "\$(fw_printenv -n wlanpass)" > /tmp/wpa_supplicant.conf
    pre-up sed -i 's/#psk.*/scan_ssid=1/g' /tmp/wpa_supplicant.conf
    pre-up ifconfig wlan0 up
    pre-up wpa_supplicant -B -i wlan0 -D nl80211,wext -c /tmp/wpa_supplicant.conf
    pre-up sleep 3
    post-down killall -q wpa_supplicant
    post-down echo 0 > /sys/class/gpio/gpio3/value
    post-down echo 3 > /sys/class/gpio/unexport
EOF
```

Now it's time to check whether it's working:
```sh
ifup wlan0
ip addr
```
Check whether you can ping and ssh into the camera. Reboot and check, if the camera connects automatically to your wifi network. Reassamble the camera, now it's time so say goodbye to UART and use ssh and the web interface. (The credentials are root and the password you set earlier.)

Finally, you should look at `/etc/majestic.yaml` and in particular set this sections as follows in order to have a correct GPIO mapping for nighmode and audio.

```yaml
audio:
  enabled: true
  volume: 70
  srate: 8000
  codec: alaw
  outputEnabled: true
  outputVolume: 30
  speakerPin: 51
  speakerPinInvert: true
nightMode:
  enabled: true
  irSensorPin: 62
  irSensorPinInvert: true
  irCutPin1: 64
  backlightPin: 63
  dncDelay: 30
  nightAPI: true
  irCutSingleInvert: false
```