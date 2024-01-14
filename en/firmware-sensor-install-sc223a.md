# OpenIPC Wiki
[Table of Content](../README.md)

Install Image Sensors
-----------------------

If your image sensor driver is not included in the firmware image, you can install it manually.
You need a sensor library and one sensor configuration file.
You can find the files for your sensor following [this list](https://github.com/OpenIPC/wiki/blob/master/en/firmware-sensors.md).

As an example the image sensor "sc223a" will be installed to a gk7205v210 board ( with openipc-gk7205v210-fpv-8mb.bin flashed).
Install the files by downloading them directly from github to your device:
```
curl -s -L -o /usr/lib/sensors/libsns_sc223a.so https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/libsns_sc223a.so
curl -s -L -o /etc/sensors/sc223a_i2c_1080p.ini https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini
```

Adjust the fps value in /etc/majestic.yaml according to your sensor specs:

```
cli -s .video0.fps 25
```

Restart streamer:

```
killall -1 majestic
```
