# OpenIPC Wiki

[Table of Content](../README.md)

## Quick Setup of Ground Station for OrangePi 5 Ubuntu 22.04

---

<p align="center">
  <img src="../images/pi5-plus.png?raw=true" alt="Logo" style="height:400px;"/> 
  <img src="../images/pi-5.png?raw=true" alt="Logo" style="height:400px;"/>
</p>

### Prepare

```
sudo apt update
sudo apt upgrade
```

### Download and install the Linux kernel headers for rockchip rk3588

[https://drive.google.com/drive/folders/1R7VmAeo3_LpFDQvYSEG9ymAC-DvaLt47](https://drive.google.com/drive/folders/1R7VmAeo3_LpFDQvYSEG9ymAC-DvaLt47)

```
sudo dpkg -i linux-headers-legacy-rockchip-rk3588_1.1.2_arm64.deb
sudo dpkg -i linux-image-legacy-rockchip-rk3588_1.1.2_arm64.deb
```

### Wifi card driver

To disable add it to the blacklist:

```
sudo bash -c "cat > /etc/modprobe.d/wfb.conf <<EOF
# blacklist stock module
blacklist 88XXau
blacklist 8812au
blacklist rtl8812au
blacklist rtl88x2bs
EOF"
```

Compile the driver from source:

```
git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git
cd rtl8812au/
sudo ./dkms-install.sh
```

### Installing WFB-NG

Using the "nmcli" command, we find out the name of your wifi adapter and substitute $WLAN in the place

```
git clone -b stable https://github.com/svpcom/wfb-ng.git
cd wfb-ng
sudo ./scripts/install_gs.sh $WLAN
```

and enable auto-upload

```
sudo systemctl enable wifibroadcast
```

### Channel configuration

```
sudo vi /etc/wifibroadcast.cfg
```

### Copying the encryption key from an IP camera

```
sudo scp root@192.168.1.10:/etc/gs.key /etc/gs.key
```

and restarting wfb-ng:

```
sudo systemctl restart wifibroadcast@gs
```

### Start WFB CLI

```
wfb-cli gs
```

### Video decoding

h265

```
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtph265depay ! h265parse ! mppvideodec ! xvimagesink sync=false
```

h264

```
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264' ! rtph264depay ! h264parse ! mppvideodec ! xvimagesink sync=false
```

###GS IS READY FOR USE###

### DVR(Digital Video Recorder) and playback
Create a file **gst_start.sh** with the following content and assign the rights to execute **chmod +x gst_start.sh**
```
#!/bin/sh
current_date=$(date +'%Y%d%m_%H%M')
cd ~/Videos
gst-launch-1.0 -e udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtph265depay ! h265parse ! tee name=t ! queue ! mppvideodec ! xvimagesink sync=false t. ! queue ! matroskamux ! filesink location=record_${current_date}.mkv
```
Each time you start, a new video file will be created in the **/home/Video/** folder.

### Start, stop, restart service

```
systemctl status wifibroadcast@gs
systemctl stop wifibroadcast@gs
systemctl start wifibroadcast@gs
```

### Get last logs from service

```
journalctl -u wifibroadcast@gs -f
journalctl -xu wifibroadcast@gs -n 100
```

### Useful commands

```
# Checking the operation of the wfb-ng
/usr/bin/wfb_rx -p 0 -c 127.0.0.1 -u 5600 -K /etc/gs.key -i 7669206 $WLAN

# Find out the name of the wifi adapter
nmcli
ifconfig
iw

# Displays the possible parameters of the wifi adapter
iw list

# Displays the current settings of the Wifi adapter
iw dev

# Outputs the current frequency and power parameters
sudo iw reg get

# Set a new region
sudo iw reg set RU
https://hackware.ru/?p=17978 - Solves the problem of channel selection

# Viewing running wfb-ng processes
ps -aux | grep wfb

# Set the power
sudo ip link set $WLAN down
sudo iw dev $WLAN set txpower fixed 30mBm
sudo ip link set $WLAN up

# View available plugins for decoding
gst-inspect-1.0 | grep 265

# Shows a list of downloaded drivers/modules
lsmod

# Displays a list of connected USB devices and related drivers
usb-devices
```
