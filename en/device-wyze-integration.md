# OpenIPC Wiki
[Table of Content](../index.md)

Wyze integration
----------------

This is where we'll be writing down our guide to flashing new devices and reports on our experiments.

### Current issues

* Exposure does not work well https://github.com/OpenIPC/majestic/issues/102
* SD card does not work in the U-Boot (power is available)
* Problem with loading u-boot from an microSD card. It doesn't reach the promt. Not only on wyze v3 (https://t.me/openipc_modding/179369), but also on another board T31L (https://t.me/openipc/47739). Most likely it will be IMPOSSIBLE, because in the camera there is a microSD power management MOSFET, which must be turned on BEFORE booting from the card (the experiment with not fully loaded u-boot was possible due to direct power supply to the microSD card, bypassing the transistor). Please confirm my version if it is not possible otherwise.

### Known camera modifications
* WYZE Cam v3

| MODEL | IC | FCC ID | PCB VER | SoC | WIFI | NOTES |
| --- | --- | --- | --- | --- | --- | --- |
| WYZEC3 | 25466-WYZEC3A | 2AUIUWYZEC3A | WYZEV3_T31GC2053 V1.2_20200715 | T31X | SDIO: Realtek 8189FTV | MAC: 7C:78:B2:99:6E:BA https://youtu.be/jm4wze_HY78 |
| WYZEC3 | 25466-WYZEC3B | 2AUIUWYZEC3B | WYZEV3_T31GC2053 V2.02_20210523 | T31ZX | SDIO: Realtek 8189FTV | https://t.me/openipc/38728 https://t.me/openipc/38753 |
| WYZEC3 | 25466-WYZEC3A | 2AUIUWYZEC3A | WYZEV3_T31GC2053 V2.03_20211206 | T31X | SDIO: AltoBeam 6031 | https://t.me/openipc/45444 https://t.me/openipc/48942|
| WYZEC3 | 25466-WYZEC3F | 2AUIUWYZEC3F | WYZEV3_T31AGC2053 V3.2_20210714 | T31A BGA | SDIO: AltoBeam 6031 | https://t.me/openipc/43299 https://t.me/openipc/38755 https://t.me/openipc/38757 |
| WYZEC3 | 25466-WYZEC3F | 2AUIUWYZEC3F | WYZEV3_T31AGC2053 V3.2_20210714 | T31A BGA | SDIO: AltoBeam 6031 | MAC:D0:3F:27:4F:23:19 https://youtu.be/VkqX9yg0odU |
