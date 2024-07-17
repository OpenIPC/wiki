# OpenIPC Wiki
[Table of Content](../README.md)

Install Image Sensors
-----------------------

If an image sensor driver is not included in the firmware image, you can install it manually.

As an example the image sensor "sc223a" will be installed to a gk7205v210 board (with openipc-gk7205v210-fpv-8mb.bin flashed).

You need a [sensor library](https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/libsns_sc223a.so) and one [sensor configuration file](https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini).

The needed files for other sensors can be found following [this list](firmware-sensors.md).

Install the files by downloading them directly from github to your device:
```sh
curl -s -L -o /usr/lib/sensors/libsns_sc223a.so https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/libsns_sc223a.so
curl -s -L -o /etc/sensors/sc223a_i2c_1080p.ini https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini
```

Adjust the fps value in /etc/majestic.yaml according to your sensor specs. 
Search for "Isp_FrameRate" in your sensor configuration file [/etc/sensors/sc223a_i2c_1080p.ini](https://github.com/OpenIPC/firmware/raw/master/general/package/goke-osdrv-gk7205v200/files/sensor/config/sc223a_i2c_1080p.ini).

```sh
cli -s .video0.fps 30
```

(Re)start streamer:

```sh
killall majestic
majestic
```

[more info about sensor `sc223a`](https://github.com/RoboSchmied/Documentation/blob/main/sc223a.md)
