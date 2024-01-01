# LSC Smart Connect Video Doorbell (2021 edition)

![device_lsc_doorbell1](../images/device-lsc-smart-connect-doorbell1.jpg)

![device_lsc_doorbell2](../images/device-lsc-smart-connect-doorbell2.jpg)

![device_lsc_doorbell4](../images/device-lsc-smart-connect-doorbell4.jpg)

The hardware and software setup is very identical to: [chacron ipcam](device-chacon-ipcam-ri01.md)

## Hardware

| System | Description                          |
|--------|--------------------------------------|
| SoC    | HI3518EV300                          |
| Sensor | JXF23                                |
| Flash  | 8Mb (XM25QH64A)                      |
| WiFi   | RTL8188FU                            |

### OpenIPC status

| Component     | Status                                                   |
|---------------|----------------------------------------------------------|
| WiFi          | [Working]                                                |
| Red/Blue LEDs | [Working](#leds)                                         |
| IR LED        | Working                                                  |
| IR Cut        | Working                                                  |


### Serial connection

![device_lsc_doorbell3](../images/device-lsc-smart-connect-doorbell3.jpg)

### Wifi
* RTL8188FU

### Nor flash
[XM25QH64A](https://datasheet.lcsc.com/lcsc/XMC-XM25QH64AHIG_C328461.pdf)
- 8MB NOR Flash

### GPIOs

| nr        | Description   |
|-----------|---------------|
| 0x0f (15) | irCut_1       |
| 0x0c (12) | irCut_2       |
| 0x28 (40) | IR LED        |
| 0x33 (51) | Red LED       |
| 0x32 (50) | Blue LED      |
| 0x0d (13) | wlan power    |
| 0x3B (59) | Doorbell btn  |

### [ipctool](https://github.com/OpenIPC/ipctool) output (8Mb flash):

```
---
chip:
  vendor: HiSilicon
  model: 3518EV300
  id: 022c40875e0038e9a770030ad8188d942567d818418e29e3
board:
  vendor: OpenIPC
  version: 2.3.12.28
  possible-IR-cut-GPIO: 12,15
ethernet:
  mac: ""
  u-mdio-phyaddr: 1
  phy-id: 0x00000000
  d-mdio-phyaddr: 0
rom:
- type: nor
  block: 64K
  partitions:
    - name: boot
      size: 0x40000
      sha1: e959aa47
    - name: env
      size: 0x10000
      sha1: 0d98dab2
      contains:
        - name: uboot-env
          offset: 0x0
    - name: kernel
      size: 0x200000
      sha1: 4fbf4879
    - name: rootfs
      size: 0x500000
      sha1: d90b9fb5
    - name: rootfs_data
      size: 0xb0000
      path: /overlay,jffs2,rw
  size: 8M
  addr-mode: 3-byte
ram:
  total: 64M
  media: 32M
firmware:
  kernel: "4.9.37 (Thu Dec 28 11:19:02 UTC 2023)"
  toolchain: buildroot-gcc-12.3.0
  sdk: "Hi3516EV200_MPP_V1.0.1.2 B030 Release (Oct 18 2019, 18:21:00)"
sensors:
- vendor: GalaxyCore
  model: GC2053
  control:
    bus: 0
    type: i2c
    addr: 0x6e
  data:
    type: MIPI
    input-data-type: DATA_TYPE_RAW_10BIT
    lane-id:
      - 0
      - 1
    image: 1920x1080
  clock: 27MHz
```

## Flashing OpenIPC

Flashed using a CH341A programmer

### LEDs

The camera has a dual color LED (red/blue) connected to GPIO's 50 and 51.
To control those LEDs you can use the /sys api:
```
# make the GPIOs accessible
echo 50 > /sys/class/gpio/export
# and set direction (only need to do once)
echo out > /sys/class/gpio50/direction
echo out > /sys/class/gpio51/direction

# turn on blue LED
echo 1 > /sys/class/gpio50/value
# turn off blue LED
echo 0 > /sys/class/gpio50/value

# turn on red LED
echo 1 > /sys/class/gpio51/value
# turn off red LED
echo 0 > /sys/class/gpio51/value
```

### Homeassistant support

A custom MQTT Client has been written to handle the doorbell event and send it to Home assistant using MQTT.
Project can be found here: [lscdoorbellmqtt](https://github.com/berobloom/lscdoorbellmqtt)

## Sources:

* https://github.com/OpenIPC/wiki/blob/master/en/device-chacon-ipcam-ri01.md
* https://github.com/berobloom/lscdoorbellmqtt
