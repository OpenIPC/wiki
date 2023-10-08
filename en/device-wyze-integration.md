# OpenIPC Wiki
[Table of Content](../README.md)

Wyze integration
----------------
This is where we'll be writing down our guide to flashing new devices and reports on our experiments.

### Known camera modifications

| MODEL      | IC               | FCC ID           | PCB VER                         | SoC      | WIFI                  | NOTES                                                                            |
|------------|------------------|------------------|---------------------------------|----------|-----------------------|----------------------------------------------------------------------------------|
| WYZEC3     | 25466-WYZEC3     | 2AUIUWYZEC3      | WYZEV3_T31GC2053 V1.4_20201010  | T31ZX    | SDIO: Realtek 8189FTV | MAC: 7C:78:B2:69:95:C9 https://t.me/openipc/49957 https://youtu.be/t7Nzo-KXTH0   |
| WYZEC3     | 25466-WYZEC3A    | 2AUIUWYZEC3A     | WYZEV3_T31GC2053 V1.2_20200715  | T31X     | SDIO: Realtek 8189FTV | MAC: 7C:78:B2:99:6E:BA https://youtu.be/jm4wze_HY78                              |
| WYZEC3     | 25466-WYZEC3A    | 2AUIUWYZEC3A     | WYZEV3_T31GC2053 V2.02_20210523 | T31ZX    | SDIO: AltoBeam 6031   | https://t.me/openipc/49049 https://t.me/openipc/49050                            |
| WYZEC3     | 25466-WYZEC3A    | 2AUIUWYZEC3A     | WYZEV3_T31GC2053 V2.03_20211206 | T31X     | SDIO: AltoBeam 6031   | https://t.me/openipc/45444 https://t.me/openipc/48942                            |
| WYZEC3     | 25466-WYZEC3B    | 2AUIUWYZEC3B     | WYZEV3_T31GC2053 V2.02_20210523 | T31ZX    | SDIO: Realtek 8189FTV | MAC: D0:3F:27:46:A7:7B https://t.me/openipc/38728 https://t.me/openipc/38753     |
| WYZEC3     | 25466-WYZEC3B    | 2AUIUWYZEC3B     | WYZEV3_T31GC2053 V2.03_20211206 | T31X     | SDIO: Realtek 8189FTV | MAC: D0:3F:27:AD:72:51 https://t.me/openipc/76036                                |
| WYZEC3     | 25466-WYZEC3F    | 2AUIUWYZEC3F     | WYZEV3_T31AGC2053 V3.2_20210714 | T31A BGA | SDIO: AltoBeam 6031   | https://t.me/openipc/43299 https://t.me/openipc/38755 https://t.me/openipc/38757 |
| WYZEC3     | 25466-WYZEC3F    | 2AUIUWYZEC3F     | WYZEV3_T31AGC2053 V3.2_20210714 | T31A BGA | SDIO: AltoBeam 6031   | MAC: D0:3F:27:4F:23:19 https://youtu.be/VkqX9yg0odU                              |

## Wyze Cam Pan v3 cameras have hardware lock in secureboot and cannot be upgraded to OpenIPC!

### OpenIPC installation

[Use these scripts](https://github.com/themactep/device-wyze-v3/blob/master/installation.md) to convert your Wyze Cam V3 to OpenIPC.

### Current issues

* Exposure does not work well https://github.com/OpenIPC/majestic/issues/102
* ~~SD card does not work in the U-Boot (power is available)~~ fixed
* ~~Problem with loading u-boot from an microSD card. It doesn't reach the promt. Not only on wyze v3 (https://t.me/openipc_modding/179369), but also on another board T31L (https://t.me/openipc/47739). Most likely it will be IMPOSSIBLE, because in the camera there is a microSD power management MOSFET, which must be turned on BEFORE booting from the card (the experiment with not fully loaded u-boot was possible due to direct power supply to the microSD card, bypassing the transistor). Please confirm my version if it is not possible otherwise.~~ impossible without modification (direct 3.3V power supply to the microSD card reader)
