# OpenIPC Wiki
[Table of Content](../README.md)

For LifeSmart cameras: LS179

## BOM

SoC: HI3518EV200  
Flash: ENQH127A (16MB NOR)  
Sensor: soif23 (???)

## Installation

Follow the [instructions](help-uboot.md#bypassing-password-protected-bootloader) to get access to U-boot.

Back up the flash and install OpenIPC according to the [instructions](https://openipc.org/cameras/vendors/hisilicon/socs/hi3518ev200).

## WiFi

In order to connect to WiFi, you need to configure the [wireless device](wireless-settings.md#initial-configuration) with:

```
rtl8188fu-hi3518ev200-lifesmart
```

This will power up the USB device (WiFi card) and load the appropriate Kernel driver.

## LEDs

The LEDs are controlled by the GPO #2.

```bash
# turn on
gpio set 2

# turn off
gpio clear 2
```

